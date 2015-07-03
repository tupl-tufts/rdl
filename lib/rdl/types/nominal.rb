require_relative 'type'

module RDL::Type
  class NominalType < Type
    attr_reader :name # string
    
    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(name)
      name = name.to_s
      return NilType.new if name == "NilClass"
      t = @@cache[name]
      return t if t
      t = self.__new__ name
      return (@@cache[name] = t) # assignment evaluates to t
    end

    def initialize(name)
      @name = name
    end

    def eql?(other)
      self == other
    end

    def ==(other)
      return (other.instance_of? self.class) && (other.name == @name)
    end

    def hash # :nodoc:
      return @name.hash
    end

    def to_s
      return @name
    end

    def klass
      @klass = RDL::Util.to_class(name) unless @klass
      return @klass
    end

    def <=(other)
      other.instance_of?(TopType) ||
#        (other.instance_of?(NominalType) && other.name == @name) ||
        (other.instance_of?(NominalType) && klass.ancestors.member?(other.klass)) ||
        (other.instance_of?(GenericType) && self <= other.base)  # raw type comparison always succeeds
    end

    def member?(obj)
      return true if obj.nil?
      k = klass
      return (obj.class == k || obj.class.ancestors.member?(klass)) # short-circuit most likely case
    end
    
    def instantiate(inst)
      return self
    end
  end
end
