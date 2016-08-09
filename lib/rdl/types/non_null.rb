require_relative 'type'

module RDL::Type
  class NonNullType < Type
    attr_reader :type

    def initialize(type)
      @type = type
      raise RuntimeError, "Singleton types are always non-null" if type.is_a? SingletonType
      raise RuntimeError, "Attempt to create doubly non-null type" if type.is_a? NonNullType
      super()
    end

    def to_s
      return "!#{@type.to_s}"
    end

    def ==(other) # :nodoc:
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? NonNullType) && (other.type == @type)
    end

    alias eql? ==

    def match(other)
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return (other.instance_of? NonNullType) && (@type.match(other.type))
    end

    def hash # :nodoc:
      return 157 + @type.hash
    end

    def <=(other)
      return Type.leq(self, other)
    end

    def member?(obj, *args)
      return false if obj.nil?
      @type.member?(obj, *args)
    end

    def instantiate(inst)
      return NonNullType.new(@type.instantiate(inst))
    end
  end
end
