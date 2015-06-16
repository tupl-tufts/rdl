require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TypeContractTest < Minitest::Test
  include RDL::Type
  include RDL::Contract

  def setup
    @p = Parser.new
  end
  
  def test_flat
    tnil = NilType.new
    cnil = tnil.to_contract
    assert (cnil.check nil)
    assert_raises(TypeException) { cnil.check true }
    tfixnum = NominalType.new :Fixnum
    cfixnum = tfixnum.to_contract
    assert (cfixnum.check 42)
    assert (cfixnum.check nil)
    assert_raises(TypeException) { cfixnum.check "42" }
  end

  def test_proc
    t1 = @p.scan_str "(nil) -> nil"
    p1 = t1.to_contract.wrap { |x| nil }
    assert_nil p1.call(nil)
    assert_raises(TypeException) { p1.call(42) }
    p1b = t1.to_contract.wrap { |x| 42 }
    assert_raises(TypeException) { p1b.call(nil) }

    t2 = @p.scan_str "(Fixnum, Fixnum) -> Fixnum"
    p2 = t2.to_contract.wrap { |x, y| x }
    assert_equal p2.call(42, 43), 42
    assert_equal p2.call(42, nil), 42
    assert_raises(TypeException) { p2.call(42, 43, 44) }
    assert_raises(TypeException) { p2.call(42, 43, 44, 45) }
    assert_raises(TypeException) { p2.call(42) }
    assert_raises(TypeException) { p2.call }

    t3 = @p.scan_str "() -> nil"
    p3 = t3.to_contract.wrap { nil }
    assert_nil p3.call
    assert_raises(TypeException) { p3.call(42) }
    
    t4 = @p.scan_str "(Fixnum, ?Fixnum) -> Fixnum"
    p4 = t4.to_contract.wrap { |x| x }
    assert_equal p4.call(42), 42
    assert_equal p4.call(42, 43), 42
    assert_raises(TypeException) { p4.call(42, 43, 44) }
    assert_raises(TypeException) { p4.call }

    t5 = @p.scan_str "(Fixnum, *Fixnum) -> Fixnum"
    p5 = t5.to_contract.wrap { |x| x }
    assert_equal p5.call(42), 42
    assert_equal p5.call(42, 43), 42
    assert_equal p5.call(42, 43, 44), 42
    assert_equal p5.call(42, 43, 44, 45), 42
    assert_raises(TypeException) { p5.call }
    assert_raises(TypeException) { p5.call("42") }
    assert_raises(TypeException) { p5.call(42, "43") }
    assert_raises(TypeException) { p5.call(42, 43, "44") }
    assert_raises(TypeException) { p5.call(42, 43, 44, "45") }

    t6 = @p.scan_str "(Fixnum, ?Fixnum, ?Fixnum, *Fixnum) -> Fixnum"
    p6 = t6.to_contract.wrap { |x| x }
    assert_equal p6.call(42), 42
    assert_equal p6.call(42, 43), 42
    assert_equal p6.call(42, 43, 44), 42
    assert_equal p6.call(42, 43, 44, 45), 42
    assert_equal p6.call(42, 43, 44, 45, 46), 42
    assert_raises(TypeException) { p6.call }
    assert_raises(TypeException) { p6.call("42") }
    assert_raises(TypeException) { p6.call(42, "43") }
    assert_raises(TypeException) { p6.call(42, 43, "44") }
    assert_raises(TypeException) { p6.call(42, 43, 44, "45") }
    assert_raises(TypeException) { p6.call(42, 43, 44, 45, "46") }

    t7 = @p.scan_str "(?Fixnum) -> nil"
    p7 = t7.to_contract.wrap { nil }
    assert_nil p7.call
    assert_nil p7.call(42)
    assert_raises(TypeException) { p7.call("42") }
    assert_raises(TypeException) { p7.call(42, 43) }
    assert_raises(TypeException) { p7.call(42, 43, 44) }

    t8 = @p.scan_str "(*Fixnum) -> nil"
    p8 = t8.to_contract.wrap { nil }
    assert_nil p8.call
    assert_nil p8.call(42)
    assert_nil p8.call(42, 43)
    assert_nil p8.call(42, 43, 44)
    assert_raises(TypeException) { p8.call("42") }
    assert_raises(TypeException) { p8.call(42, "43") }
    assert_raises(TypeException) { p8.call(42, 43, "44") }

    #TODO: Names
  end
end