require_relative './type'

module RDL::Type
  class NominalType < Type
    attr_reader :name

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(name)
      name = name.to_sym
      t = @@cache[name]
      if not t
        t = NominalType.__new__ name
        @@cache[name] = t
      end
      return t
    end

    def initialize(name)
      @name = name
    end

    def to_s # :nodoc:
      return @name.to_s
    end

    def ==(other)
      return (other.instance_of? NominalType) && (other.name == @name)
    end

    def hash # :nodoc:
      return @name.hash
    end
  end
end
