require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestParser < Minitest::Test
  include RDL::Type

  def setup
    @p = Parser.new
    @tnil = NilType.new
    @ttop = TopType.new
    @tfixnum = NominalType.new Fixnum
    @tfixnumopt = OptionalType.new @tfixnum
    @tfixnumvararg = VarargType.new @tfixnum
    @tstring = NominalType.new String
    @tenum = NominalType.new :Enumerator
    @ttrue = NominalType.new TrueClass
    @tfalse = NominalType.new FalseClass
    @tbool = UnionType.new @ttrue, @tfalse
    @ta = NominalType.new :A
    @tb = NominalType.new :B
    @tc = NominalType.new :C
    @tfixnumx = NamedArgType.new("x", @tfixnum)
    @tfixnumy = NamedArgType.new("y", @tfixnum)
    @tfixnumret = NamedArgType.new("ret", @tfixnum)
    @tfixnumoptx = NamedArgType.new("x", @tfixnumopt)
    @tfixnumvarargx = NamedArgType.new("x", @tfixnumvararg)
    @tsymbol = SymbolType.new(:symbol)
    @tsymbolx = NamedArgType.new("x", @tsymbol)
    @ttuple = NominalType.new("Tuple")
  end

  def test_basic
    t1 = @p.scan_str "(nil) -> nil"
    assert_equal (MethodType.new [@tnil], nil, @tnil), t1
    t2 = @p.scan_str "(Fixnum, Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnum], nil, @tfixnum), t2
    t3 = @p.scan_str "() -> Enumerator"
    assert_equal (MethodType.new [], nil, @tenum), t3
    t4 = @p.scan_str "(%any) -> nil"
    assert_equal (MethodType.new [@ttop], nil, @tnil), t4
    t5 = @p.scan_str "(%bool) -> Fixnum"
    assert_equal (MethodType.new [@tbool], nil, @tfixnum), t5
    assert_raises(RuntimeError) { @p.scan_str "(%foo) -> nil" }
  end

  def test_opt_vararg
    t1 = @p.scan_str "(Fixnum, ?Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnumopt], nil, @tfixnum), t1
    t2 = @p.scan_str "(Fixnum, *Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnumvararg], nil, @tfixnum), t2
    t3 = @p.scan_str "(Fixnum, ?Fixnum, ?Fixnum, *Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnumopt, @tfixnumopt, @tfixnumvararg], nil, @tfixnum), t3
    t4 = @p.scan_str "(?Fixnum) -> nil"
    assert_equal (MethodType.new [@tfixnumopt], nil, @tnil), t4
    t5 = @p.scan_str "(*Fixnum) -> nil"
    assert_equal (MethodType.new [@tfixnumvararg], nil, @tnil), t5
  end

  def test_union
    t1 = @p.scan_str "(A or B) -> nil"
    assert_equal (MethodType.new [UnionType.new(@ta, @tb)], nil, @tnil), t1
    t2 = @p.scan_str "(A or B or C) -> nil"
    assert_equal (MethodType.new [UnionType.new(@ta, @tb, @tc)], nil, @tnil), t2
    t3 = @p.scan_str "() -> A or B or C"
    assert_equal (MethodType.new [], nil, UnionType.new(@ta, @tb, @tc)), t3
  end

  def test_bare
    t1 = @p.scan_str "## nil"
    assert_equal @tnil, t1
    t2 = @p.scan_str "## %any"
    assert_equal @ttop, t2
    t3 = @p.scan_str "## A"
    assert_equal NominalType.new("A"), t3
  end

  def test_symbol
    t1 = @p.scan_str "## :symbol"
    assert_equal @tsymbol, t1
  end

  def test_named_params
    t1 = @p.scan_str "(x : Fixnum, Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, @tfixnum], nil, @tfixnum), t1
    t2 = @p.scan_str "(x : ?Fixnum, Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumoptx, @tfixnum], nil, @tfixnum), t2
    t3 = @p.scan_str "(x : *Fixnum, Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumvarargx, @tfixnum], nil, @tfixnum), t3
    t4 = @p.scan_str "(Fixnum, y : Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnumy], nil, @tfixnum), t4
    t5 = @p.scan_str "(x : Fixnum, y : Fixnum) -> Fixnum"
    assert_equal (MethodType.new [@tfixnumx, @tfixnumy], nil, @tfixnum), t5
    t6 = @p.scan_str "(Fixnum, Fixnum) -> ret : Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnum], nil, @tfixnumret), t6
    t7 = @p.scan_str "(x : Fixnum, Fixnum) -> ret : Fixnum"
    assert_equal (MethodType.new [@tfixnumx, @tfixnum], nil, @tfixnumret), t7
    t8 = @p.scan_str "(Fixnum, y : Fixnum) -> ret : Fixnum"
    assert_equal (MethodType.new [@tfixnum, @tfixnumy], nil, @tfixnumret), t8
    t9 = @p.scan_str "(x : Fixnum, y : Fixnum) -> ret : Fixnum"
    assert_equal (MethodType.new [@tfixnumx, @tfixnumy], nil, @tfixnumret), t9
    t10 = @p.scan_str "(x : :symbol) -> Fixnum"
    assert_equal (MethodType.new [@tsymbolx], nil, @tfixnum), t10
  end

  def test_generic
    t1 = @p.scan_str "## t"
    assert_equal (VarType.new "t"), t1
    t2 = @p.scan_str "## Array"
    assert_equal (NominalType.new "Array"), t2
    t3 = @p.scan_str "## Array<t>"
    assert_equal (GenericType.new(t2, t1)), t3
    t4 = @p.scan_str "## Array<Array<t>>"
    assert_equal (GenericType.new(t2, t3)), t4
    t5 = @p.scan_str "## Hash"
    assert_equal (NominalType.new "Hash"), t5
    t6 = @p.scan_str "## Hash<u, v>"
    assert_equal (GenericType.new(t5, VarType.new("u"), VarType.new("v"))), t6
    t7 = @p.scan_str "## Foo<String, Array<t>, Array<Array<t>>>"
    assert_equal (GenericType.new(NominalType.new("Foo"), @tstring, t3, t4)), t7
  end

  def test_tuple
    t1 = @p.scan_str "## [Fixnum, String]"
    assert_equal (GenericType.new(@ttuple, @tfixnum, @tstring)), t1
    t2 = @p.scan_str "## [String]"
    assert_equal (GenericType.new(@ttuple, @tstring)), t2
  end 

end
