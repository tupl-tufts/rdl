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
        if t.instance_of? NilType
          next
        elsif t.instance_of? TopType
          ts = [t]
          break
        elsif t.instance_of? UnionType
          ts.concat t.types
        else
          ts << t
        end
      }

      ts.sort! { |a,b| a.object_id <=> b.object_id }      
      ts.uniq!

      return NilType.new if ts.size == 0
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
      "(#{@types.to_a.join(' or ')})"
    end

    def eql?(other)
      self == other
    end

    def ==(other)  # :nodoc:
      return (other.instance_of? UnionType) && (other.types == @types)
    end

    def member?(obj)
      @types.any? { |t| t.member? obj }
    end
    
    def hash  # :nodoc:
      41 + @types.hash
    end
  end
end
