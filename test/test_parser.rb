require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestParser < Minitest::Test
  include RDL::Type

  def setup
    @p = Parser.new
    @tnil = NilType.new
    @ttop = TopType.new
    @tfixnum = NominalType.new Fixnum
    @tfixnumopt = OptionalType.new @tfixnum
    @tfixnumvararg = VarargType.new @tfixnum
    @tstring = NominalType.new String
    @tstringopt = OptionalType.new @tstring
    @tenum = NominalType.new :Enumerator
    @ttrue = NominalType.new TrueClass
    @tfalse = NominalType.new FalseClass
    @tbool = UnionType.new @ttrue, @tfalse
    @ta = NominalType.new :A
    @tb = NominalType.new :B
    @tc = NominalType.new :C
    @tfixnumx = AnnotatedArgType.new("x", @tfixnum)
    @tfixnumy = AnnotatedArgType.new("y", @tfixnum)
    @tfixnumret = AnnotatedArgType.new("ret", @tfixnum)
    @tfixnumoptx = AnnotatedArgType.new("x", @tfixnumopt)
    @tfixnumvarargx = AnnotatedArgType.new("x", @tfixnumvararg)
    @tsymbol = SingletonType.new(:symbol)
    @tsymbolx = AnnotatedArgType.new("x", @tsymbol)
  end

  def test_basic
    t1 = @p.scan_str "(nil) -> nil"
    assert_equal (MethodType.new [@tnil], nil, @tnil), t1
    t2 = @p.scan_str "(Fixnum, Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnum], nil, @tfixnum), t2
    t3 = @p.scan_str "() -> Enumerator"
    assert_equal (MethodType.new [], nil, @tenum), t3
    t4 = @p.scan_str "(%any) -> nil"
    assert_equal (MethodType.new [@ttop], nil, @tnil), t4
    t5 = @p.scan_str "(%bool) -> Fixnum"
    assert_equal (MethodType.new [@tbool], nil, @tfixnum), t5
    assert_raises(RuntimeError) { @p.scan_str "(%foo) -> nil" }
    t6 = @p.scan_str "(A) -> nil"
    assert_equal (MethodType.new [@ta], nil, @tnil), t6
    t7 = @p.scan_str "(TestParser::A) -> nil"
    assert_equal (MethodType.new [NominalType.new("TestParser::A")], nil, @tnil), t7
    t8 = @p.scan_str "(Fixnum) { (%any, String) -> nil } -> :symbol"
    assert_equal (MethodType.new [@tfixnum], MethodType.new([@ttop, @tstring], nil, @tnil), @tsymbol), t8
  end

  def test_opt_vararg
    t1 = @p.scan_str "(Fixnum, ?Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnumopt], nil, @tfixnum), t1
    t2 = @p.scan_str "(Fixnum, *Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnumvararg], nil, @tfixnum), t2
    t3 = @p.scan_str "(Fixnum, ?Fixnum, ?Fixnum, *Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnumopt, @tfixnumopt, @tfixnumvararg], nil, @tfixnum), t3
    t4 = @p.scan_str "(?Fixnum) -> nil"
    assert_equal (MethodType.new [@tfixnumopt], nil, @tnil), t4
    t5 = @p.scan_str "(*Fixnum) -> nil"
    assert_equal (MethodType.new [@tfixnumvararg], nil, @tnil), t5
  end

  def test_union
    t1 = @p.scan_str "(A or B) -> nil"
    assert_equal (MethodType.new [UnionType.new(@ta, @tb)], nil, @tnil), t1
    t2 = @p.scan_str "(A or B or C) -> nil"
    assert_equal (MethodType.new [UnionType.new(@ta, @tb, @tc)], nil, @tnil), t2
    t3 = @p.scan_str "() -> A or B or C"
    assert_equal (MethodType.new [], nil, UnionType.new(@ta, @tb, @tc)), t3
  end

  def test_bare
    t1 = @p.scan_str "## nil"
    assert_equal @tnil, t1
    t2 = @p.scan_str "## %any"
    assert_equal @ttop, t2
    t3 = @p.scan_str "## A"
    assert_equal NominalType.new("A"), t3
  end

  def test_symbol
    t1 = @p.scan_str "## :symbol"
    assert_equal @tsymbol, t1
  end

  def test_annotated_params
    t1 = @p.scan_str "(Fixnum 'x', Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, @tfixnum], nil, @tfixnum), t1
    t2 = @p.scan_str "(Fixnum, ?Fixnum 'x') -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnumoptx], nil, @tfixnum), t2
    t3 = @p.scan_str "(Fixnum, *Fixnum 'x') -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnumvarargx], nil, @tfixnum), t3
    t4 = @p.scan_str "(Fixnum, Fixnum 'y') -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnumy], nil, @tfixnum), t4
    t5 = @p.scan_str "(Fixnum 'x', Fixnum 'y') -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, @tfixnumy], nil, @tfixnum), t5
    t6 = @p.scan_str "(Fixnum, Fixnum) -> Fixnum 'ret'"
    assert_equal (MethodType.new [@tfixnum, @tfixnum], nil, @tfixnumret), t6
    t7 = @p.scan_str "(Fixnum 'x', Fixnum) -> Fixnum 'ret'"
    assert_equal (MethodType.new [@tfixnumx, @tfixnum], nil, @tfixnumret), t7
    t8 = @p.scan_str "(Fixnum, Fixnum 'y') -> Fixnum 'ret'"
    assert_equal (MethodType.new [@tfixnum, @tfixnumy], nil, @tfixnumret), t8
    t9 = @p.scan_str "(Fixnum 'x', Fixnum 'y') -> Fixnum 'ret'"
    assert_equal (MethodType.new [@tfixnumx, @tfixnumy], nil, @tfixnumret), t9
    t10 = @p.scan_str "(:symbol 'x') -> Fixnum"
    assert_equal (MethodType.new [@tsymbolx], nil, @tfixnum), t10
    t11 = @p.scan_str '(Fixnum "x", Fixnum) -> Fixnum'
    assert_equal (MethodType.new [@tfixnumx, @tfixnum], nil, @tfixnum), t11
  end

  def test_generic
    t1 = @p.scan_str "## t"
    assert_equal (VarType.new "t"), t1
    t2 = @p.scan_str "## Array"
    assert_equal (NominalType.new "Array"), t2
    t3 = @p.scan_str "## Array<t>"
    assert_equal (GenericType.new(t2, t1)), t3
    t4 = @p.scan_str "## Array<Array<t>>"
    assert_equal (GenericType.new(t2, t3)), t4
    t5 = @p.scan_str "## Hash"
    assert_equal (NominalType.new "Hash"), t5
    t6 = @p.scan_str "## Hash<u, v>"
    assert_equal (GenericType.new(t5, VarType.new("u"), VarType.new("v"))), t6
    t7 = @p.scan_str "## Foo<String, Array<t>, Array<Array<t>>>"
    assert_equal (GenericType.new(NominalType.new("Foo"), @tstring, t3, t4)), t7
  end

  def test_tuple
    t1 = @p.scan_str "## [Fixnum, String]"
    assert_equal (TupleType.new(@tfixnum, @tstring)), t1
    t2 = @p.scan_str "## [String]"
    assert_equal (TupleType.new(@tstring)), t2
  end 

  def test_fixnum
    t1 = @p.scan_str "## 42"
    assert_equal (SingletonType.new(42)), t1
    t2 = @p.scan_str "## -42"
    assert_equal (SingletonType.new(-42)), t2
  end

  def test_float
    t1 = @p.scan_str "## 3.14"
    assert_equal (SingletonType.new(3.14)), t1
  end

  def test_const
    t1 = @p.scan_str "## ${Math::PI}"
    assert_equal (SingletonType.new(Math::PI)), t1
  end

  def test_type_alias
    type_alias '%foobarbaz', @tnil
    assert_equal @tnil, (@p.scan_str "## %foobarbaz")
    type_alias '%quxquxqux', 'nil'
    assert_equal @tnil, (@p.scan_str "## %quxquxqux")
    assert_raises(RuntimeError) { type_alias '%quxquxqux', 'nil' }
    assert_raises(RuntimeError) { @p.scan_str "## %qux" }
  end

  def test_structural
    t1 = @p.scan_str "## [to_str: () -> String]"
    tm1 = MethodType.new [], nil, @tstring
    ts1 = StructuralType.new(to_str: tm1)
    assert_equal ts1, t1
  end

  def test_finite_hash
    t1 = @p.scan_str "## {a: Fixnum, b: String}"
    assert_equal (FiniteHashType.new({a: @tfixnum, b: @tstring})), t1
    t2 = @p.scan_str "## {'a'=>Fixnum, 2=>String}"
    assert_equal (FiniteHashType.new({"a"=>@tfixnum, 2=>@tstring})), t2
  end

  def test_named_params
    t1 = @p.scan_str "(Fixnum, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, FiniteHashType.new(x: @tfixnum)], nil, @tfixnum), t1
    t2 = @p.scan_str "(Fixnum, x: Fixnum, y: String) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, FiniteHashType.new(x: @tfixnum, y: @tstring)], nil, @tfixnum), t2
    t3 = @p.scan_str "(Fixnum, y: String, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, FiniteHashType.new(x: @tfixnum, y: @tstring)], nil, @tfixnum), t3
    t4 = @p.scan_str "(Fixnum, y: String, x: ?Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, FiniteHashType.new(x: @tfixnumopt, y: @tstring)], nil, @tfixnum), t4
    t4 = @p.scan_str "(Fixnum, y: ?String, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, FiniteHashType.new(x: @tfixnum, y: @tstringopt)], nil, @tfixnum), t4
    t5 = @p.scan_str "(Fixnum 'x', x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, FiniteHashType.new(x: @tfixnum)], nil, @tfixnum), t5
    t5 = @p.scan_str "(Fixnum 'x', x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, FiniteHashType.new(x: @tfixnum)], nil, @tfixnum), t5
    t6 = @p.scan_str "(x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [FiniteHashType.new(x: @tfixnum)], nil, @tfixnum), t6
    t7 = @p.scan_str "(x: Fixnum) { (%any, String) -> nil } -> :symbol"
    assert_equal (MethodType.new [FiniteHashType.new(x: @tfixnum)], MethodType.new([@ttop, @tstring], nil, @tnil), @tsymbol), t7
  end

end
