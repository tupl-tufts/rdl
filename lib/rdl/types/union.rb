require_relative './type'

module RDL::Type
  class UnionType < Type
    attr_reader :types

    @@cache = RDL::NativeHash.new

    class << self
      alias :__new__ :new
    end

    def self.new(*types)
      ts = []
      types.each { |t|
        if t.instance_of? NilType
          next
        elsif t.instance_of? UnionType
          ts.concat t.types
        else
          ts << t
        end
      }

      # this does not work with object_id (i.e. rake vs ruby -Ilib ...)
      # fix is added in the == method
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

    def each
      types.each {|t| yield t}
    end

    def map
      ts = types.map { |t| yield t }
      UnionType.new(*ts)
    end

    def to_s  # :nodoc:
      "(#{@types.to_a.join(' or ')})"
    end

    def <=(other)
      @types.all? do |t|
        t <= other
      end
    end

    def eql?(other)
      self == other
    end

    def ==(other)  # :nodoc:
      return false if not other.instance_of? UnionType
      return true if other.types == @types
      return false if @types.size != other.types.size

      # this step is necessary because of some really weird error with 
      # sorting with object_id in self.new.
      # rake test and ruby -Ilib test/... were having different results
      a = Set.new @types
      b = Set.new other.types
      a == b
    end

    def hash  # :nodoc:
      41 + @types.hash
    end
  end
end
