require_relative 'type'

module RDL::Type
  class TupleType < Type
    attr_reader :ordered_params

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(*arr)
      t = @@cache[arr]
      if not t
        t = TupleType.__new__(arr)
        @@cache[arr] = t
      end
      return t
    end
      
    def initialize(arr)
      @ordered_params = arr
      super()
    end

    def is_tuple
      true
    end

    def to_s
      "Tuple<[#{ordered_params.join(", ")}]>"
    end

    def inspect
      "#{self.class.name}(#{@id}): #{@ordered_params.inspect}" 
    end

    def eql?(other)
      self == other
    end

    def ==(other) 
      other.instance_of?(SymbolType) and other.symbol == symbol
    end
    
    def hash
      h = (71 + @size.hash) * @ordered_params.hash
    end
  end
end
