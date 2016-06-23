require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestGeneric < Minitest::Test

  # Make two classes that wrap Array and Hash, so we don't mess with their
  # implementations in test case evaluation.
  class A
    type_params [:t], :all?
    def initialize(a); @a = a end
    def all?(&blk)
      @a.all?(&blk)
    end
  end

  class H
    type_params [:k, :v], :all?
    def initialize(h); @h = h end
    def all?(&blk)
      @h.all? { |x, y| blk.call(x, y) } # have to do extra wrap to avoid splat issues
    end
  end

  class B
    # class for checking other variance annotations
    type_params [:a, :b], nil, variance: [:+, :-] { |a, b| true }
    type "(a) -> nil"
    def m1(x)
      nil
    end
    def m2(x) # no type annotation
      nil
    end
  end

  def setup
    @ta = RDL::Type::NominalType.new "TestGeneric::A"
    @th = RDL::Type::NominalType.new "TestGeneric::H"
    @tas = RDL::Type::GenericType.new(@ta, $__rdl_string_type)
    @tao = RDL::Type::GenericType.new(@ta, $__rdl_object_type)
    @taas = RDL::Type::GenericType.new(@ta, @tas)
    @taao = RDL::Type::GenericType.new(@ta, @tao)
    @thss = RDL::Type::GenericType.new(@th, $__rdl_string_type, $__rdl_string_type)
    @thoo = RDL::Type::GenericType.new(@th, $__rdl_object_type, $__rdl_object_type)
    @thsf = RDL::Type::GenericType.new(@th, $__rdl_string_type, $__rdl_fixnum_type)
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
    tbss = RDL::Type::GenericType.new(@tb, $__rdl_string_type, $__rdl_string_type)
    tbso = RDL::Type::GenericType.new(@tb, $__rdl_string_type, $__rdl_object_type)
    tbos = RDL::Type::GenericType.new(@tb, $__rdl_object_type, $__rdl_string_type)
    tboo = RDL::Type::GenericType.new(@tb, $__rdl_object_type, $__rdl_object_type)
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
    tbss = RDL::Type::GenericType.new(@tb, $__rdl_string_type, $__rdl_string_type)
    tma = RDL::Type::MethodType.new([], nil, $__rdl_nil_type)
    tmb = RDL::Type::MethodType.new([$__rdl_string_type], nil, $__rdl_nil_type)
    tmc = RDL::Type::MethodType.new([$__rdl_fixnum_type], nil, $__rdl_nil_type)
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

  class C
    type "() -> self"
    def m1() return self; end
    type "() -> self"
    def m2() return C.new; end
    type "() -> self"
    def m3() return Object.new; end
  end

  class D < C
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
    assert_raises(RuntimeError) { Object.new.instantiate!($__rdl_string_type) }

    # Array<String>
    assert (A.new([]).instantiate!('String'))
    assert (A.new(["a", "b", "c"]).instantiate!($__rdl_string_type))
    assert (A.new(["a", "b", "c"]).instantiate!('String'))
    assert_raises(RDL::Type::TypeError) { A.new([1, 2, 3]).instantiate!('String') }

    # Array<Object>
    assert (A.new([])).instantiate!('Object')
    assert (A.new(["a", "b", "c"]).instantiate!($__rdl_object_type))
    assert (A.new(["a", "b", "c"]).instantiate!('Object'))
    assert (A.new([1, 2, 3]).instantiate!('Object'))

    # Hash<String, Fixnum>
    assert (H.new({}).instantiate!('String', 'Fixnum'))
    assert (H.new({"one"=>1, "two"=>2}).instantiate!('String', 'Fixnum'))
    assert_raises(RDL::Type::TypeError) {
      H.new(one: 1, two: 2).instantiate!('String', 'Fixnum')
    }
    assert_raises(RDL::Type::TypeError){
      H.new({"one"=>:one, "two"=>:two}).instantiate!('String', 'Fixnum')
    }

    # Hash<Object, Object>
    assert (H.new({}).instantiate!('Object', 'Object'))
    assert (H.new({"one"=>1, "two"=>2}).instantiate!('Object', 'Object'))
    assert (H.new(one: 1, two: 2).instantiate!('Object', 'Object'))
    assert (H.new({"one"=>:one, "two"=>:two}).instantiate!('Object', 'Object'))

    # A<A<String>>
    assert (A.new([A.new(["a", "b"]).instantiate!('String'),
                   A.new(["c"]).instantiate!('String')]).instantiate!('TestGeneric::A<String>'))
    assert_raises(RDL::Type::TypeError) {
      # Must instantiate all members
      A.new([A.new(["a", "b"]).instantiate!('String'), A.new([])]).instantiate!('TestGeneric::A<String>')
    }
    assert_raises(RDL::Type::TypeError) {
      # All members must be of same type
      A.new([A.new(["a", "b"]).instantiate!('String'), "A"]).instantiate!('TestGeneric::A<String>')
    }
    assert_raises(RDL::Type::TypeError) {
      # All members must be instantiated and of same type
      A.new([A.new(["a", "b"]).instantiate!('String'),
             H.new({a: 1, b: 2}).instantiate!('Object', 'Object')]).instantiate!('TestGeneric::A<String>')
    }
  end

end
