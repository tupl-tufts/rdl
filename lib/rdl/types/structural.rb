require_relative 'type'

module RDL::Type
  class StructuralType < Type
    attr_reader :map

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(map)
      t = @@cache[map]
      return t if t
      t = StructuralType.__new__(map)
      return (@@cache[map] = t) # assignment evaluates to t
    end

    # Create a new StructuralType.
    #
    # [+map+] Map from method names as symbols to their types.
    def initialize(map)
      map.each { |m, t|
        raise RuntimeError, "Method names in StructuralType must be symbols" unless m.instance_of? Symbol
        raise RuntimeError, "Got #{t.class} where MethodType expected" unless t.instance_of? MethodType
      }
      @map = map
      super()
    end

    def to_s  # :nodoc:
      "[ " + @map.each_pair.map { |m, t| "#{m.to_s}: #{t.to_s}" }.sort.join(", ") + " ]"
    end

    def eql?(other)
      self == other
    end

    def ==(other)  # :nodoc:
      return (other.instance_of? StructuralType) && (other.map == @map)
    end

    def hash  # :nodoc:
      @map.hash
    end
  end
end
