require_relative 'type'
require_relative 'terminal'

module RDL::Type
  class NilType < Type
    include TerminalType
    
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

    def map
      self
    end
    
    def each
      yield self
    end

    def eql?(other)
      self == other
    end

    def ==(other)
      other.instance_of? NilType
    end

    def hash
      13
    end

    def <=(other)
      true
    end

    def self.instance
      return @@instance || (@@instance = NilType.new)
      end
    
    @@instance = nil
  end
end
