require_relative 'type'

module RDL::Type
  class NominalType < Type
    attr_reader :name
    
    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(name)
      name = name.to_s.to_sym
      t = @@cache[name]
      if not t
        t = self.__new__ name
        @@cache[name] = t
      end

      return t
    end

    def initialize(name)
      @name = name
    end

    def eql?(other)
      self == other
    end

    def ==(other)
      return (other.instance_of? self.class) && (other.name.to_s == @name.to_s)
    end

    def hash # :nodoc:
      return @name.to_s.hash
    end

    def to_s
      "NominalType<#{@name}>"
    end

    def klass
      name.to_s.split("::").inject(Object) { |base, name| base.const_get(name) }
    end

    def member?(obj)
      obj.nil? || obj.class.ancestors.member?(klass)
    end
  end
end
