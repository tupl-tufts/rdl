require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestTypeContract < Minitest::Test
  include RDL::Type
  include RDL::Contract

  def setup
    @p = Parser.new
  end

  def test_flat
    cnil = $__rdl_nil_type.to_contract
    assert (cnil.check self, nil)
    assert_raises(TypeError) { cnil.check self, true }
    tfixnum = NominalType.new :Fixnum
    cfixnum = tfixnum.to_contract
    assert (cfixnum.check self, 42)
    assert (cfixnum.check self, nil)
    assert_raises(TypeError) { cfixnum.check self, "42" }
  end

  def test_proc
    t1 = @p.scan_str "(nil) -> nil"
    p1 = t1.to_contract.wrap(self) { |x| nil }
    assert_nil p1.call(nil)
    assert_raises(TypeError) { p1.call(42) }
    p1b = t1.to_contract.wrap(self) { |x| 42 }
    assert_raises(TypeError) { p1b.call(nil) }

    t2 = @p.scan_str "(Fixnum, Fixnum) -> Fixnum"
    p2 = t2.to_contract.wrap(self) { |x, y| x }
    assert_equal 42, p2.call(42, 43)
    assert_equal 42, p2.call(42, nil)
    assert_raises(TypeError) { p2.call(42, 43, 44) }
    assert_raises(TypeError) { p2.call(42, 43, 44, 45) }
    assert_raises(TypeError) { p2.call(42) }
    assert_raises(TypeError) { p2.call }

    t3 = @p.scan_str "() -> nil"
    p3 = t3.to_contract.wrap(self) { nil }
    assert_nil p3.call
    assert_raises(TypeError) { p3.call(42) }

    t4 = @p.scan_str "(Fixnum, ?Fixnum) -> Fixnum"
    p4 = t4.to_contract.wrap(self) { |x| x }
    assert_equal 42, p4.call(42)
    assert_equal 42, p4.call(42, 43)
    assert_raises(TypeError) { p4.call(42, 43, 44) }
    assert_raises(TypeError) { p4.call }

    t5 = @p.scan_str "(Fixnum, *Fixnum) -> Fixnum"
    p5 = t5.to_contract.wrap(self) { |x| x }
    assert_equal 42, p5.call(42)
    assert_equal 42, p5.call(42, 43)
    assert_equal 42, p5.call(42, 43, 44)
    assert_equal 42, p5.call(42, 43, 44, 45)
    assert_raises(TypeError) { p5.call }
    assert_raises(TypeError) { p5.call("42") }
    assert_raises(TypeError) { p5.call(42, "43") }
    assert_raises(TypeError) { p5.call(42, 43, "44") }
    assert_raises(TypeError) { p5.call(42, 43, 44, "45") }

    t6 = @p.scan_str "(Fixnum, ?Fixnum, ?Fixnum, *Fixnum) -> Fixnum"
    p6 = t6.to_contract.wrap(self) { |x| x }
    assert_equal 42, p6.call(42)
    assert_equal 42, p6.call(42, 43)
    assert_equal 42, p6.call(42, 43, 44)
    assert_equal 42, p6.call(42, 43, 44, 45)
    assert_equal 42, p6.call(42, 43, 44, 45, 46)
    assert_raises(TypeError) { p6.call }
    assert_raises(TypeError) { p6.call("42") }
    assert_raises(TypeError) { p6.call(42, "43") }
    assert_raises(TypeError) { p6.call(42, 43, "44") }
    assert_raises(TypeError) { p6.call(42, 43, 44, "45") }
    assert_raises(TypeError) { p6.call(42, 43, 44, 45, "46") }

    t7 = @p.scan_str "(?Fixnum) -> nil"
    p7 = t7.to_contract.wrap(self) { nil }
    assert_nil p7.call
    assert_nil p7.call(42)
    assert_raises(TypeError) { p7.call("42") }
    assert_raises(TypeError) { p7.call(42, 43) }
    assert_raises(TypeError) { p7.call(42, 43, 44) }

    t8 = @p.scan_str "(*Fixnum) -> nil"
    p8 = t8.to_contract.wrap(self) { nil }
    assert_nil p8.call
    assert_nil p8.call(42)
    assert_nil p8.call(42, 43)
    assert_nil p8.call(42, 43, 44)
    assert_raises(TypeError) { p8.call("42") }
    assert_raises(TypeError) { p8.call(42, "43") }
    assert_raises(TypeError) { p8.call(42, 43, "44") }

    t9 = @p.scan_str "(Fixnum arg1, ?Fixnum arg2) -> Fixnum"
    p9 = t9.to_contract.wrap(self) { |x| x }
    assert_equal 42, p9.call(42)
    assert_equal 42, p9.call(42, 43)
    assert_raises(TypeError) { p9.call(42, 43, 44) }
    assert_raises(TypeError) { p9.call }

    t10 = @p.scan_str "(?Fixnum, String) -> Fixnum"
    p10 = t10.to_contract.wrap(self) { |*args| 42 }
    assert_equal 42, p10.call("44")
    assert_equal 42, p10.call(43, "44")
    assert_raises(TypeError) { p10.call() }
    assert_raises(TypeError) { p10.call(43, "44", 45) }

    t11 = @p.scan_str "(Fixnum x {{ x > 42 }}) -> Fixnum"
    p11 = t11.to_contract.wrap(self) { |x| x }
    assert_equal 43, p11.call(43)
    assert_raises(TypeError) { p11.call(42) }

    t12 = @p.scan_str "(Fixnum x {{ x>10 }}, Fixnum y {{ y > x }}) -> Fixnum z {{z > (x+y) }}"
    p12 = t12.to_contract.wrap(self) { |x,y| x+y+1 }
    assert_equal 30, p12.call(14, 15)
    assert_equal 50, p12.call(24, 25)
    assert_raises(TypeError) { p12.call(9,10) }
    assert_raises(TypeError) { p12.call(20,19) }
    p12b = t12.to_contract.wrap(self) { |x,y| x+y }
    assert_raises(TypeError) { p12b.call(42, 43) }
    assert_raises(TypeError) { p12b.call(11, 10) }
    assert_raises(TypeError) { p12b.call(9, 10) }

    t13 = @p.scan_str "(Fixnum, {(Fixnum x {{x>10}}) -> Fixnum}) -> Float"
    p13 = t13.to_higher_contract(self) { |x,y| x+y.call(11)+0.5 }
    assert_equal 53.5, p13.call(42, Proc.new { |x| x })
    assert_raises(TypeError) { p13.call(42.5, Proc.new { |x| x} ) }
    assert_raises(TypeError) { p13.call(42, Proc.new { |x| 0.5 } ) }
    p13b = t13.to_higher_contract(self) { |x,y| x+y.call(10)+0.5 }
    assert_raises(TypeError) { p13b.call(42, Proc.new { |x| x } ) }
    p13c = t13.to_higher_contract(self) { |x,y| x+y.call(11.5)+0.5 }
    assert_raises(TypeError) { p13c.call(42, Proc.new { |x| x } ) }
    p13d = t13.to_higher_contract(self) { |x,y| x+y.call(42) }
    assert_raises(TypeError) { p13d.call(42, Proc.new { |x| x } ) }

    t14 = @p.scan_str "(Fixnum, Fixnum) -> {(Fixnum) -> Fixnum}"
    p14 = t14.to_higher_contract(self) { |x,y| Proc.new {|z| x+y+z} }
    assert_raises(TypeError) { p14.call(42.5, 42) }
    p14b = p14.call(42,42)
    assert_equal 126, p14b.call(42)
    assert_raises(TypeError) { p14b.call(42.5) }
    p14c = t14.to_higher_contract(self) { |x,y| Proc.new {|z| x+y+z+0.5} }
    p14d = p14c.call(42,42)
    assert_raises(TypeError) { p14d.call(42) }

    #contracts involving method blocks
    assert_equal 47, block_contract_test1(42) {|z| z}
    assert_raises(TypeError) { block_contract_test1(42) {|z| 0.5} }
    assert_raises(TypeError) { block_contract_test2(42) {|z| z} }
    assert_raises(TypeError) { block_contract_test1(42) }
    assert_raises(TypeError) { block_contract_test3(42) { |x| x } }
    assert_equal 42, block_contract_test4(42)
    assert_equal 42, block_contract_test4(41) {|x| x+1}
    assert_raises(TypeError) { block_contract_test4(40.5) }
    assert_raises(TypeError) { block_contract_test4(42) {|x| x+1.5} }

    t15 = @p.scan_str "(Fixnum x {{x>y}}, Fixnum y) -> Fixnum"
    p15 = t15.to_contract.wrap(self) { |x, y| x+y }
    assert_equal 21, p15.call(11, 10)
    assert_raises(TypeError) { p15.call(10, 11) }

    t16 = @p.scan_str "(Fixnum x {{x > undefvar}}, Fixnum) -> Fixnum"
    p16 = t16.to_contract.wrap(self) { |x,y| x }
    assert_raises(NameError) { p16.call(10,10) }

    t17 = @p.scan_str "(Fixnum, *String, Fixnum) -> Fixnum"
    p17 = t17.to_contract.wrap(self) { |x| x }
    assert_equal 42, p17.call(42, 43)
    assert_equal 42, p17.call(42, 'foo', 43)
    assert_equal 42, p17.call(42, 'foo', 'bar', 43)
    assert_raises(TypeError) { p17.call }
    assert_raises(TypeError) { p17.call('42') }
    assert_raises(TypeError) { p17.call(42) }
    assert_raises(TypeError) { p17.call(42, '43') }
    assert_raises(TypeError) { p17.call(42, 43, '44') }

    t18 = @p.scan_str "(Fixnum, ?{(Fixnum) -> Fixnum}) -> Fixnum"
    p18 = t18.to_higher_contract(self) { |x,p=nil| if p then p.call(x) else x end }
    assert_equal 42, p18.call(41, Proc.new {|x| x+1})
    assert_equal 42, p18.call(42)
    assert_raises(TypeError) { p18.call(41.5, Proc.new {|x| x+1}) }
    assert_raises(TypeError) { p18.call(41, 1) }
    assert_raises(TypeError) { p18.call(41, Proc.new {|x| x+1.5}) }
    p18b = t18.to_higher_contract(self) { |x,p=nil| if p then p.call(x+0.5) else x end }
    assert_raises(TypeError) { p18b.call(41, Proc.new {|x| x+1}) }


  end

  type '(Fixnum) { (Fixnum) -> Fixnum } -> Fixnum'
  def block_contract_test1(x)
    x+yield(5)
  end

  type '(Fixnum) { (Fixnum) -> Fixnum } -> Float'
  def block_contract_test2(x)
    x+yield(4.5)
  end

  type '(Fixnum) -> Fixnum'
  def block_contract_test3(x)
    42
  end

  type '(Fixnum) ?{(Fixnum) -> Fixnum} -> Fixnum'
  def block_contract_test4(x,&blk)
    return yield(x) if blk
    return x
  end

  def test_proc_names
    t1 = @p.scan_str "(x: Fixnum) -> Fixnum"
    p1 = t1.to_contract.wrap(self) { |x:| x }
    assert_equal 42, p1.call(x: 42)
    assert_raises(TypeError) { p1.call(x: "42") }
    assert_raises(TypeError) { p1.call() }
    assert_raises(TypeError) { p1.call(x: 42, y: 42) }
    assert_raises(TypeError) { p1.call(y: 42) }
    assert_raises(TypeError) { p1.call(42) }
    assert_raises(TypeError) { p1.call(42, x: 42) }
    t2 = @p.scan_str "(x: Fixnum, y: String) -> Fixnum"
    p2 = t2.to_contract.wrap(self) { |x:,y:| x }
    assert_equal 42, p2.call(x: 42, y: "33")
    assert_raises(TypeError) { p2.call() }
    assert_raises(TypeError) { p2.call(x: 42) }
    assert_raises(TypeError) { p2.call(x: "42", y: "33") }
    assert_raises(TypeError) { p2.call(42, "43") }
    assert_raises(TypeError) { p2.call(42, x: 42, y: "33") }
    assert_raises(TypeError) { p2.call(x: 42, y: "33", z: 44) }
    t3 = @p.scan_str "(Fixnum, y: String) -> Fixnum"
    p3 = t3.to_contract.wrap(self) { |x, y:| x }
    assert_equal 42, p3.call(42, y:"43")
    assert_raises(TypeError) { p3.call(42) }
    assert_raises(TypeError) { p3.call(42, y: 43) }
    assert_raises(TypeError) { p3.call() }
    assert_raises(TypeError) { p3.call(42, 43, y: 44) }
    assert_raises(TypeError) { p3.call(42, y: 43, z: 44) }
    t4 = @p.scan_str "(Fixnum, x: Fixnum, y: String) -> Fixnum"
    p4 = t4.to_contract.wrap(self) { |a, x:, y:| a }
    assert_equal 42, p4.call(42, x: 43, y: "44")
    assert_raises(TypeError) { p4.call(42, x: 43) }
    assert_raises(TypeError) { p4.call(42, y: "43") }
    assert_raises(TypeError) { p4.call() }
    assert_raises(TypeError) { p4.call(42, 43, x: 44, y: "45") }
    assert_raises(TypeError) { p4.call(42, x: 43, y: "44", z: 45) }
    t5 = @p.scan_str "(x: Fixnum, y: ?String) -> Fixnum"
    p5 = t5.to_contract.wrap(self) { |x:, **ys| x }
    assert_equal 42, p5.call(x: 42, y: "43")
    assert_equal 42, p5.call(x: 42)
    assert_raises(TypeError) { p5.call() }
    assert_raises(TypeError) { p5.call(x: 42, y: 43) }
    assert_raises(TypeError) { p5.call(x: 42, y: 43, z: 44) }
    assert_raises(TypeError) { p5.call(3, x: 42, y: 43) }
    assert_raises(TypeError) { p5.call(3, x: 42) }
    t6 = @p.scan_str "(x: ?Fixnum, y: String) -> Fixnum"
    p6 = t6.to_contract.wrap(self) { |y:, **xs| 42 }
    assert_equal 42, p6.call(x: 43, y: "44")
    assert_equal 42, p6.call(y: "44")
    assert_raises(TypeError) { p6.call() }
    assert_raises(TypeError) { p6.call(x: "43", y: "44") }
    assert_raises(TypeError) { p6.call(42, x: 43, y: "44") }
    assert_raises(TypeError) { p6.call(x: 43, y: "44", z: 45) }
    t7 = @p.scan_str "(x: ?Fixnum, y: ?String) -> Fixnum"
    p7 = t7.to_contract.wrap(self) { |**args| 42 }
    assert_equal 42, p7.call
    assert_equal 42, p7.call(x: 43)
    assert_equal 42, p7.call(y: "44")
    assert_equal 42, p7.call(x: 43, y: "44")
    assert_raises(TypeError) { p7.call(x: "43", y: "44") }
    assert_raises(TypeError) { p7.call(41, x: 43, y: "44") }
    assert_raises(TypeError) { p7.call(x: 43, y: "44", z: 45) }
    t8 = @p.scan_str "(?Fixnum, x: ?Symbol, y: ?String) -> Fixnum"
    p8 = t8.to_contract.wrap(self) { |*args| 42 }
    assert_equal 42, p8.call
    assert_equal 42, p8.call(43)
    assert_equal 42, p8.call(x: :foo)
    assert_equal 42, p8.call(43, x: :foo)
    assert_equal 42, p8.call(y: "foo")
    assert_equal 42, p8.call(43, y: "foo")
    assert_equal 42, p8.call(x: :foo, y: "foo")
    assert_equal 42, p8.call(43, x: :foo, y: "foo")
    assert_raises(TypeError) { p8.call(43, 44, x: :foo, y: "foo") }
    assert_raises(TypeError) { p8.call(43, x: "foo", y: "foo") }
    assert_raises(TypeError) { p8.call(43, x: :foo, y: "foo", z: 44) }
    t9 = @p.scan_str "(Fixnum, x: String, y: Fixnum, **Float) -> Fixnum"
    p9 = t9.to_contract.wrap(self) { |*args| 42 }
    assert_raises(TypeError) { p9.call }
    assert_raises(TypeError) { p9.call(43) }
    assert_raises(TypeError) { p9.call(43, x: "foo") }
    assert_equal 42, p9.call(43, x: "foo", y: 44)
    assert_equal 42, p9.call(43, x: "foo", y: 44, pi: 3.14)
    assert_equal 42, p9.call(43, x: "foo", y: 44, pi: 3.14, e: 2.72)
    assert_raises(TypeError) { p9.call(43, x: "foo", y: 44, pi: 3) }
    assert_raises(TypeError) { p9.call(43, x: "foo", y: 44, pi: 3.14, e: 3) }
  end

  type '() { () -> nil } -> nil'
  def _test_with_block
    nil
  end

  type '() -> nil'
  def _test_without_block
    nil
  end

  type '() -> nil'
  type '() { () -> nil } -> nil'
  def _test_with_without_block
    nil
  end

  def test_block
    assert_nil(_test_with_block { nil })
    assert_raises(TypeError) { _test_with_block }

    assert_raises(TypeError) { _test_without_block { nil } }
    assert_nil(_test_without_block)

    assert_nil(_test_with_without_block)
    assert_nil(_test_with_without_block { nil })
  end
end
