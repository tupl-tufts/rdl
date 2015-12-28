require_relative 'query'

module RDL::Query
  class MethodQuery < Query
    attr_reader :args
    attr_reader :block
    attr_reader :ret

    # Create a new MethodQuery
    def initialize(args, block, ret)
      @args = *args
      @block = block
      @ret = ret
      super()
    end

    def ==(other)
      return (other.instance_of? MethodQuery) &&
        (other.args == @args) &&
        (other.block == @block) &&
        (other.ret == @ret)
    end
  end
end
