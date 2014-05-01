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
    assert_same ttop, ttop2
    assert_not_equal tnil, ttop
  end

  def test_nominal
    ta = NominalType.new :A
    ta2 = NominalType.new :A
    ta3 = NominalType.new "A"
    tb = NominalType.new :B
    assert_same ta, ta2
    assert_same ta, ta3
    assert_not_equal ta, tb
  end

  def u_or_i(c)
    tnil = NilType.new
    ttop = TopType.new
    ta = NominalType.new :A
    tb = NominalType.new :B
    tc = NominalType.new :C
    tu1 = c.new ta, tb
    assert_equal tu1.types.length, 2
    tu2 = c.new tb, ta
    assert_same tu1, tu2
    tu3 = c.new ttop, ttop
    assert_same tu3, ttop
    tu4 = c.new ttop, tnil, ttop, tnil
    assert_same tu4, ttop
    tu5 = c.new tnil, tnil
    assert_same tu5, tnil
    tu6 = c.new ta, tb, tc
    assert_equal tu6.types.length, 3
    tu7 = c.new ta, (c.new tb, tc)
    assert_same tu6, tu7
    tu8 = c.new (c.new tc, tb), (c.new ta)
    assert_same tu6, tu8
    assert_not_equal tu1, tnil
  end

  def test_union_intersection
    u_or_i UnionType
    u_or_i IntersectionType
  end

  def test_tuple
    tnil = NilType.new
    ttop = TopType.new
    ta = NominalType.new :A
    tb = NominalType.new :B
    tc = NominalType.new :C
    tt1 = TupleType.new ta, tb
    assert_equal tt1.types, [ta, tb]
    tt2 = TupleType.new ta, ta
    assert_equal tt2.types, [ta, ta]
    tt3 = TupleType.new tnil, ttop, tb, tb, ta
    assert_equal tt3.types, [tnil, ttop, tb, tb, ta]
    assert_not_equal tt1, tnil
  end

end
