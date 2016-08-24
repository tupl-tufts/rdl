require_relative 'type'

module RDL::Type
  # Type for finite maps from values to types; values are compared with ==.
  # These are used for "named" arguments in Ruby, in which case the values are symbols.
  # Finite hashes can also have a "rest" type (okay, they're not exactly finite in this case...)
  # which is treated as a hash from Symbol to the type.
  class FiniteHashType < Type
    attr_reader :elts
    attr_reader :rest
    attr_reader :the_hash # either nil or hash type if self has been promoted to hash
    attr_accessor :ubounds  # upper bounds this tuple has been compared with using <=
    attr_accessor :lbounds  # lower bounds...

    # [+ elts +] is a map from keys to types
    def initialize(elts, rest)
      elts.each { |k, t|
        raise RuntimeError, "Got #{t.inspect} where Type expected" unless t.is_a? Type
        raise RuntimeError, "Type may not be annotated or vararg" if (t.instance_of? AnnotatedArgType) || (t.instance_of? VarargType)
      }
      @elts = elts
      @rest = rest
      @the_hash = nil
      @cant_promote = false
      @ubounds = []
      @lbounds = []
      super()
    end

    def canonical
      return @the_hash if @the_hash
      return self
    end

    def to_s
      return @the_hash.to_s if @the_hash
      return "{ " + @elts.map { |k, t| k.to_s + ": " + t.to_s }.join(', ') + (if @rest then ", **" + @rest.to_s else "" end) + " }"
    end

    def ==(other) # :nodoc:
      return false if other.nil?
      return (@the_hash == other) if @the_hash
      other = other.canonical
      return (other.instance_of? FiniteHashType) && (other.elts == @elts) && (other.rest == @rest)
    end

    alias eql? ==

    def match(other)
      return @the_hash.match(other) if @the_hash
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return false unless ((@rest.nil? && other.rest.nil?) ||
                           (!@rest.nil? && !other.rest.nil? && @rest.match(other.rest)))
      return (@elts.length == other.elts.length &&
              @elts.all? { |k, v| (other.elts.has_key? k) && (v.match(other.elts[k]))})
    end

    def promote!
      return false if @cant_promote
      # TODO look at key types
      domain_type = UnionType.new(*(@elts.keys.map { |k| NominalType.new(k.class) }))
      range_type = UnionType.new(*@elts.values)
      if @rest
        domain_type = UnionType.new(domain_type, $__rdl_symbol_type)
        range_type = UnionType.new(range_type, @rest)
      end
      @the_hash = GenericType.new($__rdl_hash_type, domain_type, range_type)
      # same logic as Tuple
      return (@lbounds.all? { |lbound| lbound <= self }) && (@ubounds.all? { |ubound| self <= ubound })
    end

    def cant_promote!
      raise RuntimeError, "already promoted!" if @the_hash
      @cant_promote = true
    end

    def <=(other)
      return Type.leq(self, other)
    end

    def member?(obj, *args)
      return @the_hash.member(obj, *args) if @the_hash
      t = RDL::Util.rdl_type obj
      return t <= self if t
      right_elts = @elts.clone # shallow copy

      return false unless obj.instance_of? Hash

      # Check that every mapping in obj exists in @map and matches the type
      obj.each_pair { |k, v|
        if @elts.has_key? k
          t = @elts[k]
          t = t.type if t.instance_of? OptionalType
          return false unless t.member? v
          right_elts.delete k
        else
          return false unless @rest && @rest.member?(v)
        end
      }

      # Check that any remaining types are optional
      right_elts.each_pair { |k, vt|
        return false unless vt.instance_of? OptionalType
      }

      return true
    end

    def instantiate(inst)
      return @the_hash.instantiate(inst) if @the_hash
      return FiniteHashType.new(Hash[@elts.map { |k, t| [k, t.instantiate(inst)] }], (if @rest then @rest.instantiate(inst) end))
    end

    def hash
      # note don't change hash value if @the_hash becomes non-nil
      return 229 * @elts.hash * @rest.hash
    end
  end
end
