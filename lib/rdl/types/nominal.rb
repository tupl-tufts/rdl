module RDL::Type
  class NominalType < Type
    attr_reader :name # string

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(name)
      name = name.to_s
      name = "Integer" if RDL::Config.instance.number_mode && ["Float", "Rational", "Complex", "Decimal", "BigDecimal", "BigDecimal::ROUND_MODE", "Numeric"].include?(name)
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

    def match(other, type_var_table = {})
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return self == other
    end

    def hash # :nodoc:
      return @name.hash
    end

    def to_s
      if @name.start_with? '#<Class:'
        if @name['('] # Rails models such as Talk(:id, :name, ...)
          n = @name.split('(')[0] + '>'
        else
          n = @name
        end
        return RDL::Util.add_singleton_marker(n[8..-2])
      elsif RDL::Config.instance.number_mode && (@name == "Integer")
        return "Number"
      else
        return @name
      end
    end

    def klass
      @klass = RDL::Util.to_class(name) unless defined? @klass
      return @klass
    end

    def <=(other)
      #require 'debug/open'
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

    def widen
      return self
    end

    def copy
      return self
    end

    @@cache.merge!({"NilClass" => SingletonType.new(nil),
                    "TrueClass" => SingletonType.new(true),
                    "FalseClass" => SingletonType.new(false),
                    })
  end
end
