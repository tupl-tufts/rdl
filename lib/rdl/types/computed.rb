require_relative 'type'

module RDL::Type
  class ComputedType < Type
    attr_reader :code

    def initialize(code)
      @code = code
      super()
    end

    def compute(bind)
      res = bind.eval(@code)
      raise RuntimeError, "Expected ComputedType to evaluate to type, instead got #{res}." unless res.is_a?(Type)
      res
    end

    def to_s
      "``#{@code}``"
    end

    ### TODO:: Figure out how to fill in the below methods.
    ### I believe a ComputedType will always be evaluated to
    ### another RDL type before any of these methods would be called.
    ### Need to think about this though.

    def instantiate(inst)
      @inst = inst
      self
    end

    def widen
      self
    end
    
    def <=(other)
      ## TODO
    end

    def ==(other)
      ## TODO
    end

    alias eql? ==


  end
end
