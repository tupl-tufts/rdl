require 'test/unit'
require 'rdl'

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
    assert_equal ta.name, :A
  end

  def test_symbol
    ta = SymbolType.new :A
    ta2 = SymbolType.new :A
    ta3 = SymbolType.new "A"
    tb = SymbolType.new :B
    tan = NominalType.new :A
    assert_same ta, ta2
    assert_same ta, ta3
    assert_not_equal ta, tb
    assert_equal ta.name, :A
    assert_not_equal ta, tan
  end

  def test_var
    ta = VarType.new :A
    ta2 = VarType.new :A
    ta3 = VarType.new "A"
    tb = VarType.new :B
    tan = NominalType.new :A
    assert_same ta, ta2
    assert_same ta, ta3
    assert_not_equal ta, tb
    assert_equal ta.name, :A
    assert_not_equal ta, tan
  end

  def u_or_i(c)
    tnil = NilType.new
    ttop = TopType.new
    ta = NominalType.new :A
    tb = NominalType.new :B
    tc = NominalType.new :C
    t1 = c.new ta, tb
    assert_equal t1.types.length, 2
    t2 = c.new tb, ta
    assert_same t1, t2
    t3 = c.new ttop, ttop
    assert_same t3, ttop
    t4 = c.new ttop, tnil, ttop, tnil
    assert_same t4, ttop
    t5 = c.new tnil, tnil
    assert_same t5, tnil
    t6 = c.new ta, tb, tc
    assert_equal t6.types.length, 3
    t7 = c.new ta, (c.new tb, tc)
    assert_same t6, t7
    t8 = c.new (c.new tc, tb), (c.new ta)
    assert_same t6, t8
    assert_not_equal t1, tnil
  end

  def test_union_intersection
    u_or_i UnionType
    u_or_i IntersectionType
  end

  def test_optional
    tnil = NilType.new
    ta = NominalType.new :A
    t1 = OptionalType.new tnil
    assert_equal t1.type, tnil
    t2 = OptionalType.new tnil
    assert_same t1, t2
    t3 = OptionalType.new ta
    assert_not_equal t1, t3
  end

  def test_vararg
    tnil = NilType.new
    ta = NominalType.new :A
    t1 = VarargType.new tnil
    assert_equal t1.type, tnil
    t2 = VarargType.new tnil
    assert_same t1, t2
    t3 = VarargType.new ta
    assert_not_equal t1, t3
  end

  def test_method
    tnil = NilType.new
    ta = NominalType.new :A
    tb = NominalType.new :B
    tc = NominalType.new :C
    t1 = MethodType.new [ta, tb, tc], nil, tnil
    assert_equal t1.args, [ta, tb, tc]
    assert_nil t1.block
    assert_equal t1.ret, tnil
    t2 = MethodType.new tnil, t1, tnil
    assert_equal t2.block, t1
    assert_raise(RuntimeError) { MethodType.new tnil, tnil, tnil }
  end

  def test_generic
    thash = NominalType.new :Hash
    ta = NominalType.new :A
    tb = NominalType.new :B
    t1 = GenericType.new thash, ta, tb
    assert_equal t1.base, thash
    assert_equal t1.params, [ta, tb]
    t2 = GenericType.new thash, ta, tb
    assert_same t1, t2
    t3 = GenericType.new thash, tb, ta
    assert_not_equal t1, t3
  end

  def test_structural
    tnil = NilType.new
    ta = NominalType.new :A
    tb = NominalType.new :B
    tc = NominalType.new :C
    tm1 = MethodType.new [ta, tb, tc], nil, tnil
    tm2 = MethodType.new [ta], tm1, tb
    t1 = StructuralType.new :m1 => tm1, :m2 => tm2
    assert_equal t1.methods[:m1], tm1
    assert_equal t1.methods[:m2], tm2
    t2 = StructuralType.new :m1 => tm1, :m2 => tm2
    assert_equal t1, t2
  end

  def test_parameterized_nil
    tnil = NilType.new
    tarr = NominalType.new Array
    tfixnum = NominalType.new Fixnum
    tarr_nil = GenericType.new(tarr, tnil)
    tarr_fixnum = GenericType.new(tarr, tfixnum)

    t = [].rdl_type
    assert_equal(t, tarr_nil)

    t = [nil].rdl_type
    assert_equal(t, tarr_nil)

    t = [nil, 0].rdl_type
    assert_equal(t, tarr_fixnum)
  end
end
