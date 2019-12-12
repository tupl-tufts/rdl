module RDL::Type
  class PossibleType < VarType

    # [+ types +] is an array of the possible upper bounds.
    # [+ unionvar +] is the union var that is decided if this type is ever decided.
    def initialize(types, unionvar)
      raise "Expected at least one type." if types.size == 0
      raise "Expected UnionVar type." unless unionvar.is_a?(UnionVarType)
      @possible_ubounds = types
      @unionvar = unionvar
    end

    ## When PossibleType has been reduced to just one type, that must be the true type.
    ## Otherwise, continue to treat it as a PossibleType.
    def canonical
      if types.size == 1 then types[0] else self end
    end

  end  
end
