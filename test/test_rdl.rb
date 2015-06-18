require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class RDLTest < Minitest::Test

  def setup
    @cpos = RDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    @cneg = RDL::Contract::FlatContract.new("Positive") { |x| x < 0 }
  end
  
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
    def m5(x) return x; end
    RDL::Wrap.pre(RDLTest, :m5, @cpos)
    assert(m5(3), 3)
    assert_raises(RDL::Contract::ContractException) { m5(-1) }
  end
end