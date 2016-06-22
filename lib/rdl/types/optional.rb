module RDL::Type
  class OptionalType < Type
    attr_reader :type

    def initialize(type)
      raise RuntimeError, "Attempt to create optional type with non-type" unless type.is_a? Type
      raise "Can't have optional optional type" if type.is_a? OptionalType
      raise "Can't have optional vararg type" if type.is_a? VarargType
      @type = type
      super()
    end

    def to_s
      if @type.instance_of? UnionType
        "?(#{@type.to_s})"
      else
        "?#{@type.to_s}"
      end
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (other.instance_of? OptionalType) && (other.type == @type)
    end

    def match(other)
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return (other.instance_of? OptionalType) && (@type.match(other.type))
    end

    # Note: no member?, because these can only appear in MethodType, where they're handled specially

    def instantiate(inst)
      return OptionalType.new(@type.instantiate(inst))
    end

    def hash # :nodoc:
      return 57 + @type.hash
    end
  end
end
