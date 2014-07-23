module RDL
  class TypeInferencer
    def self.infer_type(it)
      current_types = Set.new
      it_types = it.map {|t| t.rdl_type}
      it_types = it_types.to_set

      it_types.each {|t|
        subtype = current_types.any? {|ct| t.le(ct)}
        current_types.add(t) if not subtype
      }

      if current_types.size == 1
        RDL::Type::NominalType.new current_types.to_a[0]
      elsif current_types.size == 0
        raise Exception, "Cannot infer type, no type found in #{it.inspect}"
      else
        RDL::Type::UnionType.new *current_types
      end
    end
  end
end
