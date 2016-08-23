require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestParser < Minitest::Test
  include RDL::Type

  class A; end
  class B; end
  class C; end

  def setup
    @tfixnumopt = OptionalType.new $__rdl_fixnum_type
    @tfixnumvararg = VarargType.new $__rdl_fixnum_type
    @tstringopt = OptionalType.new $__rdl_string_type
    @tenum = NominalType.new :Enumerator
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

  def tt(t)
    $__rdl_parser.scan_str('#T ' + t)
  end

  def tm(t)
    $__rdl_parser.scan_str t
  end

  def test_basic
    t1 = tm "(nil) -> nil"
    assert_equal (MethodType.new [$__rdl_nil_type], nil, $__rdl_nil_type), t1
    t2 = tm "(Fixnum, Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, $__rdl_fixnum_type], nil, $__rdl_fixnum_type), t2
    t3 = tm "() -> Enumerator"
    assert_equal (MethodType.new [], nil, @tenum), t3
    t4 = tm "(%any) -> nil"
    assert_equal (MethodType.new [$__rdl_top_type], nil, $__rdl_nil_type), t4
    t5 = tm "(%bool) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_bool_type], nil, $__rdl_fixnum_type), t5
    assert_raises(RuntimeError) { tm "(%foo) -> nil" }
    t6 = tm "(A) -> nil"
    assert_equal (MethodType.new [@ta], nil, $__rdl_nil_type), t6
    t7 = tm "(TestParser::A) -> nil"
    assert_equal (MethodType.new [NominalType.new("TestParser::A")], nil, $__rdl_nil_type), t7
    t8 = tm "(Fixnum) { (%any, String) -> nil } -> :symbol"
    assert_equal (MethodType.new [$__rdl_fixnum_type], MethodType.new([$__rdl_top_type, $__rdl_string_type], nil, $__rdl_nil_type), @tsymbol), t8
    t9 = tm "(true) -> false"
    assert_equal (MethodType.new [$__rdl_true_type], nil, $__rdl_false_type), t9
  end

  def test_opt_vararg
    t1 = tm "(Fixnum, ?Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumopt], nil, $__rdl_fixnum_type), t1
    t2 = tm "(Fixnum, *Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumvararg], nil, $__rdl_fixnum_type), t2
    t3 = tm "(Fixnum, ?Fixnum, ?Fixnum, *Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumopt, @tfixnumopt, @tfixnumvararg], nil, $__rdl_fixnum_type), t3
    t4 = tm "(?Fixnum) -> nil"
    assert_equal (MethodType.new [@tfixnumopt], nil, $__rdl_nil_type), t4
    t5 = tm "(*Fixnum) -> nil"
    assert_equal (MethodType.new [@tfixnumvararg], nil, $__rdl_nil_type), t5
  end

  def test_union
    t1 = tm "(Fixnum or String) -> nil"
    assert_equal (MethodType.new [UnionType.new($__rdl_fixnum_type, $__rdl_string_type)], nil, $__rdl_nil_type), t1
    t2 = tm "(Fixnum or String or Symbol) -> nil"
    assert_equal (MethodType.new [UnionType.new($__rdl_fixnum_type, $__rdl_string_type, $__rdl_symbol_type)], nil, $__rdl_nil_type), t2
    t3 = tm "() -> Fixnum or String or Symbol"
    assert_equal (MethodType.new [], nil, UnionType.new($__rdl_fixnum_type, $__rdl_string_type, $__rdl_symbol_type)), t3
  end

  def test_bare
    t1 = tt "nil"
    assert_equal $__rdl_nil_type, t1
    t2 = tt "%any"
    assert_equal $__rdl_top_type, t2
    t3 = tt "A"
    assert_equal NominalType.new("A"), t3
  end

  def test_symbol
    t1 = tt ":symbol"
    assert_equal @tsymbol, t1
  end

  def test_annotated_params
    t1 = tm "(Fixnum x, Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, $__rdl_fixnum_type], nil, $__rdl_fixnum_type), t1
    t2 = tm "(Fixnum, ?Fixnum x) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumoptx], nil, $__rdl_fixnum_type), t2
    t3 = tm "(Fixnum, *Fixnum x) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumvarargx], nil, $__rdl_fixnum_type), t3
    t4 = tm "(Fixnum, Fixnum y) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumy], nil, $__rdl_fixnum_type), t4
    t5 = tm "(Fixnum x, Fixnum y) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, @tfixnumy], nil, $__rdl_fixnum_type), t5
    t6 = tm "(Fixnum, Fixnum) -> Fixnum ret"
    assert_equal (MethodType.new [$__rdl_fixnum_type, $__rdl_fixnum_type], nil, @tfixnumret), t6
    t7 = tm "(Fixnum x, Fixnum) -> Fixnum ret"
    assert_equal (MethodType.new [@tfixnumx, $__rdl_fixnum_type], nil, @tfixnumret), t7
    t8 = tm "(Fixnum, Fixnum y) -> Fixnum ret"
    assert_equal (MethodType.new [$__rdl_fixnum_type, @tfixnumy], nil, @tfixnumret), t8
    t9 = tm "(Fixnum x, Fixnum y) -> Fixnum ret"
    assert_equal (MethodType.new [@tfixnumx, @tfixnumy], nil, @tfixnumret), t9
    t10 = tm "(:symbol x) -> Fixnum"
    assert_equal (MethodType.new [@tsymbolx], nil, $__rdl_fixnum_type), t10
  end

  def test_generic
    t1 = tt "t"
    assert_equal (VarType.new "t"), t1
    t2 = tt "Array"
    assert_equal (NominalType.new "Array"), t2
    t3 = tt "Array<t>"
    assert_equal (GenericType.new(t2, t1)), t3
    t4 = tt "Array<Array<t>>"
    assert_equal (GenericType.new(t2, t3)), t4
    t5 = tt "Hash"
    assert_equal (NominalType.new "Hash"), t5
    t6 = tt "Hash<u, v>"
    assert_equal (GenericType.new(t5, VarType.new("u"), VarType.new("v"))), t6
    t7 = tt "Foo<String, Array<t>, Array<Array<t>>>"
    assert_equal (GenericType.new(NominalType.new("Foo"), $__rdl_string_type, t3, t4)), t7
  end

  def test_tuple
    t1 = tt "[Fixnum, String]"
    assert_equal (TupleType.new($__rdl_fixnum_type, $__rdl_string_type)), t1
    t2 = tt "[String]"
    assert_equal (TupleType.new($__rdl_string_type)), t2
  end

  def test_fixnum
    t1 = tt "42"
    assert_equal (SingletonType.new(42)), t1
    t2 = tt "-42"
    assert_equal (SingletonType.new(-42)), t2
  end

  def test_float
    t1 = tt "3.14"
    assert_equal (SingletonType.new(3.14)), t1
  end

  def test_const
    t1 = tt "${Math::PI}"
    assert_equal (SingletonType.new(Math::PI)), t1
  end

  def test_type_alias
    type_alias '%foobarbaz', $__rdl_nil_type
    assert_equal $__rdl_nil_type, (tt "%foobarbaz")
    type_alias '%quxquxqux', 'nil'
    assert_equal $__rdl_nil_type, (tt "%quxquxqux")
    assert_raises(RuntimeError) { type_alias '%quxquxqux', 'nil' }
    assert_raises(RuntimeError) { tt "%qux" }
  end

  def test_structural
    t1 = tt "[to_str: () -> String]"
    tm1 = MethodType.new [], nil, $__rdl_string_type
    ts1 = StructuralType.new(to_str: tm1)
    assert_equal ts1, t1
  end

  def test_finite_hash
    t1 = tt "{a: Fixnum, b: String}"
    assert_equal (FiniteHashType.new({a: $__rdl_fixnum_type, b: $__rdl_string_type}, nil)), t1
    t2 = tt "{'a'=>Fixnum, 2=>String}"
    assert_equal (FiniteHashType.new({"a"=>$__rdl_fixnum_type, 2=>$__rdl_string_type}, nil)), t2
  end

  def test_named_params
    t1 = tm "(Fixnum, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, FiniteHashType.new({x: $__rdl_fixnum_type}, nil)], nil, $__rdl_fixnum_type), t1
    t2 = tm "(Fixnum, x: Fixnum, y: String) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, FiniteHashType.new({x: $__rdl_fixnum_type, y: $__rdl_string_type}, nil)], nil, $__rdl_fixnum_type), t2
    t3 = tm "(Fixnum, y: String, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, FiniteHashType.new({x: $__rdl_fixnum_type, y: $__rdl_string_type}, nil)], nil, $__rdl_fixnum_type), t3
    t4 = tm "(Fixnum, y: String, x: ?Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, FiniteHashType.new({x: @tfixnumopt, y: $__rdl_string_type}, nil)], nil, $__rdl_fixnum_type), t4
    t4 = tm "(Fixnum, y: ?String, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, FiniteHashType.new({x: $__rdl_fixnum_type, y: @tstringopt}, nil)], nil, $__rdl_fixnum_type), t4
    t5 = tm "(Fixnum x, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, FiniteHashType.new({x: $__rdl_fixnum_type}, nil)], nil, $__rdl_fixnum_type), t5
    t6 = tm "(x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [FiniteHashType.new({x: $__rdl_fixnum_type}, nil)], nil, $__rdl_fixnum_type), t6
    t7 = tm "(x: Fixnum) { (%any, String) -> nil } -> :symbol"
    assert_equal (MethodType.new [FiniteHashType.new({x: $__rdl_fixnum_type}, nil)], MethodType.new([$__rdl_top_type, $__rdl_string_type], nil, $__rdl_nil_type), @tsymbol), t7
    t8 = tm "(Fixnum, x: Fixnum, **String) -> Fixnum"
    assert_equal (MethodType.new [$__rdl_fixnum_type, FiniteHashType.new({x: $__rdl_fixnum_type}, $__rdl_string_type)], nil, $__rdl_fixnum_type), t8
  end

  def test_nonnull
    assert_equal NonNullType.new(@ta), tt("!A")
    tm2 = MethodType.new [], nil, $__rdl_string_type
    ts2 = StructuralType.new(to_str: tm2)
    assert_equal NonNullType.new(ts2), tt("![to_str: () -> String]")
    assert_raises(RuntimeError) { tt("!3") }
  end

  def test_optional_block
    t1 = tm "() { (%any) -> nil } -> %any"
    assert_equal (MethodType.new [], MethodType.new([$__rdl_top_type], nil, $__rdl_nil_type), $__rdl_top_type), t1
    t2 = tm "() ?{ (%any) -> nil } -> %any"
    assert_equal (MethodType.new [], OptionalType.new(MethodType.new([$__rdl_top_type], nil, $__rdl_nil_type)), $__rdl_top_type), t2
    t3 = tm "() ?{ (t) -> nil } -> %any"
    assert_equal (MethodType.new [], OptionalType.new(MethodType.new([VarType.new('t')], nil, $__rdl_nil_type)), $__rdl_top_type), t3
  end

end
