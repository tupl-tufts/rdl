require_relative 'type'

module RDL::Type
  class NamedArgType < Type
    attr_reader :name
    attr_reader :type

# Note: Named argument types aren't hashconsed.

    def initialize(name, type)
      @name = name
      @type = type
      super()
    end

    def to_s(inst: nil)
      "(#{@name} : #{@type.to_s(inst: inst)})"
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (other.instance_of? NamedArgType) && (other.name == @name) && (other.type == @type)
    end

    def hash # :nodoc:
      return (57 + @name.hash) * @type.hash
    end

    def le(other, h={})
      other = other.type if other.instance_of?(RDL::Type::NamedArgType)
      @type.le(other, h)
    end

    def member?(obj, inst: nil)
      @type.member?(obj, inst: inst)
    end

    def instantiate(inst)
      return NamedArgType.new(@name, @type.instantiate(inst))
    end
  end
end
