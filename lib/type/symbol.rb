require_relative './type'

module RDL::Type
  class SymbolType < Type
    attr_reader :symbol

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(symbol)
      t = @@cache[symbol]
      if not t
        t = SymbolType.__new__ symbol
        @@cache[symbol] = t
      end
      return t
    end

    def initialize(symbol)
      @symbol = symbol
      super
    end

    def to_s # :nodoc:
      return ":#{@symbol}"
    end

    def ==(other) # :nodoc:
      return (other.instance_of? SymbolType) && (other.symbol == @symbol)
    end

    def hash # :nodoc:
      return @symbol.hash
    end
  end
end
