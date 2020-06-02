require 'parlour'

module RDL::Reporting::Sorbet

  def to_sorbet_type(typ)
    RDL::Logging.debug :reporting, typ

    case typ
    when RDL::Type::StructuralType
      RDL::Globals.types[:dyn]

    when RDL::Type::VarType
      return 'self' if typ.to_s == 'self'
      RDL::Globals.types[:dyn]

    when RDL::Type::BotType
      RDL::Globals.types[:dyn]

    when RDL::Type::UnionType
      type = typ.canonical
      if type.is_a? RDL::Type::UnionType
        types = type.types.map { |x| to_sorbet_type(x) }
        RDL::Type::UnionType.new(*types)
      else
        type
      end

    when RDL::Type::IntersectionType
      type = typ.canonical
      if type.is_a? RDL::Type::IntersectionType
        types = type.types.map { |x| to_sorbet_type(x) }
        RDL::Type::IntersectionType.new(*types)
      else
        type
      end

    when RDL::Type::SingletonType
      typ.nominal

    when RDL::Type::FiniteHashType
      c = typ.canonical
      types = c.elts.values.map { |v| to_sorbet_type(v) }

      return RDL::Globals.types[:dyn] if types.member? RDL::Globals.types[:dyn]

      base_type = RDL::Globals.types[:hash]
      key_type = RDL::Globals.types[:symbol]
      val_type = RDL::Type::UnionType.new types

      RDL::Types::GenericType.new base_type, key_type, val_type

    else
      typ

    end
  end

  def to_sorbet_string(typ, header, in_hash: false)
    RDL::Logging.debug :reporting, "Processing #{header}..."

    unless typ
      RDL::Logging.error :reporting, "Given nil instead of RDL Type!"
      # return 'T.untyped'
      raise "Given nil instead of RDL Type!"
    end

    typ = to_sorbet_type(typ)

    case typ
    when 'self'
      return 'T.self_type'

    when RDL::Type::DynamicType
      'T.untyped'

    when RDL::Type::NominalType
      case typ.name
      when "Set"
        'T::Set[T.untyped]'
      else
        typ.name
      end

    when RDL::Type::UnionType
      type = typ.canonical
      if type.is_a? RDL::Type::UnionType
        types = type.types.map { |x| to_sorbet_string(x, header, in_hash: in_hash) }
        "T.any(#{types.join(', ')})"
      else
        to_sorbet_string(type, header, in_hash: in_hash)
      end

    when RDL::Type::IntersectionType
      type = typ.canonical
      if type.is_a? RDL::Type::IntersectionType
        types = type.types.map { |x| to_sorbet_string(x, header, in_hash: in_hash) }
        "T.all(#{types.join(', ')})"
      else
        to_sorbet_string(type, header, in_hash: in_hash)
      end

    when RDL::Type::OptionalType
      return "T.nilable(#{to_sorbet_string(typ.type, header, in_hash: in_hash)})" if in_hash
      to_sorbet_string(typ.type, header, in_hash: in_hash)

    when RDL::Type::VarargType
      to_sorbet_string(typ.type, header, in_hash: in_hash)

    when RDL::Type::GenericType
      case typ.base.name
      when "Hash"
        k, v = typ.params
        "T::Hash[#{to_sorbet_string(k, header, in_hash: in_hash)}, #{to_sorbet_string(v, header, in_hash: in_hash)}]"

      when "Array"
        t, = typ.params
        "T::Array[#{to_sorbet_string(t, header, in_hash: in_hash)}]"

      when "Set"
        t, = typ.params
        "T::Set[#{to_sorbet_string(t, header, in_hash: in_hash)}]"

      else
        c = typ.canonical
        b = to_sorbet_string(c.base, header, in_hash: in_hash)
        types = c.params.map { |x| to_sorbet_string(x, header, in_hash: in_hash) }
        "#{b}[#{types.join(', ')}]"

      end

    when RDL::Type::TupleType
      "T::Array[#{to_sorbet_string RDL::Type::UnionType.new(*typ.params), header, in_hash: in_hash}]"

    else
      RDL::Logging.warning :reporting, "Unmatched class #{typ.class}"
      'T.unknown'

    end
  end

  def gen_sorbet(generator)
    @methods.each do |method|
      m = method.type

      header = RDL::Util.pp_klass_method(full_name, method.method_name)

      parameters = m.args.map do |typ|
        RDL::Type::VarType.no_print_XXX!

        case typ
        when RDL::Type::VarType
          raise "no solution!" unless typ.solution
          RDL::Logging.trace :reporting, "#{header}: #{typ.name}"
          Parlour::RbiGenerator::Parameter.new(typ.name.to_s, type: to_sorbet_string(typ.solution, header))

        when RDL::Type::FiniteHashType
          typ.solution.elts.map do |kv|
            RDL::Logging.trace :reporting, "#{header}: HASH #{kv[0]} : #{kv[1]}"
            default = 'nil' if kv[1].optional?
            Parlour::RbiGenerator::Parameter.new("#{kv[0]}:", type: to_sorbet_string(kv[1], header, in_hash: true), default: default)
          end

        when RDL::Type::VarargType
          Parlour::RbiGenerator::Parameter.new("*#{typ.type.name}", type: to_sorbet_string(typ.solution, header))

        when RDL::Type::OptionalType
          Parlour::RbiGenerator::Parameter.new("#{typ.type.name}",
                                               type: to_sorbet_string(typ.solution, header),
                                               default: 'nil')
                                               # default: 'T.unsafe(nil)')

        else
          # Parlour::RbiGenerator::Parameter.new(typ.name.to_s, type: to_sorbet_string(typ.solution))
          RDL::Logging.log :reporting, :error, "Attempting to map #{typ} (a #{typ.class})"
        end
      end

      block_arg = Proc.new { to_sorbet_string(m.block.solution, header) } if m.block.solution

      unless m.ret.solution.is_a?(RDL::Type::SingletonType) &&
             m.ret.solution.nominal.name == "NilClass"
        ret_type = to_sorbet_string(m.ret.solution, header)
      end

      raise "nil ret_type: #{m.ret.solution.class}" if ret_type == 'NilClass'

      meth = generator.create_method(method.method_name.to_s,
                                     parameters: parameters.flatten,
                                     return_type: ret_type,
                                     &block_arg)

      RDL::Type::VarType.print_XXX!
      meth.add_comment "RDL Type: #{m.solution}"
    end

    @children.each_key do |key|
      child = @children[key]
      klass = RDL::Util.to_class(child.full_name)
      is_mod = !klass.is_a?(Class)

      klass_name = child.full_name.split('::').last

      if is_mod
        generator.create_module(klass_name) do |mod|
          child.gen_sorbet(mod)
        end
      else
        generator.create_class(klass_name) do |klass|
          child.gen_sorbet(klass)
        end
      end
    end

  end

  def to_sorbet(path)
    generator = Parlour::RbiGenerator.new
    gen_sorbet(generator.root)

    IO.write(path, generator.rbi)
  end
end
