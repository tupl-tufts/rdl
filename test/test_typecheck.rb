require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestTypecheck < Minitest::Test

  def setup
    @tnil = $__rdl_parser.scan_str "#T nil"
    @ttrue = $__rdl_parser.scan_str "#T TrueClass"
    @tfalse = $__rdl_parser.scan_str "#T FalseClass"
    @tfixnum = $__rdl_parser.scan_str "#T Fixnum"
    @tbignum = $__rdl_parser.scan_str "#T Bignum"
    @tfloat = $__rdl_parser.scan_str "#T Float"
    @tcomplex = $__rdl_parser.scan_str "#T Complex"
    @trational = $__rdl_parser.scan_str "#T Rational"
    @tstring = $__rdl_parser.scan_str "#T String"
    @tsymbol = $__rdl_parser.scan_str "#T Symbol"
    @tregexp = $__rdl_parser.scan_str "#T Regexp"
  end

  # [+ expr +] is a string containing the expression to typecheck
  # returns the type of the expression
  def do_tc(expr)
    ast = Parser::CurrentRuby.parse expr
    _, t = RDL::Typecheck.tc Hash.new, Hash.new, ast
    return t
  end

  def test_basics
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
    assert do_tc("nil") <= @tnil
    assert do_tc("true") <= @ttrue
    assert do_tc("false") <= @tfalse
    assert do_tc("42") <= $__rdl_parser.scan_str("#T 42")
    assert do_tc("123456789123456789123456789") <= @tbignum
    assert do_tc("3.14") <= $__rdl_parser.scan_str("#T 3.14")
    assert do_tc("1i") <= @tcomplex
    assert do_tc("2.0r") <= @trational
    assert do_tc("'42'") <= @tstring
    assert do_tc("\"42\"") <= @tstring
    assert do_tc(":foo") <= $__rdl_parser.scan_str("#T :foo")
  end

  def test_dstr_xstr
    # Hard to read if these are inside of strings, so leave like this
    self.class.class_eval {
      type "() -> String", typecheck_now: true
      def dstr() "Foo #{42} Bar #{43}"; end

      type "() -> String", typecheck_now: true
      def xstr() `ls #{42}`; end
    }
  end

  def test_seq
    assert do_tc("_ = 42; _ = 43; 'foo'") <= @tstring
  end

  def test_dsym
    # Hard to read if these are inside of strings, so leave like this
    self.class.class_eval {
      type "() -> Symbol", typecheck_now: true
      def dsym() :"foo#{42}"; end
    }
  end

  def test_regexp
    assert do_tc("/foo/") <= @tregexp

    self.class.class_eval {
      # Hard to read if these are inside of strings, so leave like this
      type "() -> Regexp", typecheck_now: true
      def regexp2() /foo#{42}bar#{"baz"}/i; end
    }
  end

  def test_tuple
    assert do_tc("[true, '42']") <= $__rdl_parser.scan_str("#T [TrueClass, String]")

    skip "not supported yet"
    assert do_tc("['foo', 'bar']") <= $__rdl_parser.scan_str("#T Array<String>")
    assert do_tc("[42, '42']") <= $__rdl_parser.scan_str("#T [Fixnum, String]")
  end

  def test_range
    assert do_tc("1..5") <= $__rdl_parser.scan_str("#T Range<Fixnum>")
    assert do_tc("1...5") <= $__rdl_parser.scan_str("#T Range<Fixnum>")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("1..'foo'") }
  end

  def test_self
    # These need to be inside an actual class
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
    assert do_tc("$4") <= @tstring
    assert do_tc("$+") <= @tstring
  end

  def test_const
    assert do_tc("String") <= $__rdl_parser.scan_str("#T ${String}")
    assert do_tc("NIL") <= @tnil
  end

  def test_defined
    assert do_tc("defined?(x)") <= @tstring
  end

  def test_lvar
    self.class.class_eval {
      type "(Fixnum, String) -> Fixnum", typecheck_now: true
      def lvar1(x, y) x; end
    }

    self.class.class_eval {
      type "(Fixnum, String) -> String", typecheck_now: true
      def lvar2(x, y) y; end
    }
  end

  def test_lvasgn
    assert do_tc("x = 42; x") <= @tfixnum
    assert do_tc("x = 42; y = x; y") <= @tfixnum
    assert do_tc("x = y = 42; x") <= @tfixnum
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

  def test_send_named_args
    skip "Not ready yet"
    self.class.class_eval {
      type :_send_named_args1, "(x: Fixnum) -> Fixnum"
      type "() -> Fixnum", typecheck_now: true
      def send_named_args1a() _send_named_args1(x: 42); end
    }

    self.class.class_eval {
      type "() -> Fixnum", typecheck_now: true
      def send_named_args1b() _send_named_args1(x: "42"); end
    }

    self.class.class_eval {
      type "() -> Fixnum", typecheck_now: true
      def send_named_args1c() _send_named_args1; end
    }

    self.class.class_eval {
      type "() -> Fixnum", typecheck_now: true
      def send_named_args1d() _send_named_args1(x: 42, y: 42); end
    }

    self.class.class_eval {
      type "() -> Fixnum", typecheck_now: true
      def send_named_args1e() _send_named_args1(y: 42); end
    }

    self.class.class_eval {
      type "() -> Fixnum", typecheck_now: true
      def send_named_args1f() _send_named_args1(42); end
    }

    self.class.class_eval {
      type "() -> Fixnum", typecheck_now: true
      def send_named_args1g() _send_named_args1(42, x: "42"); end
    }
  end

end
