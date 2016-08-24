require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestQuery < Minitest::Test
  include RDL::Type

  def setup
    @p = Parser.new
    @tfixnum = NominalType.new Fixnum
    @tarray = NominalType.new Array
    @qwild = WildQuery.new
    @qwildopt = OptionalType.new @qwild
    @qwildvararg = VarargType.new @qwild
    @qwildx = AnnotatedArgType.new("x", @qwild)
    @qdots = DotsQuery.new
  end

  def test_parse
    q1 = @p.scan_str "#Q (.) -> ."
    assert_equal (MethodType.new [@qwild], nil, @qwild), q1
    q2 = @p.scan_str "#Q (., Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@qwild, @tfixnum], nil, @tfixnum), q2
    q3 = @p.scan_str "#Q (Fixnum, ?.) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @qwildopt], nil, @tfixnum), q3
    q4 = @p.scan_str "#Q (*.) -> Fixnum"
    assert_equal (MethodType.new [@qwildvararg], nil, @tfixnum), q4
    q5 = @p.scan_str "#Q (. or Fixnum) -> Fixnum"
    assert_equal (MethodType.new [UnionType.new(@qwild, @tfixnum)], nil, @tfixnum), q5
    q6 = @p.scan_str "#Q (. x, Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@qwildx, @tfixnum], nil, @tfixnum), q6
    q7 = @p.scan_str "#Q (Array<.>) -> Fixnum"
    assert_equal (MethodType.new [GenericType.new(@tarray, @qwild)], nil, @tfixnum), q7
#    q8 = @p.scan_str "#Q (.<Fixnum>) -> Fixnum"
#    assert_equal (MethodType.new [GenericType.new(@twild, @tfixnum)], nil, @tfixnum), q8
    q9 = @p.scan_str "#Q ([Fixnum, .]) -> Fixnum"
    assert_equal (MethodType.new [TupleType.new(@tfixnum, @qwild)], nil, @tfixnum), q9
    q10 = @p.scan_str "#Q ([to_str: () -> .]) -> Fixnum"
    assert_equal (MethodType.new [StructuralType.new(to_str: (MethodType.new [], nil, @qwild))], nil, @tfixnum), q10
    q11 = @p.scan_str "#Q ({a: Fixnum, b: .}) -> Fixnum"
    assert_equal (MethodType.new [FiniteHashType.new({a: @tfixnum, b: @qwild}, nil)], nil, @tfixnum), q11
    q12 = @p.scan_str "#Q (Fixnum, x: .) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, FiniteHashType.new({x: @qwild}, nil)], nil, @tfixnum), q12
    q13 = @p.scan_str "#Q (Fixnum, ..., Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @qdots, @tfixnum], nil, @tfixnum), q13
    q14 = @p.scan_str "#Q (Fixnum, ...) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @qdots], nil, @tfixnum), q14
    q15 = @p.scan_str "#Q (...) -> Fixnum"
    assert_equal (MethodType.new [@qdots], nil, @tfixnum), q15
  end

  def test_match
    t1 = @p.scan_str "(Fixnum, Fixnum) -> Fixnum"
    assert (@p.scan_str "#Q (Fixnum, Fixnum) -> Fixnum").match(t1)
    assert (@p.scan_str "#Q (., .) -> .").match(t1)
    assert (@p.scan_str "#Q (..., Fixnum) -> Fixnum").match(t1)
    assert (@p.scan_str "#Q (Fixnum, ...) -> Fixnum").match(t1)
    assert (@p.scan_str "#Q (...) -> Fixnum").match(t1)
    assert (not (@p.scan_str "#Q (Fixnum, String) -> Fixnum").match(t1))
    assert (not (@p.scan_str "#Q (String, Fixnum) -> Fixnum").match(t1))
    assert (not (@p.scan_str "#Q (Fixnum, String) -> String").match(t1))
    assert (not (@p.scan_str "#Q (..., String) -> String").match(t1))
    assert (not (@p.scan_str "#Q (String, ...) -> String").match(t1))
    t2 = @p.scan_str "(String or Fixnum) -> Fixnum"
    assert (@p.scan_str "#Q (String or Fixnum) -> Fixnum").match(t2)
    assert (@p.scan_str "#Q (String or .) -> Fixnum").match(t2)
    assert (@p.scan_str "#Q (. or Fixnum) -> Fixnum").match(t2)
    assert (@p.scan_str "#Q (Fixnum or String) -> Fixnum").match(t2)
    assert (@p.scan_str "#Q (Fixnum or .) -> Fixnum").match(t2)
    assert (@p.scan_str "#Q (. or String) -> Fixnum").match(t2)
    t3 = @p.scan_str "(Array<Fixnum>) -> Fixnum"
    assert (@p.scan_str "#Q (Array<Fixnum>) -> Fixnum").match(t3)
    assert (@p.scan_str "#Q (Array<.>) -> Fixnum").match(t3)
    t4 = @p.scan_str "([Fixnum, String]) -> Fixnum"
    assert (@p.scan_str "#Q ([Fixnum, String]) -> Fixnum").match(t4)
    assert (@p.scan_str "#Q ([Fixnum, .]) -> Fixnum").match(t4)
    assert (@p.scan_str "#Q ([., String]) -> Fixnum").match(t4)
    t5 = @p.scan_str "([to_str: () -> Fixnum]) -> Fixnum"
    assert (@p.scan_str "#Q ([to_str: () -> Fixnum]) -> Fixnum").match(t5)
    assert (@p.scan_str "#Q ([to_str: () -> .]) -> Fixnum").match(t5)
    t6 = @p.scan_str "(Fixnum, ?Fixnum) -> Fixnum"
    assert (@p.scan_str "#Q (Fixnum, ?Fixnum) -> Fixnum").match(t6)
    assert (@p.scan_str "#Q (Fixnum, ?.) -> Fixnum").match(t6)
    assert (@p.scan_str "#Q (Fixnum, .) -> Fixnum").match(t6)
    t7 = @p.scan_str "(*Fixnum) -> Fixnum"
    assert (@p.scan_str "#Q (*Fixnum) -> Fixnum").match(t7)
    assert (@p.scan_str "#Q (*.) -> Fixnum").match(t7)
    assert (@p.scan_str "#Q (.) -> Fixnum").match(t7)
    t8 = @p.scan_str "({a: Fixnum, b: String}) -> Fixnum"
    assert (@p.scan_str "#Q ({a: Fixnum, b: String}) -> Fixnum").match(t8)
    assert (@p.scan_str "#Q ({a: Fixnum, b: .}) -> Fixnum").match(t8)
    assert (@p.scan_str "#Q ({a: ., b: String}) -> Fixnum").match(t8)
    assert (@p.scan_str "#Q ({a: ., b: .}) -> Fixnum").match(t8)
    assert (@p.scan_str "#Q ({b: String, a: Fixnum}) -> Fixnum").match(t8)
    assert (@p.scan_str "#Q ({b: ., a: Fixnum}) -> Fixnum").match(t8)
    assert (@p.scan_str "#Q ({b: String, a: .}) -> Fixnum").match(t8)
    assert (@p.scan_str "#Q ({b: ., a: .}) -> Fixnum").match(t8)
    assert (@p.scan_str "#Q (.) -> Fixnum").match(t8)
    t9 = @p.scan_str "(Fixnum, x: String) -> Fixnum"
    assert (@p.scan_str "#Q (Fixnum, x: String) -> Fixnum").match(t9)
    assert (@p.scan_str "#Q (Fixnum, x: .) -> Fixnum").match(t9)
    assert (@p.scan_str "#Q (Fixnum, .) -> Fixnum").match(t9)
    t10 = @p.scan_str "(String x, Fixnum) -> Fixnum"
    assert (@p.scan_str "#Q (String x, Fixnum) -> Fixnum").match(t10)
    assert (@p.scan_str "#Q (. x, Fixnum) -> Fixnum").match(t10)
    assert (@p.scan_str "#Q (String, Fixnum) -> Fixnum").match(t10)
    assert (@p.scan_str "#Q (., Fixnum) -> Fixnum").match(t10)
    t11 = @p.scan_str "(Fixnum, x: String, **Float) -> Fixnum"
    assert (@p.scan_str "#Q (Fixnum, x: String, **Float) -> Fixnum").match(t11)
    assert (@p.scan_str "#Q (Fixnum, x: String, **.) -> Fixnum").match(t11)
  end
end
