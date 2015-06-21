require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class RDLTypeTest < Minitest::Test
  def test_single_type_contract
    def m1(x) return x; end
    type RDLTypeTest, :m1, "(Fixnum) -> Fixnum"
    assert_equal 5, m1(5)
    assert_raises(RDL::Type::TypeError) { m1("foo") }

    type :m2, "(Fixnum) -> Fixnum"
    def m2(x) return x; end
    assert_equal 5, m2(5)
    assert_raises(RDL::Type::TypeError) { m2("foo") }

    type "(Fixnum) -> Fixnum"
    def m3(x) return x; end
    assert_equal 5, m3(5)
    assert_raises(RDL::Type::TypeError) { m3("foo") }
  end

  # def test_intersection_type_contract
  #   type "(Fixnum) -> Fixnum"
  #   type "(String) -> String"
  #   def m4(x) return x; end
  #   assert_equal 5, m4(5)
  #   assert_equal "foo", m4("foo")
  #   m4(:foo)
  #   assert_raises(RDL::Type::TypeError) { m4(:foo) }
  # end
  
end