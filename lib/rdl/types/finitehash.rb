require_relative 'type'

module RDL::Type
  # A specialized GenericType for fixed-sized maps from values to
  # types, for "named" arguments in Ruby. Values are compared with ==
  # to see if they match.
  class FiniteHashType < Type
    attr_reader :map

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(map)
      t = @@cache[map]
      return t if t
      t = FiniteHashType.__new__(map)
      return (@@cache[map] = t) # assignment evaluates to t
    end

    def initialize(map)
      map.each { |k, t|
        raise RuntimeError, "Got #{t.inspect} where Type expected" unless t.is_a? Type
        raise RuntimeError, "Type may not be annotated or vararg" if (t.instance_of? AnnotatedArgType) || (t.instance_of? VarargType)
      }
      @map = map
      super()
    end

    def to_s
      "{" + @map.map { |k, t| k.to_s + ": " + t.to_s }.join(', ') + "}"
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (other.instance_of? FiniteHashType) && (other.map == @map)
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
      rest = @map.clone # shallow copy

      return false unless obj.instance_of? Hash
      
      # Check that every mapping in obj exists in @map and matches the type
      obj.each_pair { |k, v|
        return false unless @map.has_key?(k)
        t = @map[k]
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
      FiniteHashType.new(Hash[@map.map { |k, t| [k, t.instantiate(inst)] }])
    end
    
    def hash
      h = 229 * @map.hash
    end
  end
end
