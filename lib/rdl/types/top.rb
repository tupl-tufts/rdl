require_relative './type'

module RDL::Type
  class TopType < Type
    include TerminalType

    @@cache = nil

    class << self
      alias :__new__ :new
    end

    def self.new
      @@cache = TopType.__new__ unless @@cache
      return @@cache
    end

    def initialize
      super
    end

    def map
      self
    end

    def each
      yield self
    end

    def to_s
      "%top"
    end

    def eql?(other)
      self == other
    end
      
    def ==(other)
      other.instance_of? TopType
    end

    def hash
      17
    end

    def self.instance
      return @@instance || (@@instance = TopType.new)
    end

    @@instance = nil
  end
end
