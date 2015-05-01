require 'set'

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
        RDL::Type::NilType.new
      else
        x = RDL::Type::UnionType.new(*self.unify_param_types(current_types))
#puts "x #{x} curr #{current_types.inspect}\n\n"
        x
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
    def self.unify_param_types_old(type_set)
      non_param_classes = []
      parameterized_classes = {}
p "UNIFYING #{type_set.inspect}"
      type_set.each {|member_type|
        if member_type.instance_of? RDL::Type::GenericType
          nominal_type = member_type.base

          tparam_set = parameterized_classes.fetch(nominal_type) {|n_type|
            cls = eval(n_type.name.to_s)
            type_parameters = cls.instance_variable_get :@__cls_params
            type_parameters ||= {}
            [].fill([], 0, type_parameters.size)
          }
          cls = eval(nominal_type.name.to_s)
          type_parameters = cls.instance_variable_get :@__cls_params
          type_parameters ||= {}
          ((0...(type_parameters.size)).map {|tparam_index|
             extract_types(member_type.params[tparam_index])
p "Extracting #{tparam_index}"
           }).each_with_index {|type_parameter,index|
p "Type Param #{type_parameter}"
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

        non_param_classes << RDL::Type::GenericType.new(nominal, *t)
      }
      non_param_classes
    end

$ct=0
    def self.unify_param_types(type_set)
        c = ($ct +=1)
puts "\n#{c} Unifying #{type_set.inspect}"
        non_param = [] # Types without another level of parameters
        param = {} # Hash of {Paramaterized Type => Parameters} to unify Parameters

        # Sort member types into current order and higher order
        type_set.each{ |member_type|
            if !(member_type.instance_of? RDL::Type::GenericType) then
                non_param << member_type
            else member_type.params.each { |nested_type|
                param[member_type.base] ||= []
                param[member_type.base] << nested_type}
            end
        }

puts "#{c} NON-PARAM #{non_param}"
puts "#{c} PARAM #{param}"

        # ...
        param.each{ |nominal, types|
            #t = types.map {|unioned_type_parameter|
            t = RDL::Type::UnionType.new(*unify_param_types(types))
            #}
            non_param << RDL::Type::GenericType.new(nominal, *t)
            non_param = non_param.uniq
        }

puts "#{c} Returning #{non_param} with #{non_param.map{|x| x.instance_variable_get(:@params)}}\n"
        return non_param
    end # end of :unify_param_types_new

  end # end of class TypeInferencer

end # end of module RDL




