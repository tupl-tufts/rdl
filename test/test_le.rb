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
    assert (not (@tobject <= @tstring_or_sym))
  end

  # def test_intersection
  #   skip "<= not defined on intersection"
  #   tobject_and_basicobject = IntersectionType.new(@tobject, @tbasicobject)
  #   assert (not (tobject_and_basicobject <= @tobject))
  #   assert (@tobject <= tobject_and_basicobject)
  # end
  
end
