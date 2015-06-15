require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class ContractTest < Minitest::Test
  include RDL::Contract
  
  def test_flat
    pos = FlatContract.new("Positive") { |x| x > 0 }
    assert_equal pos.to_s, "Positive"
    assert_raises(ContractException) { pos.check 0 }
    assert (pos.check 1)
    gt = FlatContract.new("Greater Than") { |x, y| x > y }
    assert (gt.check 4, 3)
    assert_raises(ContractException) { gt.check 3, 4 }
  end

  def test_and
    pos = FlatContract.new("Positive") { |x| x > 0 }
    five = FlatContract.new("Five") { |x| x == 5 }
    gt = FlatContract.new("Greater Than 3") { |x| x > 3 }
    posfive = AndContract.new(pos, five)
    assert_equal posfive.to_s, "Positive && Five"
    posfivegt = AndContract.new(pos, five, gt)
    assert (posfive.check 5)
    assert_raises(ContractException) { posfive.check 4 }
    assert (posfivegt.check 5)
    assert_raises(ContractException) { posfivegt.check 4 }
  end
  
  def test_or
    pos = FlatContract.new("Positive") { |x| x > 0 }
    zero = FlatContract.new("Zero") { |x| x == 0 }
    neg = FlatContract.new("Neg") { |x| x < 0 }
    poszero = OrContract.new(pos, zero)
    assert_equal poszero.to_s, "Positive && Zero"
    poszeroneg = OrContract.new(pos, zero, neg)
    assert (poszero.check 1)
    assert (poszero.check 0)
    assert_raises(ContractException) { poszero.check (-1) }
    assert (poszeroneg.check (-1))
  end
end