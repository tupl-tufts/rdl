class RDL::Wrap
  def self.wrapped?(klass, meth)
    RDL::Util.method_defined?(klass, wrapped_name(klass, meth))
  end

  def self.resolve_alias(klass, meth)
    klass = klass.to_s
    meth = meth.to_sym
    while $__rdl_aliases[klass] && $__rdl_aliases[klass][meth]
      raise RuntimeError, "Alias #{klass}\##{meth} has contracts. Contracts are only allowed on methods, not aliases." if has_any_contracts?(klass, meth)
      meth = $__rdl_aliases[klass][meth]
    end
    return meth
  end

  def self.add_contract(klass, meth, kind, val)
    klass = klass.to_s
    meth = meth.to_sym
    $__rdl_contracts[klass] = {} unless $__rdl_contracts[klass]
    $__rdl_contracts[klass][meth] = {} unless $__rdl_contracts[klass][meth]
    $__rdl_contracts[klass][meth][kind] = [] unless $__rdl_contracts[klass][meth][kind]
    $__rdl_contracts[klass][meth][kind] << val
  end

  def self.has_contracts?(klass, meth, kind)
    klass = klass.to_s
    meth = meth.to_sym
    return ($__rdl_contracts.has_key? klass) &&
           ($__rdl_contracts[klass].has_key? meth) &&
           ($__rdl_contracts[klass][meth].has_key? kind)
  end

  def self.has_any_contracts?(klass, meth)
    klass = klass.to_s
    meth = meth.to_sym
    return ($__rdl_contracts.has_key? klass) &&
           ($__rdl_contracts[klass].has_key? meth)
  end

  def self.get_contracts(klass, meth, kind)
    klass = klass.to_s
    meth = meth.to_sym
    return $__rdl_contracts[klass][meth][kind]
  end

  def self.get_type_params(klass)
    klass = klass.to_s
    $__rdl_type_params[klass]
  end

  # [+klass+] may be a Class, String, or Symbol
  # [+meth+] may be a String or Symbol
  #
  # Wraps klass#method to check contracts and types. Does not rewrap
  # if already wrapped.
  def self.wrap(klass_str, meth)
    $__rdl_wrap_switch.off {
      klass_str = klass_str.to_s
      klass = RDL::Util.to_class klass_str
      return if wrapped? klass, meth
      return if RDL::Config.instance.nowrap.member? klass
      raise ArgumentError, "Attempt to wrap #{klass.to_s}\##{meth.to_s}" if klass.to_s =~ /^RDL::/
      meth_old = wrapped_name(klass, meth) # meth_old is a symbol
      # return if (klass.method_defined? meth_old) # now checked above by wrapped? call
      is_singleton_method = RDL::Util.has_singleton_marker(klass_str)
      full_method_name = RDL::Util.pp_klass_method(klass_str, meth)

      klass.class_eval <<-RUBY, __FILE__, __LINE__
        alias_method meth_old, meth
        def #{meth}(*args, &blk)
          klass = "#{klass_str}"
          meth = types = matches = nil
          inst = nil
          $__rdl_wrap_switch.off {
            $__rdl_wrapped_calls["#{full_method_name}"] += 1 if RDL::Config.instance.gather_stats
            inst = @__rdl_inst
            inst = Hash[$__rdl_type_params[klass][0].zip []] if (not(inst) && $__rdl_type_params[klass])
            inst = {} if not inst
            #{if not(is_singleton_method) then "inst[:self] = RDL::Type::SingletonType.new(self)" end}
#            puts "Intercepted #{full_method_name}(\#{args.join(", ")}) { \#{blk} }, inst = \#{inst.inspect}"
            meth = RDL::Wrap.resolve_alias(klass, #{meth.inspect})
            if RDL::Wrap.has_contracts?(klass, meth, :pre)
              pres = RDL::Wrap.get_contracts(klass, meth, :pre)
              RDL::Contract::AndContract.check_array(pres, self, *args, &blk)
            end
            if RDL::Wrap.has_contracts?(klass, meth, :type)
              types = RDL::Wrap.get_contracts(klass, meth, :type)
              matches = RDL::Type::MethodType.check_arg_types("#{full_method_name}", types, inst, *args, &blk)
            end
          }
          ret = send(#{meth_old.inspect}, *args, &blk)
          $__rdl_wrap_switch.off {
            if RDL::Wrap.has_contracts?(klass, meth, :post)
              posts = RDL::Wrap.get_contracts(klass, meth, :post)
              RDL::Contract::AndContract.check_array(posts, self, ret, *args, &blk)
            end
            if matches
              RDL::Type::MethodType.check_ret_types("#{full_method_name}", types, inst, matches, ret, *args, &blk)
            end
          }
          return ret
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
      raise ArgumentError, "Invalid arguments"
    end
    raise ArgumentError, "#{contract.class} received where Contract expected" unless contract.class < RDL::Contract::Contract
#    meth = :initialize if meth && meth.to_sym == :new  # actually wrap constructor
    klass = RDL::Util.add_singleton_marker(klass) if slf # && (meth != :initialize)
    return [klass, meth, contract]
  end

  # [+default_class+] should be a class
  def self.process_type_args(default_class, *args, &blk)
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
      raise ArgumentError, "Invalid arguments"
    end
    raise ArgumentError, "Excepting method type, got #{type.class} instead" if type.class != RDL::Type::MethodType
#    meth = :initialize if meth && slf && meth.to_sym == :new  # actually wrap constructor
    klass = RDL::Util.add_singleton_marker(klass) if slf
    return [klass, meth, type]
  end

  private

  def self.wrapped_name(klass, meth)
    "__rdl_#{meth.to_s}_old".to_sym
  end

  def self.class_to_string(klass)
    case klass
    when Class
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
      return $__rdl_parser.scan_str type
    end
  end
end

class Object

  # [+klass+] may be Class, Symbol, or String
  # [+method+] may be Symbol or String
  # [+contract+] must be a Contract
  #
  # Add a precondition to a method. Possible invocations:
  # pre(klass, meth, contract)
  # pre(klass, meth) { block } = pre(klass, meth, FlatContract.new { block })
  # pre(meth, contract) = pre(self, meth, contract)
  # pre(meth) { block } = pre(self, meth, FlatContract.new { block })
  # pre(contract) = pre(self, next method, contract)
  # pre { block } = pre(self, next method, FlatContract.new { block })
  def pre(*args, &blk)
    $__rdl_contract_switch.off { # Don't check contracts inside RDL code itself
      klass, meth, contract = RDL::Wrap.process_pre_post_args(self, "Precondition", *args, &blk)
      if meth
        RDL::Wrap.add_contract(klass, meth, :pre, contract)
        if RDL::Util.method_defined?(klass, meth) || meth == :initialize # there is always an initialize
          RDL::Wrap.wrap(klass, meth)
        else
          $__rdl_to_wrap << [klass, meth]
        end
      else
        $__rdl_deferred << [klass, :pre, contract]
      end
    }
  end

  # Add a postcondition to a method. Same possible invocations as pre.
  def post(*args, &blk)
    $__rdl_contract_switch.off {
      klass, meth, contract = RDL::Wrap.process_pre_post_args(self, "Postcondition", *args, &blk)
      if meth
        RDL::Wrap.add_contract(klass, meth, :post, contract)
        if RDL::Util.method_defined?(klass, meth) || meth == :initialize
          RDL::Wrap.wrap(klass, meth)
        else
          $__rdl_to_wrap << [klass, meth]
        end
      else
        $__rdl_deferred << [klass, :post, contract]
      end
    }
  end

  # [+klass+] may be Class, Symbol, or String
  # [+method+] may be Symbol or String
  # [+type+] may be Type or String
  #
  # Set a method's type. Possible invocations:
  # type(klass, meth, type)
  # type(meth, type)
  # type(type)
  def type(*args, &blk)
    $__rdl_contract_switch.off {
      klass, meth, type = begin
                            RDL::Wrap.process_type_args(self, *args, &blk)
                          rescue Racc::ParseError => err
                            # Remove enough backtrace to only include actual source line
                            # Warning: Adjust the -5 below if the code (or this comment) changes
                            bt = err.backtrace
                            bt.shift until bt[0] =~ /^#{__FILE__}:#{__LINE__-5}/
                            bt.shift # remove $__rdl_contract_switch.off call
                            bt.shift # remove type call itself
                            err.set_backtrace bt
                            raise err
                          end
      if meth
# It turns out Ruby core/stdlib don't always follow this convention...
#        if (meth.to_s[-1] == "?") && (type.ret != $__rdl_type_bool)
#          warn "#{RDL::Util.pp_klass_method(klass, meth)}: methods that end in ? should have return type %bool"
#        end
        RDL::Wrap.add_contract(klass, meth, :type, type)
        if RDL::Util.method_defined?(klass, meth) || meth == :initialize
          RDL::Wrap.wrap(klass, meth)
        else
          $__rdl_to_wrap << [klass, meth]
        end
      else
        $__rdl_deferred << [klass, :type, type]
      end
    }
  end

  def self.method_added(meth)
    $__rdl_contract_switch.off {
      klass = self.to_s
      klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")

      # Apply any deferred contracts and reset list
      if $__rdl_deferred.size > 0
        a = $__rdl_deferred
        $__rdl_deferred = [] # Reset before doing more work to avoid infinite recursion
        a.each { |prev_klass, kind, contract|
          raise RuntimeError, "Deferred contract from class #{prev_klass} being applied in class #{klass}" if prev_klass != klass
          RDL::Wrap.add_contract(klass, meth, kind, contract)
          RDL::Wrap.wrap(klass, meth)
# It turns out Ruby core/stdlib don't always follow this convention...
#          if (kind == :type) && (meth.to_s[-1] == "?") && (contract.ret != $__rdl_type_bool)
#            warn "#{RDL::Util.pp_klass_method(klass, meth)}: methods that end in ? should have return type %bool"
#          end
        }
      end

      # Wrap method if there was a prior contract for it.
      if $__rdl_to_wrap.member? [klass, meth]
        $__rdl_to_wrap.delete [klass, meth]
        RDL::Wrap.wrap(klass, meth)
      end
    }
  end

  def self.singleton_method_added(meth)
    $__rdl_contract_switch.off {
      klass = self.to_s
      klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
      sklass = RDL::Util.add_singleton_marker(klass)

      # Apply any deferred contracts and reset list
      if $__rdl_deferred.size > 0
        a = $__rdl_deferred
        $__rdl_deferred = [] # Reset before doing more work to avoid infinite recursion
        a.each { |prev_klass, kind, contract|
          raise RuntimeError, "Deferred contract from class #{prev_klass} being applied in class #{klass}" if prev_klass != klass
          RDL::Wrap.add_contract(sklass, meth, kind, contract)
          RDL::Wrap.wrap(sklass, meth)
        }
      end

      # Wrap method if there was a prior contract for it.
      if $__rdl_to_wrap.member? [sklass, meth]
        $__rdl_to_wrap.delete [sklass, meth]
        RDL::Wrap.wrap(sklass, meth)
      end
    }
  end

  # Aliases contracts for meth_old and meth_new. Currently, this must
  # be called for any aliases or they will not be wrapped with
  # contracts. Only creates aliases in the current class.
  def rdl_alias(new_name, old_name)
    $__rdl_contract_switch.off {
      klass = self.to_s
      klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
      $__rdl_aliases[klass] = {} unless $__rdl_aliases[klass]
      if $__rdl_aliases[klass][new_name]
        raise RuntimeError,
              "Tried to alias #{new_name}, already aliased to #{$__rdl_aliases[klass][new_name]}"
      end
      $__rdl_aliases[klass][new_name] = old_name

      if self.method_defined? new_name
        RDL::Wrap.wrap(klass, new_name)
      else
        $__rdl_to_wrap << [klass, old_name]
      end
    }
  end

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
  def type_params(params, all, variance: nil, &blk)
    $__rdl_contract_switch.off {
      raise RuntimeError, "Empty type parameters not allowed" if params.empty?
      klass = self.to_s
      klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
      if $__rdl_type_params[klass]
        raise RuntimeError, "#{klass} already has type parameters #{$__rdl_type_params[klass]}"
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
      $__rdl_type_params[klass] = [params, variance, chk]
    }
  end

  def rdl_nowrap
    $__rdl_contract_switch.off {
      RDL.config { |config| config.add_nowrap(self, self.singleton_class) }
    }
  end

  # [+typs+] is an array of types, classes, symbols, or strings to instantiate
  # the type parameters. If a class, symbol, or string is given, it is
  # converted to a NominalType.
  def instantiate!(*typs)
    $__rdl_contract_switch.off {
      klass = self.class.to_s
      klass = "Object" if (klass.is_a? Object) && (klass.to_s == "main")
      formals, variance, all = $__rdl_type_params[klass]
      raise RuntimeError, "Receiver is of class #{klass}, which is not parameterized" unless formals
      raise RuntimeError, "Expecting #{params.size} type parameters, got #{typs.size}" unless formals.size == typs.size
      raise RuntimeError, "Instance already has type instantiation" if @__rdl_type
      new_typs = typs.map { |t| if t.is_a? RDL::Type::Type then t else $__rdl_parser.scan_str "#T #{t}" end }
      t = RDL::Type::GenericType.new(RDL::Type::NominalType.new(klass), *new_typs)
      if all.instance_of? Symbol
        self.send(all) { |*objs|
          new_typs.zip(objs).each { |t, obj|
            if t.instance_of? RDL::Type::GenericType # require obj to be instantiated
              t_obj = RDL::Util.rdl_type(obj)
              raise RDL::Type::TypeError, "Expecting element of type #{t.to_s}, but got uninstantiated object #{obj.inspect}" unless t_obj
              raise RDL::Type::TypeError, "Expecting type #{t.to_s}, got type #{t_obj.to_s}" unless t_obj <= t
            else
              raise RDL::Type::TypeError, "Expecting type #{t.to_s}, got #{obj.inspect}" unless t.member? obj
            end
          }
        }
      else
        raise RDL::Type::TypeError, "Not an instance of #{t}" unless instance_exec(*new_typs, &all)
      end
      @__rdl_type = t
      self
    }
  end

  def deinstantiate!
    $__rdl_contract_switch.off {
      raise RuntimeError, "Class #{self.to_s} is not parameterized" unless $__rdl_type_params[klass]
      raise RuntimeError, "Instance is not instantiated" unless @__rdl_type && @@__rdl_type.instance_of?(RDL::Type::GenericType)
      @__rdl_type = nil
    }
  end

  # Returns a new object that wraps self in a type cast. This cast is *unchecked*, so use with caution
  def type_cast(typ)
    $__rdl_contract_switch.off {
      new_typ = if typ.is_a? RDL::Type::Type then typ else $__rdl_parser.scan_str "#T #{typ}" end
      obj = SimpleDelegator.new(self)
      obj.instance_variable_set('@__rdl_type', new_typ)
      return obj
    }
  end

  # Add a new type alias.
  # [+name+] must be a string beginning with %.
  # [+typ+] can be either a string, in which case it will be parsed
  # into a type, or a Type.
  def type_alias(name, typ)
    $__rdl_contract_switch.off {
      raise RuntimeError, "Attempt to redefine type #{name}" if $__rdl_special_types[name]
      case typ
      when String
        t = $__rdl_parser.scan_str "#T #{typ}"
        $__rdl_special_types[name] = t
      when RDL::Type::Type
        $__rdl_special_types[name] = typ
      else
        raise RuntimeError, "Unexpected typ argument #{typ.inspect}"
      end
    }
  end
end
