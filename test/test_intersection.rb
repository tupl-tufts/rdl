require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestIntersection < Minitest::Test
  include RDL::Type

  def setup
    @parser = RDL::Type::Parser.new

    @integer = NominalType.new(Integer)
    @string = NominalType.new(String)
    @array = NominalType.new(Array)
    @hash = NominalType.new(Hash)
    @true_n = NominalType.new(TrueClass)

    @tparam_t = VarType.new(:t)

    @f_or_s = UnionType.new(@integer, @string)
    @string_or_true = UnionType.new(@string, @true_n)

    @array_of_integer = GenericType.new(@array, @integer)
    @array_of_true = GenericType.new(@array, @true_n)
    @array_of_integer_string = GenericType.new(@array, @f_or_s)
    @array_of_true_string = GenericType.new(@array, @string_or_true)
    @hash_of_string_integer = GenericType.new(@hash, @string, @integer)
    @hash_of_string_true_integer = GenericType.new(@hash, @string_or_true, @integer)
    @a_a_f = GenericType.new(@array, @array_of_integer)
    @a_a_a_f = GenericType.new(@array, @a_a_f)
    @a_a_a_a_f = GenericType.new(@array, @a_a_a_f)
  end

  def test_intersection_same
    t1 = @parser.scan_str "(Integer) -> Integer"
    t2 = @parser.scan_str "(Integer) -> Integer"
    t3 = @parser.scan_str "(Integer) -> Integer"
    i = IntersectionType.new(t1, t2, t3)

    assert_equal(t1, i)
  end
end
