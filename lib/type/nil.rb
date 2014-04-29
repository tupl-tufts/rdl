require 'singleton'
require_relative './type'

module RDL::Type
  class NilType < Type
    include Singleton

    def initialize
      super
    end

    def to_s
      "nil"
    end

    def ==(other)
      other.instance_of? NilType
    end

    def hash
      13
    end
  end
end
