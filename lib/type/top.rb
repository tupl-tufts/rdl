require 'singleton'
require_relative './type'

module RDL::Type
  class TopType < Type
    include Singleton

    def initialize
      super
    end

    def to_s
      "%top"
    end
      
    def ==(other)
      other.instance_of? TopType
    end

    def hash
      17
    end
  end
end
