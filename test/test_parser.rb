require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestParser < Minitest::Test
  include RDL::Type

  class A; end
  class B; end
  class C; end

  def setup
    @tintegeropt = OptionalType.new RDL::Globals.types[:integer]
    @tintegervararg = VarargType.new RDL::Globals.types[:integer]
    @tstringopt = OptionalType.new RDL::Globals.types[:string]
    @tenum = NominalType.new :Enumerator
    @ta = NominalType.new :A
    @tb = NominalType.new :B
    @tc = NominalType.new :C
    @tintegerx = AnnotatedArgType.new("x", RDL::Globals.types[:integer])
    @tintegery = AnnotatedArgType.new("y", RDL::Globals.types[:integer])
    @tintegerret = AnnotatedArgType.new("ret", RDL::Globals.types[:integer])
    @tintegeroptx = AnnotatedArgType.new("x", @tintegeropt)
    @tintegervarargx = AnnotatedArgType.new("x", @tintegervararg)
    @tsymbol = SingletonType.new(:symbol)
    @tsymbolx = AnnotatedArgType.new("x", @tsymbol)
  end

  def tt(t)
    RDL::Globals.parser.scan_str('#T ' + t)
  end

  def tm(t)
    RDL::Globals.parser.scan_str t
  end

  def test_basic
    t1 = tm "(nil) -> nil"
    assert_equal (MethodType.new [RDL::Globals.types[:nil]], nil, RDL::Globals.types[:nil]), t1
    t2 = tm "(Integer, Integer) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], RDL::Globals.types[:integer]], nil, RDL::Globals.types[:integer]), t2
    t3 = tm "() -> Enumerator"
    assert_equal (MethodType.new [], nil, @tenum), t3
    t4 = tm "(%any) -> nil"
    assert_equal (MethodType.new [RDL::Globals.types[:top]], nil, RDL::Globals.types[:nil]), t4
    t5 = tm "(%bool) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:bool]], nil, RDL::Globals.types[:integer]), t5
    assert_raises(RuntimeError) { tm "(%foo) -> nil" }
    t6 = tm "(A) -> nil"
    assert_equal (MethodType.new [@ta], nil, RDL::Globals.types[:nil]), t6
    t7 = tm "(TestParser::A) -> nil"
    assert_equal (MethodType.new [NominalType.new("TestParser::A")], nil, RDL::Globals.types[:nil]), t7
    t8 = tm "(Integer) { (%any, String) -> nil } -> :symbol"
    assert_equal (MethodType.new [RDL::Globals.types[:integer]], MethodType.new([RDL::Globals.types[:top], RDL::Globals.types[:string]], nil, RDL::Globals.types[:nil]), @tsymbol), t8
    t9 = tm "(true) -> false"
    assert_equal (MethodType.new [RDL::Globals.types[:true]], nil, RDL::Globals.types[:false]), t9
  end

  def test_opt_vararg
    t1 = tm "(Integer, ?Integer) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], @tintegeropt], nil, RDL::Globals.types[:integer]), t1
    t2 = tm "(Integer, *Integer) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], @tintegervararg], nil, RDL::Globals.types[:integer]), t2
    t3 = tm "(Integer, ?Integer, ?Integer, *Integer) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], @tintegeropt, @tintegeropt, @tintegervararg], nil, RDL::Globals.types[:integer]), t3
    t4 = tm "(?Integer) -> nil"
    assert_equal (MethodType.new [@tintegeropt], nil, RDL::Globals.types[:nil]), t4
    t5 = tm "(*Integer) -> nil"
    assert_equal (MethodType.new [@tintegervararg], nil, RDL::Globals.types[:nil]), t5
  end

  def test_union
    t1 = tm "(Integer or String) -> nil"
    assert_equal (MethodType.new [UnionType.new(RDL::Globals.types[:integer], RDL::Globals.types[:string])], nil, RDL::Globals.types[:nil]), t1
    t2 = tm "(Integer or String or Symbol) -> nil"
    assert_equal (MethodType.new [UnionType.new(RDL::Globals.types[:integer], RDL::Globals.types[:string], RDL::Globals.types[:symbol])], nil, RDL::Globals.types[:nil]), t2
    t3 = tm "() -> Integer or String or Symbol"
    assert_equal (MethodType.new [], nil, UnionType.new(RDL::Globals.types[:integer], RDL::Globals.types[:string], RDL::Globals.types[:symbol])), t3
  end

  def test_bare
    t1 = tt "nil"
    assert_equal RDL::Globals.types[:nil], t1
    t2 = tt "%any"
    assert_equal RDL::Globals.types[:top], t2
    t3 = tt "A"
    assert_equal NominalType.new("A"), t3
  end

  def test_symbol
    t1 = tt ":symbol"
    assert_equal @tsymbol, t1
  end

  def test_annotated_params
    t1 = tm "(Integer x, Integer) -> Integer"
    assert_equal (MethodType.new [@tintegerx, RDL::Globals.types[:integer]], nil, RDL::Globals.types[:integer]), t1
    t2 = tm "(Integer, ?Integer x) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], @tintegeroptx], nil, RDL::Globals.types[:integer]), t2
    t3 = tm "(Integer, *Integer x) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], @tintegervarargx], nil, RDL::Globals.types[:integer]), t3
    t4 = tm "(Integer, Integer y) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], @tintegery], nil, RDL::Globals.types[:integer]), t4
    t5 = tm "(Integer x, Integer y) -> Integer"
    assert_equal (MethodType.new [@tintegerx, @tintegery], nil, RDL::Globals.types[:integer]), t5
    t6 = tm "(Integer, Integer) -> Integer ret"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], RDL::Globals.types[:integer]], nil, @tintegerret), t6
    t7 = tm "(Integer x, Integer) -> Integer ret"
    assert_equal (MethodType.new [@tintegerx, RDL::Globals.types[:integer]], nil, @tintegerret), t7
    t8 = tm "(Integer, Integer y) -> Integer ret"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], @tintegery], nil, @tintegerret), t8
    t9 = tm "(Integer x, Integer y) -> Integer ret"
    assert_equal (MethodType.new [@tintegerx, @tintegery], nil, @tintegerret), t9
    t10 = tm "(:symbol x) -> Integer"
    assert_equal (MethodType.new [@tsymbolx], nil, RDL::Globals.types[:integer]), t10
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
    assert_equal (GenericType.new(NominalType.new("Foo"), RDL::Globals.types[:string], t3, t4)), t7
  end

  def test_tuple
    t1 = tt "[Integer, String]"
    assert_equal (TupleType.new(RDL::Globals.types[:integer], RDL::Globals.types[:string])), t1
    t2 = tt "[String]"
    assert_equal (TupleType.new(RDL::Globals.types[:string])), t2
  end

  def test_integer
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
    RDL.type_alias '%foobarbaz', RDL::Globals.types[:nil]
    assert_equal RDL::Globals.types[:nil], (tt "%foobarbaz")
    RDL.type_alias '%quxquxqux', 'nil'
    assert_equal RDL::Globals.types[:nil], (tt "%quxquxqux")
    assert_raises(RuntimeError) { RDL.type_alias '%quxquxqux', 'nil' }
    assert_raises(RuntimeError) { tt "%qux" }
  end

  def test_structural
    t1 = tt "[to_str: () -> String]"
    tm1 = MethodType.new [], nil, RDL::Globals.types[:string]
    ts1 = StructuralType.new(to_str: tm1)
    assert_equal ts1, t1
    t2 = tt "[[]: (String) -> %any]"
    tm2 = MethodType.new [RDL::Globals.types[:string]], nil, RDL::Globals.special_types['%any']
    ts2 = StructuralType.new(:[] => tm2)
    assert_equal ts2, t2
  end

  def test_finite_hash
    t1 = tt "{a: Integer, b: String}"
    assert_equal (FiniteHashType.new({a: RDL::Globals.types[:integer], b: RDL::Globals.types[:string]}, nil)), t1
    t2 = tt "{'a'=>Integer, 2=>String}"
    assert_equal (FiniteHashType.new({"a"=>RDL::Globals.types[:integer], 2=>RDL::Globals.types[:string]}, nil)), t2
  end

  def test_named_params
    t1 = tm "(Integer, x: Integer) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], FiniteHashType.new({x: RDL::Globals.types[:integer]}, nil)], nil, RDL::Globals.types[:integer]), t1
    t2 = tm "(Integer, x: Integer, y: String) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], FiniteHashType.new({x: RDL::Globals.types[:integer], y: RDL::Globals.types[:string]}, nil)], nil, RDL::Globals.types[:integer]), t2
    t3 = tm "(Integer, y: String, x: Integer) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], FiniteHashType.new({x: RDL::Globals.types[:integer], y: RDL::Globals.types[:string]}, nil)], nil, RDL::Globals.types[:integer]), t3
    t4 = tm "(Integer, y: String, x: ?Integer) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], FiniteHashType.new({x: @tintegeropt, y: RDL::Globals.types[:string]}, nil)], nil, RDL::Globals.types[:integer]), t4
    t4 = tm "(Integer, y: ?String, x: Integer) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], FiniteHashType.new({x: RDL::Globals.types[:integer], y: @tstringopt}, nil)], nil, RDL::Globals.types[:integer]), t4
    t5 = tm "(Integer x, x: Integer) -> Integer"
    assert_equal (MethodType.new [@tintegerx, FiniteHashType.new({x: RDL::Globals.types[:integer]}, nil)], nil, RDL::Globals.types[:integer]), t5
    t6 = tm "(x: Integer) -> Integer"
    assert_equal (MethodType.new [FiniteHashType.new({x: RDL::Globals.types[:integer]}, nil)], nil, RDL::Globals.types[:integer]), t6
    t7 = tm "(x: Integer) { (%any, String) -> nil } -> :symbol"
    assert_equal (MethodType.new [FiniteHashType.new({x: RDL::Globals.types[:integer]}, nil)], MethodType.new([RDL::Globals.types[:top], RDL::Globals.types[:string]], nil, RDL::Globals.types[:nil]), @tsymbol), t7
    t8 = tm "(Integer, x: Integer, **String) -> Integer"
    assert_equal (MethodType.new [RDL::Globals.types[:integer], FiniteHashType.new({x: RDL::Globals.types[:integer]}, RDL::Globals.types[:string])], nil, RDL::Globals.types[:integer]), t8
  end

  def test_nonnull
    assert_equal NonNullType.new(@ta), tt("!A")
    tm2 = MethodType.new [], nil, RDL::Globals.types[:string]
    ts2 = StructuralType.new(to_str: tm2)
    assert_equal NonNullType.new(ts2), tt("![to_str: () -> String]")
    assert_raises(RuntimeError) { tt("!3") }
  end

  def test_optional_block
    t1 = tm "() { (%any) -> nil } -> %any"
    assert_equal (MethodType.new [], MethodType.new([RDL::Globals.types[:top]], nil, RDL::Globals.types[:nil]), RDL::Globals.types[:top]), t1
    t2 = tm "() ?{ (%any) -> nil } -> %any"
    assert_equal (MethodType.new [], OptionalType.new(MethodType.new([RDL::Globals.types[:top]], nil, RDL::Globals.types[:nil])), RDL::Globals.types[:top]), t2
    t3 = tm "() ?{ (t) -> nil } -> %any"
    assert_equal (MethodType.new [], OptionalType.new(MethodType.new([VarType.new('t')], nil, RDL::Globals.types[:nil])), RDL::Globals.types[:top]), t3
  end

  def test_or
    assert_equal (FiniteHashType.new({aorganization: RDL::Globals.types[:symbol]}, nil)), tt('{aorganization: Symbol}')
    assert_equal (FiniteHashType.new({organization: RDL::Globals.types[:symbol]}, nil)), tt('{organization: Symbol}')
  end

end
