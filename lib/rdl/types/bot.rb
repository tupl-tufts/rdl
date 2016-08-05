module RDL::Type
  class BotType < Type
    @@cache = nil

    class << self
      alias :__new__ :new
    end

    def self.new
      @@cache = BotType.__new__ unless @@cache
      return @@cache
    end

    def initialize
      super
    end

    def to_s
      "%bot"
    end

    def ==(other)
      other.instance_of? BotType
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
      # There are no values of this type (note nil does *not* have type %bot)
      false
    end

    def instantiate(inst)
      return self
    end

    def hash
      13
    end
  end
end
