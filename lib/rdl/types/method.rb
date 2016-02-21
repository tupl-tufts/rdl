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
          raise "Attempt to create method type with non-type arg" unless arg.is_a? Type
          raise "Required arguments not allowed after varargs" if state == :vararg
          raise "Required arguments not allowed after named arguments" if state == :hash
        end
      }
      @args = *args

      raise "Block must be MethodType" unless (not block) or (block.instance_of? MethodType)
      @block = block

      raise "Attempt to create method type with non-type ret" unless ret.is_a? Type
      @ret = ret

      super()
    end

    def get_block()
	return @block
    end

    def le(other, h={})
      raise RuntimeError, "should not be called"
    end

    # TODO: Check blk
    def pre_cond?(blk, slf, inst, *args)
	if @block then
		blk = block_wrap(slf,inst,@block,&blk)
	end
	new_args = []
	new_arg_typs = []
	@args.each_with_index {|a,i| if a.is_a?(RDL::Type::MethodType) then
					new_arg_typs << RDL::Type::NominalType.new('Proc')
					new_args << block_wrap(slf,inst,a,&args[i])
					else
					new_arg_typs << @args[i]
					new_args << args[i]
					end }

      states = [[0, 0]] # [position in @arg, position in args]
      until states.empty?
        formal, actual = states.pop
        return [true, new_args, blk] if formal == @args.size && actual == args.size # Matched all actuals, no formals left over
        next if formal >= @args.size # Too many actuals to match
        t = new_arg_typs[formal]
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
      return [false, new_args, blk]
    end

    def post_cond?(slf, inst, ret, *args)
	new_ret = ret
	if @ret.is_a?(RDL::Type::MethodType) then
		if !ret.is_a?(Proc) then return [false,ret] else
		new_ret = block_wrap(slf,inst,@ret,&ret)
		return [true, new_ret]
		end
	end
	method_name = method_name ? method_name + ": " : ""
	return [@ret.instantiate(inst).member?(ret, vars_wild: true), new_ret]
    end

    def to_contract(inst: nil)
      c = @@contract_cache[self]
      return c if c

      # slf.ret, slf.args are the formals
      # ret, args are the actuals
      slf = self # Bind self so it's captured in a closure, since contracts are executed
                 # with self bound to the receiver method's self
      prec = RDL::Contract::FlatContract.new { |*args, &blk|
        raise TypeError, "Arguments #{args} do not match argument types #{slf}" unless slf.pre_cond?(blk, slf, inst, *args)
        true
      }
      postc = RDL::Contract::FlatContract.new { |ret, *args|
        raise TypeError, "Return #{ret} does not match return type #{slf}" unless slf.post_cond?(slf, inst, ret, *args)[0]
        true
      }
      c = RDL::Contract::ProcContract.new(pre_cond: prec, post_cond: postc)
      return (@@contract_cache[self] = c) # assignment evaluates to c
    end

    # [+types+] is an array of method types. Checks that [+args+] and
    # [+blk+] match at least one arm of the intersection type;
    # otherwise raises exception. Returns array of method types that
    # matched [+args+] and [+blk+]
    def self.check_arg_types(method_name, slf, types, inst, *args, &blk)
      $__rdl_contract_switch.off {
        matches = [] # types that matched args
	new_args = nil
        types.each_with_index { |t, i|
	x = t.pre_cond?(blk, slf, inst, *args)
	if x[0] then
	    matches << i
	    args = x[1]
	    blk = x[2]
	end }
	return [matches, args, blk] if matches.size > 0
        method_name = method_name ? method_name + ": " : ""
        raise TypeError, <<RUBY
#{method_name}Argument type error.
Method type:
#{ types.map { |t| "        " + t.to_s }.join("\n") }
Actual argument type#{args.size > 1 ? "s" : ""}:
        (#{args.map { |arg| RDL::Util.rdl_type_or_class(arg) }.join(', ')}) #{if blk then blk.to_s end}
Actual argument values (one per line):
#{ args.map { |arg| "        " + arg.inspect }.join("\n") }
RUBY
      }
    end

    def self.check_ret_types(slf, method_name, types, inst, matches, ret, *args, &blk)
      $__rdl_contract_switch.off {
        matches.each { |i| x = types[i].post_cond?(slf, inst, ret, *args)
			if x[0] then return x[1] end  }
        method_name = method_name ? method_name + ": " : ""
        raise TypeError, <<RUBY
#{method_name}Return type error. *'s indicate argument lists that matched.
Method type:
#{types.each_with_index.map { |t,i| "       " + (matches.member?(i) ? "*" : " ") + t.to_s }.join("\n") }
Actual return type:
        #{ RDL::Util.rdl_type_or_class(ret)}
Actual return value:
        #{ ret.inspect }
RUBY
      }
    end

    def to_s  # :nodoc:
      if @block
        return "(#{@args.map { |arg| arg.to_s }.join(', ')}) {#{@block.to_s}} -> #{@ret.to_s}"
      elsif @args
        return "(#{@args.map { |arg| arg.to_s }.join(', ')}) -> #{@ret.to_s}"
      else
        return "() -> #{@ret.to_s}"
      end
    end

    def <=(other)
      return false unless other.instance_of? MethodType # only comparable to method types
      return false unless other.args.size == @args.size
      return false unless @args.zip(other.args).all? { |left, right| right <= left } # contravariance
      return false unless @ret <= other.ret # covariance
      if @block && other.block
        return (other.block <= @block) # contravariance
      elsif @block.nil? && other.block.nil?
        return true
      else
        return false # one has a block and the other doesn't
      end
    end

    def instantiate(inst)
      return MethodType.new(@args.map { |arg| arg.instantiate(inst) },
                            @block ? @block.instantiate(inst) : nil,
                            @ret.instantiate(inst))
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

    # other may not be a query
    def match(other)
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return false unless @ret.match(other.ret)
      if @block == nil
        return false unless other.block == nil
      else
        return false if other.block == nil
        return false unless @block.match(other.block)
      end
      # Check arg matches; logic is similar to pre_cond
      states = [[0,0]] # [position in self, position in other]
      until states.empty?
        s_arg, o_arg = states.pop
        return true if s_arg == @args.size && o_arg == other.args.size # everything matches
        next if s_arg >= @args.size # match not possible, not enough args in self
        if @args[s_arg].instance_of? DotsQuery then
          if o_arg == other.args.size
            # no args left in other, skip ...
            states << [s_arg+1, o_arg]
          else
            states << [s_arg+1, o_arg+1] # match, no more matches to ...
            states << [s_arg, o_arg+1]   # match, more matches to ... coming
          end
        else
          next if o_arg == other.args.size # match not possible, not enough args in other
          s_arg_t = @args[s_arg]
          s_arg_t = s_arg_t.type if s_arg_t.instance_of? AnnotatedArgType
          o_arg_t = other.args[o_arg]
          o_arg_t = o_arg_t.type if o_arg_t.instance_of? AnnotatedArgType
          next unless s_arg_t.match(o_arg_t)
          states << [s_arg+1, o_arg+1]
        end
      end
      return false
    end

    def hash  # :nodoc:
      h = (37 + @ret.hash) * 41 + @args.hash
      h = h * 31 + @block.hash if @block
      return h
    end

    def self.check_block_arg_types(slf, types, inst, *args)
      $__rdl_contract_switch.off {
	x = types.pre_cond?(nil, slf, inst, *args)
        if x[0] then
		return true
	end
        raise TypeError, <<RUBY
Proc argument type error.
Proc type:
#{ [types].map { |t| "        " + t.to_s }.join("\n") }
Actual argument type#{args.size > 1 ? "s" : ""}:
        (#{args.map { |arg| RDL::Util.rdl_type_or_class(arg) }.join(', ')})
Actual argument values (one per line):
#{ args.map { |arg| "        " + arg.inspect }.join("\n") }
RUBY
      }
    end

    def self.check_block_ret_types(slf, types, inst, ret, *args)
      $__rdl_contract_switch.off {
	x = types.post_cond?(slf, inst, ret, *args)
	if x[0] then
		return x[1]
	end
        raise TypeError, <<RUBY
Proc return type error.
Proc type:
#{[types].each_with_index.map { |t,i| "       " + t.to_s }.join("\n") }
Actual Proc return type:
        #{ RDL::Util.rdl_type_or_class(ret)}
Actual Proc return value:
        #{ ret.inspect }
RUBY
      }
    end

    def block_wrap(slf, inst, types, &blk)
      Proc.new {|*v|
        test = RDL::Type::MethodType.check_block_arg_types(slf, types, inst, *v)
        tmp = slf.instance_exec(*v, &blk)
	tmp = RDL::Type::MethodType.check_block_ret_types(slf, types, inst, tmp, *v)
        tmp
      }
    end

end
end
