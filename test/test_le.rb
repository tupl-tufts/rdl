require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'
require 'types/core'

class TestLe < Minitest::Test
  include RDL::Type

  class A
  end

  class B < A
  end

  class C < B
  end

  # convert arg string to a type
  def tt(t)
    RDL.parser.scan_str('#T ' + t)
  end

  def setup
    @tbasicobject = NominalType.new "BasicObject"
    @tsymfoo = SingletonType.new :foo
    @ta = NominalType.new A
    @tb = NominalType.new B
    @tc = NominalType.new C
  end

  def test_nil
    assert (RDL.types[:nil] <= RDL.types[:top])
    assert (RDL.types[:nil] <= RDL.types[:string])
    assert (RDL.types[:nil] <= RDL.types[:object])
    assert (RDL.types[:nil] <= @tbasicobject)
    assert (not (RDL.types[:nil] <= @tsymfoo)) # nil no longer <= other singleton types
    assert (not (RDL.types[:top] <= RDL.types[:nil]))
    assert (not (RDL.types[:string] <= RDL.types[:nil]))
    assert (not (RDL.types[:object] <= RDL.types[:nil]))
    assert (not (@tbasicobject <= RDL.types[:nil]))
    assert (not (@tsymfoo <= RDL.types[:nil]))
  end

  def test_top
    assert (not (RDL.types[:top] <= RDL.types[:nil]))
    assert (not (RDL.types[:top] <= RDL.types[:string]))
    assert (not (RDL.types[:top] <= RDL.types[:object]))
    assert (not (RDL.types[:top] <= @tbasicobject))
    assert (not (RDL.types[:top] <= @tsymfoo))
    assert (RDL.types[:top] <= RDL.types[:top])
    assert (RDL.types[:string] <= RDL.types[:top])
    assert (RDL.types[:object] <= RDL.types[:top])
    assert (@tbasicobject <= RDL.types[:top])
    assert (@tsymfoo <= RDL.types[:top])
  end

  def test_sym
    assert (RDL.types[:symbol] <= RDL.types[:symbol])
    assert (@tsymfoo <= @tsymfoo)
    assert (@tsymfoo <= RDL.types[:symbol])
    assert (not (RDL.types[:symbol] <= @tsymfoo))
  end

  def test_nominal
    assert (RDL.types[:string] <= RDL.types[:string])
    assert (RDL.types[:symbol] <= RDL.types[:symbol])
    assert (not (RDL.types[:string] <= RDL.types[:symbol]))
    assert (not (RDL.types[:symbol] <= RDL.types[:string]))
    assert (RDL.types[:string] <= RDL.types[:object])
    assert (RDL.types[:string] <= @tbasicobject)
    assert (RDL.types[:object] <= @tbasicobject)
    assert (not (RDL.types[:object] <= RDL.types[:string]))
    assert (not (@tbasicobject <= RDL.types[:string]))
    assert (not (@tbasicobject <= RDL.types[:object]))
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
    tstring_or_sym = UnionType.new(RDL.types[:string], RDL.types[:symbol])
    assert (tstring_or_sym <= RDL.types[:object])
    assert (not (RDL.types[:object] <= tstring_or_sym))
  end

  def test_tuple
    t1 = TupleType.new(RDL.types[:symbol], RDL.types[:string])
    t2 = TupleType.new(RDL.types[:object], RDL.types[:object])
    tarray = NominalType.new("Array")
    assert (t1 <= t1)
    assert (t2 <= t2)
    assert (not (t2 <= t1))
    assert (not (tarray <= t1))
    assert (t1 <= t2) # covariant subtyping since tuples are *immutable*
    assert (tt("[1, 2, 3]") <= tt("[Fixnum, Fixnum, Fixnum]")) # covariant subtyping with singletons
    assert (tt("[Fixnum, Fixnum, Fixnum]") <= tt("[Object, Object, Object]"))
    assert (tt("[1, 2, 3]") <= tt("[Object, Object, Object]"))

    # subtyping of tuples and arrays
    tfs_1 = tt "[Fixnum, String]"
    tafs_1 = tt "Array<Fixnum or String>"
    assert (tfs_1 <= tafs_1) # subtyping allowed by tfs_1 promoted to array
    tfs2_1 = tt "[Fixnum, String]"
    assert (not (tfs_1 <= tfs2_1)) # t12 has been promoted to array, no longer subtype

    tfs_2 = tt "[Fixnum, String]"
    tfs2_2 = tt "[Fixnum, String]"
    assert (tfs_2 <= tfs2_2) # this is allowed here because tfs_2 is still a tuple
    tafs_2 = tt "Array<Fixnum or String>"
    assert (not (tfs_2 <= tafs_2)) # subtyping not allowed because tfs_2 <= tfs2_2 unsatisfiable after tfs_2 promoted

    tfs_3 = tt "[Fixnum, String]"
    tfs2_3 = tt "[Object, Object]"
    assert (tfs_3 <= tfs2_3) # this is allowed here because t12a is still a tuple
    tafs_3 = tt "Array<Object>"
    assert (not (tfs2_3 <= tafs_3)) # subtyping not allowed because tfs_3 <= tfs2_3 unsatisfiable after tfs2_3 promoted

    tfs_4 = tt "[Fixnum, String]"
    tfs2_4 = tt "[Fixnum, String]"
    assert (tfs_4 <= tfs2_4) # allowed, types are the same
    tafs_4 = tt "Array<Fixnum or String>"
    assert (tfs2_4 <= tafs_4) # allowed, both tfs2_4 and tfs_4 promoted to array
    tfs3_4 = tt "[Fixnum, String]"
    assert (not(tfs_4 <= tfs3_4)) # not allowed, tfs_4 has been promoted
  end

  def test_finite_hash
    t12 = tt "{a: 1, b: 2}"
    tfs = tt "{a: Fixnum, b: Fixnum}"
    too = tt "{a: Object, b: Object}"
    assert (t12 <= tfs)
    assert (t12 <= too)
    assert (tfs <= too)
    assert (not (tfs <= t12))
    assert (not (too <= tfs))
    assert (not (too <= t12))

    # subtyping of finite hashes and hashes; same pattern as tuples
    # subtyping of tuples and arrays
    tfs_1 = tt "{x: Fixnum, y: String}"
    thfs_1 = tt "Hash<Symbol, Fixnum or String>"
    assert (tfs_1 <= thfs_1) # subtyping allowed because tfs_1 promoted to hash
    tfs2_1 = tt "{x: Fixnum, y: String}"
    assert (not (tfs_1 <= tfs2_1)) # t12 has been promoted to hash, no longer subtype

    tfs_2 = tt "{x: Fixnum, y: String}"
    tfs2_2 = tt "{x: Fixnum, y: String}"
    assert (tfs_2 <= tfs2_2) # this is allowed here because tfs_2 is still finite
    thfs_2 = tt "Hash<Symbol, Fixnum or String>"
    assert (not (tfs_2 <= thfs_2)) # subtyping not allowed because tfs_2 <= tfs2_2 unsatisfiable after tfs_2 promoted

    tfs_3 = tt "{x: Fixnum, y: String}"
    tfs2_3 = tt "{x: Object, y: Object}"
    assert (tfs_3 <= tfs2_3) # this is allowed here because t12a is still finite
    thfs_3 = tt "Hash<Symbol, Object>"
    assert (not (tfs2_3 <= thfs_3)) # subtyping not allowed because tfs_3 <= tfs2_3 unsatisfiable after tfs2_3 promoted

    tfs_4 = tt "{x: Fixnum, y: String}"
    tfs2_4 = tt "{x: Fixnum, y: String}"
    assert (tfs_4 <= tfs2_4) # allowed, types are the same
    thfs_4 = tt "Hash<Symbol, Fixnum or String>"
    assert (tfs2_4 <= thfs_4) # allowed, both tfs2_4 and tfs_4 promoted to hash
    tfs3_4 = tt "{x: Fixnum, y: String}"
    assert (not(tfs_4 <= tfs3_4)) # not allowed, tfs_4 has been promoted

    tfss_5 = tt "{x: Fixnum, y: String, **Symbol}"
    tfns_5 = tt "{x: Fixnum, **Symbol}"
    tfsn_5 = tt "{x: Fixnum, y: String}"
    tftn_5 = tt "{x: Fixnum, z: Symbol}"
    tooo_5 = tt "{x: Object, y: Object, **Object}"
    tono_5 = tt "{x: Object, **Object}"
    assert (tfss_5 <= tooo_5)
    assert (tfns_5 <= tono_5)
    assert (not (tfss_5 <= tfns_5))
    assert (not (tfss_5 <= tfsn_5))
    assert (not (tfss_5 <= tftn_5))
    assert (not (tfns_5 <= tfss_5))
    assert (not (tfns_5 <= tfsn_5))
    assert (not (tfns_5 <= tftn_5))
    assert (tfsn_5 <= tfss_5)
    assert (not (tfsn_5 <= tfns_5))
    assert (not (tfsn_5 <= tftn_5))
    assert (not (tftn_5 <= tfss_5))
    assert (tftn_5 <= tfns_5)
    assert (not (tftn_5 <= tfsn_5))

    assert (not (tt("{x: ?Fixnum}") <= tt("{x: Fixnum}")))
  end

  def test_method
    tss = MethodType.new([RDL.types[:string]], nil, RDL.types[:string])
    tso = MethodType.new([RDL.types[:string]], nil, RDL.types[:object])
    tos = MethodType.new([RDL.types[:object]], nil, RDL.types[:string])
    too = MethodType.new([RDL.types[:object]], nil, RDL.types[:object])
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
    tbos = MethodType.new([], tos, RDL.types[:object])
    tbso = MethodType.new([], tso, RDL.types[:object])
    assert (tbos <= tbos)
    assert (not (tbos <= tbso))
    assert (tbso <= tbso)
    assert (tbso <= tbos)
    assert (tss <= RDL.types[:proc])
  end

  def test_structural
    tso = MethodType.new([RDL.types[:string]], nil, RDL.types[:object])
    tos = MethodType.new([RDL.types[:object]], nil, RDL.types[:string])
    ts1 = StructuralType.new(m1: tso)
    ts2 = StructuralType.new(m1: tos)
    assert (ts1 <= RDL.types[:top])
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
    tma = MethodType.new([], nil, RDL.types[:nil])
    tmb = MethodType.new([RDL.types[:fixnum]], nil, RDL.types[:nil])
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

  def test_leq_inst
    # when return of do_leq is false, ignore resulting inst, since that's very implementation dependent
    assert_equal [true, {t: @ta}], do_leq(tt("t"), @ta, true)
    assert_equal false, do_leq(tt("t"), @ta, false)[0]
    assert_equal false, do_leq(@ta, tt("t"), true)[0]
    assert_equal [true, {t: @ta}], do_leq(@ta, tt("t"), false)
    assert_equal [true, {}], do_leq(RDL.types[:bot], tt("t"), true)
    assert_equal [true, {}], do_leq(RDL.types[:bot], tt("t"), false)
    assert_equal false, do_leq(RDL.types[:top], tt("t"), true)[0]
    assert_equal [true, {t: RDL.types[:top]}], do_leq(RDL.types[:top], tt("t"), false)
    assert_equal [true, {t: @ta, u: @ta}], do_leq(tt("t or u"), @ta, true)
    assert_equal false, do_leq(tt("t or u"), @ta, false)[0]
    assert_equal false, do_leq(tt("3"), tt("t"), true)[0]
    assert_equal [true, {t: tt("3")}], do_leq(tt("3"), tt("t"), false)
    assert_equal [true, {t: RDL.types[:fixnum]}], do_leq(tt("Array<t>"), tt("Array<Fixnum>"), true)
    assert_equal false, do_leq(tt("Array<t>"), tt("Array<Fixnum>"), false)[0]
    assert_equal [true, {t: RDL.types[:fixnum]}], do_leq(tt("Array<Fixnum>"), tt("Array<t>"), false)
    assert_equal false, do_leq(tt("Array<Fixnum>"), tt("Array<t>"), true)[0]
    assert_equal [true, {t: RDL.types[:fixnum], u: RDL.types[:string]}], do_leq(tt("Hash<t,u>"), tt("Hash<Fixnum,String>"), true)
    assert_equal [true, {t: RDL.types[:fixnum]}], do_leq(tt("Hash<t,t>"), tt("Hash<Fixnum,Fixnum>"), true)
    assert_equal false, do_leq(tt("Hash<t,t>"), tt("Hash<Fixnum,String>"), true)[0]
    assert_equal false, do_leq(tt("[m:()->t]"), tt("[m:()->Fixnum]"), true)[0] # no inst inside structural types
  end

  def do_leq(tleft, tright, ileft)
    inst = Hash.new
    r = Type.leq(tleft, tright, inst, ileft)
    return [r, inst]
  end

  # nonnull annotation is simply removed! so doesn't matter
  def test_leq_nonnull
    assert tt("!Fixnum") <= tt("!Fixnum")
    assert tt("!Fixnum") <= tt("Fixnum")
    assert tt("Fixnum") <= tt("!Fixnum")
    assert tt("!Fixnum") <= tt("!Object")
    assert tt("!Fixnum") <= tt("Object")
    assert tt("Fixnum") <= tt("!Object")
  end

  # def test_intersection
  #   skip "<= not defined on intersection"
  #   tobject_and_basicobject = IntersectionType.new(RDL.types[:object], @tbasicobject)
  #   assert (not (tobject_and_basicobject <= RDL.types[:object]))
  #   assert (RDL.types[:object] <= tobject_and_basicobject)
  # end

end
