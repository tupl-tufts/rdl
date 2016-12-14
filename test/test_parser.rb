require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestParser < Minitest::Test
  include RDL::Type

  class A; end
  class B; end
  class C; end

  def setup
    @tfixnumopt = OptionalType.new RDL.types[:fixnum]
    @tfixnumvararg = VarargType.new RDL.types[:fixnum]
    @tstringopt = OptionalType.new RDL.types[:string]
    @tenum = NominalType.new :Enumerator
    @ta = NominalType.new :A
    @tb = NominalType.new :B
    @tc = NominalType.new :C
    @tfixnumx = AnnotatedArgType.new("x", RDL.types[:fixnum])
    @tfixnumy = AnnotatedArgType.new("y", RDL.types[:fixnum])
    @tfixnumret = AnnotatedArgType.new("ret", RDL.types[:fixnum])
    @tfixnumoptx = AnnotatedArgType.new("x", @tfixnumopt)
    @tfixnumvarargx = AnnotatedArgType.new("x", @tfixnumvararg)
    @tsymbol = SingletonType.new(:symbol)
    @tsymbolx = AnnotatedArgType.new("x", @tsymbol)
  end

  def tt(t)
    RDL.parser.scan_str('#T ' + t)
  end

  def tm(t)
    RDL.parser.scan_str t
  end

  def test_basic
    t1 = tm "(nil) -> nil"
    assert_equal (MethodType.new [RDL.types[:nil]], nil, RDL.types[:nil]), t1
    t2 = tm "(Fixnum, Fixnum) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:fixnum], RDL.types[:fixnum]], nil, RDL.types[:fixnum]), t2
    t3 = tm "() -> Enumerator"
    assert_equal (MethodType.new [], nil, @tenum), t3
    t4 = tm "(%any) -> nil"
    assert_equal (MethodType.new [RDL.types[:top]], nil, RDL.types[:nil]), t4
    t5 = tm "(%bool) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:bool]], nil, RDL.types[:fixnum]), t5
    assert_raises(RuntimeError) { tm "(%foo) -> nil" }
    t6 = tm "(A) -> nil"
    assert_equal (MethodType.new [@ta], nil, RDL.types[:nil]), t6
    t7 = tm "(TestParser::A) -> nil"
    assert_equal (MethodType.new [NominalType.new("TestParser::A")], nil, RDL.types[:nil]), t7
    t8 = tm "(Fixnum) { (%any, String) -> nil } -> :symbol"
    assert_equal (MethodType.new [RDL.types[:fixnum]], MethodType.new([RDL.types[:top], RDL.types[:string]], nil, RDL.types[:nil]), @tsymbol), t8
    t9 = tm "(true) -> false"
    assert_equal (MethodType.new [RDL.types[:true]], nil, RDL.types[:false]), t9
  end

  def test_opt_vararg
    t1 = tm "(Fixnum, ?Fixnum) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:fixnum], @tfixnumopt], nil, RDL.types[:fixnum]), t1
    t2 = tm "(Fixnum, *Fixnum) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:fixnum], @tfixnumvararg], nil, RDL.types[:fixnum]), t2
    t3 = tm "(Fixnum, ?Fixnum, ?Fixnum, *Fixnum) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:fixnum], @tfixnumopt, @tfixnumopt, @tfixnumvararg], nil, RDL.types[:fixnum]), t3
    t4 = tm "(?Fixnum) -> nil"
    assert_equal (MethodType.new [@tfixnumopt], nil, RDL.types[:nil]), t4
    t5 = tm "(*Fixnum) -> nil"
    assert_equal (MethodType.new [@tfixnumvararg], nil, RDL.types[:nil]), t5
  end

  def test_union
    t1 = tm "(Fixnum or String) -> nil"
    assert_equal (MethodType.new [UnionType.new(RDL.types[:fixnum], RDL.types[:string])], nil, RDL.types[:nil]), t1
    t2 = tm "(Fixnum or String or Symbol) -> nil"
    assert_equal (MethodType.new [UnionType.new(RDL.types[:fixnum], RDL.types[:string], RDL.types[:symbol])], nil, RDL.types[:nil]), t2
    t3 = tm "() -> Fixnum or String or Symbol"
    assert_equal (MethodType.new [], nil, UnionType.new(RDL.types[:fixnum], RDL.types[:string], RDL.types[:symbol])), t3
  end

  def test_bare
    t1 = tt "nil"
    assert_equal RDL.types[:nil], t1
    t2 = tt "%any"
    assert_equal RDL.types[:top], t2
    t3 = tt "A"
    assert_equal NominalType.new("A"), t3
  end

  def test_symbol
    t1 = tt ":symbol"
    assert_equal @tsymbol, t1
  end

  def test_annotated_params
    t1 = tm "(Fixnum x, Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, RDL.types[:fixnum]], nil, RDL.types[:fixnum]), t1
    t2 = tm "(Fixnum, ?Fixnum x) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:fixnum], @tfixnumoptx], nil, RDL.types[:fixnum]), t2
    t3 = tm "(Fixnum, *Fixnum x) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:fixnum], @tfixnumvarargx], nil, RDL.types[:fixnum]), t3
    t4 = tm "(Fixnum, Fixnum y) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:fixnum], @tfixnumy], nil, RDL.types[:fixnum]), t4
    t5 = tm "(Fixnum x, Fixnum y) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, @tfixnumy], nil, RDL.types[:fixnum]), t5
    t6 = tm "(Fixnum, Fixnum) -> Fixnum ret"
    assert_equal (MethodType.new [RDL.types[:fixnum], RDL.types[:fixnum]], nil, @tfixnumret), t6
    t7 = tm "(Fixnum x, Fixnum) -> Fixnum ret"
    assert_equal (MethodType.new [@tfixnumx, RDL.types[:fixnum]], nil, @tfixnumret), t7
    t8 = tm "(Fixnum, Fixnum y) -> Fixnum ret"
    assert_equal (MethodType.new [RDL.types[:fixnum], @tfixnumy], nil, @tfixnumret), t8
    t9 = tm "(Fixnum x, Fixnum y) -> Fixnum ret"
    assert_equal (MethodType.new [@tfixnumx, @tfixnumy], nil, @tfixnumret), t9
    t10 = tm "(:symbol x) -> Fixnum"
    assert_equal (MethodType.new [@tsymbolx], nil, RDL.types[:fixnum]), t10
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
    assert_equal (GenericType.new(NominalType.new("Foo"), RDL.types[:string], t3, t4)), t7
  end

  def test_tuple
    t1 = tt "[Fixnum, String]"
    assert_equal (TupleType.new(RDL.types[:fixnum], RDL.types[:string])), t1
    t2 = tt "[String]"
    assert_equal (TupleType.new(RDL.types[:string])), t2
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
    type_alias '%foobarbaz', RDL.types[:nil]
    assert_equal RDL.types[:nil], (tt "%foobarbaz")
    type_alias '%quxquxqux', 'nil'
    assert_equal RDL.types[:nil], (tt "%quxquxqux")
    assert_raises(RuntimeError) { type_alias '%quxquxqux', 'nil' }
    assert_raises(RuntimeError) { tt "%qux" }
  end

  def test_structural
    t1 = tt "[to_str: () -> String]"
    tm1 = MethodType.new [], nil, RDL.types[:string]
    ts1 = StructuralType.new(to_str: tm1)
    assert_equal ts1, t1
  end

  def test_finite_hash
    t1 = tt "{a: Fixnum, b: String}"
    assert_equal (FiniteHashType.new({a: RDL.types[:fixnum], b: RDL.types[:string]}, nil)), t1
    t2 = tt "{'a'=>Fixnum, 2=>String}"
    assert_equal (FiniteHashType.new({"a"=>RDL.types[:fixnum], 2=>RDL.types[:string]}, nil)), t2
  end

  def test_named_params
    t1 = tm "(Fixnum, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:fixnum], FiniteHashType.new({x: RDL.types[:fixnum]}, nil)], nil, RDL.types[:fixnum]), t1
    t2 = tm "(Fixnum, x: Fixnum, y: String) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:fixnum], FiniteHashType.new({x: RDL.types[:fixnum], y: RDL.types[:string]}, nil)], nil, RDL.types[:fixnum]), t2
    t3 = tm "(Fixnum, y: String, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:fixnum], FiniteHashType.new({x: RDL.types[:fixnum], y: RDL.types[:string]}, nil)], nil, RDL.types[:fixnum]), t3
    t4 = tm "(Fixnum, y: String, x: ?Fixnum) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:fixnum], FiniteHashType.new({x: @tfixnumopt, y: RDL.types[:string]}, nil)], nil, RDL.types[:fixnum]), t4
    t4 = tm "(Fixnum, y: ?String, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:fixnum], FiniteHashType.new({x: RDL.types[:fixnum], y: @tstringopt}, nil)], nil, RDL.types[:fixnum]), t4
    t5 = tm "(Fixnum x, x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, FiniteHashType.new({x: RDL.types[:fixnum]}, nil)], nil, RDL.types[:fixnum]), t5
    t6 = tm "(x: Fixnum) -> Fixnum"
    assert_equal (MethodType.new [FiniteHashType.new({x: RDL.types[:fixnum]}, nil)], nil, RDL.types[:fixnum]), t6
    t7 = tm "(x: Fixnum) { (%any, String) -> nil } -> :symbol"
    assert_equal (MethodType.new [FiniteHashType.new({x: RDL.types[:fixnum]}, nil)], MethodType.new([RDL.types[:top], RDL.types[:string]], nil, RDL.types[:nil]), @tsymbol), t7
    t8 = tm "(Fixnum, x: Fixnum, **String) -> Fixnum"
    assert_equal (MethodType.new [RDL.types[:fixnum], FiniteHashType.new({x: RDL.types[:fixnum]}, RDL.types[:string])], nil, RDL.types[:fixnum]), t8
  end

  def test_nonnull
    assert_equal NonNullType.new(@ta), tt("!A")
    tm2 = MethodType.new [], nil, RDL.types[:string]
    ts2 = StructuralType.new(to_str: tm2)
    assert_equal NonNullType.new(ts2), tt("![to_str: () -> String]")
    assert_raises(RuntimeError) { tt("!3") }
  end

  def test_optional_block
    t1 = tm "() { (%any) -> nil } -> %any"
    assert_equal (MethodType.new [], MethodType.new([RDL.types[:top]], nil, RDL.types[:nil]), RDL.types[:top]), t1
    t2 = tm "() ?{ (%any) -> nil } -> %any"
    assert_equal (MethodType.new [], OptionalType.new(MethodType.new([RDL.types[:top]], nil, RDL.types[:nil])), RDL.types[:top]), t2
    t3 = tm "() ?{ (t) -> nil } -> %any"
    assert_equal (MethodType.new [], OptionalType.new(MethodType.new([VarType.new('t')], nil, RDL.types[:nil])), RDL.types[:top]), t3
  end

  def test_or
    assert_equal (FiniteHashType.new({aorganization: RDL.types[:symbol]}, nil)), tt('{aorganization: Symbol}')
    assert_equal (FiniteHashType.new({organization: RDL.types[:symbol]}, nil)), tt('{organization: Symbol}')
  end

end
