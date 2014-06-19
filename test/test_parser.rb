require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TypeTest < Minitest::Test
  include RDL::Type

  def setup
    @p = RDL::Type::Parser.new
    @tnil = RDL::Type::NilType.new
    @ttop = RDL::Type::TopType.new
    @tfixnum = RDL::Type::NominalType.new Fixnum
    @tfixnumopt = RDL::Type::OptionalType.new @tfixnum
    @tfixnumvararg = RDL::Type::VarargType.new @tfixnum
    @tenum = RDL::Type::NominalType.new :Enumerator
    @ttrue = RDL::Type::NominalType.new TrueClass
    @tfalse = RDL::Type::NominalType.new FalseClass
    @tbool = RDL::Type::UnionType.new @ttrue, @tfalse
    @ta = RDL::Type::NominalType.new :A
    @tb = RDL::Type::NominalType.new :B
    @tc = RDL::Type::NominalType.new :C
  end

  def test_basic
    t1 = @p.scan_str "(nil) -> nil"
    assert_equal t1, (MethodType.new [@tnil], nil, @tnil)
    t2 = @p.scan_str "(Fixnum, Fixnum) -> Fixnum"
    assert_equal t2, (MethodType.new [@tfixnum, @tfixnum], nil, @tfixnum)
    t3 = @p.scan_str "() -> Enumerator"
    assert_equal t3, (MethodType.new [], nil, @tenum)
    t4 = @p.scan_str "(%any) -> nil"
    assert_equal t4, (MethodType.new [@ttop], nil, @tnil)
    t5 = @p.scan_str "(%bool) -> Fixnum"
    assert_equal t5, (MethodType.new [@tbool], nil, @tfixnum)
    assert_raise(RuntimeError) { @p.scan_str "(%foo) -> nil" }
  end

  def test_opt_vararg
    t1 = @p.scan_str "(Fixnum, ?Fixnum) -> Fixnum"
    assert_equal t1, (MethodType.new [@tfixnum, @tfixnumopt], nil, @tfixnum)
    t2 = @p.scan_str "(Fixnum, *Fixnum) -> Fixnum"
    assert_equal t2, (MethodType.new [@tfixnum, @tfixnumvararg], nil, @tfixnum)
    t3 = @p.scan_str "(Fixnum, ?Fixnum, ?Fixnum, *Fixnum) -> Fixnum"
    assert_equal t3, (MethodType.new [@tfixnum, @tfixnumopt, @tfixnumopt, @tfixnumvararg], nil, @tfixnum)
    t4 = @p.scan_str "(?Fixnum) -> nil"
    assert_equal t4, (MethodType.new [@tfixnumopt], nil, @tnil)
    t5 = @p.scan_str "(*Fixnum) -> nil"
    assert_equal t5, (MethodType.new [@tfixnumvararg], nil, @tnil)
  end

  def test_union
    t1 = @p.scan_str "(A or B) -> nil"
    assert_equal t1, (MethodType.new [UnionType.new(@ta, @tb)], nil, @tnil)
    t2 = @p.scan_str "(A or B or C) -> nil"
    assert_equal t2, (MethodType.new [UnionType.new(@ta, @tb, @tc)], nil, @tnil)
    t3 = @p.scan_str "() -> A or B or C"
    assert_equal t3, (MethodType.new [], nil, UnionType.new(@ta, @tb, @tc))
  end

#def test_generic
#    t = @p.scan_str "'[]': (Fixnum) -> t or nil"
#  t = @p.scan_str "(t) -> Array<t>"
#  t = @p.scan_str "() { (t) -> %bool } -> Fixnum"
#  t = @p.scan_str "<u> : u -> t"
#  t = @p.scan_str "<u,v> : (u) { () -> v } -> t or v"



end
