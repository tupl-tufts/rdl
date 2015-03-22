require_relative 'type'

module RDL::Type::NamedType
  def self.included(base)
    s = <<END
      attr_reader :name
      @@cache = {}

      class << self
        alias :__new__ :new
      end

      def self.new(name)
        name = name.to_s.to_sym
        t = @@cache[name]
        if not t
          t = self.__new__ name
          @@cache[name] = t
        end

        return t
      end
END
      base.class_eval s
  end

  def initialize(name)
    @name = name
    @type_parameters = []
  end

  def to_s # :nodoc:
    return @name.to_s
  end

  def klass
    eval @name.to_s
  end

  def eql?(other)
    self == other
  end

  def ==(other)
    return (other.instance_of? self.class) && (other.name.to_s == @name.to_s)
  end

  def hash # :nodoc:
    return @name.to_s.hash
  end

  def type_parameters
    @type_parameters
  end

  def type_parameters=(t_params)
    @type_parameters = t_params
  end

  def each
    yield self
  end
  
  def map
    self
  end
end

module RDL::Type
  class NominalType < Type
    include NamedType

    def le(other, h={})
      case other
      when NominalType
        s_type = eval(@name.to_s)
        o_type = eval(other.name.to_s)
        if s_type == nil || s_type == NilClass
          return true
        end
        s_type <= o_type
      when VarType
        if h.keys.include? other.name
          h[other.name] = UnionType.new(h[other.name], self)
        else
          h[other.name] ||= self
        end
        
        true
      when TopType
        true
      when StructuralType
        raise "NOT implemented"
      when GenericType
        false
      when TupleType
        false
      else
        super(other, h)
      end
    end

    def inspect
      "NominalType<#{@name}>"
    end
  end

  class SymbolType < Type
    include NamedType

    def to_s
      ":#{@name}"
    end

    def le(other, h={})
      if other.instance_of?(SymbolType)
        self == other
      elsif other.instance_of?(NominalType) 
        other.name.to_s == "Symbol" ? true : false
      elsif other.instance_of? VarType
        if h.keys.include? other.name
          h[other.name] = UnionType.new(h[other.name], self)
        else
          h[other.name] ||= self
        end

        true
      elsif other.instance_of? GenericType
        false
      else
        super(other, h)
      end
    end
  end

  class VarType < Type
    include NamedType

    def le(other, h={})
      raise RDL::TypeComparisonException, "VarType#le should not be called!"
    end
    
    def replace_vartypes(type_vars)
      return type_vars[name.to_sym] if type_vars.has_key? name.to_sym
      self
    end
  end
end
