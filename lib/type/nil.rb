require_relative './type'

module RDL::Type
  class NilType < Type

    @@cache = nil

    class << self
      alias :__new__ :new
    end

    def self.new
      @@cache = NilType.__new__ unless @@cache
      return @@cache
    end

    def initialize
      super
    end

    def to_s
      "nil"
    end

    def ==(other)
      other.instance_of? NilType
    end

    def hash
      13
    end
  end
end
