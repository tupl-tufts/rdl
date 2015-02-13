require 'minitest/autorun'
require_relative '../lib/rdl.rb'

# Tests RDL type parser
class GenericTest < Minitest::Test
    include RDL::Type
    
    def setup
        @parser = RDL::Type::Parser.new
        
        @fixnum = NominalType.new(Fixnum)
        @string = NominalType.new(String)
        @array = NominalType.new(Array)
        @hash = NominalType.new(Hash)
        @true_n = NominalType.new(TrueClass)
        
        @tparam_t = VarType.new(:t)
        
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
    
    # Tests Union Type
    def test_union
        t1 = @parser.scan_str "##Array<Array<Array<Fixnum> or String or TrueClass>>"
        t2 = @parser.scan_str "##Array<Array<String or TrueClass or Array<Fixnum>>>"
        
        assert_equal(t1, t2, "ERR 1.1 Union type error")
    end
    
    # Tests Array Type with varying composition
    def test_array_types
        t = [1,2].rdl_type
        assert_equal(@array_of_fixnum, t, "ERR 2.1 Single typed array error")
        
        t = [1,2,"a"].rdl_type
        assert_equal(@array_of_fixnum_string, t, "ERR 2.2 Mixed composition array error")
        
        t = [[[[1,2,3]]]].rdl_type
        assert_equal(@a_a_a_a_f, t, "ERR 2.3 Nested simple array error")
        
        t = [["a", true], [[1]]].rdl_type
        u = UnionType.new(@string, @true_n, @array_of_fixnum)
        ct = GenericType.new(@array, u)
        ct = GenericType.new(@array, ct)
        # ct = Array<Array<(Array<Fixnum> or String or TrueClass)>>
        assert_equal(ct, t, "ERR 2.4 Nested mixed array error") # TODO append @__cls_params in Array as only typesigs do that now
    end
    
    # Tests Hash Type with varying composition
    def test_hash_types
        h = {"a" => 1}
        t = h.rdl_type
        assert_equal(@hash_of_string_fixnum, t, "ERR 3.1 Basic hash error")
        
        h = {"a" => 1, true => 1}
        t = h.rdl_type
        assert_equal(@hash_of_string_true_fixnum, t, "ERR 3.2 Mixed composition hash error")
    end
    
    # Tests Parameterized Types using Array as sample case
    def test_generic_parser
        t = @parser.scan_str "##Array<t>"
        ct = GenericType.new(@array, @tparam_t)
        assert_equal(ct, t, "ERR 4.1 Parameterized type error")
        
        t = @parser.scan_str "##Array<Array<t>>"
        t0 = GenericType.new(@array, @tparam_t)
        ct = GenericType.new(@array, t0)
        assert_equal(ct, t, "ERR 4.2 Nested parameterized type error")
        
        t = @parser.scan_str "##Array<Fixnum or Hash<String, Array<Array<TrueClass>>>>"
        t0 = GenericType.new(@array, @true_n)
        t1 = GenericType.new(@array, t0)
        t2 = GenericType.new(@hash, @string, t1)
        t3 = UnionType.new(@fixnum, t2)
        ct = GenericType.new(@array, t3)
        assert_equal(ct, t, "ERR 4.3 Complex nesting of parameterized type error")
    end
    
    # Tests RDL rdl_inst method in types.rb
    def test_array_methods
        skip "Contract structure changed"
        
        x = [1,2,3,"123"].rdl_inst({:t => "Fixnum or String or TrueClass"})
        y = x.push(true)
        assert_equal [1,2,3,"123",true], y, "ERR 5.1 " # TODO: update err message
        
        assert_raises(RDL::TypesigException, "ERR 5.2 ") {
            x.push(false)
        }
        
        x = [1,"a"].rdl_inst({:t => "Fixnum or String or TrueClass"})
        y = x.+([true])
        assert_equal [1,"a",true], y, "ERR 5.3 "
        
        y = x.+([true, false])
        assert_equal [1,"a",true, false], y, "ERR 5.4 "
    end
    
    # Tests typesig syntax
    # See rdl_sig.rb
    def test_type_params
        t = "(t) -> t"
        t = @parser.scan_str(t)
        tps = t.get_vartypes
        assert_equal([:t].to_set, tps.to_set, "ERR 6.1 Simple method error")
        
        t = "(String, Array<TrueClass>) -> Hash<u, Array<Array<abc>>>"
        t = @parser.scan_str(t)
        tps = t.get_vartypes
        assert_equal([:u, :abc].to_set, tps.to_set, "ERR 6.2 Complex method error")
        
        # TODO add more possibilities to test suite, named arg
        
        t = "(t) -> abcd"
        t = @parser.scan_str(t)
        tps = t.get_vartypes
        assert_equal([:t, :abcd].to_set, tps.to_set, "ERR 6.3 Method with type variable and undeclared type error")
        
        t = "(a, b, Array<c>, Array<Hash<d, Array<e>>>) -> f"
        t = @parser.scan_str(t)
        tps = t.get_vartypes
        assert_equal([:a, :b, :c, :d, :e, :f].to_set, tps.to_set, "ERR 6.4 Method with parameterized type error")
        
        t = "(String) -> %any"
        t = @parser.scan_str(t)
        tps = t.get_vartypes
        assert_equal([].to_set, tps.to_set, "ERR 6.5 Method with %any error")
    end
end
