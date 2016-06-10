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
        current_types.to_a[0]
      elsif current_types.size == 0
        $__rdl_nil_type
      else
        RDL::Type::UnionType.new(*self.unify_param_types(current_types))
      end
    end

    private

    def self.extract_types(param_type)
      param_type.instance_of?(RDL::Type::UnionType) ? param_type.types.to_a : [param_type]
    end

    # Unifies i.e. #<Set: {Array<String>, Array<Array<String>>}> into
    # Array<(Array<String> or String)>
    # If this step is not called, then infer_type for
    # [["a", "b"], [["c"]]].rdl_type would return
    # (Array<Array<String>> or Array<String>) instead of
    # (Array<(Array<String> or String)>)
    def self.unify_param_types(type_set)
      non_param_classes = []
      parameterized_classes = {}

      type_set.each {|member_type|
        if member_type.instance_of? RDL::Type::GenericType
          nominal_type = member_type.base

          tparam_set = parameterized_classes.fetch(nominal_type) {|n_type|
            cls = eval(n_type.name.to_s)
            type_parameters = cls.instance_variable_get :@__cls_params
            [].fill([], 0, type_parameters.size)
          }

          cls = eval(nominal_type.name.to_s)
          type_parameters = cls.instance_variable_get :@__cls_params
          ((0..(type_parameters.size - 1)).map {|tparam_index|
             extract_types(member_type.params[tparam_index])
           }).each_with_index {|type_parameter,index|
            tparam_set[index]+=type_parameter
          }

          parameterized_classes[nominal_type] = tparam_set
        else
          non_param_classes << member_type
        end
      }

      parameterized_classes.each {|nominal, ts|
        nt = ts.map {|unioned_type_parameter|
          RDL::Type::UnionType.new(*unify_param_types(unioned_type_parameter))
        }

        non_param_classes << RDL::Type::GenericType.new(nominal, *nt)
      }

      non_param_classes
    end
  end
end
