require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestContract < Minitest::Test
  include RDL::Contract

  def test_flat
    pos = FlatContract.new("Positive") { |x| x > 0 }
    assert_equal "Positive", pos.to_s
    assert_raises(ContractError) { pos.check 0 }
    assert (pos.check 1)
    gt = FlatContract.new("Greater Than") { |x, y| x > y }
    assert (gt.check 4, 3)
    assert_raises(ContractError) { gt.check 3, 4 }
  end

  def test_and
    pos = FlatContract.new("Positive") { |x| x > 0 }
    five = FlatContract.new("Five") { |x| x == 5 }
    gt = FlatContract.new("Greater Than 3") { |x| x > 3 }
    posfive = AndContract.new(pos, five)
    assert_equal "Positive && Five", posfive.to_s
    posfivegt = AndContract.new(pos, five, gt)
    assert (posfive.check 5)
    assert_raises(ContractError) { posfive.check 4 }
    assert (posfivegt.check 5)
    assert_raises(ContractError) { posfivegt.check 4 }
  end
  
  def test_or
    pos = FlatContract.new("Positive") { |x| x > 0 }
    zero = FlatContract.new("Zero") { |x| x == 0 }
    neg = FlatContract.new("Neg") { |x| x < 0 }
    poszero = OrContract.new(pos, zero)
    assert_equal "Positive && Zero", poszero.to_s
    poszeroneg = OrContract.new(pos, zero, neg)
    assert (poszero.check 1)
    assert (poszero.check 0)
    assert_raises(ContractError) { poszero.check (-1) }
    assert (poszeroneg.check (-1))
  end

  def test_proc
    pos = FlatContract.new("Positive") { |x| x > 0 }
    neg = FlatContract.new("Negative") { |ret, x| ret < 0 }
    pc = ProcContract.new(pre_cond: pos, post_cond: neg)
    proc1 = pc.wrap { |x| -x }
    assert (proc1.call(42))
    assert_raises(ContractError) { proc1.call(-42) }
    proc2 = pc.wrap { |x| x }
    assert_raises(ContractError) { proc2.call(42) }
  end

  def test_turn_off
    foo = FlatContract.new("Foo") {
      pos = FlatContract.new("Positive") { |x| x > 0 }
      pos.check (-42)
      true
    }
    assert_equal true, foo.check
  end
end