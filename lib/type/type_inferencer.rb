module RDL
  class TypeInferencer
    def self.infer_type(it)
      curr_type = Set.new

      it.each {|elem|
        elem_type = elem.rdl_type

        if curr_type.size == 0 
          curr_type << elem_type
          next
        end

        super_count = 0

        was_subtype = curr_type.any? {|seen_type|
          if elem_type <= seen_type
            true
          elsif seen_type <= elem_type
            super_count = super_count + 1
            false
          end
        }

        if was_subtype
          next
        elsif super_count == curr_type.size
          curr_type = Set.new([elem_type])
        else
          curr_type << elem_type
        end
      }

      if curr_type.size == 0
        RDL::Type::NilType.new
      elsif curr_type.size == 1
        curr_type.to_a[0]
      else
        u = self.unify_param_types(curr_type)
        RDL::Type::UnionType.new(*u)
      end
    end

    private
    
    def self.extract_types(param_type)
      param_type.instance_of?(RDL::Type::UnionType) ? param_type.types.to_a : [param_type]
    end
    
    #FIXME(jtoman): see if we can lift this step into the gen_type step
    def self.unify_param_types(type_set)
      non_param_classes = []
      parameterized_classes = {}

      type_set.each {|member_type|
        if member_type.parameterized?
          nominal_type = member_type.base

          tparam_set = parameterized_classes.fetch(nominal_type) {|n_type|
            [].fill([], 0, n_type.type_parameters.size)
          }

          ((0..(nominal_type.type_parameters.size - 1)).map {
             |tparam_index|
             extract_types(member_type.params[tparam_index])
           }).each_with_index {
            |type_parameter,index|
            tparam_set[index]+=type_parameter
          }

          parameterized_classes[nominal_type] = tparam_set
        else
          non_param_classes << member_type
        end
      }

      parameterized_classes.each {|nominal, type_set|
        t = type_set.map {|unioned_type_parameter|
          RDL::Type::UnionType.new(*unify_param_types(unioned_type_parameter))
        }

        non_param_classes << RDL::Type::GenericType.new(nominal, *t, true)
      }

      non_param_classes
    end
  end
end
