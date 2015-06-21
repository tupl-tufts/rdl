module RDL::Contract
  class OrContract < Contract
    attr_reader :contracts
    
    def initialize(*contracts)
      @contracts = contracts
    end

    def check(*v, &blk)
      # All contracts must be satisfied
      @contracts.each { |c|
        begin
          c.check(*v, &blk)
          return true
        rescue ContractError
        end
      }
      raise ContractError, "#{v.inspect} does not satisfy #{self}"
    end
    
    def to_s
      @contracts.join(' && ')
    end
  end
end