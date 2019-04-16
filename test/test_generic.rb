require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'
RDL.reset

class TestGeneric < Minitest::Test
  extend RDL::Annotate

  # Make two classes that wrap Array and Hash, so we don't mess with their
  # implementations in test case evaluation.
  class A
    def initialize(a); @a = a end
    def all?(&blk)
      @a.all?(&blk)
    end
  end

  class H
    def initialize(h); @h = h end
    def all?(&blk)
      @h.all? { |x, y| blk.call(x, y) } # have to do extra wrap to avoid splat issues
    end
  end

  class B
    extend RDL::Annotate
    # class for checking other variance annotations
    def m1(x) # type annotation
      nil
    end
    def m2(x) # no type annotation
      nil
    end
  end

  class C
    def m1() return self; end
    def m2() return C.new; end
    def m3() return Object.new; end
  end

  class D < C
  end



  def setup
    RDL.reset
    RDL.type_params A, [:t], :all?
    RDL.type_params H, [:k, :v], :all?
    RDL.type_params(B, [:a, :b], nil, variance: [:+, :-]) { |a, b| true }
    RDL.type B, :m1, "(a) -> nil"
    RDL.type C, :m1, "() -> self"
    RDL.type C, :m2, "() -> self"
    RDL.type C, :m3, "() -> self"
    @ta = RDL::Type::NominalType.new "TestGeneric::A"
    @th = RDL::Type::NominalType.new "TestGeneric::H"
    @tas = RDL::Type::GenericType.new(@ta, RDL::Globals.types[:string])
    @tao = RDL::Type::GenericType.new(@ta, RDL::Globals.types[:object])
    @taas = RDL::Type::GenericType.new(@ta, @tas)
    @taao = RDL::Type::GenericType.new(@ta, @tao)
    @thss = RDL::Type::GenericType.new(@th, RDL::Globals.types[:string], RDL::Globals.types[:string])
    @thoo = RDL::Type::GenericType.new(@th, RDL::Globals.types[:object], RDL::Globals.types[:object])
    @thsf = RDL::Type::GenericType.new(@th, RDL::Globals.types[:string], RDL::Globals.types[:integer])
    @tb = RDL::Type::NominalType.new "TestGeneric::B"
  end

  def test_le
    # Check invariance for A and H
    assert (@tas <= @tas)
    assert (@tao <= @tao)
    assert (@taas <= @taas)
    assert (@thss <= @thss)
    assert (@thoo <= @thoo)
    assert (not (@tas <= @tao))
    assert (not (@tao <= @tas))
    assert (not (@thss <= @thoo))
    assert (not (@thoo <= @thss))

    # Check "raw" class subtyping is forbidden
    assert (not (@ta <= @tas))
    assert (not (@tas <= @ta))
    assert (not (@ta <= @taas))
    assert (not (@taas <= @ta))
    assert (not (@th <= @thss))
    assert (not (@thss <= @th))

    # Check co- and contravariance using B
    tbss = RDL::Type::GenericType.new(@tb, RDL::Globals.types[:string], RDL::Globals.types[:string])
    tbso = RDL::Type::GenericType.new(@tb, RDL::Globals.types[:string], RDL::Globals.types[:object])
    tbos = RDL::Type::GenericType.new(@tb, RDL::Globals.types[:object], RDL::Globals.types[:string])
    tboo = RDL::Type::GenericType.new(@tb, RDL::Globals.types[:object], RDL::Globals.types[:object])
    assert (tbss <= tbss)
    assert (not (tbss <= tbso))
    assert (tbss <= tbos)
    assert (not (tbss <= tboo))
    assert (tbso <= tbss)
    assert (tbso <= tbso)
    assert (tbso <= tbos)
    assert (tbso <= tboo)
    assert (not (tbos <= tbss))
    assert (not (tbos <= tbso))
    assert (tbos <= tbos)
    assert (not (tbos <= tboo))
    assert (not (tboo <= tbss))
    assert (not (tboo <= tbso))
    assert (tboo <= tbos)
    assert (tboo <= tboo)
  end

  def test_le_structural
    tbss = RDL::Type::GenericType.new(@tb, RDL::Globals.types[:string], RDL::Globals.types[:string])
    tma = RDL::Type::MethodType.new([], nil, RDL::Globals.types[:nil])
    tmb = RDL::Type::MethodType.new([RDL::Globals.types[:string]], nil, RDL::Globals.types[:nil])
    tmc = RDL::Type::MethodType.new([RDL::Globals.types[:integer]], nil, RDL::Globals.types[:nil])
    ts1 = RDL::Type::StructuralType.new(m2: tma)
    assert (tbss <= ts1)
    ts2 = RDL::Type::StructuralType.new(m1: tmb)
    assert (tbss <= ts2)
    ts3 = RDL::Type::StructuralType.new(m1: tmb, m2: tma)
    assert (tbss <= ts3)
    ts4 = RDL::Type::StructuralType.new(m1: tmc, m2: tma)
    assert (not (tbss <= ts4))
    ts5 = RDL::Type::StructuralType.new(m1: tmb, m2: tmc)
    assert (tbss <= ts5)
  end

  def test_self_type
    c = C.new
    assert(c.m1)
    assert(c.m2)
    assert_raises(RDL::Type::TypeError) { c.m3 }
    assert(D.new.m1)
  end

  def test_member
    # member? should only check the base types
    assert (@ta.member?(A.new([1, 2, 3])))
    assert (@ta.member?(A.new([])))
    assert (@ta.member?(A.new(["a", "b", "c"])))
    assert (@tas.member?(A.new([1, 2, 3])))
    assert (@tas.member?(A.new([])))
    assert (@tas.member?(A.new(["a", "b", "c"])))
    assert (@taas.member?(A.new([1, 2, 3])))
    assert (@taas.member?(A.new([])))
    assert (@taas.member?(A.new(["a", "b", "c"])))
  end

  def test_instantiate
    assert_raises(RuntimeError) { RDL.instantiate!(Object.new, RDL::Globals.types[:string]) }

    # Array<String>
    assert (RDL.instantiate!(A.new([]), 'String'))
    assert (RDL.instantiate!(A.new(["a", "b", "c"]), RDL::Globals.types[:string], check: true))
    assert (RDL.instantiate!(A.new(["a", "b", "c"]), 'String', check: true))
    assert_raises(RDL::Type::TypeError) { RDL.instantiate!(A.new([1, 2, 3]), 'String', check: true) }
    assert (RDL.instantiate!(A.new([1, 2, 3]), 'String', check: false))

    # Array<Object>
    assert (RDL.instantiate!(A.new([]), 'Object', check: true))
    assert (RDL.instantiate!(A.new(["a", "b", "c"]), RDL::Globals.types[:object], check: true))
    assert (RDL.instantiate!(A.new(["a", "b", "c"]), 'Object', check: true))
    assert (RDL.instantiate!(A.new([1, 2, 3]), 'Object', check: true))

    # Hash<String, Integer>
    assert (RDL.instantiate!(H.new({}), 'String', 'Integer', check: true))
    assert (RDL.instantiate!(H.new({"one"=>1, "two"=>2}), 'String', 'Integer', check: true))
    assert_raises(RDL::Type::TypeError) {
      RDL.instantiate!(H.new(one: 1, two: 2), 'String', 'Integer', check: true)
    }
    assert (RDL.instantiate!(H.new(one: 1, two: 2), 'String', 'Integer', check: false))
    assert_raises(RDL::Type::TypeError){
      RDL.instantiate!(H.new({"one"=>:one, "two"=>:two}), 'String', 'Integer', check: true)
    }

    # Hash<Object, Object>
    assert (RDL.instantiate!(H.new({}), 'Object', 'Object', check: true))
    assert (RDL.instantiate!(H.new({"one"=>1, "two"=>2}), 'Object', 'Object', check: true))
    assert (RDL.instantiate!(H.new(one: 1, two: 2), 'Object', 'Object', check: true))
    assert (RDL.instantiate!(H.new({"one"=>:one, "two"=>:two}), 'Object', 'Object', check: true))

    # A<A<String>>
    assert (RDL.instantiate!(A.new([RDL.instantiate!(A.new(["a", "b"]), 'String', check: true),
                                    RDL.instantiate!(A.new(["c"]), 'String', check: true)]), 'TestGeneric::A<String>', check: true))
    assert_raises(RDL::Type::TypeError) {
      # Must instantiate all members
      RDL.instantiate!(A.new([RDL.instantiate!(A.new(["a", "b"]), 'String', check: true), A.new([])]), 'TestGeneric::A<String>', check: true)
    }
    assert_raises(RDL::Type::TypeError) {
      # All members must be of same type
      RDL.instantiate!(A.new([RDL.instantiate!(A.new(["a", "b"]), 'String', check: true), "A"]), 'TestGeneric::A<String>', check: true)
    }
    assert_raises(RDL::Type::TypeError) {
      # All members must be instantiated and of same type
      RDL.instantiate!(A.new([RDL.instantiate!(A.new(["a", "b"]), 'String', check: true),
                              RDL.instantiate!(H.new({a: 1, b: 2}), 'Object', 'Object', check: true)]), 'TestGeneric::A<String>', check: true)
    }
  end

end
