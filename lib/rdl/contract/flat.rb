module RDL::Contract
  class FlatContract < Contract
    attr_accessor :desc

    def initialize(desc="No Description", &blk)
      @pred = blk
      @desc = desc
    end

    def check(*v, &blk)
      if (@pred &&
          ((@pred.arity < 0) ? (@pred.arity.abs - 1) <= v.size : @pred.arity == v.size)) then
        # TODO: Labels and proc.parameters :lbl, :rest
        unless blk ? @pred.call(*v, &blk) : @pred.call(*v)
          raise ContractException,
                "#{v.inspect} does not satisfy #{self}"
        end
      else
        raise ContractException,
              "Invalid number of arguments: Expecting #{@pred.arity}, got #{v.size}"
      end
      true
    end

    def to_s
      @desc
    end
  end
end