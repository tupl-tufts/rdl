require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestTypes < Minitest::Test
  include RDL::Type

  class A; end
  class B; end
  class C; end

  def setup
    RDL.reset
  end

  def test_nil_top
    tnil = NominalType.new :NilClass
    assert_equal RDL::Globals.types[:nil], tnil
    tnil2 = SingletonType.new nil
    assert_equal RDL::Globals.types[:nil], tnil2
    ttop = TopType.new
    ttop2 = TopType.new
    assert_equal ttop, ttop2
    assert (RDL::Globals.types[:nil] != ttop)
  end

  def test_nominal
    ta = NominalType.new :A
    ta2 = NominalType.new :A
    ta3 = NominalType.new "A"
    tb = NominalType.new :B
    assert_equal ta, ta2
    assert_equal ta, ta3
    assert (ta != tb)
    assert_equal "A", ta.name
  end

  def test_symbol
    ta = SingletonType.new :A
    ta2 = SingletonType.new :A
    tb = SingletonType.new :B
    tan = NominalType.new :A
    assert_equal ta, ta2
    assert (ta != tb)
    assert_equal :A, ta.val
    assert (ta != tan)
  end

  def test_var
    ta = VarType.new :A
    ta2 = VarType.new :A
    ta3 = VarType.new "A"
    tb = VarType.new :B
    tan = NominalType.new :A
    assert_equal ta, ta2
    assert_equal ta, ta3
    assert (ta != tb)
    assert_equal :A, ta.name
    assert (ta != tan)
  end

  def u_or_i(c)
    ta = NominalType.new A
    tb = NominalType.new B
    tc = NominalType.new C
    t1 = c.new ta, tb
    assert_equal 2, t1.types.length
    t2 = c.new tb, ta
    assert_equal t1, t2
    t3 = c.new RDL::Globals.types[:top], RDL::Globals.types[:top]
    assert_equal RDL::Globals.types[:top], t3
    t4 = c.new RDL::Globals.types[:nil], RDL::Globals.types[:nil]
    assert_equal RDL::Globals.types[:nil], t4
    t5 = c.new ta, tb, tc
    assert_equal 3, t5.types.length
    t6 = c.new ta, (c.new tb, tc)
    assert_equal t5, t6
    t7 = c.new (c.new tc, tb), (c.new ta)
    assert_equal t5, t7
    assert (t1 != RDL::Globals.types[:nil])
  end

  def test_union_intersection
    u_or_i UnionType
    u_or_i IntersectionType
    t = UnionType.new RDL::Globals.types[:top], RDL::Globals.types[:nil], RDL::Globals.types[:top], RDL::Globals.types[:nil]
    assert_equal RDL::Globals.types[:top], t
  end

  def test_optional
    ta = NominalType.new :A
    t1 = OptionalType.new RDL::Globals.types[:nil]
    assert_equal RDL::Globals.types[:nil], t1.type
    t2 = OptionalType.new RDL::Globals.types[:nil]
    assert_equal t1, t2
    t3 = OptionalType.new ta
    assert (t1 != t3)
  end

  def test_vararg
    ta = NominalType.new :A
    t1 = VarargType.new RDL::Globals.types[:nil]
    assert_equal RDL::Globals.types[:nil], t1.type
    t2 = VarargType.new RDL::Globals.types[:nil]
    assert_equal t1, t2
    t3 = VarargType.new ta
    assert (t1 != t3)
  end

  def test_method
    ta = NominalType.new :A
    tb = NominalType.new :B
    tc = NominalType.new :C
    t1 = MethodType.new [ta, tb, tc], nil, RDL::Globals.types[:nil]
    assert_equal [ta, tb, tc], t1.args
    assert_nil t1.block
    assert_equal RDL::Globals.types[:nil], t1.ret
    t2 = MethodType.new [RDL::Globals.types[:nil]], t1, RDL::Globals.types[:nil]
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
    assert_equal t1, t2
    t3 = GenericType.new thash, tb, ta
    assert (t1 != t3)
    tavar = VarType.new :a
    tbvar = VarType.new :b
    t4 = GenericType.new thash, tavar, tbvar
    assert_equal "Hash<a, b>", t4.to_s
  end

  def test_structural
    ta = NominalType.new :A
    tb = NominalType.new :B
    tc = NominalType.new :C
    tm1 = MethodType.new [ta, tb, tc], nil, RDL::Globals.types[:nil]
    tm2 = MethodType.new [ta], tm1, tb
    t1 = StructuralType.new(m1: tm1, m2: tm2)
    assert_equal tm1, t1.methods[:m1]
    assert_equal tm2, t1.methods[:m2]
    t2 = StructuralType.new(m1: tm1, m2: tm2)
    assert_equal t1, t2
  end

  def test_singleton_caching
    s = Set.new
    r = Set.new
    t1 = SingletonType.new(s)
    t2 = SingletonType.new(r)
    assert (t1 != t2) # shouldn't be the same since they're different
                      # objects! e.g., mutating one won't change the
                      # other
  end

  def test_instantiate
    tA = NominalType.new A
    tB = NominalType.new B
    toptionalA = OptionalType.new tA
    tvarargA = VarargType.new tA
    tannotatedA = AnnotatedArgType.new("arg", tA)
    tdependentA = DependentArgType.new("arg", tA, "{{ arg > 10 }}")
    tunionAB = UnionType.new(tA, tB)
    tinterAB = IntersectionType.new(tA, tB)
    tsyma = SingletonType.new(:a)
    tstring = NominalType.new :String
    tinteger = NominalType.new :Integer
    ta = VarType.new :a
    tb = VarType.new :b
    tc = VarType.new :c
    td = VarType.new :d
    thash = NominalType.new :Hash
    thashAB = GenericType.new(thash, tA, tB)
    thashab = GenericType.new(thash, ta, tb)
    thashstringfixnum = GenericType.new(thash, tstring, tinteger)
    inst = {a: tstring, b: tinteger, d: tsyma}
    ttupleAB = TupleType.new(tA, tB)
    ttupleab = TupleType.new(ta, tb)
    ttuplestringfixnum = TupleType.new(tstring, tinteger)
    tfinitehashaAbB = FiniteHashType.new({a: tA, b: tB}, nil)
    tfinitehashaabb = FiniteHashType.new({a: ta, b: tb}, nil)
    tfinitehashastringbfixnum = FiniteHashType.new({a: tstring, b: tinteger}, nil)
    tfinitehashaabbrd = FiniteHashType.new({a: ta, b: tb}, td)
    tfinitehashastringbfixnumrsyma = FiniteHashType.new({a: tstring, b: tinteger}, tsyma)
    tmethAAB = MethodType.new([tA, tA], nil, tB)
    tmethaab = MethodType.new([ta, ta], nil, tb)
    tmethstringstringfixnum = MethodType.new([tstring, tstring], nil, tinteger)
    tmethbAABn = MethodType.new([], tmethAAB, RDL::Globals.types[:nil])
    tmethbaabn = MethodType.new([], tmethaab, RDL::Globals.types[:nil])
    tmethbssfn = MethodType.new([], tmethstringstringfixnum, RDL::Globals.types[:nil])
    tstructorig = StructuralType.new(m1: tmethAAB, m2: tmethaab,
                                     m3: tmethbAABn, m4: tmethbaabn)
    tstructinst = StructuralType.new(m1: tmethAAB, m2: tmethstringstringfixnum,
                                     m3: tmethbAABn, m4: tmethbssfn)
    assert_equal RDL::Globals.types[:nil], RDL::Globals.types[:nil].instantiate(inst)
    assert_equal RDL::Globals.types[:top], RDL::Globals.types[:top].instantiate(inst)
    assert_equal tA, tA.instantiate(inst)
    assert_equal toptionalA, toptionalA.instantiate(inst)
    assert_equal tvarargA, tvarargA.instantiate(inst)
    assert_equal tannotatedA, tannotatedA.instantiate(inst)
    assert_equal tdependentA, tdependentA.instantiate(inst)
    assert_equal tunionAB, tunionAB.instantiate(inst)
    assert_equal tinterAB, tinterAB.instantiate(inst)
    assert_equal tsyma, tsyma.instantiate(inst)
    assert_equal tstring, ta.instantiate(inst)
    assert_equal tinteger, tb.instantiate(inst)
    assert_equal tc, tc.instantiate(inst)
    assert_equal thashAB, thashAB.instantiate(inst)
    assert_equal thashstringfixnum, thashab.instantiate(inst)
    assert_equal ttupleAB, ttupleAB.instantiate(inst)
    assert_equal ttuplestringfixnum, ttupleab.instantiate(inst)
    assert_equal tfinitehashaAbB, tfinitehashaAbB.instantiate(inst)
    assert_equal tfinitehashastringbfixnum, tfinitehashaabb.instantiate(inst)
    assert_equal tfinitehashastringbfixnumrsyma, tfinitehashaabbrd.instantiate(inst)
    assert_equal tmethAAB, tmethAAB.instantiate(inst)
    assert_equal tmethstringstringfixnum, tmethaab.instantiate(inst)
    assert_equal tmethbAABn, tmethbAABn.instantiate(inst)
    assert_equal tmethbssfn, tmethbaabn.instantiate(inst)
    assert_equal tstructinst, tstructorig.instantiate(inst)
  end

  def test_canonical
    t = RDL::Globals.parser.scan_str '#T Array<Fixnum or Fixnum>'
    assert_equal 'Array<Fixnum>', t.canonical.to_s
  end
end
