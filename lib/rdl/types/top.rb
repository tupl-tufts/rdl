require_relative 'type'

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

    def map
      self
    end

    def each
      yield self
    end

    def to_s
      "%top"
    end

    def eql?(other)
      self == other
    end
      
    def ==(other)
      other.instance_of? TopType
    end

    def le(other, h={})
      if other.instance_of?(TopType)
        true
      elsif other.instance_of?(VarType)
        if h.keys.include? other.name
          h[other.name] = UnionType.new(h[other.name], self)
        else
          h[other.name] ||= self
        end

        true
      else
        false
      end
    end

    def hash
      17
    end
  end
end
