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
      t = OptionalType.__new__ type
      return (@@cache[type] = t) # assignment evaluates to t
    end

    def initialize(type)
      raise "Can't have optional optional type" if type.class == OptionalType
      raise "Can't have optional vararg type" if type.class == VarargType
      @type = type
      super()
    end

    def to_s(inst: nil)
      "?(#{@type.to_s(inst: inst)})"
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
