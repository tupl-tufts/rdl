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

  def test_lits
    self.class.class_eval {
      type "() -> nil", typecheck_now: true
      def lit1() nil; end
    }

    self.class.class_eval {
      type "() -> TrueClass", typecheck_now: true
      def lit2() true; end
    }

    self.class.class_eval {
      type "() -> FalseClass", typecheck_now: true
      def lit3() false; end
    }

    self.class.class_eval {
      type "() -> Fixnum", typecheck_now: true
      def lit4() 42; end
    }

    self.class.class_eval {
      type "() -> Bignum", typecheck_now: true
      def lit5() 123456789123456789123456789; end
    }

    self.class.class_eval {
      type "() -> Float", typecheck_now: true
      def lit6() 3.14; end
    }

    self.class.class_eval {
      type "() -> Complex", typecheck_now: true
      def lit7() 1i; end
    }

    self.class.class_eval {
      type "() -> Rational", typecheck_now: true
      def lit8() 2.0r; end
    }

    self.class.class_eval {
      type "() -> String", typecheck_now: true
      def lit9() "foo"; end
    }

    self.class.class_eval {
      type "() -> String", typecheck_now: true
      def lit10() 'foo'; end
    }
  end

  def test_dstr_xstr
    self.class.class_eval {
      type "() -> String", typecheck_now: true
      def dstr() "Foo #{42} Bar #{43}"; end

      type "() -> String", typecheck_now: true
      def xstr() `ls #{42}`; end
    }
  end

  def test_singleton
    self.class.class_eval {
      type "() -> 42", typecheck_now: true
      def sing1() 42; end
    }

    self.class.class_eval {
      type "() -> 3.14", typecheck_now: true
      def sing2() 3.14; end
    }

    self.class.class_eval {
      type "() -> :foo", typecheck_now: true
      def sing3() :foo; end
    }
  end

  def test_seq
    self.class.class_eval {
      type "() -> String", typecheck_now: true
      def seq() 42; 43; "foo" end
    }
  end

  def test_dsym
    self.class.class_eval {
      type "() -> Symbol", typecheck_now: true
      def dsym() :"foo#{42}"; end
    }
  end

  def test_tuple
    self.class.class_eval {
      type "() -> [TrueClass, String]", typecheck_now: true
      def tuple_ts() [true, "42"]; end
    }

    skip "not supported yet"
    self.class.class_eval {
      type "() -> Array<String>", typecheck_now: true
      def tuple_ss() ["foo", "bar"]; end
    }

    self.class.class_eval {
      type "() -> [Fixnum, String]", typecheck_now: true
      def tuple_fs() [42, "42"]; end
    }
  end

  def test_range
    self.class.class_eval {
      type "() -> Range<Fixnum>", typecheck_now: true
      def range1() 1..5; end
    }

    self.class.class_eval {
      type "() -> Range<Fixnum>", typecheck_now: true
      def range2() 1...5; end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Range<Fixnum>", typecheck_now: true
        def range3() 1.."foo"; end
      }
    }
  end

  def test_self
    self.class.class_eval {
      type "() -> self", typecheck_now: true
      def self1() self; end
    }

    skip "not supported yet"
    self.class.class_eval {
      type "() -> self", typecheck_now: true
      def self2() TestTypecheck.new; end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> self", typecheck_now: true
        def self3() Object.new; end
      }
    }
  end

  def test_nth_back
    self.class.class_eval {
      type "() -> String", typecheck_now: true
      def nth_ref() $4; end
    }

    self.class.class_eval {
      type "() -> String", typecheck_now: true
      def back_ref() $+; end
    }
  end

  def test_const
    self.class.class_eval {
      type "() -> ${String}", typecheck_now: true
      def const_class() String; end
    }
  end

end
