require_relative 'type'
require_relative 'native'

module RDL::Type

  # A type representing some method or block. MethodType has subcomponent
  # types for arguments (zero or more), block (optional) and return value
  # (exactly one).
  class MethodType < Type
    attr_reader :args
    attr_reader :block
    attr_reader :ret
    attr_accessor :parameters
    attr_accessor :type_variables

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
      @parameters = []
      @type_variables = []
      super()
    end

    def map
      new_arg_types = RDL::NativeArray.new

      args.each {|p|
        new_arg_types << (yield p)
      }

      MethodType.new(new_arg_types,
                     block.nil? ? nil : (yield block),
                     (yield ret)
                     )
    end

    def each
      yield ret
      yield block if block
      args.each { |a| yield a }
    end

    def parameterized?
      not parameters.empty?
    end
    
    def contains_free_variables?
      not type_variables.empty?
    end
    
    def free_vars
      type_variables.map { |v| v.name }
    end
        
    def instantiate(type_replacement = nil)
      if type_replacement.nil? and not parameterized?
        return self
      end

      free_variables = []

      if not type_replacement.nil?
        duped = false

        parameters.each {|t_param|
          unless type_replacement.include?(t_param.symbol)
            if not duped
              type_replacement = type_replacement.dup
              duped = true
            end

            new_tv = TypeVariable.new(t_param.symbol, self)
            type_replacement[t_param.symbol] = new_tv
            free_variables.push(new_tv)
          end
        }
      else
        type_replacement = RDL::NativeHash.new

        parameters.map {|t_param|
          new_tv = TypeVariable.new(t_param.symbol, self)
          type_replacement[t_param.symbol] = new_tv
          free_variables.push(new_tv)
        }
      end

      to_return = self.map {|t|
        t.replace_parameters(type_replacement)
      };

      to_return.type_variables = free_variables
      
      return to_return
    end    

    # Return true if +self+ is a subtype of +other+. This follows the usual
    # semantics of TopType and BottomType. If +other+ is also an instance of
    # ProceduralType, return true iff all of the following hold:
    # 1. +self+'s return type is a subtype of +other+'s (covariant).
    # 2. +other+'s block type is a subtype of +self+'s (contravariant.
    # 3. Both types have blocks, or neither type does.
    # 4. Both types have the same number of arguments, and +other+'s
    #    arguments are subtypes of +self+'s (contravariant).
    def <=(other)
      case other
      when MethodType
        # Check number of arguments, presence of blocks, etc.
        return false unless compatible_with?(other)
        
        # Return types are covariant.
        return false unless @ret <= other.ret
        # Block types must both exist and are contravariant.
        if @block
          return false unless other.block <= @block
        end
        
        # Arguments are contravariant.
        @args.zip(other.args).each do |a, b|
          return false unless b <= a
        end

        return true
      when TupleType
        false
      else
        super(other)
      end
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
      to_return = RDL::NativeHash.new()
      to_return[:required] = RDL::NativeArray[0,0]
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

    private
    
    # Return true iff all of the following are true:
    # 1. +other+ is a ProceduralType.
    # 2. +other+ has the same number of arguments as +self+.
    # 3. +self+ and +other+ both have a block type, or neither do.
    def compatible_with?(other)
      return false unless other.instance_of?(MethodType)
      return false unless @args.size() == other.args.size()
      if @block
        return false unless other.block
      else
        return false if other.block
      end
      return true
    end
  end
end

