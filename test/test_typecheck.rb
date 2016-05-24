require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestTypecheck < Minitest::Test

  def test_fixnum_id
    self.class.class_eval {
      type "(Fixnum) -> Fixnum", typecheck_now: true
      def id_ff(x) x; end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Fixnum) -> Fixnum", typecheck_now: true
        def id_fs(x) "42"; end
      }
    }

    self.class.class_eval {
      type "(Fixnum) -> Fixnum", typecheck_now: true
      def id_ff2(x) x; end
    }
    assert_equal 42, id_ff2(42)

    self.class.class_eval {
      type "(Fixnum) -> Fixnum", typecheck: true
      def id_fs2(x) "42"; end
    }
    assert_raises(RDL::Typecheck::StaticTypeError) { id_fs2(42) }

    skip "not implemented yet"
    self.class.class_eval {
      type "(Fixnum, Fixnum) -> Fixnum", typecheck_now: true
      def add(x, y) x+y; end
    }
    assert_equal 42, id_ff(42)
  end

  def test_consts
    self.class.class_eval {
      type "() -> nil", typecheck_now: true
      def c1() nil; end
    }

    self.class.class_eval {
      type "() -> TrueClass", typecheck_now: true
      def c2() true; end
    }

    self.class.class_eval {
      type "() -> FalseClass", typecheck_now: true
      def c3() false; end
    }

    self.class.class_eval {
      type "() -> Fixnum", typecheck_now: true
      def c4() 42; end
    }

    self.class.class_eval {
      type "() -> Bignum", typecheck_now: true
      def c5() 123456789123456789123456789; end
    }

    self.class.class_eval {
      type "() -> Float", typecheck_now: true
      def c6() 3.14; end
    }

    self.class.class_eval {
      type "() -> Complex", typecheck_now: true
      def c7() 1i; end
    }

    self.class.class_eval {
      type "() -> Rational", typecheck_now: true
      def c8() 2.0r; end
    }

    self.class.class_eval {
      type "() -> String", typecheck_now: true
      def c9() "foo"; end
    }

    self.class.class_eval {
      type "() -> String", typecheck_now: true
      def c10() 'foo'; end
    }
  end

  def test_dstr
    self.class.class_eval {
      type "() -> String", typecheck_now: true
      def dstr() "Foo #{42} Bar #{43}"; end
    }
  end

  def test_singleton
    self.class.class_eval {
      type "() -> 42", typecheck_now: true
      def s1() 42; end
    }

    self.class.class_eval {
      type "() -> 3.14", typecheck_now: true
      def s2() 3.14; end
    }

    self.class.class_eval {
      type "() -> :foo", typecheck_now: true
      def s3() :foo; end
    }
  end

  def test_seq
    self.class.class_eval {
      type "() -> String", typecheck_now: true
      def seq() 42; 43; "foo" end
    }
  end
end
