require_relative 'type_query'

module RDL::Type
  class DotsQuery < TypeQuery
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

    # doesn't have match method---taken care of at a higher level, in MethodType#match
  end
end
