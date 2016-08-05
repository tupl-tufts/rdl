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
      other = other.type if other.is_a? DependentArgType
      other = other.canonical
      other.instance_of? TopType
    end

    def leq_inst(other, inst=nil, ileft=true)
      other = other.type if other.is_a? DependentArgType
      other = other.canonical
      if inst && !ileft && other.is_a?(VarType)
        return leq_inst(inst[other.name], inst, ileft) if inst[other.name]
        inst.merge!(other.name => self)
        return true
      end
      return other.is_a? TopType
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
