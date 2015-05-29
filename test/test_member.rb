require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class MemberTest < Minitest::Test
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
    @tsymfoo = SymbolType.new :foo
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
    @tobject_and_basicobject = IntersectionType.new(@tobject, @tbasicobject)
    @ta = NominalType.new A
    @tb = NominalType.new B
    @tc = NominalType.new C
    @tkernel = NominalType.new Kernel
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
  end
  
end
