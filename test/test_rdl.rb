require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class RDLTest < Minitest::Test

  # Test wrapping with no types or contracts
  def test_wrap
    def m1(x) return x; end
    def m2(x) return x; end
    def m3(x) return x; end
    def m4(x) return x; end
    assert(not(RDL::Wrap.wrapped?(RDLTest, :m1)))
    assert(not(RDL::Wrap.wrapped?(RDLTest, :m2)))
    assert(not(RDL::Wrap.wrapped?(RDLTest, :m3)))
    assert(not(RDL::Wrap.wrapped?(RDLTest, :m4)))
    RDL::Wrap.wrap(RDLTest, :m1)
    RDL::Wrap.wrap("RDLTest", :m2)
    RDL::Wrap.wrap(:RDLTest, :m3)
    RDL::Wrap.wrap(RDLTest, "m4")
    assert(RDL::Wrap.wrapped?(RDLTest, :m1))
    assert(RDL::Wrap.wrapped?(RDLTest, :m2))
    assert(RDL::Wrap.wrapped?(RDLTest, :m3))
    assert(RDL::Wrap.wrapped?(RDLTest, :m4))
    assert_equal 3, m1(3)
    assert_equal 3, m2(3)
    assert_equal 3, m3(3)
    assert_equal 3, m4(3)
  end

  def test_pre_contract
    pos = RDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    def m5(x) return x; end
    RDL::Wrap.pre(RDLTest, :m5, pos)
    assert_equal 3, m5(3)
    assert_raises(RDL::Contract::ContractException) { m5(-1) }
  end

  def test_post_contract
    neg = RDL::Contract::FlatContract.new("Negative") { |x| x < 0 }
    def m6(x) return 3; end
    RDL::Wrap.post(RDLTest, :m6, neg)
    assert_raises(RDL::Contract::ContractException) { m6(42) }
  end

  def test_pre_post_contract
    pos = RDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    ppos = RDL::Contract::FlatContract.new("Positive") { |r, x| r > 0 }
    def m7(x) return x; end
    RDL::Wrap.pre(RDLTest, :m7, pos)
    RDL::Wrap.post(RDLTest, :m7, ppos)
    assert_equal 3, m7(3)
  end

  def test_and_contract
    pos = RDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    five = RDL::Contract::FlatContract.new("Five") { |x| x == 5 }
    gt = RDL::Contract::FlatContract.new("Greater Than 3") { |x| x > 3 }
    def m8(x) return x; end
    RDL::Wrap.pre(RDLTest, :m8, pos)
    RDL::Wrap.pre(RDLTest, :m8, gt)
    assert_equal 5, m8(5)
    assert_equal 4, m8(4)
    assert_raises(RDL::Contract::ContractException) { m8 3 }
    def m9(x) return x; end
    RDL::Wrap.pre(RDLTest, :m9, pos)
    RDL::Wrap.pre(RDLTest, :m9, gt)
    RDL::Wrap.pre(RDLTest, :m9, five)
    assert_equal 5, m9(5)
    assert_raises(RDL::Contract::ContractException) { m9 4 }
    assert_raises(RDL::Contract::ContractException) { m9 3 }

    ppos = RDL::Contract::FlatContract.new("Positive") { |r, x| r > 0 }
    pfive = RDL::Contract::FlatContract.new("Five") { |r, x| r == 5 }
    pgt = RDL::Contract::FlatContract.new("Greater Than 3") { |r, x| r > 3 }
    def m10(x) return x; end
    RDL::Wrap.post(RDLTest, :m10, ppos)
    RDL::Wrap.post(RDLTest, :m10, pgt)
    assert_equal 5, m10(5)
    assert_equal 4, m10(4)
    assert_raises(RDL::Contract::ContractException) { m10 3 }
    def m11(x) return x; end
    RDL::Wrap.post(RDLTest, :m11, ppos)
    RDL::Wrap.post(RDLTest, :m11, pgt)
    RDL::Wrap.post(RDLTest, :m11, pfive)
    assert_equal 5, m11(5)
    assert_raises(RDL::Contract::ContractException) { m11 4 }
    assert_raises(RDL::Contract::ContractException) { m11 3 }
  end

  def test_process_pre_post_args
    ppos = RDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    assert_equal [RDLTest, :m1, ppos], RDL::Wrap.process_pre_post_args(self.class, RDLTest, :m1, ppos)
    assert_equal [RDLTest, :m1, ppos], RDL::Wrap.process_pre_post_args(self.class, RDLTest, "m1", ppos)
    assert_equal [RDLTest, :m1, ppos], RDL::Wrap.process_pre_post_args(self.class, :m1, ppos)
    assert_equal [RDLTest, nil, ppos], RDL::Wrap.process_pre_post_args(self.class, ppos)
    klass1, meth1, c1 = RDL::Wrap.process_pre_post_args(self.class, RDLTest, :m1) { |x| x > 0 }
    assert_equal [RDLTest, :m1], [klass1, meth1]
    assert (c1.is_a? RDL::Contract::FlatContract)

    klass2, meth2, c2 = RDL::Wrap.process_pre_post_args(self.class, :m1) { |x| x > 0 }
    assert_equal [RDLTest, :m1], [klass2, meth2]
    assert (c2.is_a? RDL::Contract::FlatContract)

    klass3, meth3, c3 = RDL::Wrap.process_pre_post_args(self.class) { |x| x > 0 }
    assert_equal [RDLTest, nil], [klass3, meth3]
    assert (c3.is_a? RDL::Contract::FlatContract)
    
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class) }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, 42) }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, 42) { |x| x > 0} }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, ppos) { |x| x > 0 } }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, :m1) }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, RDLTest) }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, RDLTest) { |x| x > 0 } }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, RDLTest, ppos) }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, RDLTest, :m1, ppos, 42) }
  end

end