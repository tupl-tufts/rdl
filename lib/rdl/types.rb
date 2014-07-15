module RDL
  class TypesigException < StandardError; end
  class InvalidParameterException < StandardError; end
end

['lexer.rex.rb',
 'parser.tab.rb',
 'generic.rb',
 'intersection.rb',
 'method.rb',
 'nil.rb',
 'named.rb',
 'named_arg.rb',
 'optional.rb',
 'structural.rb',
 'top.rb',
 'tuple.rb',
 'type.rb',
 'type_inferencer.rb',
 'type_parameters.rb',
 'type_variables.rb',
 'union.rb',
 'vararg.rb'].each { |f| require_relative "types/#{f}" }

class Object
  def method_added(method_name)
    
  end

  def rtc_meta
    if defined? @_rtc_meta
      @_rtc_meta
    else
      to_return = {}
      to_return[:iterators] = {}
      to_return[:_type] = nil

      @_rtc_meta = to_return
    end
  end

  def rdl_type
    if self.class.name == "Symbol"
      RDL::Type::SymbolType.new(self)
    else
      class_obj = RDL::Type::NominalType.new self.class

      if class_obj.name.to_s == "Array"
        t = RDL::TypeInferencer.infer_type(self.each)
        RDL::Type::GenericType.new(class_obj, *RDL::NativeArray[t], true)
      elsif class_obj.name.to_s == "Set"
        t = RDL::TypeInferencer.infer_type(self.each)
        RDL::Type::GenericType.new(class_obj, *[t], true)
      elsif class_obj.name.to_s == "Hash"
        k = RDL::TypeInferencer.infer_type(self.each_key)
        v = RDL::TypeInferencer.infer_type(self.each_value)
        RDL::Type::GenericType.new(class_obj, *RDL::NativeArray[k, v], true)
      elsif class_obj.type_parameters.size == 0 
        class_obj
      else
        raise Exception, "User defined GenericType not supported yet"
      end
    end
  end
  
  def rtc_is_complex?
    return false if self.nil?
    not RDL::Type::NominalType.new(self.class).type_parameters.empty?
  end
  
  def is_terminal
    false
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

      tp = self.instance_variable_get(:@s_type_parameters)
      h = self.instance_variable_get(:@s_type_parameters).merge(h) if tp
      self.instance_variable_set(:@s_type_parameters, h)
    else
      raise Exception, "argument type to rdl_inst not support yet"
    end

    self
  end

  def subst_type_vars(method_type, type_var_map) 
  end
end

class Module
  def rdl_type
    RDL::Type::NominalType.new(class <<self; self; end)
  end
end

class NilClass
  def rdl_type
    RDL::Type::NilType.new
  end
end
