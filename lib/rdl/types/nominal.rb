module RDL::Type
  class NominalType < Type
    attr_reader :name # string

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(name)
      name = name.to_s
      t = @@cache[name]
      return t if t
      t = self.__new__ name
      return (@@cache[name] = t) # assignment evaluates to t
    end

    def initialize(name)
      @name = name
    end

    def ==(other)
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? self.class) && (other.name == @name)
    end

    alias eql? ==

    def match(other)
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return self == other
    end

    def hash # :nodoc:
      return @name.hash
    end

    def to_s
      return @name
    end

    def klass
      @klass = RDL::Util.to_class(name) unless defined? @klass
      return @klass
    end

    def <=(other)
      return Type.leq(self, other)
    end

    def member?(obj, *args)
      t = RDL::Util.rdl_type obj
      return t <= self if t
      return true if obj.nil?
      return obj.is_a? klass
    end

    def instantiate(inst)
      return self
    end

    @@cache.merge!({"NilClass" => SingletonType.new(nil),
                    "TrueClass" => SingletonType.new(true),
                    "FalseClass" => SingletonType.new(false),
                    })
  end
end
