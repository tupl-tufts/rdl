module RDL::Contract
  class AndContract < Contract
    attr_reader :contracts
    
    def initialize(*contracts)
      @contracts = contracts
    end

    def check(*v, &blk)
      AndContract.check_array(@contracts, *v, &blk)
    end

    # Check an array of contracts a
    def self.check_array(a, *v, &blk)
      # All contracts must be satisfied
      a.all? { |c| c.check(*v, &blk) }
    end
    
    def to_s
      AndContract.array_to_s(@contracts)
    end

    def self.array_to_s(a)
      a.join(' && ')
    end
  end
end