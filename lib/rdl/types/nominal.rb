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
      other = other.type if other.is_a? DependentArgType
      other = other.canonical
      k = klass
      if other.instance_of? TopType
        return true
      elsif other.instance_of? NominalType
        return k.ancestors.member?(other.klass)
#      return self <= other.base if other.instance_of? GenericType # raw subtyping not allowed
      elsif other.instance_of? StructuralType
        # similar logic in GenericType
        other.methods.each_pair { |m, t|
          return false unless k.method_defined? m
          types = $__rdl_info.get(k, m, :type)
          if types
            return false unless types.all? { |t_self| t_self <= t }
          end
        }
        return true
      elsif other.instance_of? UnionType
        return other.types.any? { |ot| self <= ot }
      else
        return false
      end
    end

    def leq_inst(other, inst: nil, ileft: true)
      other = other.type if other.is_a? DependentArgType
      other = other.canonical
      if inst && !ileft && other.is_a?(VarType)
        return leq_inst(inst[other.name], inst, ileft) if inst[other.name]
        inst.merge!(other.name => self)
        return true
      end
      k = klass
      if other.instance_of? TopType
        return true
      elsif other.instance_of? NominalType
        return k.ancestors.member?(other.klass)
#      return self <= other.base if other.instance_of? GenericType # raw subtyping not allowed
      elsif other.instance_of? StructuralType
        # similar logic in GenericType
        other.methods.each_pair { |m, t|
          return false unless k.method_defined? m
          types = $__rdl_info.get(k, m, :type)
          if types
            return false unless types.all? { |t_self| t_self.leq_inst(t, nil, ileft) }
            # inst above is nil because the method types inside the class k and
            # inside the structural type have an implicit quantifier on them. So
            # even if we're allowed to instantiate type variables we can't do that
            # inside those types
          end
        }
        return true
      elsif other.instance_of? UnionType
        other.types.each { |ot|
          # return true at first match, updating inst accordingly to first succeessful match
          new_inst = inst.dup
          if leq_inst(ot, new_inst, ileft)
            inst.update(new_inst)
            return true
          end
        }
        return false
      else
        return false
      end
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
