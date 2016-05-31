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
    @aself = {self: $__rdl_parser.scan_str("#T TestTypecheck")}
  end

  # [+ a +] is the environment, a map from symbols to types; empty if omitted
  # [+ expr +] is a string containing the expression to typecheck
  # returns the type of the expression
  def do_tc(a = {}, expr)
    ast = Parser::CurrentRuby.parse expr
    _, t = RDL::Typecheck.tc Hash.new, a, ast
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

    assert_raises(RDL::Typecheck::StaticTypeError) {
      # really a send
      self.class.class_eval {
        type "(Fixnum, String) -> String", typecheck_now: true
        def lvar3(x, y) z; end
      }
    }
  end

  def test_lvasgn
    assert do_tc("x = 42; x") <= @tfixnum
    assert do_tc("x = 42; y = x; y") <= @tfixnum
    assert do_tc("x = y = 42; x") <= @tfixnum
  end

  def test_send_basic
    self.class.class_eval {
      type :_send_basic2, "() -> Fixnum"
      type :_send_basic3, "(Fixnum) -> Fixnum"
      type :_send_basic4, "(Fixnum, String) -> Fixnum"
    }

    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@aself, "z") }
    assert do_tc(@aself, "_send_basic2") <= @tfixnum
    assert do_tc(@aself, "_send_basic3(42)") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_basic3('42')") }
    assert do_tc(@aself, "_send_basic4(42, '42')") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_basic4(42, 43)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_basic4('42', '43')") }
  end

  def test_send_inter
    self.class.class_eval {
      type :_send_inter1, "(Fixnum) -> Fixnum"
      type :_send_inter1, "(String) -> String"
    }
    assert do_tc(@aself, "_send_inter1(42)") <= @tfixnum
    assert do_tc(@aself, "_send_inter1('42')") <= @tstring

    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@aself, "_send_inter1(:forty_two)") }
  end

  def test_send_opt_varargs
    # from test_type_contract.rb
    self.class.class_eval {
      type :_send_opt_varargs1, "(Fixnum, ?Fixnum) -> Fixnum"
      type :_send_opt_varargs2, "(Fixnum, *Fixnum) -> Fixnum"
      type :_send_opt_varargs3, "(Fixnum, ?Fixnum, ?Fixnum, *Fixnum) -> Fixnum"
      type :_send_opt_varargs4, "(?Fixnum) -> Fixnum"
      type :_send_opt_varargs5, "(*Fixnum) -> Fixnum"
      type :_send_opt_varargs6, "(?Fixnum, String) -> Fixnum"
    }
    assert do_tc(@aself, "_send_opt_varargs1(42)") <= @tfixnum
    assert do_tc(@aself, "_send_opt_varargs1(42, 43)") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs1()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs1(42, 43, 44)") }
    assert do_tc(@aself, "_send_opt_varargs2(42)") <= @tfixnum
    assert do_tc(@aself, "_send_opt_varargs2(42, 43)") <= @tfixnum
    assert do_tc(@aself, "_send_opt_varargs2(42, 43, 44)") <= @tfixnum
    assert do_tc(@aself, "_send_opt_varargs2(42, 43, 44, 45)") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs2()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs2('42')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs2(42, '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs2(42, 43, '44')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs2(42, 43, 44, '45')") }
    assert do_tc(@aself, "_send_opt_varargs3(42)") <= @tfixnum
    assert do_tc(@aself, "_send_opt_varargs3(42, 43)") <= @tfixnum
    assert do_tc(@aself, "_send_opt_varargs3(42, 43, 44)") <= @tfixnum
    assert do_tc(@aself, "_send_opt_varargs3(42, 43, 45)") <= @tfixnum
    assert do_tc(@aself, "_send_opt_varargs3(42, 43, 46)") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs3()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs3('42')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs3(42, '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs3(42, 43, '44')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs3(42, 43, 44, '45')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs3(42, 43, 44, 45, '46')") }
    assert do_tc(@aself, "_send_opt_varargs4()") <= @tfixnum
    assert do_tc(@aself, "_send_opt_varargs4(42)") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs4('42')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs4(42, 43)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs4(42, 43, 44)") }
    assert do_tc(@aself, "_send_opt_varargs5()") <= @tfixnum
    assert do_tc(@aself, "_send_opt_varargs5(42)") <= @tfixnum
    assert do_tc(@aself, "_send_opt_varargs5(42, 43)") <= @tfixnum
    assert do_tc(@aself, "_send_opt_varargs5(42, 43, 44)") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs5('42')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs5(42, '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs5(42, 43, '44')") }
    assert do_tc(@aself, "_send_opt_varargs6('44')") <= @tfixnum
    assert do_tc(@aself, "_send_opt_varargs6(43, '44')") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs6()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_opt_varargs6(43, '44', 45)") }
  end

  def test_send_named_args
    # from test_type_contract.rb
    skip "Not ready yet"
    self.class.class_eval {
      type :_send_named_args1, "(x: Fixnum) -> Fixnum"
      type :_send_named_args2, "(x: Fixnum, y: String) -> Fixnum"
      type :_send_named_args3, "(Fixnum, y: String) -> Fixnum"
      type :_send_named_args4, "(Fixnum, x: Fixnum, y: String) -> Fixnum"
      type :_send_named_args5, "(x: Fixnum, y: ?String) -> Fixnum"
      type :_send_named_args6, "(x: ?Fixnum, y: String) -> Fixnum"
      type :_send_named_args7, "(x: ?Fixnum, y: ?String) -> Fixnum"
      type :_send_named_args7, "(?Fixnum x: ?Symbol, y: ?String) -> Fixnum"
    }
    assert do_tc(@aself, "_send_named_args1(x: 42)") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args1(x: '42')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args1()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args1(x: 42, y: 42)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args1(y: 42)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args1(42)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args1(42, x: '42')") }
    assert do_tc(@aself, "_send_named_args2(x: 42, y: '43')") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args2()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args2(x: 42)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args2(x: '42', y: '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args2(42, '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args2(42, x: 42, y: '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args2(x: 42, y: '43', z: 44)") }
    assert do_tc(@aself, "_send_named_args3(42, y: '43')") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args3(42, y: 43)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args3()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args3(42, 43, y: 44)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args3(42, y: 43, z: 44)") }
    assert do_tc(@aself, "_send_named_args4(42, x: 43, y: '44')") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args4(42, x: 43)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args4(42, y: '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args4()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args4(42, 43, x: 44, y: '45')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args4(42, x: 43, y: '44', z: 45)") }
    assert do_tc(@aself, "_send_named_args5(x: 42, y: '43')") <= @tfixnum
    assert do_tc(@aself, "_send_named_args5(x: 42)") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args5()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args5(x: 42, y: 43)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args5(x: 42, y: 43, z: 44)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args5(3, x: 42, y: 43)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args5(3, x: 42)") }
    assert do_tc(@aself, "_send_named_args6(x: 43, y: '44')") <= @tfixnum
    assert do_tc(@aself, "_send_named_args6(y: '44')") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args6()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args6(x: '43', y: '44')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args6(42, x: 43, y: '44')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args6(x: 43, y: '44', z: 45)") }
    assert do_tc(@aself, "_send_named_args7()") <= @tfixnum
    assert do_tc(@aself, "_send_named_args7(x: 43)") <= @tfixnum
    assert do_tc(@aself, "_send_named_args7(y: '44')") <= @tfixnum
    assert do_tc(@aself, "_send_named_args7(x: 43, y: '44')") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args7(x: '43', y: '44')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args7(41, x: 43, y: '44')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args7(x: 43, y: '44', z: 45)") }
    assert do_tc(@aself, "_send_named_args8()") <= @tfixnum
    assert do_tc(@aself, "_send_named_args8(43)") <= @tfixnum
    assert do_tc(@aself, "_send_named_args8(x: :foo)") <= @tfixnum
    assert do_tc(@aself, "_send_named_args8(43, x: :foo)") <= @tfixnum
    assert do_tc(@aself, "_send_named_args8(y: 'foo')") <= @tfixnum
    assert do_tc(@aself, "_send_named_args8(43, y: 'foo')") <= @tfixnum
    assert do_tc(@aself, "_send_named_args8(x: :foo, y: 'foo')") <= @tfixnum
    assert do_tc(@aself, "_send_named_args8(43, x: :foo, y: 'foo')") <= @tfixnum
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args8(43, 44, x: :foo, y: 'foo')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args8(43, x: 'foo', y: 'foo')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@aself, "_send_named_args8(43, x: :foo, y: 'foo', z: 44)") }
  end

end
