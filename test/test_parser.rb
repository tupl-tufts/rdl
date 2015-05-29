require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TypeParserTest < Minitest::Test
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
    assert_equal t7, (GenericType.new(NominalType.new("Foo"), @tstring, t3, t4))
  end

  def test_tuple
    t1 = @p.scan_str "## [Fixnum, String]"
    assert_equal t1, (GenericType.new(@ttuple, @tfixnum, @tstring))
    t2 = @p.scan_str "## [String]"
    assert_equal t2, (GenericType.new(@ttuple, @tstring))
  end 

end
