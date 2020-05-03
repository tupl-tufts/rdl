require_relative 'type'

module RDL::Type
  class IntersectionType < Type
    attr_reader :types

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(*types)
      ts = []
      types.each { |t|
        if t == RDL::Globals.types[:bot]
          next
        elsif t.instance_of? IntersectionType
          ts.concat t.types
        else
          raise RuntimeError, "Attempt to create intersection type with non-type #{t.inspect}" unless t.is_a? Type
          ts << t
        end
      }
      ts.sort! { |a,b| a.object_id <=> b.object_id }
      ts.uniq!

      return RDL::Globals.types[:bot] if ts.size == 0
      return ts[0] if ts.size == 1

      t = @@cache[ts]
      return t if t
      t = IntersectionType.__new__(ts)
      return (@@cache[ts] = t) # assignment evaluates to t
    end

    def initialize(types)
      @types = types
      @canonical = false
      @canonicalized = false
      super()
    end

    def canonical
      canonicalize!
      return @canonical if @canonical
      return self
    end

    def canonicalize!
      return if @canonicalized
      # for any type such that a subtype is already in ts, set its position to nil
      @types.map! { |t| t.canonical }
      for i in 0..(@types.length-1)
        for j in i+1..(@types.length-1)
          next if (@types[j].nil?) || (@types[i].nil?) || (@types[i].is_a?(VarType)) || (@types[j].is_a?(VarType))|| @types[i].is_a?(ChoiceType) || @types[j].is_a?(ChoiceType)
          (@types[j] = nil; break) if Type.leq(@types[i], @types[j], nil, true, [])
          (@types[i] = nil) if Type.leq(@types[j], @types[i], nil, true, [])
        end
      end
      @types.delete(nil)
      @types.sort! { |a, b| a.object_id <=> b.object_id } # canonicalize order
      @types.uniq!
      @canonical = @types[0] if @types.size == 1
      @canonicalized = true
    end

    def drop_vars!
      @types.map! { |t|
        if t.is_a?(UnionType) then
          t.drop_vars! unless t.types.all? { |t| t.is_a?(VarType) }
          if t.types.empty? then nil else t end
        else t
        end }
      @types.delete(nil)
      @types.reject! { |t| t.is_a? VarType }
      self
    end

    def drop_vars
      return self if @types.all? { |t| t.is_a? VarType } ## when all are VarTypes, we have nothing concrete to reduce to, so don't want to drop vars
      new_types = []
      for i in 0..(@types.length-1)
        if @types[i].is_a?(UnionType)
          new_types << @types[i].drop_vars.canonical
        else
          new_types << @types[i] unless @types[i].is_a? VarType
        end
      end
      RDL::Type::IntersectionType.new(*new_types).canonical
    end

    def to_s  # :nodoc:
      return "(#{@types.map { |t| t.to_s }.sort.join(' and ')})"
    end

    def ==(other)  # :nodoc:
      return false if other.nil?
      other = other.type if other.is_a? DependentArgType
      other = other.canonical
      return (other.instance_of? IntersectionType) && (other.types == @types)
    end

    alias eql? ==

    def match(other, type_var_table = {})
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return false unless other.instance_of? IntersectionType
      return false if @types.length != other.types.length

      @types.all? { |t| other.types.any? { |ot| t.match(ot, type_var_table) } }
    end

    def member?(obj, *args)
      @types.all? { |t| t.member?(obj, *args) }
    end

    def instantiate(inst)
      return IntersectionType.new(*(@types.map { |t| t.instantiate(inst) }))
    end

    def widen
      return IntersectionType.new(*(@types.map { |t| t.widen }))
    end

    def copy
      return IntersectionType.new(*(@types.map { |t| t.copy }))
    end

    def hash  # :nodoc:
      return 47 + @types.hash
    end
  end
end
