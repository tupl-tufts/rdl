require_relative 'type'

module RDL::Type
  # A type that is parameterized on one or more other types. The base type
  # must be a NominalType, while the parameters can be any type.
  class GenericType < Type
    attr_reader :base
    attr_reader :params

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(base, *params)
      t = @@cache[[base, params]]
      if not t
        t = GenericType.__new__(base, params)
        @@cache[[base, params]] = t
      end
      return t
    end

    def initialize(base, params)
      raise "base must be NominalType" unless base.instance_of? NominalType

      @base = base
      @params = params
      super()
    end

    def to_s
      "#{@base}<#{params.join(', ')}>"
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (other.instance_of? GenericType) && (other.base == @base) && (other.params == @params)
    end

    def hash
      h = (61 + @base.hash) * @params.hash
    end
  end
end
