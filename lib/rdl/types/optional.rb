require_relative 'type'

module RDL::Type
  class OptionalType < Type
    attr_reader :type

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(type)
      t = @@cache[type]
      return t if t
      raise RuntimeError, "Attempt to create vararg type with non-type" unless type.is_a? Type
      t = OptionalType.__new__ type
      return (@@cache[type] = t) # assignment evaluates to t
    end

    def initialize(type)
      raise "Can't have optional optional type" if type.class == OptionalType
      raise "Can't have optional vararg type" if type.class == VarargType
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

    # Note: no member?, because these can only appear in MethodType, where they're handled specially
    
    def instantiate(inst)
      return OptionalType.new(@type.instantiate(inst))
    end
    
    def hash # :nodoc:
      return 57 + @type.hash
    end
  end
end
