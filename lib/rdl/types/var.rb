module RDL::Type
  class VarType < Type
    attr_reader :name

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(name)
      name = name.to_s.to_sym
      t = @@cache[name]
      return t if t
      t = self.__new__ name
      return (@@cache[name] = t) # assignment evaluates to t
    end

    def initialize(name)
      @name = name
    end

    def to_s # :nodoc:
      return @name.to_s
    end

    def ==(other)
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? self.class) && (other.name.to_s == @name.to_s)
    end

    alias eql? ==

    # an uninstantiated variable is only comparable to itself
    def <=(other)
      return Type.leq(self, other)
    end

    def match(other)
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return self == other
    end

    def hash # :nodoc:
      return @name.to_s.hash
    end

    def member?(obj, vars_wild: false)
      return true if vars_wild
      raise TypeError, "Unbound type variable #{@name}"
    end

    def instantiate(inst)
      return inst[@name] if inst[@name]
      return self
    end
  end
end
