require 'minitest/autorun'
require_relative '../lib/rdl.rb'

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
    assert_equal (MethodType.new [FiniteHashType.new({a: @tfixnum, b: @qwild})], nil, @tfixnum), q11
    q12 = @p.scan_str "#Q (Fixnum, x: .) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, FiniteHashType.new(x: @qwild)], nil, @tfixnum), q12
    q13 = @p.scan_str "#Q (Fixnum, ..., Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @qdots, @tfixnum], nil, @tfixnum), q13
    q14 = @p.scan_str "#Q (Fixnum, ...) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @qdots], nil, @tfixnum), q14
    q15 = @p.scan_str "#Q (...) -> Fixnum"
    assert_equal (MethodType.new [@qdots], nil, @tfixnum), q15
  end
end
