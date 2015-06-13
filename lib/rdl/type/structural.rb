require_relative 'type'

module RDL::Type
  class StructuralType < Type
    attr_reader :methods

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(methods)
      t = @@cache[methods]
      if not t
        t = StructuralType.__new__(methods)
        @@cache[methods] = t
      end
      return t
    end

    # Create a new StructuralType.
    #
    # [+methods+] Map from method names as symbols to their types.
    def initialize(methods)
      @methods = methods
      super()
    end

    def to_s  # :nodoc:
      "[ " + @methods.to_a.map { |k,v| "#{k}: #{v}" }.sort.join(", ") + " ]"
    end

    def eql?(other)
      self == other
    end

    def ==(other)  # :nodoc:
      return (other.instance_of? StructuralType) && (other.methods == @methods)
    end

    def hash  # :nodoc:
      @methods.hash
    end
  end
end
