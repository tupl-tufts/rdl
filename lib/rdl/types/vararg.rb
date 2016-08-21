module RDL::Type
  class VarargType < Type
    attr_reader :type

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(type)
      t = @@cache[type]
      return t if t
      raise RuntimeError, "Attempt to create vararg type with non-type" unless type.is_a? Type
      t = VarargType.__new__ type
      return (@@cache[type] = t) # assignment evaluates to t
    end

    def initialize(type)
      raise "Can't have vararg optional type" if type.is_a? OptionalType
      raise "Can't have vararg vararg type" if type.is_a? VarargType
      raise "Can't have optional annotated type" if type.is_a? AnnotatedArgType
      @type = type
      super()
    end

    def to_s
      if @type.instance_of? UnionType
        "*(#{@type.to_s})"
      else
        "*#{@type.to_s}"
      end
    end

    def ==(other) # :nodoc:
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? VarargType) && (other.type == @type)
    end

    alias eql? ==

    def match(other)
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return (other.instance_of? VarargType) && (@type.match(other.type))
    end

    # Note: no member?, because these can only appear in MethodType, where they're handled specially

    def instantiate(inst)
      return VarargType.new(@type.instantiate(inst))
    end

    def hash # :nodoc:
      return 59 + @type.hash
    end

    def vararg?
      return true
    end
  end
end
