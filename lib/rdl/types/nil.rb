require_relative 'type'

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

    def to_s(inst: nil)
      "nil"
    end

    def eql?(other)
      self == other
    end

    def ==(other)
      other.instance_of? NilType
    end

    def member?(obj, inst: nil)
      obj == nil
    end

    def instantiate(inst)
      return self
    end
    
    def hash
      13
    end
  end
end
