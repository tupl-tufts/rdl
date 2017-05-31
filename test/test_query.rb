require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestQuery < Minitest::Test
  include RDL::Type

  def setup
    @p = Parser.new
    @tinteger = NominalType.new Integer
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
    q2 = @p.scan_str "#Q (., Integer) -> Integer"
    assert_equal (MethodType.new [@qwild, @tinteger], nil, @tinteger), q2
    q3 = @p.scan_str "#Q (Integer, ?.) -> Integer"
    assert_equal (MethodType.new [@tinteger, @qwildopt], nil, @tinteger), q3
    q4 = @p.scan_str "#Q (*.) -> Integer"
    assert_equal (MethodType.new [@qwildvararg], nil, @tinteger), q4
    q5 = @p.scan_str "#Q (. or Integer) -> Integer"
    assert_equal (MethodType.new [UnionType.new(@qwild, @tinteger)], nil, @tinteger), q5
    q6 = @p.scan_str "#Q (. x, Integer) -> Integer"
    assert_equal (MethodType.new [@qwildx, @tinteger], nil, @tinteger), q6
    q7 = @p.scan_str "#Q (Array<.>) -> Integer"
    assert_equal (MethodType.new [GenericType.new(@tarray, @qwild)], nil, @tinteger), q7
#    q8 = @p.scan_str "#Q (.<Integer>) -> Integer"
#    assert_equal (MethodType.new [GenericType.new(@twild, @tinteger)], nil, @tinteger), q8
    q9 = @p.scan_str "#Q ([Integer, .]) -> Integer"
    assert_equal (MethodType.new [TupleType.new(@tinteger, @qwild)], nil, @tinteger), q9
    q10 = @p.scan_str "#Q ([to_str: () -> .]) -> Integer"
    assert_equal (MethodType.new [StructuralType.new(to_str: (MethodType.new [], nil, @qwild))], nil, @tinteger), q10
    q11 = @p.scan_str "#Q ({a: Integer, b: .}) -> Integer"
    assert_equal (MethodType.new [FiniteHashType.new({a: @tinteger, b: @qwild}, nil)], nil, @tinteger), q11
    q12 = @p.scan_str "#Q (Integer, x: .) -> Integer"
    assert_equal (MethodType.new [@tinteger, FiniteHashType.new({x: @qwild}, nil)], nil, @tinteger), q12
    q13 = @p.scan_str "#Q (Integer, ..., Integer) -> Integer"
    assert_equal (MethodType.new [@tinteger, @qdots, @tinteger], nil, @tinteger), q13
    q14 = @p.scan_str "#Q (Integer, ...) -> Integer"
    assert_equal (MethodType.new [@tinteger, @qdots], nil, @tinteger), q14
    q15 = @p.scan_str "#Q (...) -> Integer"
    assert_equal (MethodType.new [@qdots], nil, @tinteger), q15
  end

  def test_match
    t1 = @p.scan_str "(Integer, Integer) -> Integer"
    assert (@p.scan_str "#Q (Integer, Integer) -> Integer").match(t1)
    assert (@p.scan_str "#Q (., .) -> .").match(t1)
    assert (@p.scan_str "#Q (..., Integer) -> Integer").match(t1)
    assert (@p.scan_str "#Q (Integer, ...) -> Integer").match(t1)
    assert (@p.scan_str "#Q (...) -> Integer").match(t1)
    assert (not (@p.scan_str "#Q (Integer, String) -> Integer").match(t1))
    assert (not (@p.scan_str "#Q (String, Integer) -> Integer").match(t1))
    assert (not (@p.scan_str "#Q (Integer, String) -> String").match(t1))
    assert (not (@p.scan_str "#Q (..., String) -> String").match(t1))
    assert (not (@p.scan_str "#Q (String, ...) -> String").match(t1))
    t2 = @p.scan_str "(String or Integer) -> Integer"
    assert (@p.scan_str "#Q (String or Integer) -> Integer").match(t2)
    assert (@p.scan_str "#Q (String or .) -> Integer").match(t2)
    assert (@p.scan_str "#Q (. or Integer) -> Integer").match(t2)
    assert (@p.scan_str "#Q (Integer or String) -> Integer").match(t2)
    assert (@p.scan_str "#Q (Integer or .) -> Integer").match(t2)
    assert (@p.scan_str "#Q (. or String) -> Integer").match(t2)
    t3 = @p.scan_str "(Array<Integer>) -> Integer"
    assert (@p.scan_str "#Q (Array<Integer>) -> Integer").match(t3)
    assert (@p.scan_str "#Q (Array<.>) -> Integer").match(t3)
    t4 = @p.scan_str "([Integer, String]) -> Integer"
    assert (@p.scan_str "#Q ([Integer, String]) -> Integer").match(t4)
    assert (@p.scan_str "#Q ([Integer, .]) -> Integer").match(t4)
    assert (@p.scan_str "#Q ([., String]) -> Integer").match(t4)
    t5 = @p.scan_str "([to_str: () -> Integer]) -> Integer"
    assert (@p.scan_str "#Q ([to_str: () -> Integer]) -> Integer").match(t5)
    assert (@p.scan_str "#Q ([to_str: () -> .]) -> Integer").match(t5)
    t6 = @p.scan_str "(Integer, ?Integer) -> Integer"
    assert (@p.scan_str "#Q (Integer, ?Integer) -> Integer").match(t6)
    assert (@p.scan_str "#Q (Integer, ?.) -> Integer").match(t6)
    assert (@p.scan_str "#Q (Integer, .) -> Integer").match(t6)
    t7 = @p.scan_str "(*Integer) -> Integer"
    assert (@p.scan_str "#Q (*Integer) -> Integer").match(t7)
    assert (@p.scan_str "#Q (*.) -> Integer").match(t7)
    assert (@p.scan_str "#Q (.) -> Integer").match(t7)
    t8 = @p.scan_str "({a: Integer, b: String}) -> Integer"
    assert (@p.scan_str "#Q ({a: Integer, b: String}) -> Integer").match(t8)
    assert (@p.scan_str "#Q ({a: Integer, b: .}) -> Integer").match(t8)
    assert (@p.scan_str "#Q ({a: ., b: String}) -> Integer").match(t8)
    assert (@p.scan_str "#Q ({a: ., b: .}) -> Integer").match(t8)
    assert (@p.scan_str "#Q ({b: String, a: Integer}) -> Integer").match(t8)
    assert (@p.scan_str "#Q ({b: ., a: Integer}) -> Integer").match(t8)
    assert (@p.scan_str "#Q ({b: String, a: .}) -> Integer").match(t8)
    assert (@p.scan_str "#Q ({b: ., a: .}) -> Integer").match(t8)
    assert (@p.scan_str "#Q (.) -> Integer").match(t8)
    t9 = @p.scan_str "(Integer, x: String) -> Integer"
    assert (@p.scan_str "#Q (Integer, x: String) -> Integer").match(t9)
    assert (@p.scan_str "#Q (Integer, x: .) -> Integer").match(t9)
    assert (@p.scan_str "#Q (Integer, .) -> Integer").match(t9)
    t10 = @p.scan_str "(String x, Integer) -> Integer"
    assert (@p.scan_str "#Q (String x, Integer) -> Integer").match(t10)
    assert (@p.scan_str "#Q (. x, Integer) -> Integer").match(t10)
    assert (@p.scan_str "#Q (String, Integer) -> Integer").match(t10)
    assert (@p.scan_str "#Q (., Integer) -> Integer").match(t10)
    t11 = @p.scan_str "(Integer, x: String, **Float) -> Integer"
    assert (@p.scan_str "#Q (Integer, x: String, **Float) -> Integer").match(t11)
    assert (@p.scan_str "#Q (Integer, x: String, **.) -> Integer").match(t11)
  end
end
