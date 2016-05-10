require_relative 'type'

module RDL::Type
  # A specialized GenericType for tuples, i.e., fixed-sized arrays
  class TupleType < Type
    attr_reader :params

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(*params)
      t = @@cache[params]
      return t if t
      raise RuntimeError, "Attempt to create tuple type with non-type param" unless params.all? { |p| p.is_a? Type }
      t = TupleType.__new__(params)
      return (@@cache[params] = t) # assignment evaluates to t
    end

    def initialize(params)
      @params = params
      super()
    end

    def to_s
      "[#{@params.map { |t| t.to_s }.join(', ')}]"
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (other.instance_of? TupleType) && (other.params == @params)
    end

    def match(other)
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return @params.length == other.params.length && @params.zip(other.params).all? { |t,o| t.match(o) }
    end

    def <=(other)
      return true if other.instance_of? TopType
      return self == other
      # Subtyping with Array not allowed
      # All positions of Tuple are invariant since tuples are mutable
    end

    def member?(obj, *args)
      t = RDL::Util.rdl_type obj
      return t <= self if t
      return false unless obj.instance_of?(Array) && obj.size == @params.size
      return @params.zip(obj).all? { |formal, actual| formal.member?(actual, *args) }
    end

    def instantiate(inst)
      TupleType.new(*@params.map { |t| t.instantiate(inst) })
    end

    def hash
      73 * @params.hash
    end
  end
end
