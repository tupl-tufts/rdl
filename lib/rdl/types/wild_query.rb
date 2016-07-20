module RDL::Type
  class WildQuery < TypeQuery
    @@cache = nil

    class << self
      alias :__new__ :new
    end

    def self.new
      @@cache = WildQuery.__new__ unless @@cache
      return @@cache
    end

    def to_s
      "*"
    end

    def ==(other)
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? WildQuery)
    end

    alias eql? ==

    def <=(other)
      other = other.type if other.is_a? DependentArgType
      other = other.canonical
      return self == other
    end

    def match(other)
      return true
    end
  end
end
