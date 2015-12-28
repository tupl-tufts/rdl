require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestQuery < Minitest::Test
  include RDL::Query

  def setup
    @p = RDL::Type::Parser.new
    @tnil = RDL::Type::NilType.new
    @ttop = RDL::Type::TopType.new
    @tfixnum = RDL::Type::NominalType.new Fixnum
    @twild = RDL::Query::WildQuery.new
  end

  def test_parse
    q1 = @p.scan_str "#Q (.) -> ."
    assert_equal (RDL::Query::MethodQuery.new [@twild], nil, @twild), q1
    q2 = @p.scan_str "#Q (., Fixnum) -> Fixnum"
    assert_equal (RDL::Query::MethodQuery.new [@twild, @tfixnum], nil, @tfixnum), q2
  end
end
