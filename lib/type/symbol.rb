require_relative './type'

module RDL::Type
  class SymbolType < Type
    attr_reader :name

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(name)
      name = name.to_sym
      t = @@cache[name]
      if not t
        t = SymbolType.__new__ name
        @@cache[name] = t
      end
      return t
    end

    def initialize(name)
      @name = name
      super()
    end

    def to_s # :nodoc:
      return ":#{@name}"
    end

    def ==(other) # :nodoc:
      return (other.instance_of? SymbolType) && (other.name == @name)
    end

    def hash # :nodoc:
      return @name.hash
    end
  end
end
