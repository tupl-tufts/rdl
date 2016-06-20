require_relative 'type'

module RDL::Type
  class UnionType < Type
    attr_reader :types

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(*types)
      ts = []
      types.each { |t|
        if t.instance_of? TopType
          ts = [t]
          break
        elsif t.instance_of? UnionType
          ts.concat t.types
        else
          raise RuntimeError, "Attempt to create union type with non-type" unless t.is_a? Type
          ts << t
        end
      }

      ts.sort! { |a, b| a.object_id <=> b.object_id }
      ts.uniq!

      if ts.member? $__rdl_nil_type
        # nil shouldn't be in union *unless* there are only otherwise singleton types, since
        # nil is not a subtype of singleton types
        ts.delete $__rdl_nil_type unless ts.all? { |t| t.is_a? SingletonType }
      end

      return $__rdl_nil_type if ts.size == 0
      return ts[0] if ts.size == 1

      t = @@cache[ts]
      return t if t
      t = UnionType.__new__(ts)
      return (@@cache[ts] = t) # assignment evaluates to t
    end

    def initialize(types)
      @types = types
      super()
    end

    def to_s  # :nodoc:
      "#{@types.map { |t| t.to_s }.join(' or ')}"
    end

    def eql?(other)
      self == other
    end

    def ==(other)  # :nodoc:
      return (other.instance_of? UnionType) && (other.types == @types)
    end

    def match(other)
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return false if @types.length != other.types.length
      @types.all? { |t| other.types.any? { |ot| t.match(ot) } }
    end

    def <=(other)
      @types.all? { |t| t <= other }
    end

    def member?(obj, *args)
      @types.any? { |t| t.member?(obj, *args) }
    end

    def instantiate(inst)
      return UnionType.new(*(@types.map { |t| t.instantiate(inst) }))
    end

    def hash  # :nodoc:
      41 + @types.hash
    end
  end
end
