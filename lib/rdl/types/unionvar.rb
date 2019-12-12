module RDL::Type
  class UnionVarType < VarType

    # [+ type_map +] is a Hash<Type, Type>. Keys represent types in the corresponding
    # PossibleType, and values represent the resulting true types of self.
    # [+ possible +] is the corresponding PossibleType.
    def initialize(type_map, possible)
      raise "Expected at least one type." if type_map.size == 0
      raise "Expected PossibleType, given #{possible}" unless possible.is_a?(PossibleType)
      @type_map = type_map
      @possible = possible
    end

    ## When UnionVarType has been reduced to just one type, that is the true type.
    ## Otherwise, continue to treat it as UnionVarType.
    def canonical
      if (type_map.size == 1) return type_map.values[0] else return self end
    end
    
  end
end
