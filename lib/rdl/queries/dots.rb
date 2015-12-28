require_relative 'query'

module RDL::Query
  class DotsQuery < Query
    @@cache = nil

    class << self
      alias :__new__ :new
    end

    def self.new
      @@cache = DotsQuery.__new__ unless @@cache
      return @@cache
    end

    def to_s
      "..."
    end

    def ==(other)
      return (other.instance_of? DotsQuery)
    end
  end
end
