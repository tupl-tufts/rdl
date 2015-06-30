require_relative 'type'

module RDL::Type
  class VarType < Type
    attr_reader :name

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(name)
      name = name.to_s.to_sym
      t = @@cache[name]
      return t if t
      t = self.__new__ name
      return (@@cache[name] = t) # assignment evaluates to t
    end

    def initialize(name)
      @name = name
    end

    def to_s(inst: nil) # :nodoc:
      # don't signal unbound variables in to_s, since it makes error reporting hard
      return "self" if @name == :self && inst && inst[@name]
      return inst[@name].to_s(inst: inst) if inst && inst.class == Hash && inst[@name]
      return @name.to_s
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

    def member?(obj, inst: nil)
      return inst[@name].equal? obj if @name == :self && inst && inst[@name]
      return inst[@name].member?(obj, inst: inst) if inst && inst[@name]
      return true if inst && inst.has_key?(@name)
      # otherwise this is an unbound variable
      raise TypeError, "Unbound type variable #{@name}"
    end
  end
end
