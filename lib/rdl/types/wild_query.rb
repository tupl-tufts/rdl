require_relative 'type_query'

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
      return (other.instance_of? WildQuery)
    end

    def match(other)
      return true
    end
  end
end
