require_relative 'type'

module RDL::Type

  # A type representing some method or block. MethodType has subcomponent
  # types for arguments (zero or more), block (optional) and return value
  # (exactly one).
  class MethodType < Type
    attr_reader :args
    attr_reader :block
    attr_reader :ret

    @@contract_cache = {}
    
    # Create a new MethodType
    #
    # [+args+] List of types of the arguments of the procedure (use [] for no args).
    # [+block+] The type of the block passed to this method, if it takes one.
    # [+ret+] The type that the procedure returns.
    def initialize(args, block, ret)
      # First check argument types have form (any number of required
      # or optional args, at most one vararg, any number of named arguments)
      state = :required
      args.each { |arg|
        arg = arg.type if arg.instance_of? RDL::Type::AnnotatedArgType
        case arg
        when OptionalType
          raise "Optional arguments not allowed after varargs" if state == :vararg
          raise "Optional arguments not allowed after named arguments" if state == :hash
          state = :optional
        when VarargType
          raise "Multiple varargs not allowed" if state == :vararg
          raise "Varargs not allowed after named arguments" if state == :hash
          state = :vararg
        when FiniteHashType
          raise "Only one set of named arguments allowed" if state == :hash
          state = :hash
        else
          raise "Required arguments not allowed after varargs" if state == :vararg
          raise "Required arguments not allowed after named arguments" if state == :hash
        end
      }
      @args = *args

      raise "Block must be MethodType" unless (not block) or (block.instance_of? MethodType)
      @block = block

      @ret = ret

      super()
    end

    def le(other, h={})
      raise RuntimeError, "should not be called"
    end

    def pre_cond_check(method_name, inst, *args)
      states = [[0, 0]] # [position in @arg, position in args]
      until states.empty?
        formal, actual = states.pop
        return true if formal == @args.size && actual == args.size # Matched all actuals, no formals left over
        next if formal >= @args.size # Too many actuals to match
        t = @args[formal]
        t = t.type if t.instance_of? AnnotatedArgType
        case t
        when OptionalType
          t = t.type.instantiate(inst)
          if actual == args.size
            states << [formal+1, actual] # skip to allow extra formal optionals at end
          elsif t.member?(args[actual], vars_wild: true)
            states << [formal+1, actual+1] # match
            states << [formal+1, actual] # skip
          else
            states << [formal+1, actual]  # type doesn't match; must skip this formal
          end
        when VarargType
          t = t.type.instantiate(inst)
          if actual == args.size
            states << [formal+1, actual] # skip to allow empty vararg at end
          elsif t.member?(args[actual], vars_wild: true)
            states << [formal, actual+1] # match, more varargs coming
            states << [formal+1, actual+1] # match, no more varargs
#            states << [formal+1, actual] # skip - can't happen, varargs have to be at end
          else
            states << [formal+1, actual] # skip
          end
        else
          t = t.instantiate(inst)
          the_actual = nil
          if actual == args.size
            next unless t.instance_of? FiniteHashType
            if t.member?({}, vars_wild: true) # try matching against the empty hash
              states << [formal+1, actual]
            end
          elsif t.member?(args[actual], vars_wild: true)
            states << [formal+1, actual+1] # match
            # no else case; if there is no match, this is a dead end
          end
        end
      end
      raise TypeError, "#{method_name}No match of #{args} with #{self}"
    end
    
    def old_pre_cond_check(method_name, inst, *args)
      i = 0 # position in @args
      method_name = method_name ? method_name + ": " : ""
      args.each_with_index { |arg, j|
        raise TypeError, "Too many arguments" if i >= @args.size
        expected = @args[i]
        expected = expected.type if expected.instance_of? AnnotatedArgType
        case expected
        when OptionalType
          expected = expected.type
          i += 1
        when VarargType
          expected = expected.type
          # do not increment i, since vararg can take any number of argument
        else
          i += 1
        end
        expected = expected.instantiate(inst)
        expected.check_member_or_leq(arg, "#{method_name}Argument #{j}: ")
      }
      # Check if there aren't enough arguments; uses invariant established in initialize
      # that method types end with several optional types and then one (optional) vararg type
      if (i < @args.size)
        remaining = @args[i]
        remaining = remaining.type if remaining.instance_of? AnnotatedArgType
        raise TypeError, "#{method_name}: Too few arguments" unless (remaining.instance_of? OptionalType) || (remaining.instance_of? VarargType)
      end
      true
    end

    def post_cond_check(method_name, inst, ret, *args)
      method_name = method_name ? method_name + ": " : ""
      @ret.instantiate(inst).check_member_or_leq(ret, "#{method_name}Returned value: ")
      true
    end

    def to_contract(inst: nil)
      c = @@contract_cache[self]
      return c if c

      # @ret, @args are the formals
      # ret, args are the actuals
      prec = RDL::Contract::FlatContract.new(@args) { |*args| pre_cond_check(nil, inst, *args) }
      postc = RDL::Contract::FlatContract.new(@ret) { |ret, *args| post_cond_check(nil, inst, ret, *args) }
      c = RDL::Contract::ProcContract.new(pre_cond: prec, post_cond: postc)
      return (@@contract_cache[self] = c) # assignment evaluates to c
    end

    # Types is an array of method types. Checks that args and blk match at least
    # one arm of the intersection type; otherwise raises exception. Returns
    # array of method types that matched args and blk
    def self.check_arg_types(method_name, types, inst, *args, &blk)
      matches = [] # types that matched args
      exns = [] # exceptions from types that did not match args
      types.each_with_index { |t, i|
        begin
          $__rdl_contract_switch.off { t.pre_cond_check(method_name, inst, *args, &blk) }
        rescue TypeError => te
          exns << [te, i]
        else
          matches << [t, i]
        end
      }
      return matches if matches.size > 0
      raise exns[0][0] if types.size == 1 # if there's only one possible method type, report error
      method_name = method_name ? method_name + ": " : ""
      raise TypeError, ("#{method_name}No argument matches:\n\t" + (exns.map { |e, i| "Doesn't match type #{types[i].to_s}: " + e.message }).join("\n\t"))
    end

    def self.check_ret_types(method_name, types, inst, ret_types, ret, *args, &blk)
      matches = [] # types that match ret
      exns = [] # exceptions from types that did not match args
      ret_types.each { |t,i|
        begin
          $__rdl_contract_switch.off { t.post_cond_check(method_name, inst, ret, *args, &blk) }
        rescue TypeError => te
          exns << [te, i]
        else
          matches << [t, i]
        end
      }
      return true if matches.size > 0
      raise exns[0][0] if types.size == 1 # if there's only one possible type, report error
      method_name = method_name ? method_name + ": " : ""
      raise TypeError, ("#{method_name}Return type doesn't match:\n\t" + (exns.map { |e, i| "Argument#{args.size>1 ? "s" : ""} matched #{types[i].to_s} but: " + e.message}).join("\n\t"))
    end
    
    def to_s  # :nodoc:
      if @block
        "(#{@args.join(', ')}) {#{@block}} -> #{@ret}"
      elsif @args
        "(#{@args.join(', ')}) -> #{@ret}"
      else
        "() -> #{@ret}"
      end
    end

    def eql?(other)
      self == other
    end

    # Return +true+ if +other+ is the same type
    def ==(other)
      return (other.instance_of? MethodType) &&
        (other.args == @args) &&
        (other.block == @block) &&
        (other.ret == @ret)
    end

    def hash  # :nodoc:
      h = (37 + @ret.hash) * 41 + @args.hash
      h = h * 31 + @block.hash if @block
      return h
    end
  end
end

