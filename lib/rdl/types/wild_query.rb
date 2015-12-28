require_relative 'query'

module RDL::Type
  class WildQuery < Query
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

  end
end
