require_relative 'type'

module RDL::Type
  class BoundArgType < Type
    attr_reader :name
    attr_reader :type

    # Note: Named argument types aren't hashconsed.

    def initialize(name, type)
      @name = name
      @type = type
      raise RuntimeError, "Attempt to create bound type with non-type" unless type.is_a? Type
      raise RuntimeError, "Attempt to create doubly annotated type" if (type.is_a?(BoundArgType) || type.is_a?(AnnotatedArgType))
      raise RuntimeError, "Cannot create bound type with optional type" if type.is_a? OptionalType
      raise RuntimeError, "Cannot create bound type with variable argument type" if type.is_a? VarargType                                                                       
      super()
    end

    def to_s
      return "#{@name}<::#{@type.to_s}"
    end

    def render
      return "#{@name}<::#{@type.render}"
    end

    def ==(other) # :nodoc:
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? BoundArgType) && (other.name == @name) && (other.type == @type)
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
      return BoundArgType.new(@name, @type.instantiate(inst))
    end

    def widen
      return BoundArgType.new(@name, @type.widen)
    end

    def copy
      return BoundArgType.new(@name, @type.copy)
    end

    def optional?
      return type.optional?
    end

    def vararg?
      return type.vararg?
    end
  end
end

