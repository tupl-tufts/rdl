require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestTypes < Minitest::Test
  include RDL::Type

  def test_nil_top
    tnil = NilType.new
    tnil2 = NilType.new
    assert(tnil.equal? tnil2)
    ttop = TopType.new
    ttop2 = TopType.new
    assert_same ttop, ttop2
    assert (tnil != ttop)
  end

  def test_nominal
    ta = NominalType.new :A
    ta2 = NominalType.new :A
    ta3 = NominalType.new "A"
    tb = NominalType.new :B
    assert_same ta, ta2
    assert_same ta, ta3
    assert (ta != tb)
    assert_equal "A", ta.name
  end

  def test_symbol
    ta = SymbolType.new :A
    ta2 = SymbolType.new :A
    ta3 = SymbolType.new "A"
    tb = SymbolType.new :B
    tan = NominalType.new :A
    assert_same ta, ta2
    assert_same ta, ta3
    assert (ta != tb)
    assert_equal :A, ta.name
    assert (ta != tan)
  end

  def test_var
    ta = VarType.new :A
    ta2 = VarType.new :A
    ta3 = VarType.new "A"
    tb = VarType.new :B
    tan = NominalType.new :A
    assert_same ta, ta2
    assert_same ta, ta3
    assert (ta != tb)
    assert_equal :A, ta.name
    assert (ta != tan)
  end

  def u_or_i(c)
    tnil = NilType.new
    ttop = TopType.new
    ta = NominalType.new :A
    tb = NominalType.new :B
    tc = NominalType.new :C
    t1 = c.new ta, tb
    assert_equal 2, t1.types.length
    t2 = c.new tb, ta
    assert_same t1, t2
    t3 = c.new ttop, ttop
    assert_same t3, ttop
    t4 = c.new ttop, tnil, ttop, tnil
    assert_same t4, ttop
    t5 = c.new tnil, tnil
    assert_same t5, tnil
    t6 = c.new ta, tb, tc
    assert_equal 3, t6.types.length
    t7 = c.new ta, (c.new tb, tc)
    assert_same t6, t7
    t8 = c.new (c.new tc, tb), (c.new ta)
    assert_same t6, t8
    assert (t1 != tnil)
  end

  def test_union_intersection
    u_or_i UnionType
    u_or_i IntersectionType
  end

  def test_optional
    tnil = NilType.new
    ta = NominalType.new :A
    t1 = OptionalType.new tnil
    assert_equal tnil, t1.type
    t2 = OptionalType.new tnil
    assert_same t1, t2
    t3 = OptionalType.new ta
    assert (t1 != t3)
  end

  def test_vararg
    tnil = NilType.new
    ta = NominalType.new :A
    t1 = VarargType.new tnil
    assert_equal tnil, t1.type
    t2 = VarargType.new tnil
    assert_same t1, t2
    t3 = VarargType.new ta
    assert (t1 != t3)
  end

  def test_method
    tnil = NilType.new
    ta = NominalType.new :A
    tb = NominalType.new :B
    tc = NominalType.new :C
    t1 = MethodType.new [ta, tb, tc], nil, tnil
    assert_equal [ta, tb, tc], t1.args
    assert_nil t1.block
    assert_equal tnil, t1.ret
    t2 = MethodType.new [tnil], t1, tnil
    assert_equal t1, t2.block
  end

  def test_generic
    thash = NominalType.new :Hash
    ta = NominalType.new :A
    tb = NominalType.new :B
    t1 = GenericType.new thash, ta, tb
    assert_equal thash, t1.base
    assert_equal [ta, tb], t1.params
    t2 = GenericType.new thash, ta, tb
    assert_same t1, t2
    t3 = GenericType.new thash, tb, ta
    assert (t1 != t3)
    tavar = VarType.new :a
    tbvar = VarType.new :b
    t4 = GenericType.new thash, tavar, tbvar
    assert_equal "Hash<a, b>", t4.to_s
    assert_equal "Hash<B, A>", t4.to_s(inst: {a: tb, b: ta})
  end

  def test_structural
    tnil = NilType.new
    ta = NominalType.new :A
    tb = NominalType.new :B
    tc = NominalType.new :C
    tm1 = MethodType.new [ta, tb, tc], nil, tnil
    tm2 = MethodType.new [ta], tm1, tb
    t1 = StructuralType.new :m1 => tm1, :m2 => tm2
    assert_equal tm1, t1.methods[:m1]
    assert_equal tm2, t1.methods[:m2]
    t2 = StructuralType.new :m1 => tm1, :m2 => tm2
    assert_equal t1, t2
  end
end
