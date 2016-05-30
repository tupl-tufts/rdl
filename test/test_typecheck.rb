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
      def seq() _ = 42; _ = 43; "foo" end
    }
  end

  def test_dsym
    self.class.class_eval {
      type "() -> Symbol", typecheck_now: true
      def dsym() :"foo#{42}"; end
    }
  end

  def test_regexp
    self.class.class_eval {
      type "() -> Regexp", typecheck_now: true
      def regexp1() /foo/; end
    }

    self.class.class_eval {
      type "() -> Regexp", typecheck_now: true
      def regexp2() /foo#{42}bar#{"baz"}/i; end
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

    self.class.class_eval {
      type "() -> nil", typecheck_now: true
      def const_nil() NIL; end
    }
  end

  def test_defined
    self.class.class_eval {
      type "() -> String", typecheck_now: true
      def defined() defined?(x); end
    }
  end

  def test_lvar_lvasgn
    self.class.class_eval {
      type "(Fixnum, String) -> Fixnum", typecheck_now: true
      def lvar1(x, y) x; end
    }

    self.class.class_eval {
      type "(Fixnum, String) -> String", typecheck_now: true
      def lvar2(x, y) y; end
    }

    self.class.class_eval {
      type "() -> Fixnum", typecheck_now: true
      def lvar3() x = 42; x; end
    }

    self.class.class_eval {
      type "() -> Fixnum", typecheck_now: true
      def lvar4() x = 42; y = x; y; end
    }

    self.class.class_eval {
      type "() -> Fixnum", typecheck_now: true
      def lvar5() x = y = 42; _ = y; x; end
    }
  end

  def test_send_basic
    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Fixnum, String) -> String", typecheck_now: true
        def send_basic1(x, y) z; end
      }
    }

    self.class.class_eval {
      type :_send_basic2, "() -> Fixnum"
      type "() -> Fixnum", typecheck_now: true
      def send_basic2() _send_basic2; end
    }

    self.class.class_eval {
      type :_send_basic3, "(Fixnum) -> Fixnum"
      type "() -> Fixnum", typecheck_now: true
      def send_basic3a() _send_basic3(42); end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_basic3b() _send_basic3("42"); end
      }
    }

    self.class.class_eval {
      type :_send_basic4, "(Fixnum, String) -> Fixnum"
      type "() -> Fixnum", typecheck_now: true
      def send_basic4a() _send_basic4(42, "42"); end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_basic4b() _send_basic4(42, 43); end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_basic4c() _send_basic4("42", "43"); end
      }
    }
  end

  def test_send_inter
    self.class.class_eval {
      type :_send_inter1, "(Fixnum) -> Fixnum"
      type :_send_inter1, "(String) -> String"
      type "() -> Fixnum", typecheck_now: true
      def send_inter1a() _send_inter1(42); end
      type "() -> String", typecheck_now: true
      def send_inter1b() _send_inter1("42"); end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_inter1c() _send_inter3(:forty_two); end
      }
    }
  end

  def test_send_opt_varargs
    self.class.class_eval {
      type :_send_opt_varargs1, "(Fixnum, ?Fixnum) -> Fixnum"
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs1a() _send_opt_varargs1(42); end
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs1b() _send_opt_varargs1(42, 43); end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs1c() _send_opt_varargs1; end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs1d() _send_opt_varargs1(42, 43, 44); end
      }
    }

    self.class.class_eval {
      type :_send_opt_varargs2, "(Fixnum, *Fixnum) -> Fixnum"
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs2a() _send_opt_varargs2(42); end
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs2b() _send_opt_varargs2(42, 43); end
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs2c() _send_opt_varargs2(42, 43, 44); end
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs2d() _send_opt_varargs2(42, 43, 44, 45); end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs2e() _send_opt_varargs2; end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs2f() _send_opt_varargs2("42"); end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs2g() _send_opt_varargs2(42, "43"); end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs2h() _send_opt_varargs2(42, 43, "44"); end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs2i() _send_opt_varargs2(42, 43, 44, "45"); end
      }
    }

    self.class.class_eval {
      type :_send_opt_varargs3, "(Fixnum, ?Fixnum, ?Fixnum, *Fixnum) -> Fixnum"
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs3a() _send_opt_varargs3(42); end
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs3b() _send_opt_varargs3(42, 43); end
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs3c() _send_opt_varargs3(42, 43, 44); end
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs3d() _send_opt_varargs3(42, 43, 44, 45); end
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs3e() _send_opt_varargs3(42, 43, 44, 45, 46); end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs3f() _send_opt_varargs3(); end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs3g() _send_opt_varargs3("42"); end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs3h() _send_opt_varargs3(42, "43"); end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs3i() _send_opt_varargs3(42, 43, "44"); end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs3j() _send_opt_varargs3(42, 43, 44, "45"); end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs3k() _send_opt_varargs3(42, 43, 44, 45, "46"); end
      }
    }

    self.class.class_eval {
      type :_send_opt_varargs4, "(?Fixnum) -> Fixnum"
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs4a() _send_opt_varargs4(); end
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs4b() _send_opt_varargs4(42); end
    }

   assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs4c() _send_opt_varargs4("42"); end
      }
   }

   assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs4d() _send_opt_varargs4(42, 43); end
      }
   }

   assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs4e() _send_opt_varargs4(42, 43, 44); end
      }
   }

   self.class.class_eval {
     type :_send_opt_varargs5, "(*Fixnum) -> Fixnum"
     type "() -> Fixnum", typecheck_now: true
     def send_opt_varargs5a() _send_opt_varargs5(); end
     type "() -> Fixnum", typecheck_now: true
     def send_opt_varargs5b() _send_opt_varargs5(42); end
     type "() -> Fixnum", typecheck_now: true
     def send_opt_varargs5c() _send_opt_varargs5(42, 43); end
     type "() -> Fixnum", typecheck_now: true
     def send_opt_varargs5d() _send_opt_varargs5(42, 43, 44); end
   }

   assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs5e() _send_opt_varargs5("42"); end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs5f() _send_opt_varargs5(42, "43"); end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs5g() _send_opt_varargs5(42, 43, "44"); end
      }
    }

    self.class.class_eval {
      type :_send_opt_varargs6, "(?Fixnum, String) -> Fixnum"
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs6a() _send_opt_varargs6("44"); end
      type "() -> Fixnum", typecheck_now: true
      def send_opt_varargs6b() _send_opt_varargs6(43, "44"); end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs6c() _send_opt_varargs6(); end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Fixnum", typecheck_now: true
        def send_opt_varargs6d() _send_opt_varargs6(43, "44", 45); end
      }
    }

  end

end
