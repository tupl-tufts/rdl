['generic.rb',
 'intersection.rb',
 'method.rb',
 'nil.rb',
 'named.rb',
 'optional.rb',
# 'parameterized.rb',
 'structural.rb',
 'top.rb',
 'type.rb',
# 'type_parametrs.rb',
 'union.rb',
 'vararg.rb'].each { |f| require_relative f }

class Object
  def rdl_type
    class_obj = RDL::Type::NominalType.new self.class

    class_obj
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
