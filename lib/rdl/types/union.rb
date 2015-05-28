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
      if not t
        t = UnionType.__new__(ts)
        @@cache[ts] = t
      end
      return t
    end

    def initialize(types)
      @types = types
      super()
    end

    def to_s  # :nodoc:
      "(#{@types.to_a.join(' or ')})"
    end

    def le(other, h={})
      if not self.get_vartypes.empty?
        raise RDL::TypeComparisonException, "UnionType#le's caller cannot contain VarTypes"
      end

      if other.instance_of? VarType
        if h.keys.include? other.name
          h[other.name] = UnionType.new(h[other.name], self)
        else
          h[other.name] ||= self
        end

        true
      else
        @types.all? {|t| t.le(other, h)}
      end
    end

    def eql?(other)
      self == other
    end

    def ==(other)  # :nodoc:
      return false if not other.instance_of? UnionType
      return true if other.types == @types
      return false if @types.size != other.types.size
      return (a == b)
    end

    def hash  # :nodoc:
      41 + @types.hash
    end
  end
end
