require_relative './type'
require_relative './native'

module RDL::Type
  class OptionalType < Type
    attr_reader :type

    @@cache = RDL::NativeHash.new

    class << self
      alias :__new__ :new
    end

    def self.new(type)
      t = @@cache[type]
      if not t
        t = OptionalType.__new__ type
        @@cache[type] = t
      end
      return t
    end

    def initialize(type)
      @type = type
      super()
    end

    def map
      OptionalType.new(yield type)
    end

    def to_s
      "?(#{@type})"
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (other.instance_of? OptionalType) && (other.type == @type)
    end

    def hash # :nodoc:
      return 57 + @type.hash
    end
  end
end
