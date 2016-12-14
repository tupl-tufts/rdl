require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestMember < Minitest::Test
  include RDL::Type

  class A
  end

  class B < A
  end

  class C < B
  end

  def setup
    @tbasicobject = NominalType.new "BasicObject"
    @tsymfoo = SingletonType.new :foo
    @tarraystring = GenericType.new(RDL.types[:array], RDL.types[:string])
    @tarrayobject = GenericType.new(RDL.types[:array], RDL.types[:object])
    @tarrayarraystring = GenericType.new(RDL.types[:array], @tarraystring)
    @tarrayarrayobject = GenericType.new(RDL.types[:array], @tarrayobject)
    RDL.types[:hash] = NominalType.new Hash
    @thashstringstring = GenericType.new(RDL.types[:hash], RDL.types[:string], RDL.types[:string])
    @thashobjectobject = GenericType.new(RDL.types[:hash], RDL.types[:object], RDL.types[:object])
    @tstring_or_sym = UnionType.new(RDL.types[:string], RDL.types[:symbol])
    @tstring_and_sym = IntersectionType.new(RDL.types[:string], RDL.types[:symbol])
    @tobject_and_basicobject = IntersectionType.new(RDL.types[:object], @tbasicobject)
    @ta = NominalType.new A
    @tb = NominalType.new B
    @tc = NominalType.new C
    @tkernel = NominalType.new Kernel
    @tavar = VarType.new :a
  end

  def test_nil
    assert (RDL.types[:nil].member? nil)
    assert (not (RDL.types[:nil].member? "foo"))
    assert (not (RDL.types[:nil].member? (Object.new)))
  end

  def test_top
    assert (RDL.types[:top].member? nil)
    assert (RDL.types[:top].member? "foo")
    assert (RDL.types[:top].member? (Object.new))
  end

  def test_nominal
    o = Object.new
    assert (RDL.types[:string].member? "Foo")
    assert (not (RDL.types[:string].member? :Foo))
    assert (not (RDL.types[:string].member? o))

    assert (RDL.types[:object].member? "Foo")
    assert (RDL.types[:object].member? :Foo)
    assert (RDL.types[:object].member? o)

    assert (@tkernel.member? "Foo")
    assert (@tkernel.member? :Foo)
    assert (@tkernel.member? o)

    a = A.new
    b = B.new
    c = C.new
    assert (@ta.member? a)
    assert (@ta.member? b)
    assert (@ta.member? c)
    assert (not (@tb.member? a))
    assert (@tb.member? b)
    assert (@tb.member? c)
    assert (not (@tc.member? a))
    assert (not (@tc.member? b))
    assert (@tc.member? c)

    assert (RDL.types[:string].member? nil)
    assert (RDL.types[:object].member? nil)
  end

  def test_symbol
    assert (RDL.types[:symbol].member? :foo)
    assert (RDL.types[:symbol].member? :bar)
    assert (not (RDL.types[:symbol].member? "foo"))
    assert (@tsymfoo.member? :foo)
    assert (not (@tsymfoo.member? :bar))
    assert (not (@tsymfoo.member? "foo"))
    assert (not(@tsymfoo.member? nil)) # nil no longer subtype of other singletons
  end

  def test_union_intersection
    o = Object.new

    assert (@tstring_or_sym.member? "foo")
    assert (@tstring_or_sym.member? :foo)
    assert (not (@tstring_or_sym.member? o))
    assert (@tstring_or_sym.member? nil)

    assert (not (@tstring_and_sym.member? "foo"))
    assert (not (@tstring_and_sym.member? :foo))
    assert (not (@tstring_and_sym.member? o))
    assert (@tstring_and_sym.member? nil)

    assert (@tobject_and_basicobject.member? o)
    assert (@tobject_and_basicobject.member? nil)
  end

  def test_var
    assert_raises(TypeError) { @tavar.member? "foo" }
  end

  def test_tuple
    t1 = TupleType.new(RDL.types[:symbol], RDL.types[:string])
    assert (t1.member? [:foo, "foo"])
    assert (not (t1.member? ["foo", :foo]))
    assert (not (t1.member? [:foo, "foo", "bar"]))
    t2 = TupleType.new
    assert (t2.member? [])
    assert (not (t2.member? [:foo]))
  end

  def test_finite_hash
    t1 = FiniteHashType.new({a: RDL.types[:symbol], b: RDL.types[:string]}, nil)
    assert (t1.member?(a: :foo, b: "foo"))
    assert (not (t1.member?(a: 1, b: "foo")))
    assert (not (t1.member?(a: :foo)))
    assert (not (t1.member?(b: "foo")))
    assert (not (t1.member?(a: :foo, b: "foo", c: :baz)))
    t2 = FiniteHashType.new({"a"=>RDL.types[:symbol], 2=>RDL.types[:string]}, nil)
    assert (t2.member?({"a"=>:foo, 2=>"foo"}))
    assert (not (t2.member?({"a"=>2, 2=>"foo"})))
    assert (not (t2.member?({"a"=>:foo})))
    assert (not (t2.member?({2=>"foo"})))
    assert (not (t2.member?({"a"=>:foo, 2=>"foo", 3=>"bar"})))
    t3 = FiniteHashType.new({"a"=>RDL.types[:symbol], 2=>RDL.types[:string]}, RDL.types[:fixnum])
    assert (t3.member?({"a"=>:foo, 2=>"foo"}))
    assert (t3.member?({"a"=>:foo, 2=>"foo", two: 2}))
    assert (t3.member?({"a"=>:foo, 2=>"foo", two: 2, three: 3}))
    assert (not (t3.member?({"a"=>:foo, 2=>"foo", two: 'two'})))
    assert (not (t3.member?({"a"=>:foo, 2=>"foo", two: 2, three: 'three'})))
    assert (not (t3.member?({"a"=>:foo, two: 2})))
    assert (not (t3.member?({2=>"foo", two: 2})))
    t4 = FiniteHashType.new({a: RDL.types[:symbol], b: RDL.types[:string]}, RDL.types[:fixnum])
    assert (t4.member?(a: :foo, b: "foo"))
    assert (t4.member?(a: :foo, b: "foo", c: 3))
    assert (t4.member?(a: :foo, b: "foo", c: 3, d: 4))
    assert (not (t4.member?(a: :foo, b: "foo", c: "three")))
    t5 = FiniteHashType.new({a: RDL.types[:symbol], b: OptionalType.new(RDL.types[:string])}, RDL.types[:fixnum])
    assert (t5.member?(a: :foo, b: "foo"))
    assert (t5.member?(a: :foo, b: "foo", c: 3))
    assert (t5.member?(a: :foo, b: "foo", c: 3, d: 4))
    assert (not (t5.member?(a: :foo, b: "foo", c: "three")))
    assert (t5.member?(a: :foo))
    assert (t5.member?(a: :foo, c: 3))
    assert (t5.member?(a: :foo, c: 3, d: 4))
    assert (not (t5.member?(a: :foo, c: "three")))
  end
end
