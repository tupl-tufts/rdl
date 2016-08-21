require_relative 'type'

module RDL::Type
  class AnnotatedArgType < Type
    attr_reader :name
    attr_reader :type

# Note: Named argument types aren't hashconsed.

    def initialize(name, type)
      @name = name
      @type = type
      raise RuntimeError, "Attempt to create annotated type with non-type" unless type.is_a? Type
      raise RuntimeError, "Attempt to create doubly annotated type" if type.is_a? AnnotatedArgType
      super()
    end

    def to_s
      return "#{@type.to_s} #{@name}"
    end

    def ==(other) # :nodoc:
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? AnnotatedArgType) && (other.name == @name) && (other.type == @type)
    end

    alias eql? ==

    # doesn't have a match method - queries shouldn't have annotations in them

    def hash # :nodoc:
      return (57 + @name.hash) * @type.hash
    end

    def member?(obj, *args)
      @type.member?(obj, *args)
    end

    def instantiate(inst)
      return AnnotatedArgType.new(@name, @type.instantiate(inst))
    end

    def optional?
      return type.optional?
    end

    def vararg?
      return type.vararg?
    end
  end
end
