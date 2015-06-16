require_relative 'type'

module RDL::Type

  # A type representing some method or block. MethodType has subcomponent
  # types for arguments (zero or more), block (optional) and return value
  # (exactly one).
  class MethodType < Type
    attr_reader :args
    attr_reader :block
    attr_reader :ret

    # Create a new MethodType
    #
    # [+args+] List of types of the arguments of the procedure (use [] for no args).
    # [+block+] The type of the block passed to this method, if it takes one.
    # [+ret+] The type that the procedure returns.
    def initialize(args, block, ret)
      # First check argument types have form (any number of required
      # args, any number of optional args, at most one vararg)
      state = :required
      args.each { |arg|
        case arg.class
        when OptionalType
          raise "optional arguments not allowed after varargs" if state == :vararg
          state = :optional
        when VarargType
          raise "multiple varargs not allowed" if state == :vararg
          state = :vararg
        else
          raise "required arguments not allowed after optional arguments or varargs" if state == :optional || state == :vararg
        end
      }
      @args = *args

      raise "block must be MethodType" unless (not block) or (block.instance_of? MethodType)
      @block = block

      @ret = ret

      super()
    end

    def le(other, h={})
      raise Exception, "should not be called"
    end

    def to_contract
      # @ret, @args are the formals
      # ret, args are the actuals
      prec = RDL::Contract::FlatCtc.new(@args) { |*args|
        i = 0 # position in @args
        args.each { |arg|
          raise TypeException, "Type error: Too many arguments" if i >= @args[size]
          case @args[i].class
          when OptionalType
            unless @args[i].type.member? arg
              raise TypeException,
                    "Type error: Argument #{i}, expecting (optional) #{@args[i]}, got #{arg.inspect}"
            end
            i += 1
          when VarargType
            unless @args[i].type.member? arg
              raise TypeException,
                    "Type error: Argument #{i}, expecting (vararg) #{@args[i]}, got #{arg.inspect}"
            end
            # do not increment i, since vararg can take any number of arugment
          else
            unless @args[formal_i].member? arg
              raise TypeException,
                    "Type error: Argument #{i}, expecting #{@args[i]}, got #{arg.inspect}"
            end
            i += 1
          end
        }
        # Check if there aren't enough arguments; uses invariant established in initialize
        # that method types end with several optional types and then one (optional) vararg type
        if (i < @args.size) && (@args[i].class != OptionalType) && (@args[i] != VarargType)
          raise TypeException, "Type error: Too few arguments"
        end
      }
      postc = RDL::Contract::FlatCtc.new(@ret) { |ret, *args|
        unless @ret.member? ret
          raise TypeException, "Type error: excepting (return) #{@ret}, got #{ret.inspect}"
        end
      }
    end
    
    def to_s  # :nodoc:
      if @block
        "[ (#{@args.join(', ')}) {#{@block}} -> #{@ret} ]"
      elsif @args
        "[ (#{@args.join(', ')}) -> #{@ret} ]"
      else
        "[ () -> #{@ret} ]"
      end
    end

    def eql?(other)
      self == other
    end

    # Return +true+ if +other+ is the same type
    def ==(other)
      return (other.instance_of? MethodType) &&
        (other.args == args) &&
        (other.block == block) &&
        (other.ret == ret)
    end

    def hash  # :nodoc:
      h = (37 + @ret.hash) * 41 + @args.hash
      h = h * 31 + @block.hash if @block
      return h
    end
  end
end

