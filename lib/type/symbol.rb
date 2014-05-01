require_relative './type'

module RDL::Type
  class SymbolType < Type
    attr_reader :sym

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(sym)
      sym = sym.to_sym
      t = @@cache[sym]
      if not t
        t = SymbolType.__new__ sym
        @@cache[sym] = t
      end
      return t
    end

    def initialize(sym)
      @sym = sym
      super()
    end

    def to_s # :nodoc:
      return ":#{@sym}"
    end

    def ==(other) # :nodoc:
      return (other.instance_of? SymbolType) && (other.sym == @sym)
    end

    def hash # :nodoc:
      return @sym.hash
    end
  end
end
