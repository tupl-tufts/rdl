module RDL
  module TurnOffCheck
    def self.turn_off_check
      ms = get_methods_to_turn_off
      make_aliases(ms)
    end
    
    private
    
    def self.make_aliases(method_map)
      method_map.each {|c, ms|
        cs = c.to_s.sub("::", "_").downcase

        ms.each {|m|
          old_mname = "__rdl_no_check_#{cs}_#{m}"
          
          c.class_eval do
            alias_method old_mname, m
            define_method m do |*args, &blk|
              status = RDL.on?
              RDL.turn_off if status
              
              begin
                r = self.__send__ old_mname, *args, &blk
              ensure
                RDL.turn_on if status
              end
              
              r
            end
          end
        }
      }
    end
    
    def self.get_methods_to_turn_off
      # make sure there are no duplicated classes
      # or the code will not termiante when running with aliases

      # TODO: replace Contract2, MyCtc, MyCtc2 and other related ones
      #       with Alex's ones
      regular_classes = [RDL,
                         RDL::Spec,
                         RDL::MethodCheck,
                         RDL::BlockProxy,
                         RDL::Type::NilType,
                         RDL::Type::TopType,
                         RDL::Type::SymbolType,
                         RDL::Type::NominalType,
                         RDL::Type::VarType,
                         RDL::Type::NamedType,
                         RDL::Type::UnionType,
                         RDL::Type::GenericType,
                         RDL::Type::MethodType,
                         RDL::Type::OptionalType,
                         RDL::Type::StructuralType,
                         RDL::Type::TupleType,
                         RDL::Type::VarargType,
                         RDL::Type::IntersectionType,
                         RDL::Type::Type,
                         RDL::TypeInferencer,
                         RDL::Contract2,
                         RDL::Contract,
                         RDL::MyCtc,
                         RDL::MyCtc2,
                         RDL::Dsl,
                         RDL::Proxy,
                         RDL::Lang,
                         RDL::Keyword,
                         RDL::Type::Parser,
                        ].uniq
      
      all_methods = {}
      regular_classes.each {|c|
        all_methods[c] = c.instance_methods(false)
        c = c.singleton_class
        all_methods[c] = c.instance_methods(false)
      }
      
      remove_map = {}
      remove_map[RDL.singleton_class] = [:master_switch, :on?, :turn_on, :turn_off, :set_to, :ensure_off]
      remove_map[RDL] = [:pre, :post]
      remove_map.each {|c, ms| 
        ms.each {|m| all_methods[c].delete m}
      }

      all_methods[Object] = []
      all_methods[Object.singleton_class] = [:method_added]

      all_methods
    end
  end
end
