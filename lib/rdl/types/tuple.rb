require_relative 'type'

module RDL::Type
  # A specialized GenericType for tuples, i.e., fixed-sized arrays
  class TupleType < Type
    attr_reader :params
    attr_reader :array  # either nil or array type if self has been promoted to array
    attr_accessor :ubounds # upper bounds this tuple has been compared with using <=
    attr_accessor :lbounds # lower bounds...

    @@array_type = nil

    # no caching because array might be mutated
    def initialize(*params)
      raise RuntimeError, "Attempt to create tuple type with non-type param" unless params.all? { |p| p.is_a? Type }
      @params = params
      @array = nil # emphasize initially this is a tuple, not an array
      @ubounds = []
      @lbounds = []
      @@array_type = NominalType.new(Array) unless @@array_type
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
      other = other.array if other.instance_of?(TupleType) && other.array
      if other.instance_of? TupleType
        # Tuples are immutable, so covariant subtyping allowed
        return false unless @params.length == other.params.length
        return false unless @params.zip(other.params).all? { |left, right| left <= right }
        # subyping check passed
        ubounds << other
        other.lbounds << self
        return true
      end
      return self == other if other.instance_of? TupleType
      if (other.instance_of? GenericType) && (other.base == @@array_type)
        @array = GenericType.new(@@array_type, UnionType.new(*@params))
        return (self <= other) && (@lbounds.all? { |lbound| lbound <= self }) && (@ubounds.all? { |ubound| self <= ubound })
      end
      return false
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
