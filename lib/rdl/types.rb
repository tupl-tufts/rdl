module RDL
    class TypesigException < StandardError; end
    class TypeComparisonException < StandardError; end
    class AmbiguousUnionException < StandardError; end
    class InvalidParameterException < StandardError; end
end

# Supported Types for Ruby
['lexer.rex.rb',
'parser.tab.rb',
'generic.rb',
'intersection.rb',
'method.rb',
'method_check.rb',
'nil.rb',
'named.rb',
'named_arg.rb',
'optional.rb',
'structural.rb',
'top.rb',
'tuple.rb',
'type.rb',
'type_inferencer.rb',
'union.rb',
'vararg.rb'].each { |f| require_relative "types/#{f}" }

class Object
    
    def rdl_type
        if self.class.name == "Symbol"
            RDL::Type::SymbolType.new(self)
        else
            class_obj = RDL::Type::NominalType.new self.class
            
            if class_obj.name.to_s == "Array"
                t = RDL::TypeInferencer.infer_type(self.each)
                RDL::Type::GenericType.new(class_obj, *[t])
            elsif class_obj.name.to_s == "Set"
                t = RDL::TypeInferencer.infer_type(self.each)
                RDL::Type::GenericType.new(class_obj, *[t])
            elsif class_obj.name.to_s == "Hash"
                k = RDL::TypeInferencer.infer_type(self.each_key)
                v = RDL::TypeInferencer.infer_type(self.each_value)
                RDL::Type::GenericType.new(class_obj, *[k, v])
            elsif class_obj.type_parameters.size == 0
                class_obj
            else
                raise Exception, "User defined class not supported yet"
            end
        end
        
    end
    
    def rdl_inst(types)
        parser = RDL::Type::Parser.new
        
        if types.class == Hash
            h = {}
            
            types.each {|parameter, type|
                if type.class == String
                    type_str = "##" + type
                    h[parameter] = parser.scan_str type_str
                elsif type.class.ancestors.include?(RDL::Type::Type)
                    h[parameter] = type
                else
                    h[parameter] = RDL::Type::NominalType.new(type)
                end
            }
            
            tp = self.instance_variable_get(:@__rdl_s_type_parameters)
            h = self.instance_variable_get(:@__rdl_s_type_parameters).merge(h) if tp
            self.instance_variable_set(:@__rdl_s_type_parameters, h)
        else
            raise Exception, "argument type to rdl_inst not support yet"
        end
        
        self
    end
    
end

class NilClass
    
    def rdl_type
        RDL::Type::NilType.new
    end
    
end
