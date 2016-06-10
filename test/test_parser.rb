require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestParser < Minitest::Test
  include RDL::Type

  def setup
    @tfixnumopt = OptionalType.new $__rdl_fixnum_type
    @tfixnumvararg = VarargType.new $__rdl_fixnum_type
    @tstringopt = OptionalType.new $__rdl_string_type
    @tenum = NominalType.new :Enumerator
    @tbool = UnionType.new $__rdl_true_type, $__rdl_false_type
    @ta = NominalType.new :A
    @tb = NominalType.new :B
    @tc = NominalType.new :C
    @tfixnumx = AnnotatedArgType.new("x", $__rdl_fixnum_type)
    @tfixnumy = AnnotatedArgType.new("y", $__rdl_fixnum_type)
    @tfixnumret = AnnotatedArgType.new("ret", $__rdl_fixnum_type)
    @tfixnumoptx = AnnotatedArgType.new("x", @tfixnumopt)
    @tfixnumvarargx = AnnotatedArgType.new("x", @tfixnumvararg)
    @tsymbol = SingletonType.new(:symbol)
    @tsymbolx = AnnotatedArgType.new("x", @tsymbol)
  end

  def test_basic
    t1 = $__rdl_parser.scan_str "(nil) -> nil"
    assert_equal (MethodType.new [$__rdl_nil_type], nil, $__rdl_nil_type), t1
    t2 = $__rdl_parser.scan_str "(Fixnum, Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, $__rdl_fixnum_type], nil, $__rdl_fixnum_type), t2
    t3 = $__rdl_parser.scan_str "() -> Enumerator"
    assert_equal (MethodType.new [], nil, @tenum), t3
    t4 = $__rdl_parser.scan_str "(%any) -> nil"
    assert_equal (MethodType.new [$__rdl_top_type], nil, $__rdl_nil_type), t4
    t5 = $__rdl_parser.scan_str "(%bool) -> Fixnum"
    assert_equal (MethodType.new [@tbool], nil, $__rdl_fixnum_type), t5
    assert_raises(RuntimeError) { $__rdl_parser.scan_str "(%foo) -> nil" }
    t6 = $__rdl_parser.scan_str "(A) -> nil"
    assert_equal (MethodType.new [@ta], nil, $__rdl_nil_type), t6
    t7 = $__rdl_parser.scan_str "(TestParser::A) -> nil"
    assert_equal (MethodType.new [NominalType.new("TestParser::A")], nil, $__rdl_nil_type), t7
    t8 = $__rdl_parser.scan_str "(Fixnum) { (%any, String) -> nil } -> :symbol"
    assert_equal (MethodType.new [$__rdl_fixnum_type], MethodType.new([$__rdl_top_type, $__rdl_string_type], nil, $__rdl_nil_type), @tsymbol), t8
    t9 = $__rdl_parser.scan_str "(true) -> false"
    assert_equal (MethodType.new [$__rdl_true_type], nil, $__rdl_false_type), t9
  end

  def test_opt_vararg
    t1 = $__rdl_parser.scan_str "(Fixnum, ?Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumopt], nil, $__rdl_fixnum_type), t1
    t2 = $__rdl_parser.scan_str "(Fixnum, *Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumvararg], nil, $__rdl_fixnum_type), t2
    t3 = $__rdl_parser.scan_str "(Fixnum, ?Fixnum, ?Fixnum, *Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumopt, @tfixnumopt, @tfixnumvararg], nil, $__rdl_fixnum_type), t3
    t4 = $__rdl_parser.scan_str "(?Fixnum) -> nil"
    assert_equal (MethodType.new [@tfixnumopt], nil, $__rdl_nil_type), t4
    t5 = $__rdl_parser.scan_str "(*Fixnum) -> nil"
    assert_equal (MethodType.new [@tfixnumvararg], nil, $__rdl_nil_type), t5
  end

  def test_union
    t1 = $__rdl_parser.scan_str "(A or B) -> nil"
    assert_equal (MethodType.new [UnionType.new(@ta, @tb)], nil, $__rdl_nil_type), t1
    t2 = $__rdl_parser.scan_str "(A or B or C) -> nil"
    assert_equal (MethodType.new [UnionType.new(@ta, @tb, @tc)], nil, $__rdl_nil_type), t2
    t3 = $__rdl_parser.scan_str "() -> A or B or C"
    assert_equal (MethodType.new [], nil, UnionType.new(@ta, @tb, @tc)), t3
  end

  def test_bare
    t1 = $__rdl_parser.scan_str "#T nil"
    assert_equal $__rdl_nil_type, t1
    t2 = $__rdl_parser.scan_str "#T %any"
    assert_equal $__rdl_top_type, t2
    t3 = $__rdl_parser.scan_str "#T A"
    assert_equal NominalType.new("A"), t3
  end

  def test_symbol
    t1 = $__rdl_parser.scan_str "#T :symbol"
    assert_equal @tsymbol, t1
  end

  def test_annotated_params
    t1 = $__rdl_parser.scan_str "(Fixnum x, Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, $__rdl_fixnum_type], nil, $__rdl_fixnum_type), t1
    t2 = $__rdl_parser.scan_str "(Fixnum, ?Fixnum x) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumoptx], nil, $__rdl_fixnum_type), t2
    t3 = $__rdl_parser.scan_str "(Fixnum, *Fixnum x) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumvarargx], nil, $__rdl_fixnum_type), t3
    t4 = $__rdl_parser.scan_str "(Fixnum, Fixnum y) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumy], nil, $__rdl_fixnum_type), t4
    t5 = $__rdl_parser.scan_str "(Fixnum x, Fixnum y) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, @tfixnumy], nil, $__rdl_fixnum_type), t5
    t6 = $__rdl_parser.scan_str "(Fixnum, Fixnum) -> Fixnum ret"
    assert_equal (MethodType.new [$__rdl_fixnum_type, $__rdl_fixnum_type], nil, @tfixnumret), t6
    t7 = $__rdl_parser.scan_str "(Fixnum x, Fixnum) -> Fixnum ret"
    assert_equal (MethodType.new [@tfixnumx, $__rdl_fixnum_type], nil, @tfixnumret), t7
    t8 = $__rdl_parser.scan_str "(Fixnum, Fixnum y) -> Fixnum ret"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumy], nil, @tfixnumret), t8
    t9 = $__rdl_parser.scan_str "(Fixnum x, Fixnum y) -> Fixnum ret"
    assert_equal (MethodType.new [@tfixnumx, @tfixnumy], nil, @tfixnumret), t9
    t10 = $__rdl_parser.scan_str "(:symbol x) -> Fixnum"
    assert_equal (MethodType.new [@tsymbolx], nil, $__rdl_fixnum_type), t10
  end

  def test_generic
    t1 = $__rdl_parser.scan_str "#T t"
    assert_equal (VarType.new "t"), t1
    t2 = $__rdl_parser.scan_str "#T Array"
    assert_equal (NominalType.new "Array"), t2
    t3 = $__rdl_parser.scan_str "#T Array<t>"
    assert_equal (GenericType.new(t2, t1)), t3
    t4 = $__rdl_parser.scan_str "#T Array<Array<t>>"
    assert_equal (GenericType.new(t2, t3)), t4
    t5 = $__rdl_parser.scan_str "#T Hash"
    assert_equal (NominalType.new "Hash"), t5
    t6 = $__rdl_parser.scan_str "#T Hash<u, v>"
    assert_equal (GenericType.new(t5, VarType.new("u"), VarType.new("v"))), t6
    t7 = $__rdl_parser.scan_str "#T Foo<String, Array<t>, Array<Array<t>>>"
    assert_equal (GenericType.new(NominalType.new("Foo"), $__rdl_string_type, t3, t4)), t7
  end

  def test_tuple
    t1 = $__rdl_parser.scan_str "#T [Fixnum, String]"
    assert_equal (TupleType.new($__rdl_fixnum_type, $__rdl_string_type)), t1
    t2 = $__rdl_parser.scan_str "#T [String]"
    assert_equal (TupleType.new($__rdl_string_type)), t2
  end

  def test_fixnum
    t1 = $__rdl_parser.scan_str "#T 42"
    assert_equal (SingletonType.new(42)), t1
    t2 = $__rdl_parser.scan_str "#T -42"
    assert_equal (SingletonType.new(-42)), t2
  end

  def test_float
    t1 = $__rdl_parser.scan_str "#T 3.14"
    assert_equal (SingletonType.new(3.14)), t1
  end

  def test_const
    t1 = $__rdl_parser.scan_str "#T ${Math::PI}"
    assert_equal (SingletonType.new(Math::PI)), t1
  end

  def test_type_alias
    type_alias '%foobarbaz', $__rdl_nil_type
    assert_equal $__rdl_nil_type, ($__rdl_parser.scan_str "#T %foobarbaz")
    type_alias '%quxquxqux', 'nil'
    assert_equal $__rdl_nil_type, ($__rdl_parser.scan_str "#T %quxquxqux")
    assert_raises(RuntimeError) { type_alias '%quxquxqux', 'nil' }
    assert_raises(RuntimeError) { $__rdl_parser.scan_str "#T %qux" }
  end

  def test_structural
    t1 = $__rdl_parser.scan_str "#T [to_str: () -> String]"
    tm1 = MethodType.new [], nil, $__rdl_string_type
    ts1 = StructuralType.new(to_str: tm1)
    assert_equal ts1, t1
  end

  def test_finite_hash
    t1 = $__rdl_parser.scan_str "#T {a: Fixnum, b: String}"
    assert_equal (FiniteHashType.new({a: $__rdl_fixnum_type, b: $__rdl_string_type})), t1
    t2 = $__rdl_parser.scan_str "#T {'a'=>Fixnum, 2=>String}"
    assert_equal (FiniteHashType.new({"a"=>$__rdl_fixnum_type, 2=>$__rdl_string_type})), t2
  end

  def test_named_params
    t1 = $__rdl_parser.scan_str "(Fixnum, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, FiniteHashType.new(x: $__rdl_fixnum_type)], nil, $__rdl_fixnum_type), t1
    t2 = $__rdl_parser.scan_str "(Fixnum, x: Fixnum, y: String) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, FiniteHashType.new(x: $__rdl_fixnum_type, y: $__rdl_string_type)], nil, $__rdl_fixnum_type), t2
    t3 = $__rdl_parser.scan_str "(Fixnum, y: String, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, FiniteHashType.new(x: $__rdl_fixnum_type, y: $__rdl_string_type)], nil, $__rdl_fixnum_type), t3
    t4 = $__rdl_parser.scan_str "(Fixnum, y: String, x: ?Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, FiniteHashType.new(x: @tfixnumopt, y: $__rdl_string_type)], nil, $__rdl_fixnum_type), t4
    t4 = $__rdl_parser.scan_str "(Fixnum, y: ?String, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, FiniteHashType.new(x: $__rdl_fixnum_type, y: @tstringopt)], nil, $__rdl_fixnum_type), t4
    t5 = $__rdl_parser.scan_str "(Fixnum x, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, FiniteHashType.new(x: $__rdl_fixnum_type)], nil, $__rdl_fixnum_type), t5
    t6 = $__rdl_parser.scan_str "(x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [FiniteHashType.new(x: $__rdl_fixnum_type)], nil, $__rdl_fixnum_type), t6
    t7 = $__rdl_parser.scan_str "(x: Fixnum) { (%any, String) -> nil } -> :symbol"
    assert_equal (MethodType.new [FiniteHashType.new(x: $__rdl_fixnum_type)], MethodType.new([$__rdl_top_type, $__rdl_string_type], nil, $__rdl_nil_type), @tsymbol), t7
  end

end
