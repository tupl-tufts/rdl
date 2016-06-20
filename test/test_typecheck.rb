require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestTypecheck < Minitest::Test

  type :_any_object, "() -> Object" # a method that could return true or false

  def setup
    @t3 = RDL::Type::SingletonType.new 3
    @t4 = RDL::Type::SingletonType.new 4
    @t5 = RDL::Type::SingletonType.new 5
    @t34 = RDL::Type::UnionType.new(@t3, @t4)
    @t345 = RDL::Type::UnionType.new(@t34, @t5)
    @ts3 = RDL::Type::UnionType.new($__rdl_string_type, @t3)
    @ts34 = RDL::Type::UnionType.new(@ts3, @t4)
    @t4n = RDL::Type::UnionType.new(@t4, $__rdl_nil_type)
    @env = RDL::Typecheck::Env.new(self: $__rdl_parser.scan_str("#T TestTypecheck"))
  end

  # [+ a +] is the environment, a map from symbols to types; empty if omitted
  # [+ expr +] is a string containing the expression to typecheck
  # returns the type of the expression
  def do_tc(env = RDL::Typecheck::Env.new, expr)
    ast = Parser::CurrentRuby.parse expr
    _, t = RDL::Typecheck.tc Hash.new, env, ast
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
    assert do_tc("nil") <= $__rdl_nil_type
    assert do_tc("true") <= $__rdl_true_type
    assert do_tc("false") <= $__rdl_false_type
    assert do_tc("42") <= $__rdl_parser.scan_str("#T 42")
    assert do_tc("123456789123456789123456789") <= $__rdl_bignum_type
    assert do_tc("3.14") <= $__rdl_parser.scan_str("#T 3.14")
    assert do_tc("1i") <= $__rdl_complex_type
    assert do_tc("2.0r") <= $__rdl_rational_type
    assert do_tc("'42'") <= $__rdl_string_type
    assert do_tc("\"42\"") <= $__rdl_string_type
    assert do_tc(":foo") <= $__rdl_parser.scan_str("#T :foo")
  end

  def test_empty
    self.class.class_eval {
      type "() -> nil", typecheck_now: true
      def empty() end
    }
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
    assert do_tc("_ = 42; _ = 43; 'foo'") <= $__rdl_string_type
  end

  def test_dsym
    # Hard to read if these are inside of strings, so leave like this
    self.class.class_eval {
      type "() -> Symbol", typecheck_now: true
      def dsym() :"foo#{42}"; end
    }
  end

  def test_regexp
    assert do_tc("/foo/") <= $__rdl_regexp_type

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

  def test_hash
    assert do_tc("{x: true, y: false}") <= $__rdl_parser.scan_str("#T {x: TrueClass, y: FalseClass}")
    assert do_tc("{'a' => 1, 'b' => 2}") <= $__rdl_parser.scan_str("#T Hash<String, 1 or 2>")
    assert do_tc("{1 => 'a', 2 => 'b'}") <= $__rdl_parser.scan_str("#T Hash<1 or 2, String>")
    assert do_tc("{}") <= $__rdl_parser.scan_str("#T {}")
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
    assert do_tc("$4") <= $__rdl_string_type
    assert do_tc("$+") <= $__rdl_string_type
  end

  def test_const
    assert do_tc(@env, "String") <= $__rdl_parser.scan_str("#T ${String}")
    assert do_tc(@env, "NIL") <= $__rdl_nil_type
  end

  def test_defined
    assert do_tc("defined?(x)") <= $__rdl_string_type
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
    assert do_tc("x = 42; x") <= $__rdl_fixnum_type
    assert do_tc("x = 42; y = x; y") <= $__rdl_fixnum_type
    assert do_tc("x = y = 42; x") <= $__rdl_fixnum_type
  end

  def test_lvar_type
    # var_type arg type and formattests
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "var_type :x") }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "var_type :x, 3") }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "var_type 'x', 'Fixnum'") }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "var_type :@x, 'Fixnum'") }

    assert do_tc(@env, "var_type :x, 'Fixnum'; x = 3; x") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "var_type :x, 'Fixnum'; x = 'three'") }
    self.class.class_eval {
      type "(Fixnum) -> nil", typecheck_now: true
      def lvar_type_ff(x) x = 42; nil; end
    }
    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Fixnum) -> nil", typecheck_now: true
        def lvar_type_ff2(x) x = "forty-two"; nil; end
      }
    }
  end

  def test_ivar_ivasgn
    self.class.class_eval {
      var_type :@foo, "Fixnum"
      var_type :@@foo, "Fixnum"
      var_type :$test_ivar_ivasgn_global, "Fixnum"
      var_type :@object, "Object"
    }

    assert do_tc(@env, "@foo") <= $__rdl_fixnum_type
    assert do_tc(@env, "@@foo") <= $__rdl_fixnum_type
    assert do_tc("$test_ivar_ivasgn_global") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "@bar") }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "@bar") }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "@@bar") }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("$_test_ivar_ivasgn_global_2") }

    assert do_tc(@env, "@foo = 3") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "@foo = 'three'") }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "@bar = 'three'") }
    assert do_tc(@env, "@@foo = 3") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "@@foo = 'three'") }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "@@bar = 'three'") }
    assert do_tc("$test_ivar_ivasgn_global = 3") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("$test_ivar_ivasgn_global = 'three'") }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("$test_ivar_ivasgn_global_2 = 'three'") }
    assert do_tc(@env, "@object = 3") <= $__rdl_fixnum_type  # type of assignment is type of rhs
  end

  def test_send_basic
    self.class.class_eval {
      type :_send_basic2, "() -> Fixnum"
      type :_send_basic3, "(Fixnum) -> Fixnum"
      type :_send_basic4, "(Fixnum, String) -> Fixnum"
    }

    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "z") }
    assert do_tc(@env, "_send_basic2") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_basic3(42)") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_basic3('42')") }
    assert do_tc(@env, "_send_basic4(42, '42')") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_basic4(42, 43)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_basic4('42', '43')") }
  end

  class A
    type :_send_inherit1, "() -> Fixnum"
  end
  class B < A
  end

  def test_send_inherit
    assert do_tc(@env, "B.new._send_inherit1") <= $__rdl_fixnum_type
  end

  def test_send_inter
    self.class.class_eval {
      type :_send_inter1, "(Fixnum) -> Fixnum"
      type :_send_inter1, "(String) -> String"
    }
    assert do_tc(@env, "_send_inter1(42)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_inter1('42')") <= $__rdl_string_type

    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "_send_inter1(:forty_two)") }
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
    assert do_tc(@env, "_send_opt_varargs1(42)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_opt_varargs1(42, 43)") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs1()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs1(42, 43, 44)") }
    assert do_tc(@env, "_send_opt_varargs2(42)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_opt_varargs2(42, 43)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_opt_varargs2(42, 43, 44)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_opt_varargs2(42, 43, 44, 45)") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs2()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs2('42')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs2(42, '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs2(42, 43, '44')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs2(42, 43, 44, '45')") }
    assert do_tc(@env, "_send_opt_varargs3(42)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_opt_varargs3(42, 43)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_opt_varargs3(42, 43, 44)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_opt_varargs3(42, 43, 45)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_opt_varargs3(42, 43, 46)") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs3()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs3('42')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs3(42, '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs3(42, 43, '44')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs3(42, 43, 44, '45')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs3(42, 43, 44, 45, '46')") }
    assert do_tc(@env, "_send_opt_varargs4()") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_opt_varargs4(42)") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs4('42')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs4(42, 43)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs4(42, 43, 44)") }
    assert do_tc(@env, "_send_opt_varargs5()") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_opt_varargs5(42)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_opt_varargs5(42, 43)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_opt_varargs5(42, 43, 44)") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs5('42')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs5(42, '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs5(42, 43, '44')") }
    assert do_tc(@env, "_send_opt_varargs6('44')") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_opt_varargs6(43, '44')") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs6()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_opt_varargs6(43, '44', 45)") }
  end

  def test_send_named_args
    # from test_type_contract.rb
    self.class.class_eval {
      type :_send_named_args1, "(x: Fixnum) -> Fixnum"
      type :_send_named_args2, "(x: Fixnum, y: String) -> Fixnum"
      type :_send_named_args3, "(Fixnum, y: String) -> Fixnum"
      type :_send_named_args4, "(Fixnum, x: Fixnum, y: String) -> Fixnum"
      type :_send_named_args5, "(x: Fixnum, y: ?String) -> Fixnum"
      type :_send_named_args6, "(x: ?Fixnum, y: String) -> Fixnum"
      type :_send_named_args7, "(x: ?Fixnum, y: ?String) -> Fixnum"
      type :_send_named_args8, "(?Fixnum, x: ?Symbol, y: ?String) -> Fixnum"
    }
    assert do_tc(@env, "_send_named_args1(x: 42)") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args1(x: '42')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args1()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args1(x: 42, y: 42)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args1(y: 42)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args1(42)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args1(42, x: '42')") }
    assert do_tc(@env, "_send_named_args2(x: 42, y: '43')") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args2()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args2(x: 42)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args2(x: '42', y: '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args2(42, '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args2(42, x: 42, y: '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args2(x: 42, y: '43', z: 44)") }
    assert do_tc(@env, "_send_named_args3(42, y: '43')") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args3(42, y: 43)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args3()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args3(42, 43, y: 44)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args3(42, y: 43, z: 44)") }
    assert do_tc(@env, "_send_named_args4(42, x: 43, y: '44')") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args4(42, x: 43)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args4(42, y: '43')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args4()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args4(42, 43, x: 44, y: '45')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args4(42, x: 43, y: '44', z: 45)") }
    assert do_tc(@env, "_send_named_args5(x: 42, y: '43')") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_named_args5(x: 42)") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args5()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args5(x: 42, y: 43)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args5(x: 42, y: 43, z: 44)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args5(3, x: 42, y: 43)") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args5(3, x: 42)") }
    assert do_tc(@env, "_send_named_args6(x: 43, y: '44')") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_named_args6(y: '44')") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args6()") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args6(x: '43', y: '44')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args6(42, x: 43, y: '44')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args6(x: 43, y: '44', z: 45)") }
    assert do_tc(@env, "_send_named_args7()") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_named_args7(x: 43)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_named_args7(y: '44')") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_named_args7(x: 43, y: '44')") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args7(x: '43', y: '44')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args7(41, x: 43, y: '44')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args7(x: 43, y: '44', z: 45)") }
    assert do_tc(@env, "_send_named_args8()") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_named_args8(43)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_named_args8(x: :foo)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_named_args8(43, x: :foo)") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_named_args8(y: 'foo')") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_named_args8(43, y: 'foo')") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_named_args8(x: :foo, y: 'foo')") <= $__rdl_fixnum_type
    assert do_tc(@env, "_send_named_args8(43, x: :foo, y: 'foo')") <= $__rdl_fixnum_type
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args8(43, 44, x: :foo, y: 'foo')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args8(43, x: 'foo', y: 'foo')") }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc(@env, "_send_named_args8(43, x: :foo, y: 'foo', z: 44)") }
  end

  def test_send_singleton
    type Fixnum, :_send_singleton, "() -> String"
    assert do_tc(@env, "3._send_singleton") <= $__rdl_string_type
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "3._send_singleton_nexists") }
  end

  def test_new
    assert do_tc(@env, "B.new") <= RDL::Type::NominalType.new(B)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "B.new(3)") }
  end

  def test_if
    assert do_tc(@env, "if _any_object then 3 end") <= $__rdl_fixnum_type
    assert do_tc(@env, "unless _any_object then 3 end") <= $__rdl_fixnum_type
    assert do_tc(@env, "if _any_object then 3 else 4 end") <= $__rdl_fixnum_type
    assert do_tc(@env, "unless _any_object then 3 else 4 end") <= $__rdl_fixnum_type
    assert_equal @ts3, do_tc(@env, "if _any_object then 3 else 'three' end")
    assert_equal @ts3, do_tc(@env, "unless _any_object then 3 else 'three' end")
    assert do_tc(@env, "3 if _any_object") <= $__rdl_fixnum_type
    assert do_tc(@env, "3 unless _any_object") <= $__rdl_fixnum_type
    assert do_tc(@env, "if true then 3 else 'three' end") <= $__rdl_fixnum_type
    assert do_tc(@env, "if :foo then 3 else 'three' end") <= $__rdl_fixnum_type
    assert do_tc(@env, "if false then 3 else 'three' end") <= $__rdl_string_type
    assert do_tc(@env, "if nil then 3 else 'three' end") <= $__rdl_string_type

    assert do_tc(@env, "x = 'three'; if _any_object then x = 4 else x = 5 end; x") <= $__rdl_fixnum_type
    assert_equal @ts3, do_tc(@env, "x = 'three'; if _any_object then x = 3 end; x")
    assert_equal @ts3, do_tc(@env, "x = 'three'; unless _any_object then x = 3 end; x")
    assert_equal @t4n, do_tc(@env, "if _any_object then y = 4 end; y") # vars are nil if not defined on branch
    assert do_tc(@env, "if _any_object then x = 3; y = 4 else x = 5 end; x") <= $__rdl_fixnum_type
    assert_equal @t4n, do_tc(@env, "if _any_object then x = 3; y = 4 else x = 5 end; y")
  end

  def test_and_or
    assert_equal @ts3, do_tc("'foo' and 3")
    assert_equal @ts3, do_tc("'foo' && 3")
    assert do_tc("3 and 'foo'") <= $__rdl_string_type
    assert do_tc("nil and 'foo'") <= $__rdl_nil_type
    assert do_tc("false and 'foo'") <= $__rdl_false_type
    assert_equal @ts3, do_tc("(x = 'foo') and (x = 3); x")
    assert do_tc("(x = 3) and (x = 'foo'); x") <= $__rdl_string_type
    assert do_tc("(x = nil) and (x = 'foo'); x") <= $__rdl_nil_type
    assert do_tc("(x = false) and (x = 'foo'); x") <= $__rdl_false_type

    assert_equal @ts3, do_tc("'foo' or 3")
    assert_equal @ts3, do_tc("'foo' || 3")
    assert do_tc("3 or 'foo'") <= $__rdl_fixnum_type
    assert do_tc("nil or 3") <= @t3
    assert do_tc("false or 3") <= @t3
    assert_equal @ts3, do_tc("(x = 'foo') or (x = 3); x")
    assert do_tc("(x = 3) or (x = 'foo'); x") <= $__rdl_fixnum_type
    assert do_tc("(x = nil) or (x = 3); x") <= @t3
    assert do_tc("(x = false) or (x = 3); x") <= @t3
  end

  class C
    type :===, "(Object) -> %bool"
  end

  class D
    type :===, "(String) -> %bool"
  end

  def test_when
    assert_equal @t3, do_tc(@env, "case when C.new then 3 end")
    assert_equal @t34, do_tc(@env, "x = 4; case when _any_object then x = 3 end; x")
    assert_equal @ts3, do_tc(@env, "case when _any_object then 3 else 'foo' end")
    assert_equal @ts3, do_tc(@env, "x = 4; case when _any_object then x = 3 else x = 'foo' end; x")

    assert_equal $__rdl_string_type, do_tc(@env, "case _any_object when C.new then 'foo' end")
    assert_equal @ts3, do_tc(@env, "x = 3; case _any_object when C.new then x = 'foo' end; x")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc(@env, "case _any_object when D.new then 'foo' end") }
    assert_equal @ts3, do_tc(@env, "case _any_object when C.new then 'foo' else 3 end")
    assert_equal @ts3, do_tc(@env, "x = 4; case _any_object when C.new then x = 'foo' else x = 3 end; x")
    assert_equal @ts34, do_tc(@env, "case _any_object when C.new then 'foo' when C.new then 4 else 3 end")
    assert_equal @ts34, do_tc(@env, "x = 5; case _any_object when C.new then x = 'foo' when C.new then x = 4 else x = 3 end; x")

    assert_equal @t3, do_tc(@env, "case when (x = 3) then 'foo' end; x")
    assert_equal @t34, do_tc(@env, "case when (x = 3), (x = 4) then 'foo' end; x")
    assert_equal @t34, do_tc(@env, "case when (x = 3), (x = 4) then 'foo' end; x")
    assert_equal @t34, do_tc(@env, "case when (x = 4) then x = 3 end; x")
    assert_equal @t34, do_tc(@env, "x = 5; case when (x = 3) then 'foo' when (x = 4) then 'foo' end; x") # first guard always executed!
    assert_equal @t345, do_tc(@env, "x = 6; case when (x = 3) then 'foo' when (x = 4) then 'foo' else x = 5 end; x")
  end

end
