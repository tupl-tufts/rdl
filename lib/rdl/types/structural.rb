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
      return t if t
      t = StructuralType.__new__(methods)
      return (@@cache[methods] = t) # assignment evaluates to t
    end

    # Create a new StructuralType.
    #
    # [+methods+] Map from method names as symbols to their types.
    def initialize(methods)
      raise "methods can't be empty" if methods.empty?
      methods.each { |m, t|
        raise RuntimeError, "Method names in StructuralType must be symbols" unless m.instance_of? Symbol
        raise RuntimeError, "Got #{t.class} where MethodType expected" unless t.instance_of? MethodType
      }
      @methods = methods
      super()
    end

    def to_s  # :nodoc:
      "[ " + @methods.each_pair.map { |m, t| "#{m.to_s}: #{t.to_s}" }.sort.join(", ") + " ]"
    end

    def <=(other)
      # allow width subtyping
      other.methods.each_pair.map { |m, t|
        return false unless @methods.has_key?(m) && @methods[m] <= t
      }
      return true
    end
    
    def instantiate(inst)
      StructuralType.new(Hash[*@methods.each_pair.map { |m, t| [m, t.instantiate(inst)] }.flatten])
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
