require_relative './type'

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

  def ==(other)
    return (other.instance_of? self.class) && (other.name == @name)
  end

  def hash # :nodoc:
    return @name.hash
  end

  def type_parameters
    @type_parameters
  end

  def type_parameters=(t_params)
  end
end

module RDL::Type
  class NominalType < Type
    include NamedType

    def <=(other)
      case other
      when NominalType
        s_type = eval(self.name.to_s)
        o_type = eval(other.name.to_s)
        s_type <= o_type
      when OptionalType
        self <= other.type
      when UnionType
        other.types.any? do |a|
          self <= a
        end
      when TopType
        true
      else
        raise "NominalType #{self.inspect} <= #{other.inspect} not supported yet!"
      end
    end

    def add_method_type(name, type)
      @method_types ||= {}

      if @method_types[name]
        # this branch is untested
        extant_type = @method_types[name]
        if extant_type.instance_of?(IntersectionType)
          type = [type] + extant_type.types.to_a
        else
          type = [type, extant_type]
        end
        type = IntersectionType.of(type)
      end

      @method_types[name] = type
    end

    def get_method(name)
      it = self

      if not it.method_types.has_key?(name)
        return nil
      end

      m_type = it.method_types[name]

      m_type
    end

    def method_types
      @method_types ? @method_types : {}
    end

    def inspect
      "NominalType<#{@name}>"
    end
  end
  class SymbolType < Type
    include NamedType
  end
  class VarType < Type
    include NamedType
  end
end
