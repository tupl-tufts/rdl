module RDL::Contract
  class FlatContract < Contract
    attr_accessor :desc

    def initialize(desc="No Description", &blk)
      @pred = blk
      @desc = desc
    end

    def check(slf, *v, &blk)
      $__rdl_contract_switch.off {
        if (@pred &&
            ((@pred.arity < 0) ? (@pred.arity.abs - 1) <= v.size : @pred.arity == v.size)) then
          unless blk ? slf.instance_exec(*v, blk, &@pred) : slf.instance_exec(*v, &@pred) # TODO: Fix blk
          #unless blk ? x=@pred.call(*v, &blk) : x=@pred.call(*v)
            raise ContractError,
                  "#{v.inspect} does not satisfy #{self.to_s}"
          end
        else
          raise ContractError,
                "Invalid number of arguments: Expecting #{@pred.arity}, got #{v.size}"
        end
      }
      return true
    end

    def to_s
      @desc
    end
  end
end
