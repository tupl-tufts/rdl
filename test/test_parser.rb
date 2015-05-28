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
    @tfixnumx = RDL::Type::NamedArgType.new("x", @tfixnum)
    @tfixnumy = RDL::Type::NamedArgType.new("y", @tfixnum)
    @tfixnumret = RDL::Type::NamedArgType.new("ret", @tfixnum)
    @tfixnumoptx = RDL::Type::NamedArgType.new("x", @tfixnumopt)
    @tfixnumvarargx = RDL::Type::NamedArgType.new("x", @tfixnumvararg)
    @tsymbol = RDL::Type::SymbolType.new(:symbol)
    @tsymbolx = RDL::Type::NamedArgType.new("x", @tsymbol)
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
    assert_raises(RuntimeError) { @p.scan_str "(%foo) -> nil" }
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

  def test_bare
    t1 = @p.scan_str "## nil"
    assert_equal t1, @tnil
    t2 = @p.scan_str "## %any"
    assert_equal t2, @ttop
    t3 = @p.scan_str "## A"
    assert_equal t3, NominalType.new("A")
  end

  def test_symbol
    t1 = @p.scan_str "## :symbol"
    assert_equal t1, @tsymbol
  end

  def test_named_params
    t1 = @p.scan_str "(x : Fixnum, Fixnum) -> Fixnum"
    assert_equal t1, (MethodType.new [@tfixnumx, @tfixnum], nil, @tfixnum)
    t2 = @p.scan_str "(x : ?Fixnum, Fixnum) -> Fixnum"
    assert_equal t2, (MethodType.new [@tfixnumoptx, @tfixnum], nil, @tfixnum)
    t3 = @p.scan_str "(x : *Fixnum, Fixnum) -> Fixnum"
    assert_equal t3, (MethodType.new [@tfixnumvarargx, @tfixnum], nil, @tfixnum)
    t4 = @p.scan_str "(Fixnum, y : Fixnum) -> Fixnum"
    assert_equal t4, (MethodType.new [@tfixnum, @tfixnumy], nil, @tfixnum)
    t5 = @p.scan_str "(x : Fixnum, y : Fixnum) -> Fixnum"
    assert_equal t5, (MethodType.new [@tfixnumx, @tfixnumy], nil, @tfixnum)
    t6 = @p.scan_str "(Fixnum, Fixnum) -> ret : Fixnum"
    assert_equal t6, (MethodType.new [@tfixnum, @tfixnum], nil, @tfixnumret)
    t7 = @p.scan_str "(x : Fixnum, Fixnum) -> ret : Fixnum"
    assert_equal t7, (MethodType.new [@tfixnumx, @tfixnum], nil, @tfixnumret)
    t8 = @p.scan_str "(Fixnum, y : Fixnum) -> ret : Fixnum"
    assert_equal t8, (MethodType.new [@tfixnum, @tfixnumy], nil, @tfixnumret)
    t9 = @p.scan_str "(x : Fixnum, y : Fixnum) -> ret : Fixnum"
    assert_equal t9, (MethodType.new [@tfixnumx, @tfixnumy], nil, @tfixnumret)
    t10 = @p.scan_str "(x : :symbol) -> Fixnum"
    assert_equal t10, (MethodType.new [@tsymbolx], nil, @tfixnum)
  end

  def test_generic
    t1 = @p.scan_str "## t"
    assert_equal t1, (VarType.new "t")
    t2 = @p.scan_str "## Array"
    assert_equal t2, (NominalType.new "Array")
    t3 = @p.scan_str "## Array<t>"
    assert_equal t3, (GenericType.new(t2, t1))
    t4 = @p.scan_str "## Array<Array<t>>"
    assert_equal t4, (GenericType.new(t2, t3))
    t5 = @p.scan_str "## Hash"
    assert_equal t5, (NominalType.new "Hash")
    t6 = @p.scan_str "## Hash<u, v>"
    assert_equal t6, (GenericType.new(t5, VarType.new("u"), VarType.new("v")))
    t7 = @p.scan_str "## Foo<String, Array<t>, Array<Array<t>>>"
    assert_equal t7, (GenericType.new(NominalType.new("Foo"), NominalType.new("String"), t3, t4))
  end


end
