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
      @args = args
      raise "block must be MethodType" unless (not block) or (block.instance_of? MethodType)
      @block = block
      @ret = ret
      super()
    end

    def map
      new_arg_types = []

      args.each {|p|
        new_arg_types << (yield p)
      }

      MethodType.new(new_arg_types,
                     block.nil? ? nil : (yield block),
                     (yield ret)
                     )
    end

    def le(other, h={})
      raise Exception, "should not be called"
    end

    def each
      yield ret
      yield block if block
      args.each { |a| yield a }
    end

    #returns the minimum number of arguments required by this function
    # i.e. a count of the required arguments.
    def min_args
      p_layout = parameter_layout
      p_layout[:required][0] + p_layout[:required][1]
    end
    
    #gets the maximum number of arguments this function can take. If there is a rest
    # argument, this function returns -1 (unlimited)
    def max_args
      p_layout = parameter_layout
      if p_layout[:rest]
        -1
      else
        min_args + p_layout[:opt]
      end
    end

    # gets a hash describing the layout of the arguments to a function
    # the requied member is a two member array that indicates the number of
    # required arugments at the beginning of the parameter list and the number
    # at the end respectively. The opt member indicates the number of optional
    # arguments. If rest is true, then there is a rest argument.
    # For reference, parameter lists are described by the following grammar
    # required*, optional*, rest?, required*
    def parameter_layout
      return @param_layout_cache if defined? @param_layout_cache
      a_list = args + [nil]
      to_return = {}
      to_return[:required] = [0,0]
      to_return[:rest] =  false
      to_return[:opt] = 0

      def param_type(arg_type)
        case arg_type
        when NilClass
          :end
        when OptionalType
          :opt
        when VarargType
          :rest
        else
          :req
        end
      end
      
      counter = 0
      i = 0
      p_type = param_type(a_list[i])
      
      while p_type == :req
        counter+=1
        i+=1
        p_type = param_type(a_list[i])
      end
      
      to_return[:required][0] = counter
      counter = 0
      
      while p_type == :opt
        counter+=1
        i+=1
        p_type = param_type(a_list[i])
      end
      
      to_return[:opt] = counter
      
      if p_type == :rest
        to_return[:rest] = true
        i+=1
        p_type = param_type(a_list[i])
      end
      
      counter = 0
      
      while p_type == :req
        counter+=1
        i+=1
        p_type = param_type(a_list[i])
      end
      
      to_return[:required][1] = counter
      raise "Invalid argument string detected" unless p_type == :end
      @param_layout_cache = to_return
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

