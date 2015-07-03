require_relative 'type'

module RDL::Type
  class TopType < Type
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

    def to_s
      "%any"
    end

    def eql?(other)
      self == other
    end
      
    def ==(other)
      other.instance_of? TopType
    end

    def <=(other)
      other.instance_of? TopType
    end
    
    def instantiate(inst)
      return self
    end
    
    def hash
      17
    end
  end
end
