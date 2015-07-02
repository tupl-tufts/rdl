module RDL::Type
  # Abstract base class for all types. This class
  # should never be instantiated directly.

  class TypeError < StandardError; end

  class Type

    @@contract_cache = {}
    
    # t1 <= t2
    # Note this method is probably not useful, and it doesn't handle variance for generic types
    def self.<=(t1, t2)
      if t1.instance_of?(NilType)
        true
      elsif t2.instance_of?(TopType)
        true
      elsif t1.instance_of?(SingletonType) && t2.instance_of?(SingletonType)
        t1.val == t2.val
      elsif t1.instance_of?(NominalType) && t2.instance_of?(NominalType)
        t1.name == t2.name || t1.klass.ancestors.member?(t2.klass)
      elsif t1.instance_of?(SingletonType) && t2.instance_of?(NominalType)
        t1.val.class.ancestors.member?(t2.klass)
      elsif t1.instance_of?(GenericType) && t2.instance_of?(GenericType)
        t1.base == t2.base && t1.params == t2.params
      elsif t1.instance_of?(UnionType)
        t1.types.all? { |t| Type.<=(t, t2) }
      elsif t2.instance_of?(IntersectionType)
        t2.types.all? { |t| Type.<=(t1, t) }
      else
        false
      end
    end

    def <=(other)
      Type.<=(self, other)
    end

    def to_contract
      c = @@contract_cache[self]
      return c if c

      c = RDL::Contract::FlatContract.new(to_s) { |x|
        unless member? x
          raise TypeError, "Expecting type #{to_s}, got #{x.inspect}"
        end
        true
      }
      return (@@contract_cache[self] = c)  # assignment evaluates to c
    end
  end
end
