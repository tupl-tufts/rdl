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
        # Note intersection types not allowed as subtyping would be tricky
      }
      @methods = methods
      super()
    end

    def to_s  # :nodoc:
      "[ " + @methods.each_pair.map { |m, t| "#{m.to_s}: #{t.to_s}" }.sort.join(", ") + " ]"
    end

    def <=(other)
      return Type.leq(self, other)
    end

    def member?(obj, *args)
      t = RDL::Util.rdl_type obj
      return t <= self if t
      return NominalType.new(obj.class) <= self
    end

    def instantiate(inst)
      StructuralType.new(Hash[*@methods.each_pair.map { |m, t| [m, t.instantiate(inst)] }.flatten])
    end

    def ==(other)  # :nodoc:
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? StructuralType) && (other.methods == @methods)
    end

    alias eql? ==

    def match(other)
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return (@methods.length == other.methods.length &&
              @methods.all? { |k, v| (other.methods.has_key? k) && (v.match(other.methods[k]))})
    end

    def hash  # :nodoc:
      @methods.hash
    end
  end
end
