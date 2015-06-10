module RDL::Type
  # Abstract base class for all types. This class
  # should never be instantiated directly.
  class Type

    # t1 <= t2
    # Note this method is probably not useful.
    def self.<=(t1, t2)
      if t1.instance_of?(NilType)
        true
      elsif t2.instance_of?(TopType)
        true
      elsif t1.instance_of?(SymbolType) && t2.instance_of?(SymbolType)
        t1.name == t2.name
      elsif t1.instance_of?(NominalType) && t2.instance_of?(NominalType)
        t1.name == t2.name ||
         t1.klass.ancestors.member?(t2.klass)
      elsif t1.instance_of?(SymbolType) && t2.instance_of?(NominalType)
        t2.name == :Symbol
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
    
    def rdoc_str
        _to_actual_type.to_s
    end
  end
end
