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

    def to_s
      "nil"
    end

    def eql?(other)
      self == other
    end

    def ==(other)
      other.instance_of? NilType
    end

    def match(other)
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return self == other
    end

    def <=(other)
      true
    end

    def member?(obj, *args)
      t = RDL::Util.rdl_type obj
      return t <= self if t
      obj.nil?
    end

    def instantiate(inst)
      return self
    end

    def hash
      13
    end
  end
end
