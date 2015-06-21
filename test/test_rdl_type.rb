require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class RDLTypeTest < Minitest::Test
  def test_type_contract
    def m1(x) return x; end
    type RDLTypeTest, :m1, "(Fixnum) -> Fixnum"
    assert_equal 5, m1(5)
    assert_raises(RDL::Type::TypeException) { m1("foo") }
  end

end