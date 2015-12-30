require_relative 'type'

module RDL::Type
  # A specialized GenericType for fixed-sized maps from values to
  # types, for "named" arguments in Ruby. Values are compared with ==
  # to see if they match.
  class FiniteHashType < Type
    attr_reader :elts

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(elts)
      t = @@cache[elts]
      return t if t
      t = FiniteHashType.__new__(elts)
      return (@@cache[elts] = t) # assignment evaluates to t
    end

    # [+elts+] is a map from keys to types
    def initialize(elts)
      elts.each { |k, t|
        raise RuntimeError, "Got #{t.inspect} where Type expected" unless t.is_a? Type
        raise RuntimeError, "Type may not be annotated or vararg" if (t.instance_of? AnnotatedArgType) || (t.instance_of? VarargType)
      }
      @elts = elts
      super()
    end

    def to_s
      "{" + @elts.map { |k, t| k.to_s + ": " + t.to_s }.join(', ') + "}"
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (other.instance_of? FiniteHashType) && (other.elts == @elts)
    end

    def match(other)
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return (@elts.length == other.elts.length &&
              @elts.all? { |k, v| (other.elts.has_key? k) && (v.match(other.elts[k]))})
    end

    def <=(other)
      return true if other.instance_of? TopType
      return self == other
      # Subtyping with Hash not allowed
      # All positions of HashTuple are invariant since tuples are mutable
    end

    def member?(obj, *args)
      t = RDL::Util.rdl_type obj
      return t <= self if t
      rest = @elts.clone # shallow copy

      return false unless obj.instance_of? Hash

      # Check that every mapping in obj exists in @map and matches the type
      obj.each_pair { |k, v|
        return false unless @elts.has_key?(k)
        t = @elts[k]
        t = t.type if t.instance_of? OptionalType
        return false unless t.member?(v)
        rest.delete(k)
      }

      # Check that any remaining types are optional
      rest.each_pair { |k, t|
        return false unless t.instance_of? OptionalType
      }
    end

    def instantiate(inst)
      FiniteHashType.new(Hash[@elts.map { |k, t| [k, t.instantiate(inst)] }])
    end

    def hash
      h = 229 * @elts.hash
    end
  end
end
