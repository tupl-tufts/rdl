require_relative 'type'

module RDL::Type
  class VarargType < Type
    attr_reader :type

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(type)
      t = @@cache[type]
      if not t
        t = VarargType.__new__ type
        @@cache[type] = t
      end
      return t
    end

    def initialize(type)
      raise "Can't have vararg optional type" if type.class == OptionalType
      raise "Can't have vararg vararg type" if type.class == VarargType
      @type = type
      super()
    end

    def to_s
      "*(#{@type})"
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (other.instance_of? VarargType) && (other.type == @type)
    end

    # Note: no member?, because these can only appear in MethodType, where they're handled specially
    
    def hash # :nodoc:
      return 59 + @type.hash
    end
  end
end
