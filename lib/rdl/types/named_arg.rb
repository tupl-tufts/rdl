require_relative 'type'
require_relative 'native'

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
      "(#{@name} : #{@type})"
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
  end
end
