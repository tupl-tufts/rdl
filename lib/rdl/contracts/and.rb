module RDL::Contract
  class AndContract < Contract
    attr_reader :contracts
    
    def initialize(*contracts)
      @contracts = contracts
    end

    # [:slf:] is bound to self when the contracts are checked
    def check(slf, *v, &blk)
      AndContract.check_array(@contracts, slf, *v, &blk)
    end

    # Check an array of contracts a
    # [:slf:] is bound to self when the contracts are checked
    def self.check_array(a, slf, *v, &blk)
      # All contracts must be satisfied
      a.all? { |c| c.check(slf, *v, &blk) }
    end
    
    def to_s
      AndContract.array_to_s(@contracts)
    end

    def self.array_to_s(a)
      a.join(' && ')
    end
  end
end
