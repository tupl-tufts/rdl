require_relative 'type'

module RDL::Type
  class AnnotatedArgType < Type
    attr_reader :name
    attr_reader :type

# Note: Named argument types aren't hashconsed.

    def initialize(name, type)
      @name = name
      @type = type
      raise RuntimeError, "Attempt to create vararg type with non-type" unless type.is_a? Type
      super()
    end

    def to_s
      "#{@type.to_s} \"#{@name}\""
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (other.instance_of? AnnotatedArgType) && (other.name == @name) && (other.type == @type)
    end

    def hash # :nodoc:
      return (57 + @name.hash) * @type.hash
    end

    def member?(obj, *args)
      @type.member?(obj, *args)
    end

    def instantiate(inst)
      return AnnotatedArgType.new(@name, @type.instantiate(inst))
    end
  end
end
