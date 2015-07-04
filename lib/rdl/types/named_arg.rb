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

    def to_s
      "(#{@name} : #{@type.to_s})"
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

    def member?(obj)
      @type.member?(obj)
    end

    def instantiate(inst)
      return NamedArgType.new(@name, @type.instantiate(inst))
    end
  end
end
