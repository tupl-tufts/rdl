class RDL::Wrap
  def self.wrapped?(klass, meth)
    RDL::Util.method_defined?(klass, wrapped_name(klass, meth))
  end

  def self.resolve_alias(klass, meth)
    klass = klass.to_s
    meth = meth.to_sym
    while RDL::Globals.aliases[klass] && RDL::Globals.aliases[klass][meth]
      if RDL::Globals.info.has_any?(klass, meth, [:pre, :post, :type])
        raise RuntimeError, "Alias #{RDL::Util.pp_klass_method(klass, meth)} has contracts. Contracts are only allowed on methods, not aliases."
      end
      meth = RDL::Globals.aliases[klass][meth]
    end
    return meth
  end

  def self.get_type_params(klass)
    klass = klass.to_s
    RDL::Globals.type_params[klass]
  end

  # [+klass+] may be a Class, String, or Symbol
  # [+meth+] may be a String or Symbol
  #
  # Wraps klass#method to check contracts and types. Does not rewrap
  # if already wrapped. Also records source location of method.
  def self.wrap(klass_str, meth)
    RDL::Globals.wrap_switch.off {
      klass_str = klass_str.to_s
      klass = RDL::Util.to_class klass_str
      return if wrapped? klass, meth
      return if RDL::Config.instance.nowrap.member? klass_str.to_sym
      raise ArgumentError, "Attempt to wrap #{RDL::Util.pp_klass_method(klass, meth)}" if klass.to_s =~ /^RDL::/
      meth_old = wrapped_name(klass, meth) # meth_old is a symbol
      # return if (klass.method_defined? meth_old) # now checked above by wrapped? call
      is_singleton_method = RDL::Util.has_singleton_marker(klass_str)
      full_method_name = RDL::Util.pp_klass_method(klass_str, meth)
      klass_str_without_singleton = if is_singleton_method then RDL::Util.remove_singleton_marker(klass_str) else klass_str end

      klass.class_eval <<-RUBY, __FILE__, __LINE__
        alias_method meth_old, meth
        def #{meth}(*args, &blk)
          klass = "#{klass_str}"
          meth = types = matches = nil
	        bind = binding
          inst = nil

          RDL::Globals.wrap_switch.off {
            RDL::Globals.wrapped_calls["#{full_method_name}"] += 1 if RDL::Config.instance.gather_stats
            inst = nil
            inst = @__rdl_type.to_inst if ((defined? @__rdl_type) && @__rdl_type.is_a?(RDL::Type::GenericType))
            inst = Hash[RDL::Globals.type_params[klass][0].zip []] if (not(inst) && RDL::Globals.type_params[klass])
            inst = {} if not inst
            #{if not(is_singleton_method) then "inst[:self] = RDL::Type::NominalType.new(self.class)" end}
#            puts "Intercepted #{full_method_name}(\#{args.join(", ")}) { \#{blk} }, inst = \#{inst.inspect}"
            meth = RDL::Wrap.resolve_alias(klass, #{meth.inspect})
            RDL::Typecheck.typecheck(klass, meth) if RDL::Globals.info.get(klass, meth, :typecheck) == :call
            pres = RDL::Globals.info.get(klass, meth, :pre)
            RDL::Contract::AndContract.check_array(pres, self, *args, &blk) if pres
            types = RDL::Globals.info.get(klass, meth, :type)
            if types
              matches, args, blk, bind = RDL::Type::MethodType.check_arg_types("#{full_method_name}", self, bind, types, inst, *args, &blk)
            end
          }
	        ret = send(#{meth_old.inspect}, *args, &blk)
          RDL::Globals.wrap_switch.off {
            posts = RDL::Globals.info.get(klass, meth, :post)
            RDL::Contract::AndContract.check_array(posts, self, ret, *args, &blk) if posts
            if matches
              if meth.to_sym == :initialize
                types.each { |t|
                  raise ArgumentError, "Initialize method must be annotated with return type `self` or a generic type where base is `self`. #{full_method_name} has incorrect type." unless ((t.ret.is_a?(RDL::Type::VarType) && t.ret.name == :self) || (t.ret.is_a?(RDL::Type::GenericType) && t.ret.base.is_a?(RDL::Type::VarType) && t.ret.base.name == :self))
                }
              else
                ret = RDL::Type::MethodType.check_ret_types(self, "#{full_method_name}", types, inst, matches, ret, bind, *args, &blk) unless (meth.to_sym == :initialize)
              end
            end
            if RDL::Config.instance.guess_types.include?("#{klass_str_without_singleton}".to_sym)
              RDL::Globals.info.add(klass, meth, :otype, { args: (args.map { |arg| arg.class }), ret: ret.class, block: block_given? })
            end
            return ret
          }
        end
        if (public_method_defined? meth_old) then public meth
        elsif (protected_method_defined? meth_old) then protected meth
        elsif (private_method_defined? meth_old) then private meth
        end
RUBY
    }
  end

  # [+default_class+] should be a class
  # [+name+] is the name to give the block as a contract
  def self.process_pre_post_args(default_class, name, *args, &blk)
    klass = slf = meth = contract = nil
    default_class = "Object" if (default_class.is_a? Object) && (default_class.to_s == "main") # special case for main
    if args.size == 3
      klass = class_to_string args[0]
      slf, meth = meth_to_sym args[1]
      contract = args[2]
    elsif args.size == 2 && blk
      klass = class_to_string args[0]
      slf, meth = meth_to_sym args[1]
      contract = RDL::Contract::FlatContract.new(name, &blk)
    elsif args.size == 2
      klass = default_class.to_s
      slf, meth = meth_to_sym args[0]
      contract = args[1]
    elsif args.size == 1 && blk
      klass = default_class.to_s
      slf, meth = meth_to_sym args[0]
      contract = RDL::Contract::FlatContract.new(name, &blk)
    elsif args.size == 1
      klass = default_class.to_s
      contract = args[0]
    elsif blk
      klass = default_class.to_s
      contract = RDL::Contract::FlatContract.new(name, &blk)
    else
      raise ArgumentError, "Invalid arguments to `pre` or `post`"
    end
    raise ArgumentError, "#{contract.class} received where Contract expected" unless contract.class < RDL::Contract::Contract
#    meth = :initialize if meth && meth.to_sym == :new  # actually wrap constructor
    klass = RDL::Util.add_singleton_marker(klass) if slf # && (meth != :initialize)
    return [klass, meth, contract]
  end

  # [+default_class+] should be a class
  def self.process_type_args(default_class, *args)
    klass = meth = type = nil
    default_class = "Object" if (default_class.is_a? Object) && (default_class.to_s == "main") # special case for main
    if args.size == 3
      klass = class_to_string args[0]
      slf, meth = meth_to_sym args[1]
      type = type_to_type args[2]
    elsif args.size == 2
      klass = default_class.to_s
      slf, meth = meth_to_sym args[0]
      type = type_to_type args[1]
    elsif args.size == 1
      klass = default_class.to_s
      type = type_to_type args[0]
    else
      raise ArgumentError, "Invalid arguments to `type`"
    end
    raise ArgumentError, "Excepting method type, got #{type.class} instead" if type.class != RDL::Type::MethodType
#    meth = :initialize if meth && slf && meth.to_sym == :new  # actually wrap constructor
    klass = RDL::Util.add_singleton_marker(klass) if slf
    return [klass, meth, type]
  end

  private

  def self.wrapped_name(klass, meth)
    klass_str = RDL::Util.to_class_str(klass).hash
    "__rdl_#{meth.to_s}_old_#{klass_str}".to_sym
  end

  def self.unwrapped_name(klass, meth_str)
    if not meth_str.start_with?('__rdl_') and meth_str.include?('_old_')
      raise Exception, "cannot get unwrapped name for #{meth_str}"
    end
    klass_str = RDL::Util.to_class_str(klass).hash.to_s
    meth_str = meth_str.split("_#{klass_str}")[0]
    meth_str[6..-5]
  end

  def self.class_to_string(klass)
    case klass
    when Class, Module
      return klass.to_s
    when String
      return klass
    when Symbol
      return klass.to_s
    else
      raise ArgumentError, "#{klass.class} received where klass (Class, Symbol, or String) expected"
    end
  end

  def self.meth_to_sym(meth)
    raise ArgumentError, "#{meth.class} received where method (Symbol or String) expected" unless meth.class == String || meth.class == Symbol
    meth = meth.to_s
    meth =~ /^(.*\.)?(.*)$/
    raise RuntimeError, "Only self.method allowed" if $1 && $1 != "self."
    return [$1, $2.to_sym]
  end

  def self.type_to_type(type)
    case type
    when RDL::Type::Type
      return type
    when String
      return RDL::Globals.parser.scan_str type
    end
  end

  # called by Object#method_added (sing=false) and Object#singleton_method_added (sing=true)
  def self.do_method_added(the_self, sing, klass, meth)
    # Apply any deferred contracts and reset list

    if RDL::Globals.deferred.size > 0
      if sing
        loc = the_self.singleton_method(meth).source_location
      else
        loc = the_self.instance_method(meth).source_location
      end
      RDL::Globals.info.set(klass, meth, :source_location, loc)
      a = RDL::Globals.deferred
      RDL::Globals.deferred = [] # Reset before doing more work to avoid infinite recursion
      a.each { |prev_klass, kind, contract, h|
        if RDL::Util.has_singleton_marker(klass)
          tmp_klass = RDL::Util.remove_singleton_marker(klass)
        else
          tmp_klass = klass
        end
        if (!h[:class_check] && (prev_klass != tmp_klass)) || (h[:class_check] && (h[:class_check].to_s != tmp_klass))
          raise RuntimeError, "Deferred #{kind} contract from class #{prev_klass} being applied in class #{tmp_klass} to #{meth}"
        end
        RDL::Globals.info.add(klass, meth, kind, contract)
        RDL::Wrap.wrap(klass, meth) if h[:wrap]
        unless !h.has_key?(:typecheck) || RDL::Globals.info.set(klass, meth, :typecheck, h[:typecheck])
          raise RuntimeError, "Inconsistent typecheck flag on #{RDL::Util.pp_klass_method(klass, meth)}"
        end
        RDL::Typecheck.typecheck(klass, meth) if h[:typecheck] == :now
        if (h[:typecheck] && h[:typecheck] != :call)
          RDL::Globals.to_typecheck[h[:typecheck]] = Set.new unless RDL::Globals.to_typecheck[h[:typecheck]]
          RDL::Globals.to_typecheck[h[:typecheck]].add([klass, meth])
        end
      }
    end

    # Wrap method if there was a prior contract for it.
    if RDL::Globals.to_wrap.member? [klass, meth]
      RDL::Globals.to_wrap.delete [klass, meth]
      if sing
        loc = the_self.singleton_method(meth).source_location
      else
        loc = the_self.instance_method(meth).source_location
      end
      RDL::Globals.info.set(klass, meth, :source_location, loc)
      RDL::Wrap.wrap(klass, meth)
    end

    # Type check method if requested
    if RDL::Globals.to_typecheck[:now].member? [klass, meth]
      RDL::Globals.to_typecheck[:now].delete [klass, meth]
      RDL::Typecheck.typecheck(klass, meth)
    end

    if RDL::Config.instance.guess_types.include?(the_self.to_s.to_sym) && !RDL::Globals.info.has?(klass, meth, :type)
      # Added a method with no type annotation from a class we want to guess types for
      RDL::Wrap.wrap(klass, meth)
    end
  end
end

module RDL::Annotate
  # [+klass+] may be Class, Symbol, or String
  # [+method+] may be Symbol or String
  # [+contract+] must be a Contract
  # [+wrap+] indicates whether the contract should be enforced (true) or just recorded (false)
  # [+ version +] is a rubygems version requirement string (or array of such requirement strings)
  #    if the current Ruby version does not satisfy the version, the type call will be ignored
  #
  # Add a precondition to a method. Possible invocations:
  # pre(klass, meth, contract)
  # pre(klass, meth) { block } = pre(klass, meth, FlatContract.new { block })
  # pre(meth, contract) = pre(self, meth, contract)
  # pre(meth) { block } = pre(self, meth, FlatContract.new { block })
  # pre(contract) = pre(self, next method, contract)
  # pre { block } = pre(self, next method, FlatContract.new { block })
  def pre(*args, wrap: RDL::Config.instance.pre_defaults[:wrap], version: nil, &blk)
    return if version && !(Gem::Requirement.new(version).satisfied_by? Gem.ruby_version)
    klass, meth, contract = RDL::Wrap.process_pre_post_args(self, "Precondition", *args, &blk)
    if meth
      RDL::Globals.info.add(klass, meth, :pre, contract)
      if wrap
        if RDL::Util.method_defined?(klass, meth) || meth == :initialize # there is always an initialize
          RDL::Wrap.wrap(klass, meth)
        else
          RDL::Globals.to_wrap << [klass, meth]
        end
      end
    else
      RDL::Globals.deferred << [klass, :pre, contract, {wrap: wrap}]
    end
    nil
  end

  # Add a postcondition to a method. Same possible invocations as pre.
  def post(*args, wrap: RDL::Config.instance.post_defaults[:wrap], version: nil, &blk)
    return if version && !(Gem::Requirement.new(version).satisfied_by? Gem.ruby_version)
    klass, meth, contract = RDL::Wrap.process_pre_post_args(self, "Postcondition", *args, &blk)
    if meth
      RDL::Globals.info.add(klass, meth, :post, contract)
      if wrap
        if RDL::Util.method_defined?(klass, meth) || meth == :initialize
          RDL::Wrap.wrap(klass, meth)
        else
          RDL::Globals.to_wrap << [klass, meth]
        end
      end
    else
      RDL::Globals.deferred << [klass, :post, contract, {wrap: wrap}]
    end
    nil
  end

  # [+ klass +] may be Class, Symbol, or String
  # [+ method +] may be Symbol or String
  # [+ type +] may be Type or String
  # [+ wrap +] indicates whether the type should be enforced (true) or just recorded (false)
  # [+ typecheck +] indicates a method that should be statically type checked, as follows
  #    if :call, indicates method should be typechecked when called
  #    if :now, indicates method should be typechecked immediately
  #    if other-symbol, indicates method should be typechecked when rdl_do_typecheck(other-symbol) is called
  # [+ version +] is a rubygems version requirement string (or array of such requirement strings)
  #    if the current Ruby version does not satisfy the version, the type call will be ignored
  #
  # Set a method's type. Possible invocations:
  # type(klass, meth, type)
  # type(meth, type)
  # type(type)
  def type(*args, wrap: RDL::Config.instance.type_defaults[:wrap], typecheck: RDL::Config.instance.type_defaults[:typecheck], version: nil)
    return if version && !(Gem::Requirement.new(version).satisfied_by? Gem.ruby_version)
    klass, meth, type = begin
                          RDL::Wrap.process_type_args(self, *args)
                        rescue Racc::ParseError => err
                          # Remove enough backtrace to only include actual source line
                          # Warning: Adjust the -5 below if the code (or this comment) changes
                          bt = err.backtrace
                          bt.shift until bt[0] =~ /^#{__FILE__}:#{__LINE__-5}/
                          bt.shift # remove RDL::Globals.contract_switch.off call
                          bt.shift # remove type call itself
                          err.set_backtrace bt
                          raise err
                        end
    typs = type.args + [type.ret, type.block]
    RDL::Globals.dep_types << [klass, meth, type] if typs.any? { |t| t.is_a?(RDL::Type::ComputedType) }
    if meth
# It turns out Ruby core/stdlib don't always follow this convention...
#        if (meth.to_s[-1] == "?") && (type.ret != RDL::Globals.types[:bool])
#          warn "#{RDL::Util.pp_klass_method(klass, meth)}: methods that end in ? should have return type %bool"
#        end
      RDL::Globals.info.add(klass, meth, :type, type)
      unless RDL::Globals.info.set(klass, meth, :typecheck, typecheck)
        raise RuntimeError, "Inconsistent typecheck flag on #{RDL::Util.pp_klass_method(klass, meth)}"
      end
      if wrap || typecheck
        if RDL::Util.method_defined?(klass, meth) || meth == :initialize
          RDL::Globals.info.set(klass, meth, :source_location, RDL::Util.to_class(klass).instance_method(meth).source_location)
          if typecheck == :now
            RDL::Typecheck.typecheck(klass, meth)
          elsif typecheck && (typecheck != :call)
            RDL::Globals.to_typecheck[typecheck] = Set.new unless RDL::Globals.to_typecheck[typecheck]
            RDL::Globals.to_typecheck[typecheck].add([klass, meth])
          end
          RDL::Wrap.wrap(klass, meth) if wrap
        else
          RDL::Globals.to_wrap << [klass, meth] if wrap
          if (typecheck && typecheck != :call)
            RDL::Globals.to_typecheck[typecheck] = Set.new unless RDL::Globals.to_typecheck[typecheck]
            RDL::Globals.to_typecheck[typecheck].add([klass, meth])
          end
        end
      end
    else
      RDL::Globals.deferred << [klass, :type, type, {wrap: wrap,
                                               typecheck: typecheck}]
    end
    nil
  end

  # [+ klass +] is the class containing the variable; self if omitted; ignored for local and global variables
  # [+ var +] is a symbol or string containing the name of the variable
  # [+ typ +] is a string containing the type
  def var_type(klass=self, var, typ)
    raise RuntimeError, "Variable cannot begin with capital" if var.to_s =~ /^[A-Z]/
    return if var.to_s =~ /^[a-z]/ # local variables handled specially, inside type checker
    ## TODO: Figure out below
    ##raise RuntimeError, "Global variables can't be typed in a class" unless klass = self
    klass = RDL::Util::GLOBAL_NAME if var.to_s =~ /^\$/
    unless RDL::Globals.info.set(klass, var, :type, RDL::Globals.parser.scan_str("#T #{typ}"))
      raise RuntimeError, "Type already declared for #{var}"
    end
    nil
  end

  # In the following three methods
  # [+ args +] is a sequence of symbol, typ. attr_reader is called for each symbol,
  # and var_type is called to assign the immediately following type to the
  # attribute named after that symbol.
  # Note these three methods are duplicated in RDLAnnotate
  def attr_accessor_type(*args)
    args.each_slice(2) { |name, typ|
      attr_accessor name
      var_type ("@" + name.to_s), typ
      type name, "() -> #{typ}"
      type name.to_s + "=", "(#{typ}) -> #{typ}"
    }
    nil
  end

  def attr_reader_type(*args)
    args.each_slice(2) { |name, typ|
      attr_reader name
      var_type ("@" + name.to_s), typ
      type name, "() -> #{typ}"
    }
    nil
  end

  alias_method :attr_type, :attr_reader_type

  def attr_writer_type(*args)
    args.each_slice(2) { |name, typ|
      attr_writer name
      var_type ("@" + name.to_s), typ
      type name.to_s + "=", "(#{typ}) -> #{typ}"
    }
    nil
  end

  # Aliases contracts for meth_old and meth_new. Currently, this must
  # be called for any aliases or they will not be wrapped with
  # contracts. Only creates aliases in the current class.
  def rdl_alias(klass=self, new_name, old_name)
    klass = klass.to_s
    klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
    RDL::Globals.aliases[klass] = {} unless RDL::Globals.aliases[klass]
    if RDL::Globals.aliases[klass][new_name]
      raise RuntimeError,
            "Tried to alias #{new_name}, already aliased to #{RDL::Globals.aliases[klass][new_name]}"
    end
    RDL::Globals.aliases[klass][new_name] = old_name

    if Module.const_defined?(klass) && RDL::Util.to_class(klass).method_defined?(new_name)
      RDL::Wrap.wrap(klass, new_name)
    else
      RDL::Globals.to_wrap << [klass, old_name]
    end
    nil
  end

  # [+ klass +] is the class whose type parameters to set; self if omitted
  # [+params+] is an array of symbols or strings that are the
  # parameters of this (generic) type
  # [+variance+] is an array of the corresponding variances, :+ for
  # covariant, :- for contravariant, and :~ for invariant. If omitted,
  # all parameters are assumed to be invariant
  # [+all+] should be a symbol naming an all? method that behaves like Array#all?, and that accepts
  # a block that takes arguments in the same order as the type parameters
  # [+blk+] is for advanced use only. If present, [+all+] must be
  # nil. Whenever an instance of this class is instantiated!, the
  # block will be passed an array typs corresponding to the type
  # parameters of the class, and the block should return true if and
  # only if self is a member of self.class<typs>.
  def type_params(klass=self, params, all, variance: nil, &blk)
    raise RuntimeError, "Empty type parameters not allowed" if params.empty?
    klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
    klass = klass.to_s
    if RDL::Globals.type_params[klass]
      raise RuntimeError, "#{klass} already has type parameters #{RDL::Globals.type_params[klass]}"
    end
    params = params.map { |v|
      raise RuntimeError, "Type parameter #{v.inspect} is not symbol or string" unless v.class == String || v.class == Symbol
      v.to_sym
    }
    raise RuntimeError, "Duplicate type parameters not allowed" unless params.uniq.size == params.size
    raise RuntimeError, "Expecting #{params.size} variance annotations, got #{variance.size}" if variance && params.size != variance.size
    raise RuntimeError, "Only :+, +-, and :~ are allowed variance annotations" unless (not variance) || variance.all? { |v| [:+, :-, :~].member? v }
    raise RuntimeError, "Can't pass both all and a block" if all && blk
    raise RuntimeError, "all must be a symbol" unless (not all) || (all.instance_of? Symbol)
    chk = all || blk
    raise RuntimeError, "At least one of {all, blk} required" unless chk
    variance = params.map { |p| :~ } unless variance # default to invariant
    RDL::Globals.type_params[klass] = [params, variance, chk]
    nil
  end

  # The following code attempts to warn about annotation methods already being defined on the class/module.
  # But it doesn't work because `extended` gets called *after* the module's methods are already added...
  # def self.extended(other)
  #   [:pre,
  #    :post,
  #    :type,
  #    :var_type,
  #    :attr_accessor_type,
  #    :attr_reader_type,
  #    :attr_type,
  #    :attr_writer_type,
  #    :rdl_alias,
  #    :type_params].each { |a|
  #      warn "RDL WARNING: #{other.to_s} extended RDL::Annotate but already has #{a} defined" if other.respond_to? a
  #    }
  # end
end

# all methods in RDL::Annotate but with an `rdl_` prefix
module RDL::RDLAnnotate
  define_method :rdl_pre, RDL::Annotate.instance_method(:pre)
  define_method :rdl_post, RDL::Annotate.instance_method(:post)
  define_method :rdl_type, RDL::Annotate.instance_method(:type)
  define_method :rdl_var_type, RDL::Annotate.instance_method(:var_type)
  define_method :rdl_alias, RDL::Annotate.instance_method(:rdl_alias)
  define_method :rdl_type_params, RDL::Annotate.instance_method(:type_params)

  # Need to duplicate these methods because they need to call rdl_var_type and rdl_type
  # and couldn't figure out how to do instance_method with a partial argument binding
  def rdl_attr_accessor_type(*args)
    args.each_slice(2) { |name, typ|
      attr_accessor name
      rdl_var_type ("@" + name.to_s), typ
      rdl_type name, "() -> #{typ}"
      rdl_type name.to_s + "=", "(#{typ}) -> #{typ}"
    }
    nil
  end

  def rdl_attr_reader_type(*args)
    args.each_slice(2) { |name, typ|
      attr_reader name
      rdl_var_type ("@" + name.to_s), typ
      rdl_type name, "() -> #{typ}"
    }
    nil
  end

  alias_method :rdl_attr_type, :rdl_attr_reader_type

  def rdl_attr_writer_type(*args)
    args.each_slice(2) { |name, typ|
      attr_writer name
      rdl_var_type ("@" + name.to_s), typ
      rdl_type name.to_s + "=", "(#{typ}) -> #{typ}"
    }
    nil
  end
end

module RDL
  extend RDL::Annotate

  # Add a new type alias.
  # [+name+] must be a string beginning with %.
  # [+typ+] can be either a string, in which case it will be parsed
  # into a type, or a Type.
  def self.type_alias(name, typ)
    raise RuntimeError, "Attempt to redefine type #{name}" if RDL::Globals.special_types[name]
    case typ
    when String
      t = RDL::Globals.parser.scan_str "#T #{typ}"
      RDL::Globals.special_types[name] = t
    when RDL::Type::Type
      RDL::Globals.special_types[name] = typ
    else
      raise RuntimeError, "Unexpected typ argument #{typ.inspect}"
    end
    nil
  end

  def self.nowrap(klass=self)
    RDL.config { |config| config.add_nowrap(klass) }
    nil
  end

  # Register [+ blk +] to be executed when `rdl_do_typecheck [+ sym +]` is called.
  # The blk will be called with sym as its argument. The order
  # in which multiple blks for the same sym will be executed is unspecified
  def self.at(sym, &blk)
    RDL::Globals.to_do_at[sym] = [] unless RDL::Globals.to_do_at[sym]
    RDL::Globals.to_do_at[sym] << blk
  end

  # Invokes all callbacks from rdl_at(sym), in unspecified order.
  # Afterwards, type checks all methods that had annotation `typecheck: sym' at type call, in unspecified order.
  def self.do_typecheck(sym)
    if RDL::Globals.to_do_at[sym]
      RDL::Globals.to_do_at[sym].each { |blk| blk.call(sym) }
    end
    RDL::Globals.to_do_at[sym] = Array.new
    return unless RDL::Globals.to_typecheck[sym]
    RDL::Globals.to_typecheck[sym].each { |klass, meth|
      RDL::Typecheck.typecheck(klass, meth)
    }
    RDL::Globals.to_typecheck[sym] = Set.new
    nil
  end

  def self.check_type_code
    RDL.config { |config| config.use_dep_types = false }
    count = 1
    code_type = RDL::Globals.parser.scan_str "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type"
    RDL::Globals.dep_types.each { |klass, meth, typ|
      comp_types = []
      klass = RDL::Util.has_singleton_marker(klass) ? RDL::Util.remove_singleton_marker(klass) : klass
      (typ.args+[typ.ret]+[typ.block]).each { |t|
        if t.is_a?(RDL::Type::ComputedType)
          meth = cleanse_meth_name(meth)
          tmp_meth = "def #{klass}.tc_#{meth}#{count}(trec, targs) #{t.code}; end"
          eval tmp_meth
          ast = Parser::CurrentRuby.parse tmp_meth
          RDL::Typecheck.typecheck("[s]#{klass}", "tc_#{meth}#{count}".to_sym, ast, [code_type])
          count += 1
        end
      }
    }
    RDL.do_typecheck :type_code
    RDL.config { |config| config.use_dep_types = true }
    true
  end

  def self.cleanse_meth_name(meth)
    meth = meth.to_s
    meth.gsub!("%", "percent")
    meth.gsub!("&", "ampersand")
    meth.gsub!("*", "asterisk")
    meth.gsub!("+", "plus")
    meth.gsub!("-", "dash")
    meth.gsub!("@", "at")
    meth.gsub!("/", "slash")
    meth.gsub!("<", "lt")
    meth.gsub!(">", "gt")
    meth.gsub!("=", "eq")
    meth.gsub!("[", "lbracket")
    meth.gsub!("]", "rbracket")
    meth.gsub!("^", "carrot")
    meth.gsub!("|", "line")
    meth.gsub!("~", "line")
    meth.gsub!("?", "qmark")
    meth.gsub!("!", "bang")
    meth
  end

  # Does nothing at run time
  def self.note_type(x)
    return x
  end

  def self.remove_type(klass, meth)
    raise RuntimeError, "No existing type for #{RDL::Util.pp_klass_method(klass, meth)}" unless RDL::Globals.info.has? klass, meth, :type
    RDL::Globals.info.remove klass, meth, :type
    nil
  end

  # Returns a new object that wraps self in a type cast. If force is true this cast is *unchecked*, so use with caution
  def self.type_cast(obj, typ, force: false)
    new_typ = if typ.is_a? RDL::Type::Type then typ else RDL::Globals.parser.scan_str "#T #{typ}" end
    raise RuntimeError, "type cast error: self not a member of #{new_typ}" unless force || typ.member?(obj)
    new_obj = SimpleDelegator.new(obj)
    new_obj.instance_variable_set('@__rdl_type', new_typ)
    new_obj
  end

  # [+typs+] is an array of types, classes, symbols, or strings to instantiate
  # the type parameters. If a class, symbol, or string is given, it is
  # converted to a NominalType.
  def self.instantiate!(obj, *typs, check: false)
    klass = obj.class.to_s
    klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
    formals, _, all = RDL::Globals.type_params[klass]
    raise RuntimeError, "Receiver is of class #{klass}, which is not parameterized" unless formals
    raise RuntimeError, "Expecting #{formals.size} type parameters, got #{typs.size}" unless formals.size == typs.size
    raise RuntimeError, "Instance already has type instantiation" if obj.instance_variable_defined?(:@__rdl_type) && obj.instance_variable_get(:@__rdl_type)
    new_typs = typs.map { |t| if t.is_a? RDL::Type::Type then t else RDL::Globals.parser.scan_str "#T #{t}" end }
    t = RDL::Type::GenericType.new(RDL::Type::NominalType.new(klass), *new_typs)
    if check
      if all.instance_of? Symbol
        obj.send(all) { |*objs|
          new_typs.zip(objs).each { |nt, o|
            if nt.instance_of? RDL::Type::GenericType # require o to be instantiated
              t_o = RDL::Util.rdl_type(o)
              raise RDL::Type::TypeError, "Expecting element of type #{nt.to_s}, but got uninstantiated object #{o.inspect}" unless t_o
              raise RDL::Type::TypeError, "Expecting type #{nt.to_s}, got type #{t_o.to_s}" unless t_o <= nt
            else
              raise RDL::Type::TypeError, "Expecting type #{nt.to_s}, got #{o.inspect}" unless nt.member? o
            end
          }
        }
      else
        raise RDL::Type::TypeError, "Not an instance of #{t}" unless instance_exec(*new_typs, &all)
      end
    end
    obj.instance_variable_set(:@__rdl_type, t)
    obj
  end

  def self.deinstantiate!(obj)
    klass = obj.class.to_s
    klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
    raise RuntimeError, "Class #{self.to_s} is not parameterized" unless RDL::Globals.type_params[klass]
    raise RuntimeError, "Instance is not instantiated" unless obj.instance_variable_get(:@__rdl_type).instance_of?(RDL::Type::GenericType)
    obj.instance_variable_set(:@__rdl_type, nil)
    obj
  end
end

class Object
  def singleton_method_added(meth)
    klass = self.to_s
    klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
    sklass = RDL::Util.add_singleton_marker(klass)
    RDL::Wrap.do_method_added(self, true, sklass, meth)
    nil
  end  
end

class Module
  define_method :singleton_method_added, Object.instance_method(:singleton_method_added)
  
  def method_added(meth)
    klass = self.to_s
    klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
    RDL::Wrap.do_method_added(self, false, klass, meth)
    nil
  end
end

class Class
  def ===(x)
    if x.method(:is_a?).owner == SimpleDelegator then super(x.__getobj__) else super(x) end
  end
end

class SimpleDelegator
  ## pass methods through to wrapped object
  ## necessary when type casts are inside type-level code
  def is_a?(c)
    __getobj__.is_a?(c)
  end

  def instance_of?(c)
    __getobj__.instance_of?(c)
  end

  def kind_of?(c)
    __getobj__.kind_of?(c)
  end

  def ===(x)
    __getobj__ === x
  end

  def ==(x)
    __getobj__ == x
  end

  def class
     __getobj__.class
  end

end

