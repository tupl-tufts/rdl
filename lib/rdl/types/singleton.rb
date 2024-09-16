module RDL::Type
  class SingletonType < Type
    attr_accessor :val
    attr_reader :nominal

    @@cache = {}
    @@cache.compare_by_identity

    class << self
      alias :__new__ :new
    end

    def self.new(val)
      if RDL::Config.instance.number_mode && val.is_a?(Numeric) #&& !val.is_a?(Integer)
        return RDL::Type::NominalType.new(Integer)
      end
      t = @@cache[val]
      return t if t
      t = self.__new__ val
      return (@@cache[val] = t) # assignment evaluates to t
    end

    def initialize(val)
      @val = val
      @nominal = NominalType.new(val.class)
    end

    def ==(other)
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? self.class) && (other.val.equal? @val)
    end

    alias eql? ==

    def match(other, type_var_table = {})
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return self == other
    end

    def hash # :nodoc:
      return @val.hash
    end

    def to_s
      if @val.instance_of? Symbol
        ":#{@val}"
      elsif @val.nil?
        "nil"
      elsif @val.is_a?(Class)
        "[s]#{@val}"
      else
        @val.to_s
#        "Singleton(#{@val.to_s})"
      end
    end

    def <=(other)
      return Type.leq(self, other)
    end

    # Path Sensitivity: `pi` here is empty. 
    def member?(obj, *args)
      t = RDL::Util.rdl_type obj
      return RDL::Type::Type.leq(t, self, PathTrue.new) if t
      return true if obj.nil?
      obj.equal?(@val)
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

    def satisfies?
      yield(val)
    end
  end
end
