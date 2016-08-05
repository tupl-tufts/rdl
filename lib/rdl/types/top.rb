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

    def ==(other)
      return false if other.nil?
      other = other.canonical
      other.instance_of? TopType
    end

    alias eql? ==

    def match(other)
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return self == other
    end

    def <=(other)
      return Type.leq(self, other)
    end

    def member?(obj, *args)
      t = RDL::Util.rdl_type obj
      return t <= self if t
      true
    end

    def instantiate(inst)
      return self
    end

    def hash
      17
    end
  end
end
