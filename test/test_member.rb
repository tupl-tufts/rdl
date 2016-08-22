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
    @tarraystring = GenericType.new($__rdl_array_type, $__rdl_string_type)
    @tarrayobject = GenericType.new($__rdl_array_type, $__rdl_object_type)
    @tarrayarraystring = GenericType.new($__rdl_array_type, @tarraystring)
    @tarrayarrayobject = GenericType.new($__rdl_array_type, @tarrayobject)
    $__rdl_hash_type = NominalType.new Hash
    @thashstringstring = GenericType.new($__rdl_hash_type, $__rdl_string_type, $__rdl_string_type)
    @thashobjectobject = GenericType.new($__rdl_hash_type, $__rdl_object_type, $__rdl_object_type)
    @tstring_or_sym = UnionType.new($__rdl_string_type, $__rdl_symbol_type)
    @tstring_and_sym = IntersectionType.new($__rdl_string_type, $__rdl_symbol_type)
    @tobject_and_basicobject = IntersectionType.new($__rdl_object_type, @tbasicobject)
    @ta = NominalType.new A
    @tb = NominalType.new B
    @tc = NominalType.new C
    @tkernel = NominalType.new Kernel
    @tavar = VarType.new :a
  end

  def test_nil
    assert ($__rdl_nil_type.member? nil)
    assert (not ($__rdl_nil_type.member? "foo"))
    assert (not ($__rdl_nil_type.member? (Object.new)))
  end

  def test_top
    assert ($__rdl_top_type.member? nil)
    assert ($__rdl_top_type.member? "foo")
    assert ($__rdl_top_type.member? (Object.new))
  end

  def test_nominal
    o = Object.new
    assert ($__rdl_string_type.member? "Foo")
    assert (not ($__rdl_string_type.member? :Foo))
    assert (not ($__rdl_string_type.member? o))

    assert ($__rdl_object_type.member? "Foo")
    assert ($__rdl_object_type.member? :Foo)
    assert ($__rdl_object_type.member? o)

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

    assert ($__rdl_string_type.member? nil)
    assert ($__rdl_object_type.member? nil)
  end

  def test_symbol
    assert ($__rdl_symbol_type.member? :foo)
    assert ($__rdl_symbol_type.member? :bar)
    assert (not ($__rdl_symbol_type.member? "foo"))
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
    t1 = TupleType.new($__rdl_symbol_type, $__rdl_string_type)
    assert (t1.member? [:foo, "foo"])
    assert (not (t1.member? ["foo", :foo]))
    assert (not (t1.member? [:foo, "foo", "bar"]))
    t2 = TupleType.new
    assert (t2.member? [])
    assert (not (t2.member? [:foo]))
  end

  def test_finite_hash
    t1 = FiniteHashType.new({a: $__rdl_symbol_type, b: $__rdl_string_type}, nil)
    assert (t1.member?(a: :foo, b: "foo"))
    assert (not (t1.member?(a: 1, b: "foo")))
    assert (not (t1.member?(a: :foo)))
    assert (not (t1.member?(b: "foo")))
    assert (not (t1.member?(a: :foo, b: "foo", c: :baz)))
    t2 = FiniteHashType.new({"a"=>$__rdl_symbol_type, 2=>$__rdl_string_type}, nil)
    assert (t2.member?({"a"=>:foo, 2=>"foo"}))
    assert (not (t2.member?({"a"=>2, 2=>"foo"})))
    assert (not (t2.member?({"a"=>:foo})))
    assert (not (t2.member?({2=>"foo"})))
    assert (not (t2.member?({"a"=>:foo, 2=>"foo", 3=>"bar"})))
    t3 = FiniteHashType.new({"a"=>$__rdl_symbol_type, 2=>$__rdl_string_type}, $__rdl_fixnum_type)
    assert (t3.member?({"a"=>:foo, 2=>"foo"}))
    assert (t3.member?({"a"=>:foo, 2=>"foo", two: 2}))
    assert (t3.member?({"a"=>:foo, 2=>"foo", two: 2, three: 3}))
    assert (not (t3.member?({"a"=>:foo, 2=>"foo", two: 'two'})))
    assert (not (t3.member?({"a"=>:foo, 2=>"foo", two: 2, three: 'three'})))
    assert (not (t3.member?({"a"=>:foo, two: 2})))
    assert (not (t3.member?({2=>"foo", two: 2})))
    t4 = FiniteHashType.new({a: $__rdl_symbol_type, b: $__rdl_string_type}, $__rdl_fixnum_type)
    assert (t4.member?(a: :foo, b: "foo"))
    assert (t4.member?(a: :foo, b: "foo", c: 3))
    assert (t4.member?(a: :foo, b: "foo", c: 3, d: 4))
    assert (not (t4.member?(a: :foo, b: "foo", c: "three")))
    t5 = FiniteHashType.new({a: $__rdl_symbol_type, b: OptionalType.new($__rdl_string_type)}, $__rdl_fixnum_type)
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
