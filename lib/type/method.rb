require_relative './type'

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
      @args = args
      @block = block
      @ret = ret
      super
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

    # Return +true+ if +other+ is the same type
    def ==(other)
      return other.instance_of? MethodType &&
        other.args == args &&
        other.block == block &&
        other.ret == ret
    end

    def hash  # :nodoc:
      h = (37 + @ret.hash) * 41 + @args.hash
      h = h * 31 + @block.hash if @block
      return h
    end
  end
end
