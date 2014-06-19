require_relative 'type'

module RDL::Type
  class TypeParameter < Type
    attr_accessor :symbol

    def initialize(symbol)
      @symbol = symbol
      super()
    end

    def map
      self
    end

    def replace_parameters(type_vars)
      return type_vars[@symbol] if type_vars.has_key? @symbol

      self
    end

    def is_terminal
      true
    end

    def replace_parameters(type_vars)
      return type_vars[@symbol] if type_vars.has_key? @symbol
      self
    end

    def _to_actual_type
      self
    end

    def each 
      yield self
    end

    def to_s  
      "TParam<#{symbol.to_s}>"
    end

    def eql?(other)
      self == other
    end

    def ==(other)  
      other.instance_of? TypeParameter and @symbol == other.symbol
    end
  end
end
