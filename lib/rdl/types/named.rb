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
  end

  def to_s # :nodoc:
    return @name.to_s
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
end

module RDL::Type
  class NominalType < Type
    include NamedType

    def to_s
      "NominalType<#{@name}>"
    end
  end

  class SymbolType < Type
    include NamedType

    def to_s
      ":#{@name}"
    end
  end

  class VarType < Type
    include NamedType

    def to_s
      "#{@name}"
    end
  end
end
