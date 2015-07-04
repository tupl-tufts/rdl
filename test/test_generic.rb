require 'minitest/autorun'
require_relative '../lib/rdl.rb'

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
      @h.all?(&blk)
    end
  end

  class B
    # class for checking other variance annotations
    type_params [:a, :b], nil, variance: [:+, :-] { |a, b| true }
  end
  
  def setup
    @ta = RDL::Type::NominalType.new "TestGeneric::A"
    @th = RDL::Type::NominalType.new "TestGeneric::H"
    @tstring = RDL::Type::NominalType.new "String"
    @tobject = RDL::Type::NominalType.new "Object"
    @tfixnum = RDL::Type::NominalType.new "Fixnum"
    @tas = RDL::Type::GenericType.new(@ta, @tstring)
    @tao = RDL::Type::GenericType.new(@ta, @tobject)
    @taas = RDL::Type::GenericType.new(@ta, @tas)
    @taao = RDL::Type::GenericType.new(@ta, @tao)
    @thss = RDL::Type::GenericType.new(@th, @tstring, @tstring)
    @thoo = RDL::Type::GenericType.new(@th, @tobject, @tobject)
    @thsf = RDL::Type::GenericType.new(@th, @tstring, @tfixnum)
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
    tbss = RDL::Type::GenericType.new(@tb, @tstring, @tstring)
    tbso = RDL::Type::GenericType.new(@tb, @tstring, @tobject)
    tbos = RDL::Type::GenericType.new(@tb, @tobject, @tstring)
    tboo = RDL::Type::GenericType.new(@tb, @tobject, @tobject)
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

  class C
    type "() -> self"
    def m1() return self; end
    type "() -> self"
    def m2() return C.new; end
  end
  
  def test_self_type
    c = C.new
    assert(c.m1)
    assert_raises(RDL::Type::TypeError) { c.m2 }
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
    assert_raises(RuntimeError) { Object.new.instantiate!(@tstring) }
    
    # Array<String>
    assert (A.new([]).instantiate!(@tstring))
    assert (A.new(["a", "b", "c"]).instantiate!(@tstring))
    assert_raises(RDL::Type::TypeError) { A.new([1, 2, 3]).instantiate!(@tstring) }

    # Array<Object>
    assert (A.new([])).instantiate!(@tobject)
    assert (A.new(["a", "b", "c"]).instantiate!(@tobject))
    assert (A.new([1, 2, 3]).instantiate!(@tobject))

    # Hash<String, Fixnum>
    assert (H.new({}).instantiate!(@tstring, @tfixnum))
    assert (H.new({"one"=>1, "two"=>2}).instantiate!(@tstring, @tfixnum))
    assert_raises(RDL::Type::TypeError) {
      H.new(one: 1, two: 2).instantiate!(@tstring, @tfixnum)
    }
    assert_raises(RDL::Type::TypeError){
      H.new({"one"=>:one, "two"=>:two}).instantiate!(@tstring, @tfixnum)
    }

    # Hash<Object, Object>
    assert (H.new({}).instantiate!(@tobject, @tobject))
    assert (H.new({"one"=>1, "two"=>2}).instantiate!(@tobject, @tobject))
    assert (H.new(one: 1, two: 2).instantiate!(@tobject, @tobject))
    assert (H.new({"one"=>:one, "two"=>:two}).instantiate!(@tobject, @tobject))

    # Array<Array<String>>
    assert (A.new([A.new(["a", "b"]).instantiate!(@tstring),
                   A.new(["c"]).instantiate!(@tstring)]).instantiate!(@tas))
    assert_raises(RDL::Type::TypeError) {
      # Must instantiate all members
      A.new([A.new(["a", "b"]).instantiate!(@tstring), A.new([])]).instantiate!(@tas)
    }
    assert_raises(RDL::Type::TypeError) {
      # All members must be of same type
      A.new([A.new(["a", "b"].instantiate!(@tstring)), "A"]).instantiate!(@tas)
    }
    assert_raises(RDL::Type::TypeError) {
      # All members must be instantiated of same type
      A.new([A.new(["a", "b"].instantiate!(@tstring)),
             H.new({a: 1, b: 2}).instantiate!(@tobject, @tobject)]).instantiate!(@tas)
    }
  end

end
