require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestGeneric < Minitest::Test

  # Make two classes that wrap Array and Hash, so we don't mess with their
  # implementations in test case evaluation.
  class A
    type_params [:t], [:~]
    def __rdl_member?(inst)
      t = inst[:t]
      return @a.all? { |x| t.member? x }
    end
    def initialize(a); @a = a end
  end
  class H
    type_params [:k, :v], [:~, :~]
    def __rdl_member?(inst)
      tk = inst[:k]
      tv = inst[:v]
      return @h.all? { |k, v| (tk.member? k) && (tv.member? v) }
    end
    def initialize(h); @h = h end
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
  end

  def test_le
    assert (@tas <= @tas)
    assert (@tao <= @tao)
    assert (@taas <= @taas)
    assert (@thss <= @thss)
    assert (@thoo <= @thoo)
    assert (not (@tas <= @tao))
    assert (not (@tao <= @tas))
    assert (not (@thss <= @thoo))
    assert (not (@thoo <= @thss))
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
    assert (@ta.member?(A.new([1, 2, 3])))
    assert (@ta.member?(A.new([])))
    assert (@tas.member?(A.new(["a", "b", "c"])))
    assert (@tas.member?(A.new([])))
    assert (not (@tas.member?(A.new([1, 2, 3]))))
    assert (@tao.member?(A.new([1, 2, 3])))
    assert (@tao.member?(A.new(["a", "b", "c"])))
    assert (@taas.member?(A.new([A.new(["a", "b"]), A.new(["c"])])))
    assert (@taas.member?(A.new([])))
    assert (@taas.member?(A.new([A.new([])])))
    assert (@taas.member?(A.new([A.new([]), A.new([])])))
    assert (not (@taas.member?(A.new(["a", "b", "c"]))))
    assert (not (@taas.member?(A.new([A.new(["a", "b"]), A.new([1])]))))
    assert (@th.member?(H.new(Hash.new)))
    assert (@th.member?(H.new(a:1, b:2)))
    assert (@thsf.member?(H.new({"one"=>1, "two"=>2})))
    assert (not (@thsf.member?(H.new(one: 1, two: 2))))
    assert (not (@thsf.member?(H.new({"one"=>:one, "two"=>:two}))))
    assert (@thoo.member?(H.new({"one"=>1, "two"=>2})))
    assert (@thoo.member?(H.new(one: 1, two: 2)))
    assert (@thoo.member?(H.new({"one"=>:one, "two"=>:two})))
  end


end
