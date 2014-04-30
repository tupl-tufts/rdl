require_relative './type'

module RDL::Type
  class TupleType < Type
    attr_reader :types

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(types)
      t = @@cache[ts]
      if not t
        t = TupleType.__new__(ts)
        @@cache[ts] = t
      end
      return t
    end

    def initialize(types)
      @types = types
      super
    end

    def to_s  # :nodoc:
      "[#{@types.to_a.join(', ')}]"
    end

    def ==(other)  # :nodoc:
      return other.instance_of? TupleType && other.types == @types
    end

    def hash  # :nodoc:
      53 + @types.hash
    end
  end
end
