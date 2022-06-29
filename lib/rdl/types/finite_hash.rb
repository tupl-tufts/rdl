require_relative 'type'

module RDL::Type
  # Type for finite maps from values to types; values are compared with ==.
  # These are used for "named" arguments in Ruby, in which case the values are symbols.
  # Finite hashes can also have a "rest" type (okay, they're not exactly finite in this case...)
  # which is treated as a hash from Symbol to the type.
  class FiniteHashType < Type
    attr_accessor :elts
    attr_reader :rest
    attr_reader :the_hash # either nil or hash type if self has been promoted to hash
    attr_accessor :ubounds  # upper bounds this tuple has been compared with using <=
    attr_accessor :lbounds  # lower bounds...
    attr_accessor :default # For hashes created with Hash.new, gives the default type to return for non-existent keys
    attr_accessor :solution # to store the solution from inference

    # [+ elts +] is a map from keys to types
    def initialize(elts, rest, default: nil)
      elts.each { |k, t|
        raise RuntimeError, "Got #{t.inspect} for key #{k} where Type expected" unless t.is_a? Type
        raise RuntimeError, "Type may not be annotated or vararg" if (t.instance_of? AnnotatedArgType) || (t.instance_of? VarargType)
      }
      @elts = elts
      @rest = rest
      @the_hash = nil
      @cant_promote = false
      @ubounds = []
      @lbounds = []
      @default = default
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

    def match(other, type_var_table = {})
      return @the_hash.match(other, type_var_table) if @the_hash

      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return false unless other.instance_of? FiniteHashType

      return false unless ((@rest.nil? && other.rest.nil?) ||
                           (!@rest.nil? && !other.rest.nil? && @rest.match(other.rest, type_var_table)))

      return @elts.length == other.elts.length &&
        @elts.all? { |k, v| other.elts.has_key?(k) && v.match(other.elts[k], type_var_table) }
    end

    def promote(key=nil, value=nil)
      return false if @cant_promote
      #domain_type = (@elts.empty? && !key) ? RDL::Type::VarType.new({ name: :k, cls: Hash, to_infer: true }) : UnionType.new(*(@elts.keys.map { |k| NominalType.new(k.class) }), key)
      if @elts.empty? && !key
        domain_type = RDL::Type::VarType.new(:k)
      else
        domain_type = UnionType.new(*@elts.keys.map { |k| if k.is_a?(Type) then k else NominalType.new(k.class) end }, key)
      end
      #range_type = (@elts.empty? && !value) ? RDL::Type::VarType.new({ name: :v, cls: Hash, to_infer: true }) : UnionType.new(*@elts.values, value)
      if @elts.empty? && !value
        range_type = RDL::Type::VarType.new(:v)
      else
        range_type = UnionType.new(*@elts.values.map { |v| if v.is_a?(OptionalType) then v.type else v end }, value)
      end

      if @rest
        domain_type = UnionType.new(domain_type, RDL::Globals.types[:symbol])
        range_type = UnionType.new(range_type, @rest)
      end
      if RDL::Config.instance.promote_widen
        case range_type
        when RDL::Type::SingletonType
          range_type = range_type.nominal if range_type.val
        when RDL::Type::UnionType
          range_type = range_type.widen
        end
      end
      x = GenericType.new(RDL::Globals.types[:hash], domain_type.canonical, range_type.canonical)
      return x#GenericType.new(RDL::Globals.types[:hash], domain_type.canonical, range_type.canonical)
    end

    ### [+ key +] is type to add to promoted key types
    ### [+ value +] is type to add to promoted value types
    def promote!(key=nil, value=nil)
      hash = promote(key, value)
      return hash if !hash
      @the_hash = hash
      # same logic as Tuple
      return check_bounds
    end

    def cant_promote!
      raise RuntimeError, "already promoted!" if @the_hash
      @cant_promote = true
    end

    def check_bounds(no_promote=false)
      return (@lbounds.all? { |lbound| lbound.<=(self, no_promote) }) && (@ubounds.all? { |ubound| self.<=(ubound, no_promote) })
    end

    def <=(other, no_constraint=false, ast: nil)
      return Type.leq(self, other, no_constraint: no_constraint, ast: ast)
    end

    def member?(obj, *args)
      return @the_hash.member(obj, *args) if @the_hash
      t = RDL::Util.rdl_type obj
      return t <= self if t
      right_elts = @elts.clone # shallow copy

      return true if obj.nil?
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
      #return FiniteHashType.new(Hash[@elts.map { |k, t| [k, t.instantiate(inst)] }], (if @rest then @rest.instantiate(inst) end))
      @elts = Hash[@elts.map { |k, t| [k, t.instantiate(inst)] }]
      @rest = @rest.instantiate(inst) if @rest
      self
    end

    def widen
      return @the_hash.widen if @the_hash
      #return FiniteHashType.new(Hash[@elts.map { |k, t| [k, t.widen] }], (if @rest then @rest.widen end))
      @elts = Hash[@elts.map { |k, t| [k, t.widen] }]
      @rest = @rest.widen if @rest
      self
    end

    def copy
      rest = @rest.copy if @rest
      return FiniteHashType.new(Hash[@elts.map { |k,t| [k, t.copy] }], rest)
    end

    def hash
      # note don't change hash value if @the_hash becomes non-nil
      return 229 * @elts.hash * @rest.hash
    end
  end
end
