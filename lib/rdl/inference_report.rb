require 'csv'
require 'parlour'

class RDL::InferenceReport

  class Method
    attr_accessor :klass, :method_name, :type,
                  :source_code, :comments
  end

  attr_reader :full_name

  def initialize(full_name = nil)
    RDL::Logging.log :inference, :info, "MK #{full_name}"
    @full_name = full_name
    @children = {}
    @methods = []
  end

  def [](className)
    # TODO: We need to know whether or not each level is a module or class...
    part, parts = className.split '::', 2
    part = part.to_sym

    unless @children.key? part
      child_full_name = @full_name ? "#{@full_name}::" : ''
      child_full_name += part.to_s
      @children[part] = self.class.new(child_full_name)
    end

    return @children[part][parts] if parts

    @children[part]
  end

  def <<(input)
    meth = Method.new

    meth.klass       = input[:klass]
    meth.method_name = input[:method_name]
    meth.type        = input[:type]
    meth.source_code = input[:source_code]
    meth.comments    = input[:comments]

    @methods << meth
  end

  def to_csv(path, open_file = nil)
    csv = open_file || CSV.open(path, 'wb')

    unless open_file
      csv << ['Class', 'Method', 'Inferred Type', 'Original Type',
              'Source Code', 'Comments']
    end

    @methods.each do |method|
      class_str = @full_name || 'ERROR: UNKNOWN'

      RDL::Logging.log :inference, :info, "Rendering #{class_str} / #{method.method}"

      if method.type.solution.is_a? RDL::Type::MethodType
        meth = method.type.solution

        RDL::Type::VarType.print_XXX!
        inf_type = "(#{meth.args.join(', ')})#{meth.block} -> #{meth.ret}"
      else
        RDL::Logging.log :inference, :warning, "Got a non-method type in type solutions"

        RDL::Type::VarType.print_XXX!
        inf_type = method.type.solution.to_s # This would be weird
      end

      csv << [class_str, method.method_name, inf_type,
              method.type.to_s, method.source_code]
    end

    @children.each_key do |key|
      @children[key].to_csv(path, csv)
    end

    csv.close unless open_file
  end

  def to_sorbet_type(typ)
    case typ
    when RDL::Type::StructuralType
      'T.untyped'

    when RDL::Type::VarType
      'T.untyped'

    when RDL::Type::BotType
      'T.untyped'

    when RDL::Type::NominalType
      typ.to_s

    when RDL::Type::UnionType
      types = typ.canonical.types
      types = types.map { |x| to_sorbet_type(x) }
      "T.any(#{types.join(', ')})"

    when RDL::Type::IntersectionType
      types = typ.canonical.types
      types = types.map { |x| to_sorbet_type(x) }
      "T.all(#{types.join(', ')})"

    when RDL::Type::SingletonType
      typ.nominal.to_s

    when RDL::Type::FiniteHashType
      c = typ.canonical
      if c.elts.size > 1
        types = c.elts.values.map { |v| to_sorbet_type(v) }
        types = "T.any(#{types.join(', ')})"
      else
        types = to_sorbet_type(c.elts.values[0])
      end

      "T::Hash[Symbol, #{types}]"

    when RDL::Type::OptionalType
      "T.nilable(#{to_sorbet_type(typ.type)})"

    when RDL::Type::GenericType
      case typ.base.name
      when "Hash"
        k, v = typ.params
        "T::Hash[#{to_sorbet_type(k)}, #{to_sorbet_type(v)}]"

      when "Array"
        t, = typ.params
        "T::Array[#{to_sorbet_type(t)}]"

      else
        c = typ.canonical
        b = to_sorbet_type(c.base)
        types = c.params.map { |x| to_sorbet_type(x) }
        "#{b}[#{types.join(', ')}]"

      end

    else
      typ.to_s

    end
  end

  def gen_sorbet(generator)
    @methods.each do |method|
      m = method.type

      parameters = m.args.map do |typ|
        case typ
        when RDL::Type::FiniteHashType
          typ.elts.map do |kv|
            Parlour::RbiGenerator::Parameter.new("#{kv[0]}:", type: to_sorbet_type(kv[1]))
          end

        when RDL::Type::VarargType
          Parlour::RbiGenerator::Parameter.new("*#{typ.type.name}", type: to_sorbet_type(typ.type.solution))

        when RDL::Type::OptionalType
          Parlour::RbiGenerator::Parameter.new("#{typ.type.name}?", type: to_sorbet_type(typ.type.solution))

        else
          Parlour::RbiGenerator::Parameter.new(typ.name.to_s, type: to_sorbet_type(typ.solution))
        end
      end

      generator.create_method(method.method_name.to_s,
                              parameters: parameters.flatten,
                              return_type: to_sorbet_type(m.ret)) { to_sorbet_type(m.block.solution)}
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

    puts "OUTPUT >>>>>>>>>"
    puts generator.rbi
    puts "<<<<<<<<<"
  end
end
