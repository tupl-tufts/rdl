require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestRDLType < Minitest::Test
  def test_single_type_contract
    def m1(x) return x; end
    type TestRDLType, :m1, "(Fixnum) -> Fixnum"
    assert_equal 5, m1(5)
    assert_raises(RDL::Type::TypeError) { m1("foo") }

    self.class.class_eval {
      type :m2, "(Fixnum) -> Fixnum"
      def m2(x) return x; end
    }
    assert_equal 5, m2(5)
    assert_raises(RDL::Type::TypeError) { m2("foo") }

    self.class.class_eval {
      type "(Fixnum) -> Fixnum"
      def m3(x) return x; end
    }
    assert_equal 5, m3(5)
    assert_raises(RDL::Type::TypeError) { m3("foo") }
  end

  def test_intersection_type_contract
    self.class.class_eval {
      type "(Fixnum) -> Fixnum"
      type "(String) -> String"
      def m4(x) return x; end
    }
    assert_equal 5, m4(5)
    assert_equal "foo", m4("foo")
    assert_raises(RDL::Type::TypeError) { m4(:foo) }

    self.class.class_eval {
      type "(Fixnum) -> Fixnum"
      type "(String) -> String"
      def m5(x) return 42; end
    }
    assert_equal 42, m5(3)
    assert_raises(RDL::Type::TypeError) { m5("foo") }

    self.class.class_eval {
      type "(Fixnum) -> Fixnum"
      type "(Fixnum) -> String"
      def m6(x) if x > 10 then :oops elsif x > 5 then x else "small" end end
    }
    assert_equal 8, m6(8)
    assert_equal "small", m6(1)
    assert_raises(RDL::Type::TypeError) { m6(42) }
  end

  def test_self_type
    self.class.class_eval <<RUBY
      class A
        type "() -> self"
        def m7() return self; end
        type "() -> self"
        def m8() return A.new; end
      end
RUBY
    a = A.new
    assert(a.m7)
    assert_raises(RDL::Type::TypeError) { a.m8 }
  end
end