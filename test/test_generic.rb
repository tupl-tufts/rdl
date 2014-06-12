require 'test/unit'
require 'rdl'

class GenericTest < Test::Unit::TestCase
  include RDL::Type

  def setup
    @parser = RDL::Type::Parser.new

    @fixnum = NominalType.new(Fixnum)
    @string = NominalType.new(String)
    @array = NominalType.new(Array)
    @hash = NominalType.new(Hash)
    @true_n = NominalType.new(TrueClass)

    @tparam_t = TypeParameter.new(:t)
    
    @f_or_s = UnionType.new(@fixnum, @string)
    @string_or_true = UnionType.new(@string, @true_n)

    @array_of_fixnum = GenericType.new(@array, @fixnum)
    @array_of_true = GenericType.new(@array, @true_n)
    @array_of_fixnum_string = GenericType.new(@array, @f_or_s)
    @array_of_true_string = GenericType.new(@array, @string_or_true)
    @hash_of_string_fixnum = GenericType.new(@hash, @string, @fixnum)
    @hash_of_string_true_fixnum = GenericType.new(@hash, @string_or_true, @fixnum)
    @a_a_f = GenericType.new(@array, @array_of_fixnum)
    @a_a_a_f = GenericType.new(@array, @a_a_f)
    @a_a_a_a_f = GenericType.new(@array, @a_a_a_f)
  end

  def test_union
    t1 = @parser.scan_str "##Array<Array<Array<Fixnum> or String or TrueClass>>"
    t2 = @parser.scan_str "##Array<Array<String or TrueClass or Array<Fixnum>>>"
    
    assert_equal(t1, t2)
  end

  def test_array_types
    t = [1,2].rdl_type
    assert_equal(@array_of_fixnum, t)

    t = [1,2,"a"].rdl_type    
    assert_equal(@array_of_fixnum_string, t)

    t = [[[[1,2,3]]]].rdl_type
    assert_equal(@a_a_a_a_f, t)

    t = [["a", true], [[1]]].rdl_type
    u = UnionType.new(@string, @true_n, @array_of_fixnum)
    ct = GenericType.new(@array, u)
    ct = GenericType.new(@array, ct)
    # ct = Array<Array<(Array<Fixnum> or String or TrueClass)>>

    assert_equal(ct, t)
  end

  def test_hash_types
    h = {"a" => 1}
    t = h.rdl_type
    assert_equal(@hash_of_string_fixnum, t)

    h = {"a" => 1, true => 1}
    t = h.rdl_type
    assert_equal(@hash_of_string_true_fixnum, t)
  end

  def test_generic_parser
    t = @parser.scan_str "##Array<t>"
    ct = GenericType.new(@array, @tparam_t)
    assert_equal(ct, t)

    t = @parser.scan_str "##Array<Array<t>>"
    t0 = GenericType.new(@array, @tparam_t)
    ct = GenericType.new(@array, t0)
    assert_equal(ct, t)

    t = @parser.scan_str "##Array<Fixnum or Hash<String, Array<Array<TrueClass>>>>"
    t0 = GenericType.new(@array, @true_n)
    t1 = GenericType.new(@array, t0)
    t2 = GenericType.new(@hash, @string, t1)
    t3 = UnionType.new(@fixnum, t2)
    ct = GenericType.new(@array, t3)
    assert_equal(ct, t)
  end

  def test_array_methods
    x = [1,2,3,"123"].rdl_inst({:t => "Fixnum or String or TrueClass"})
    y = x.push(true)
    assert_equal [1,2,3,"123",true], y

    assert_raise(RDL::TypesigException) {
      x.push(false)
    }

    x = [1,"a"].rdl_inst({:t => "Fixnum or String or TrueClass"})
    y = x.+([true])
    assert_equal [1,"a",true], y

    y = x.+([true, false])
    assert_equal [1,"a",true, false], y
  end

  def test_type_params
    t = "(t) -> t"
    t = @parser.scan_str(t)
    tps = t.get_method_parameters
    assert_equal([:t].to_set, tps.to_set)

    t = "(String, Array<TrueClass>) -> Hash<u, Array<Array<abc>>>"
    t = @parser.scan_str(t)
    tps = t.get_method_parameters
    assert_equal([:u, :abc].to_set, tps.to_set)

    t = "(t) -> abcd"
    t = @parser.scan_str(t)
    tps = t.get_method_parameters
    assert_equal([:t, :abcd].to_set, tps.to_set)

    t = "(a, b, Array<c>, Array<Hash<d, Array<e>>>) -> f"
    t = @parser.scan_str(t)
    tps = t.get_method_parameters
    assert_equal([:a, :b, :c, :d, :e, :f].to_set, tps.to_set)

    t = "(String) -> %any"
    t = @parser.scan_str(t)
    tps = t.get_method_parameters
    assert_equal([].to_set, tps.to_set)
  end
end
