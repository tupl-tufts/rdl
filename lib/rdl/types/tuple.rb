require_relative 'type'

module RDL::Type
  # A specialized GenericType for tuples, i.e., fixed-sized arrays
  class TupleType < Type
    attr_reader :params
    attr_reader :array

    # no caching because array might be mutated
    def initialize(*params)
      raise RuntimeError, "Attempt to create tuple type with non-type param" unless params.all? { |p| p.is_a? Type }
      @params = params
      @array = nil # emphasize initially this is a tuple, not an array
      super()
    end

    def to_s
      return @array.to_s if @array
      return "[#{@params.map { |t| t.to_s }.join(', ')}]"
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (@array == other) if @array
      return (other.instance_of? TupleType) && (other.params == @params)
    end

    def match(other)
      return @array.match(other) if @array
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return @params.length == other.params.length && @params.zip(other.params).all? { |t,o| t.match(o) }
    end

    def <=(other)
      return @array <= other if @array
      return true if other.instance_of? TopType
      return self == other
      # Subtyping with Array not allowed
      # All positions of Tuple are invariant since tuples are mutable
    end

    def member?(obj, *args)
      return @array.member?(obj, *args) if @array
      t = RDL::Util.rdl_type obj
      return t <= self if t
      return false unless obj.instance_of?(Array) && obj.size == @params.size
      return @params.zip(obj).all? { |formal, actual| formal.member?(actual, *args) }
    end

    def instantiate(inst)
      return @array.instantiate(inst) if @array
      return TupleType.new(*@params.map { |t| t.instantiate(inst) })
    end

    def hash
      # note don't change hash value if @array becomes non-nil
      73 * @params.hash
    end
  end
end
