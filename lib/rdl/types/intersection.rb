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
        if t.nil_type?
          next
        elsif t.instance_of? IntersectionType
          ts.concat t.types
        else
          raise RuntimeError, "Attempt to create intersection type with non-type" unless t.is_a? Type
          ts << t
        end
      }
      ts.sort! { |a,b| a.object_id <=> b.object_id }
      ts.uniq!

      return $__rdl_nil_type if ts.size == 0
      return ts[0] if ts.size == 1

      t = @@cache[ts]
      return t if t
      t = IntersectionType.__new__(ts)
      return (@@cache[ts] = t) # assignment evaluates to t
    end

    def initialize(types)
      @types = types
      super()
    end

    def to_s  # :nodoc:
      return "(#{@types.map { |t| t.to_s }.join(' and ')})"
    end

    def ==(other)  # :nodoc:
      return false if other.nil?
      other = other.type if other.is_a? DependentArgType
      other = other.canonical
      return (other.instance_of? IntersectionType) && (other.types == @types)
    end

    alias eql? ==

    def match(other)
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return false if @types.length != other.types.length
      @types.all? { |t| other.types.any? { |ot| t.match(ot) } }
    end

    def member?(obj, *args)
      @types.all? { |t| t.member?(obj, *args) }
    end

    def instantiate(inst)
      return IntersectionType.new(*(@types.map { |t| t.instantiate(inst) }))
    end

    def hash  # :nodoc:
      return 47 + @types.hash
    end
  end
end
