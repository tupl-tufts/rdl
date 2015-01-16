require 'minitest/autorun'
require_relative '../lib/rdl.rb'

# Tests typesig typechecking for overloaded methods
class IntersectionTest < Minitest::Test
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
    
    # Tests intersection of multiple same method types
    def test_intersection_same
        t1 = @parser.scan_str "(Fixnum) -> Fixnum"
        t2 = @parser.scan_str "(Fixnum) -> Fixnum"
        t3 = @parser.scan_str "(Fixnum) -> Fixnum"
        i = IntersectionType.new(t1, t2, t3)
        
        assert_equal(t1, i, "ERR 1.1 Intersect same method type error")
    end
    
    # Tests overloaded method signatures using Array::[] as sample case
    def test_array_types
        arr = [1,2,3,4,5]
        x = arr[1]
        assert_equal(2, x, "ERR 2.1")
        
        x = arr[1.0]
        assert_equal(2, x, "ERR 2.2")
        
        r = Range.new(0, 2)
        x = arr[r]
        assert_equal([1,2,3], x, "ERR 2.3")
        
        x = arr[0,2]
        assert_equal([1,2], x, "ERR 2.4")
        
        assert_raises(RDL::TypesigException, "ERR 2.5 errorcase arg1") {
            arr[true]
        }
        
        assert_raises(RDL::TypesigException, "ERR 2.6 errorcase arg2") {
            arr[1, true]
        }
    end
end

