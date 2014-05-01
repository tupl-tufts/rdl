require_relative './type'

module RDL::Type
  class NominalType < Type
    attr_reader :klass

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    # Create a new nominal type for +klass+, or return existing 
    def self.new(klass)
      t = @@cache[klass]
      if not t
        t = NominalType.__new__ klass
        @@cache[klass] = t
      end
      return t
    end

    def initialize(klass)
      @klass = klass
    end

    def to_s # :nodoc:
      return @klass.to_s
    end

    # Return +true+ if +other+ is a NominalType with the same +klass+ as
    # +self.
    def ==(other)
      return (other.instance_of? NominalType) && (other.klass == @klass)
    end

    def hash # :nodoc:
      return @klass.name.hash
    end
  end
end
