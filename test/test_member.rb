require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestMember < Minitest::Test
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
    @tarray = NominalType.new Array
    @tarraystring = GenericType.new(@tarray, @tstring)
    @tarrayobject = GenericType.new(@tarray, @tobject)
    @tarrayarraystring = GenericType.new(@tarray, @tarraystring)
    @tarrayarrayobject = GenericType.new(@tarray, @tarrayobject)
    @thash = NominalType.new Hash
    @thashstringstring = GenericType.new(@thash, @tstring, @tstring)
    @thashobjectobject = GenericType.new(@thash, @tobject, @tobject)
    @tstring_or_sym = UnionType.new(@tstring, @tsym)
    @tstring_and_sym = IntersectionType.new(@tstring, @tsym)
    @tobject_and_basicobject = IntersectionType.new(@tobject, @tbasicobject)
    @ta = NominalType.new A
    @tb = NominalType.new B
    @tc = NominalType.new C
    @tkernel = NominalType.new Kernel
    @tarray = NominalType.new Array
    @tarraystring = GenericType.new(@tarray, @tstring)
    @tarrayobject = GenericType.new(@tarray, @tobject)
    @tarrayarraystring = GenericType.new(@tarray, @tarraystring)
    @tarrayarrayobject = GenericType.new(@tarray, @tarrayobject)
    @thash = NominalType.new Hash
    @thashsymstring = GenericType.new(@thash, @tsym, @tstring)
    @thashobjectobject = GenericType.new(@thash, @tobject, @tobject)
    @tavar = VarType.new :a
  end

  def test_nil
    assert (@tnil.member? nil)
    assert (not (@tnil.member? "foo"))
    assert (not (@tnil.member? (Object.new)))
  end

  def test_top
    assert (@ttop.member? nil)
    assert (@ttop.member? "foo")
    assert (@ttop.member? (Object.new))
  end

  def test_nominal
    o = Object.new
    assert (@tstring.member? "Foo")
    assert (not (@tstring.member? :Foo))
    assert (not (@tstring.member? o))

    assert (@tobject.member? "Foo")
    assert (@tobject.member? :Foo)
    assert (@tobject.member? o)

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

    assert (@tstring.member? nil)
    assert (@tobject.member? nil)
end

  def test_symbol
    assert (@tsym.member? :foo)
    assert (@tsym.member? :bar)
    assert (not (@tsym.member? "foo"))
    assert (@tsymfoo.member? :foo)
    assert (not (@tsymfoo.member? :bar))
    assert (not (@tsymfoo.member? "foo"))
    assert (@tsymfoo.member? nil)
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

  def test_var_inst
    assert(@tavar.member?("foo", inst: {a: @tstring}))
  end

  def test_generic
    # Make two classes that wrap Array and Hash, so we don't mess with their
    # implementations in test case evaluation.
    self.class.class_eval <<-RUBY, __FILE__, __LINE__
      module Generic
        class A
          type_params [:t]
          def __rdl_member?(inst)
            t = inst[:t]
            return @a.all? { |x| t.member? x }
          end
          def initialize(a); @a = a end
        end
        class B
          type_params [:k, :v]
          def __rdl_member?(inst)
            tk = inst[:k]
            tv = inst[:v]
            return @h.all? { |k, v| (tk.member? k) && (tv.member? v) }
          end
          def initialize(h); @h = h end
        end
      end
RUBY
    ta = NominalType.new "TestMember::Generic::A"
    tb = NominalType.new "TestMember::Generic::B"
    assert (ta.member?(Generic::A.new([1, 2, 3])))
    assert (ta.member?(Generic::A.new([])))
    tas = GenericType.new(ta, @tstring)
    assert (tas.member?(Generic::A.new(["a", "b", "c"])))
    assert (tas.member?(Generic::A.new([])))
    assert (not (tas.member?(Generic::A.new([1, 2, 3]))))
    tao = GenericType.new(ta, @tobject)
    assert (tao.member?(Generic::A.new([1, 2, 3])))
    assert (tao.member?(Generic::A.new(["a", "b", "c"])))
    taas = GenericType.new(ta, tas)
    assert (taas.member?(Generic::A.new([Generic::A.new(["a", "b"]), Generic::A.new(["c"])])))
    assert (taas.member?(Generic::A.new([])))
    assert (taas.member?(Generic::A.new([Generic::A.new([])])))
    assert (taas.member?(Generic::A.new([Generic::A.new([]), Generic::A.new([])])))
    assert (not (taas.member?(Generic::A.new(["a", "b", "c"]))))
    assert (not (taas.member?(Generic::A.new([Generic::A.new(["a", "b"]), Generic::A.new([1])]))))
    assert (tb.member?(Generic::B.new(Hash.new)))
    assert (tb.member?(Generic::B.new(a:1, b:2)))
    tbsyms = GenericType.new(tb, @tsym, @tstring)
    assert (tbsyms.member?(Generic::B.new(a:"one", b:"two")))
    assert (not (tbsyms.member?(Generic::B.new(a:1, b:2))))
    assert (not (tbsyms.member?(Generic::B.new({"a"=>"one", "b"=>"two"}))))
    tboo = GenericType.new(tb, @tobject, @tobject)
    assert (tboo.member?(Generic::B.new(a:"one", b:"two")))
    assert (tboo.member?(Generic::B.new(a:1, b:2)))
    assert (tboo.member?(Generic::B.new({"a"=>"one", "b"=>"two"})))
  end
  
end
