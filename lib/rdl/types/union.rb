module RDL::Type
  class UnionType < Type
    attr_reader :types

    class << self
      alias :__new__ :new
    end

    def self.new(*types)
      return RDL::Globals.types[:bot] if types.size == 0
      ts = []
      # flatten nested unions, check that all args are types
      types.each { |t|
        if t.instance_of? UnionType
          ts.concat t.types
        else
          raise RuntimeError, "Attempt to create union type with non-type" unless t.is_a?(Type) || t.nil?
          raise RuntimeError, "Attempt to create union with optional type" if t.is_a? OptionalType
          raise RuntimeError, "Attempt to create union with vararg type" if t.is_a? VarargType
          raise RuntimeError, "Attempt to create union with annotated type" if t.is_a? AnnotatedArgType
          ts << t if t
        end
      }
      return ts[0] if ts.size == 1
      return UnionType.__new__(ts)
    end

    def initialize(types)
      @types = types
      @canonical = false
      @canonicalized = false
      @hash = 41 + @types.hash # don't rehash if @types changes
      super()
    end

    def canonical
      canonicalize!
      return @canonical if @canonical
      return self
    end

    def canonicalize!
      return if @canonicalized
      # for any type such that a supertype is already in ts, set its position to nil
      for i in 0..(@types.length-1)
        for j in (i+1)..(@types.length-1)
          next if (@types[j].nil?) || (@types[i].nil?)
          (@types[i] = nil; break) if @types[i] <= @types[j]
          (@types[j] = nil) if @types[j] <= @types[i]
        end
      end
      @types.delete(nil) # eliminate any "deleted" elements
      @types.sort! { |a, b| a.object_id <=> b.object_id } # canonicalize order
      @types.uniq!
      @canonical = @types[0] if @types.size == 1
      @canonicalized = true
    end

    def to_s  # :nodoc:
      return @canonical.to_s if @canonical
      return "#{@types.map { |t| t.to_s }.join(' or ')}"
    end

    def ==(other)  # :nodoc:
      return false if other.nil?
      canonicalize!
      return @canonical == other if @canonical
      other = other.canonical
      return false unless other.instance_of? UnionType
      other.canonicalize!
      return false unless @types.length == other.types.length
      return @types.all? { |t| other.types.any? { |ot| t == ot } }
    end

    alias eql? ==

    def match(other)
      canonicalize!
      return @canonical.match(other) if @canonical
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return false unless other.instance_of? UnionType
      return false if @types.length != other.types.length
      @types.all? { |t| other.types.any? { |ot| t.match(ot) } }
    end

    def <=(other)
      return Type.leq(self, other)
    end

    def leq_inst(other, inst=nil, ileft=true)
      canonicalize!
      return @canonical.leq_inst(other, inst, ileft) if @canonical
      other = other.type if other.is_a? DependentArgType
      other = other.canonical
      if inst && !ileft && other.is_a?(VarType)
        return leq_inst(inst[other.name], inst, ileft) if inst[other.name]
        inst.merge!(other.name => self)
        return true
      end
      return @types.all? { |t| t.leq_inst(other, inst, ileft) }
    end

    def member?(obj, *args)
      canonicalize!
      return @canonical.member?(obj, *args) if @canonical
      @types.any? { |t| t.member?(obj, *args) }
    end

    def instantiate(inst)
      canonicalize!
      return @canonical.instantiate(inst) if @canonical
      return UnionType.new(*(@types.map { |t| t.instantiate(inst) }))
    end

    def widen
      return @canonical.widen if @canonical
      sing_types = []
      non_sing_types = []
      @types.each { |t|
        case t
        when SingletonType
          sing_types << t.nominal
        when TupleType
          sing_types << t.promote
        when FiniteHashType
          sing_types << t.promote
        else
          non_sing_types << t
        end
      }
      UnionType.new(*sing_types, *non_sing_types).canonical
    end

    def copy
      UnionType.new(*@types.map { |t| t.copy })
    end
=begin
    def self.widened_type(u)
      return u unless u.instance_of?(UnionType)
      nominal_class = nil
      @types.each { |t|
        return u if !t.instance_of?(SingletonType)
        if nominal_class.nil?
          nominal_class = t.nominal ## first type
        elsif nominal_class <= t.nominal
          nominal_class = t.nominal ## update to more general class (or just stay the same)
        else
          return u ## found a case with differing singleton classes, can't widen
        end
      }
      nominal_class
    end
=end
    def hash  # :nodoc:
      return @hash
    end
  end
end
