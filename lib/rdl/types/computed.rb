require_relative 'type'

module RDL::Type
  class ComputedType < Type
    attr_reader :code

    def initialize(code)
      @code = code
    end




    ### TODO:: Figure out how to fill in the below methods.
    ### I believe a ComputedType will always be resolved to
    ### another RDL type before any of these methods would be called.
    ### Need to think about this though.
    
    def <=(other)
      ## TODO
    end

    def ==(other)
      ## TODO
    end

    alias eql? ==
    
    def instantiate(inst)
      ## TODO
    end

  end
end
