require_relative 'type'

module RDL::Type
  class NominalType < Type
    attr_reader :name
    
    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(name)
      name = name.to_s
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
      name
    end

    def klass
      @klass = RDL::Util.to_class(name) unless @klass
      return @klass
    end

    def member?(obj)
      obj.nil? || obj.class.ancestors.member?(klass)
    end
  end
end
