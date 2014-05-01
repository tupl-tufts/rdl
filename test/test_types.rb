require 'test/unit'
require_relative '../lib/type/types'

class TypeTest < Test::Unit::TestCase
  include RDL::Type

  def test_nil_top
    tnil = NilType.new
    tnil2 = NilType.new
    assert(tnil.equal? tnil2)
    ttop = TopType.new
    ttop2 = TopType.new
    assert(ttop.equal? ttop2)
    assert_not_equal tnil, ttop
  end

  def test_nominal
    ta = NominalType.new :a
    ta2 = NominalType.new :a
    tb = NominalType.new :b
    assert(ta.equal? ta2)
    assert_not_equal ta, tb
  end
end
