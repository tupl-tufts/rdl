module RDL::Type
  # Abstract base class for all types. This class
  # should never be instantiated directly.
  class Type

    # t1 <= t2
    def self.<=(t1, t2)
      if t1.instance_of?(NilType)
        true
      elsif t2.instance_of?(TopType)
        true
      elsif t1.instance_of?(SymbolType) && t2.instance_of?(SymbolType)
        t1.name == t2.name
      elsif t1.instance_of?(NominalType) && t2.instance_of?(NominalType)
#TODO: Subtyping
        t1.name == t2.name
      elsif t1.instance_of?(SymbolType) && t2.instance_of?(NominalType)
        t2.name == "Symbol"
      elsif t1.instance_of?(GenericType) && t1.base.name == "Tuple" &&
            t2.instance_of?(GenericType) && t2.base.name == "Array" &&
            t2.params.size == 1
        t1.params.all? { |t| Type.<=(t, t2.params[0]) }
      elsif t1.instance_of?(GenericType) && t2.instance_of?(GenericType)
        t1.base == t2.base && t1.params == t2.params
      elsif t1.instance_of?(UnionType)
        t1.types.all? { |t| Type.<=(t, t2) }
      elsif t2.instance_of(IntersectionType)
        t2.types.all? { |t| Type.<=(t1, t) }
      else
        false
      end
    end

    def <=(other)
      Type.<=(self, other)
    end
  end
end
