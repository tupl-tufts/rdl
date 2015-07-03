require_relative 'type'

module RDL::Type
  class SingletonType < Type
    attr_reader :val

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(val)
      t = @@cache[val]
      return t if t
      t = self.__new__ val
      return (@@cache[val] = t) # assignment evaluates to t
    end

    def initialize(val)
      @val = val
    end

    def eql?(other)
      self == other
    end

    def ==(other)
      return (other.instance_of? self.class) && (other.val == @val)
    end

    def hash # :nodoc:
      return @val.hash
    end

    def to_s
      val.to_s
    end

    def <=(other)
      other.instance_of?(TopType) ||
        (other.instance_of?(SingletonType) && other.val == @val) ||
        (other.instance_of?(NominalType) && @val.class == other.klass) ||
        (other.instance_of?(NominalType) && @val.class.ancestors.member?(other.klass))
    end

    def member?(obj)
      obj.nil? || obj == @val
    end
    
    def instantiate(inst)
      return self
    end
  end
end
