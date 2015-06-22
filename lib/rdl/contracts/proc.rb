module RDL::Contract
  class ProcContract < Contract
    attr_accessor :pre_cond, :post_cond

    def initialize(pre_cond:nil, post_cond:nil)
      @pre_cond = pre_cond
      @post_cond = post_cond
    end

    def wrap(&blk)
      Proc.new {|*v, &other_blk|
        @pre_cond.check(*v, &other_blk)
        tmp = blk.call(*v, &other_blk)
        @post_cond.check(tmp, *v, &other_blk)
        tmp
      }
    end
    
    def to_s
      "(#{@pre_cond}) -> (#{@post_cond})"
    end
  end
end