module RDL::Type
  class OptionalType < Type
    attr_reader :type

    def initialize(type)
      raise RuntimeError, "Attempt to create optional type with non-type" unless type.is_a? Type
      raise "Can't have optional optional type" if type.is_a? OptionalType
      raise "Can't have optional vararg type" if type.is_a? VarargType
      raise "Can't have optional annotated type" if type.is_a? AnnotatedArgType
      @type = type
      super()
    end

    def to_s
      if @type.is_a? UnionType
        "?(#{@type.to_s})"
      elsif @type.is_a? MethodType
        "?{ #{@type.to_s} }"
      else
        "?#{@type.to_s}"
      end
    end

    def ==(other) # :nodoc:
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? OptionalType) && (other.type == @type)
    end

    alias eql? ==

    def match(other)
      other = other.canonical
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

    def optional?
      return true
    end
  end
end
