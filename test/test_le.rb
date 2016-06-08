require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestLe < Minitest::Test
  include RDL::Type

  class A
  end

  class B < A
  end

  class C < B
  end

  def setup
    @tnil = NilType.new
    @ttop = TopType.new
    @tstring = NominalType.new "String"
    @tobject = NominalType.new "Object"
    @tbasicobject = NominalType.new "BasicObject"
    @tsymfoo = SingletonType.new :foo
    @tsym = NominalType.new Symbol
    @ta = NominalType.new A
    @tb = NominalType.new B
    @tc = NominalType.new C
    @tfixnum = NominalType.new "Fixnum"
  end

  def test_nil
    assert (@tnil <= @ttop)
    assert (@tnil <= @tstring)
    assert (@tnil <= @tobject)
    assert (@tnil <= @tbasicobject)
    assert (@tnil <= @tsymfoo)
    assert (not (@ttop <= @tnil))
    assert (not (@tstring <= @tnil))
    assert (not (@tobject <= @tnil))
    assert (not (@tbasicobject <= @tnil))
    assert (not (@tsymfoo <= @tnil))
  end

  def test_top
    assert (not (@ttop <= @tnil))
    assert (not (@ttop <= @tstring))
    assert (not (@ttop <= @tobject))
    assert (not (@ttop <= @tbasicobject))
    assert (not (@ttop <= @tsymfoo))
    assert (@ttop <= @ttop)
    assert (@tstring <= @ttop)
    assert (@tobject <= @ttop)
    assert (@tbasicobject <= @ttop)
    assert (@tsymfoo <= @ttop)
  end

  def test_sym
    assert (@tsym <= @tsym)
    assert (@tsymfoo <= @tsymfoo)
    assert (@tsymfoo <= @tsym)
    assert (not (@tsym <= @tsymfoo))
  end

  def test_nominal
    assert (@tstring <= @tstring)
    assert (@tsym <= @tsym)
    assert (not (@tstring <= @tsym))
    assert (not (@tsym <= @tstring))
    assert (@tstring <= @tobject)
    assert (@tstring <= @tbasicobject)
    assert (@tobject <= @tbasicobject)
    assert (not (@tobject <= @tstring))
    assert (not (@tbasicobject <= @tstring))
    assert (not (@tbasicobject <= @tobject))
    assert (@ta <= @ta)
    assert (@tb <= @ta)
    assert (@tc <= @ta)
    assert (not (@ta <= @tb))
    assert (@tb <= @tb)
    assert (@tc <= @tb)
    assert (not (@ta <= @tc))
    assert (not (@tb <= @tc))
    assert (@tc <= @tc)
  end

  def test_union
    tstring_or_sym = UnionType.new(@tstring, @tsym)
    assert (tstring_or_sym <= @tobject)
    assert (not (@tobject <= tstring_or_sym))
  end

  def test_tuple
    t1 = TupleType.new(@tsym, @tstring)
    t2 = TupleType.new(@tobject, @tobject)
    tarray = NominalType.new("Array")
    assert (t1 <= t1)
    assert (t2 <= t2)
    assert (not (t2 <= t1))
    assert (not (tarray <= t1))
    assert (t1 <= t2) # covariant subtyping since tuples are *immutable*
    t123 = $__rdl_parser.scan_str "#T [1, 2, 3]"
    tfff = $__rdl_parser.scan_str "#T [Fixnum, Fixnum, Fixnum]"
    tooo = $__rdl_parser.scan_str "#T [Object, Object, Object]"
    assert (t123 <= tfff) # covariant subtyping with singletons
    assert (tfff <= tooo)
    assert (t123 <= tooo)

    # subtyping of tuples and arrays
    tfs_1 = $__rdl_parser.scan_str "#T [Fixnum, String]"
    tafs_1 = $__rdl_parser.scan_str "#T Array<Fixnum or String>"
    assert (tfs_1 <= tafs_1) # subtyping allowed by t12 promoted to array
    tfs2_1 = $__rdl_parser.scan_str "#T [Fixnum, String]"
    assert (not (tfs_1 <= tfs2_1)) # t12 has been promoted to array, no longer subtype

    tfs_2 = $__rdl_parser.scan_str "#T [Fixnum, String]"
    tfs2_2 = $__rdl_parser.scan_str "#T [Fixnum, String]"
    assert (tfs_2 <= tfs2_2) # this is allowed here because tfs_2 is still a tuple
    tafs_2 = $__rdl_parser.scan_str "#T Array<Fixnum or String>"
    assert (not (tfs_2 <= tafs_2)) # subtyping not allowed because tfs_2 <= tfs2_2 unsatisfiable after tfs_2 promoted

    tfs_3 = $__rdl_parser.scan_str "#T [Fixnum, String]"
    tfs2_3 = $__rdl_parser.scan_str "#T [Object, Object]"
    assert (tfs_3 <= tfs2_3) # this is allowed here because t12a is still a tuple
    tafs_3 = $__rdl_parser.scan_str "#T Array<Object>"
    assert (not (tfs2_3 <= tafs_3)) # subtyping not allowed because tfs_3 <= tfs2_3 unsatisfiable after tfs2_3 promoted

    tfs_4 = $__rdl_parser.scan_str "#T [Fixnum, String]"
    tfs2_4 = $__rdl_parser.scan_str "#T [Fixnum, String]"
    assert (tfs_4 <= tfs2_4) # allowed, types are the same
    tafs_4 = $__rdl_parser.scan_str "#T Array<Fixnum or String>"
    assert (tfs2_4 <= tafs_4) # allowed, both tfs2_4 and tfs_4 promoted to array
    tfs3_4 = $__rdl_parser.scan_str "#T [Fixnum, String]"
    assert (not(tfs_4 <= tfs3_4)) # not allowed, tfs_4 has been promoted
  end

  def test_finite_hash
    t12 = $__rdl_parser.scan_str "#T {a: 1, b: 2}"
    tfs = $__rdl_parser.scan_str "#T {a: Fixnum, b: Fixnum}"
    too = $__rdl_parser.scan_str "#T {a: Object, b: Object}"
    assert (t12 <= tfs)
    assert (t12 <= too)
    assert (tfs <= too)
    assert (not (tfs <= t12))
    assert (not (too <= tfs))
    assert (not (too <= t12))

    # subtyping of finite hashes and hashes; same pattern as tuples

  end

  def test_method
    tss = MethodType.new([@tstring], nil, @tstring)
    tso = MethodType.new([@tstring], nil, @tobject)
    tos = MethodType.new([@tobject], nil, @tstring)
    too = MethodType.new([@tobject], nil, @tobject)
    assert (tss <= tss)
    assert (tss <= tso)
    assert (not (tss <= tos))
    assert (not (tss <= too))
    assert (not (tso <= tss))
    assert (tso <= tso)
    assert (not (tso <= tos))
    assert (not (tso <= too))
    assert (tos <= tss)
    assert (tos <= tso)
    assert (tos <= tos)
    assert (tos <= too)
    assert (not (too <= tss))
    assert (too <= tso)
    assert (not (too <= tos))
    assert (too <= too)
    tbos = MethodType.new([], tos, @tobject)
    tbso = MethodType.new([], tso, @tobject)
    assert (tbos <= tbos)
    assert (not (tbos <= tbso))
    assert (tbso <= tbso)
    assert (tbso <= tbos)
  end

  def test_structural
    tso = MethodType.new([@tstring], nil, @tobject)
    tos = MethodType.new([@tobject], nil, @tstring)
    ts1 = StructuralType.new(m1: tso)
    ts2 = StructuralType.new(m1: tos)
    assert (ts1 <= @ttop)
    assert (ts1 <= ts1)
    assert (ts2 <= ts2)
    assert (ts2 <= ts1)
    assert (not (ts1 <= ts2))
    ts3 = StructuralType.new(m1: tso, m2: tso) # width subtyping
    assert (ts3 <= ts1)
    assert (not (ts1 <= ts3))
  end

  class Nom
    def m1()
      nil
    end
    def m2()
      nil
    end
  end

  class NomT
    type "() -> nil"
    def m1()
      nil
    end
    type "() -> nil"
    def m2()
      nil
    end
  end

  def test_nominal_structural
    tnom = NominalType.new(Nom)
    tnomt = NominalType.new(NomT)
    tma = MethodType.new([], nil, @tnil)
    tmb = MethodType.new([@tfixnum], nil, @tnil)
    ts1 = StructuralType.new(m1: tma)
    assert (tnom <= ts1)
    assert (tnomt <= ts1)
    ts2 = StructuralType.new(m1: tma, m2: tma)
    assert (tnom <= ts2)
    assert (tnomt <= ts2)
    ts3 = StructuralType.new(m1: tma, m2: tma, m3: tma)
    assert (not (tnom <= ts3))
    assert (not (tnomt <= ts3))
    ts4 = StructuralType.new(m1: tmb)
    assert (tnom <= ts4) # types don't matter, only methods
    assert (not (tnomt <= ts4))
  end

  # def test_intersection
  #   skip "<= not defined on intersection"
  #   tobject_and_basicobject = IntersectionType.new(@tobject, @tbasicobject)
  #   assert (not (tobject_and_basicobject <= @tobject))
  #   assert (@tobject <= tobject_and_basicobject)
  # end

end
