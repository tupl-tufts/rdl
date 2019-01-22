module RDL::Type
  class DynamicType < Type
    @@cache = nil

    attr_reader :block

    class << self
      alias :__new__ :new
    end

    def self.new
      @@cache = DynamicType.__new__ unless @@cache
      return @@cache
    end

    def initialize
      super
    end

    def to_s
      "%dyn"
    end

    def ==(other)
      return false if other.nil?
      other = other.canonical
      other.instance_of? DynamicType
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
      16
    end
  end
end
