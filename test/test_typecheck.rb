require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'
require 'rdl_types'

class TestTypecheck < Minitest::Test

  type :_any_object, "() -> Object" # a method that could return true or false

  def setup
    @t3 = RDL::Type::SingletonType.new 3
    @t4 = RDL::Type::SingletonType.new 4
    @t5 = RDL::Type::SingletonType.new 5
    @t34 = RDL::Type::UnionType.new(@t3, @t4)
    @t45 = RDL::Type::UnionType.new(@t4, @t5)
    @t35 = RDL::Type::UnionType.new(@t3, @t5)
    @t345 = RDL::Type::UnionType.new(@t34, @t5)
    @ts3 = RDL::Type::UnionType.new($__rdl_string_type, @t3)
    @ts34 = RDL::Type::UnionType.new(@ts3, @t4)
    @t3n = RDL::Type::UnionType.new(@t3, $__rdl_nil_type)
    @t4n = RDL::Type::UnionType.new(@t4, $__rdl_nil_type)
    @env = RDL::Typecheck::Env.new(self: $__rdl_parser.scan_str("#T TestTypecheck"))
    @scopef = { tret: $__rdl_fixnum_type }
    @tfs = RDL::Type::UnionType.new($__rdl_fixnum_type, $__rdl_string_type)
    @scopefs = { tret: @tfs }
  end

  # [+ a +] is the environment, a map from symbols to types; empty if omitted
  # [+ expr +] is a string containing the expression to typecheck
  # returns the type of the expression
  def do_tc(expr, scope: Hash.new, env: RDL::Typecheck::Env.new)
    ast = Parser::CurrentRuby.parse expr
    _, t = RDL::Typecheck.tc scope, env, ast
    return t
  end

  def test_def
    self.class.class_eval {
      type "(Fixnum) -> Fixnum", typecheck_now: true
      def def_ff(x) x; end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Fixnum) -> Fixnum", typecheck_now: true
        def def_fs(x) "42"; end
      }
    }

    self.class.class_eval {
      type "(Fixnum) -> Fixnum", typecheck_now: true
      def def_ff2(x) x; end
    }
    assert_equal 42, def_ff2(42)

    self.class.class_eval {
      type "(Fixnum) -> Fixnum", typecheck: true
      def def_fs2(x) "42"; end
    }
    assert_raises(RDL::Typecheck::StaticTypeError) { def_fs2(42) }
  end

  def test_defs
    self.class.class_eval {
      type "(Fixnum) -> Class", typecheck_now: true
      def self.defs_ff(x) self; end
    }

    self.class.class_eval {
      type "() -> Class", typecheck_now: true
      def self.defs_nn() defs_ff(42); end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Class", typecheck_now: true
        def self.defs_other() fdsakjfhds(42); end
      }
    }
  end

  def test_lits
    assert_equal $__rdl_nil_type, do_tc("nil")
    assert_equal $__rdl_true_type, do_tc("true")
    assert_equal $__rdl_false_type, do_tc("false")
    assert_equal $__rdl_parser.scan_str("#T 42"), do_tc("42")
    assert do_tc("123456789123456789123456789") <= $__rdl_bignum_type
    assert_equal $__rdl_parser.scan_str("#T 3.14"), do_tc("3.14")
    assert_equal $__rdl_complex_type, do_tc("1i")
    assert_equal $__rdl_rational_type, do_tc("2.0r")
    assert_equal $__rdl_string_type, do_tc("'42'")
    assert_equal $__rdl_string_type, do_tc("\"42\"")
    assert_equal $__rdl_parser.scan_str("#T :foo"), do_tc(":foo")
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
    assert_equal $__rdl_string_type, do_tc("_ = 42; _ = 43; 'foo'")
  end

  def test_dsym
    # Hard to read if these are inside of strings, so leave like this
    self.class.class_eval {
      type "() -> Symbol", typecheck_now: true
      def dsym() :"foo#{42}"; end
    }
  end

  def test_regexp
    assert_equal $__rdl_regexp_type, do_tc("/foo/")

    self.class.class_eval {
      # Hard to read if these are inside of strings, so leave like this
      type "() -> Regexp", typecheck_now: true
      def regexp2() /foo#{42}bar#{"baz"}/i; end
    }
  end

  def test_tuple
    assert_equal $__rdl_parser.scan_str("#T [TrueClass, String]"), do_tc("[true, '42']")
    assert_equal $__rdl_parser.scan_str("#T [42, String]"), do_tc("[42, '42']")
  end

  def test_hash
    assert_equal $__rdl_parser.scan_str("#T {x: TrueClass, y: FalseClass}"), do_tc("{x: true, y: false}")
    assert_equal $__rdl_parser.scan_str("#T Hash<String, 1 or 2>"), do_tc("{'a' => 1, 'b' => 2}")
    assert_equal $__rdl_parser.scan_str("#T Hash<1 or 2, String>"), do_tc("{1 => 'a', 2 => 'b'}")
    assert_equal $__rdl_parser.scan_str("#T {}"), do_tc("{}")
  end

  def test_range
    assert_equal $__rdl_parser.scan_str("#T Range<Fixnum>"), do_tc("1..5")
    assert_equal $__rdl_parser.scan_str("#T Range<Fixnum>"), do_tc("1...5")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("1..'foo'") }
  end

  def test_self
    # These need to be inside an actual class
    self.class.class_eval {
      type "() -> self", typecheck_now: true
      def self1() self; end
    }

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
    assert_equal $__rdl_string_type, do_tc("$4")
    assert_equal $__rdl_string_type, do_tc("$+")
  end

  def test_const
    assert_equal $__rdl_parser.scan_str("#T ${String}"), do_tc("String", env: @env)
    assert_equal $__rdl_nil_type, do_tc("NIL", env: @env)
  end

  def test_defined
    assert_equal $__rdl_string_type, do_tc("defined?(x)")
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
    assert_equal $__rdl_parser.scan_str("#T 42"), do_tc("x = 42; x")
    assert_equal $__rdl_parser.scan_str("#T 42"), do_tc("x = 42; y = x; y")
    assert_equal $__rdl_parser.scan_str("#T 42"), do_tc("x = y = 42; x")
    assert_equal $__rdl_nil_type, do_tc("x = x") # weird behavior - lhs bound to nil always before assignment!
  end

  def test_lvar_type
    # var_type arg type and formattests
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("var_type :x", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("var_type :x, 3", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("var_type 'x', 'Fixnum'", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("var_type :@x, 'Fixnum'", env: @env) }

    assert_equal $__rdl_fixnum_type, do_tc("var_type :x, 'Fixnum'; x = 3; x", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("var_type :x, 'Fixnum'; x = 'three'", env: @env) }
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

    assert_equal $__rdl_fixnum_type, do_tc("@foo", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("@@foo", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("$test_ivar_ivasgn_global")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@bar", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@bar", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@@bar", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("$_test_ivar_ivasgn_global_2") }

    assert_equal @t3, do_tc("@foo = 3", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@foo = 'three'", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@bar = 'three'", env: @env) }
    assert_equal @t3, do_tc("@@foo = 3", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@@foo = 'three'", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@@bar = 'three'", env: @env) }
    assert_equal @t3, do_tc("$test_ivar_ivasgn_global = 3")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("$test_ivar_ivasgn_global = 'three'") }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("$test_ivar_ivasgn_global_2 = 'three'") }
    assert_equal @t3, do_tc("@object = 3", env: @env)  # type of assignment is type of rhs
  end

  def test_send_basic
    self.class.class_eval {
      type :_send_basic2, "() -> Fixnum"
      type :_send_basic3, "(Fixnum) -> Fixnum"
      type :_send_basic4, "(Fixnum, String) -> Fixnum"
      type "self._send_basic5", "(Fixnum) -> Fixnum"
    }

    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("z", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_basic2", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_basic3(42)", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_basic3('42')", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_basic4(42, '42')", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_basic4(42, 43)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_basic4('42', '43')", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("TestTypecheck._send_basic5(42)", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("TestTypecheck._send_basic5('42')", env: @env) }
  end

  class A
    type :_send_inherit1, "() -> Fixnum"
  end
  class B < A
  end

  def test_send_inherit
    assert_equal $__rdl_fixnum_type, do_tc("B.new._send_inherit1", env: @env)
  end

  def test_send_inter
    self.class.class_eval {
      type :_send_inter1, "(Fixnum) -> Fixnum"
      type :_send_inter1, "(String) -> String"
    }
    assert_equal $__rdl_fixnum_type, do_tc("_send_inter1(42)", env: @env)
    assert_equal $__rdl_string_type, do_tc("_send_inter1('42')", env: @env)

    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_inter1(:forty_two)", env: @env) }
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
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs1(42)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs1(42, 43)", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs1()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs1(42, 43, 44)", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs2(42)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs2(42, 43)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs2(42, 43, 44)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs2(42, 43, 44, 45)", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs2()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs2('42')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs2(42, '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs2(42, 43, '44')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs2(42, 43, 44, '45')", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs3(42)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs3(42, 43)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs3(42, 43, 44)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs3(42, 43, 45)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs3(42, 43, 46)", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs3()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs3('42')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs3(42, '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs3(42, 43, '44')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs3(42, 43, 44, '45')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs3(42, 43, 44, 45, '46')", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs4()", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs4(42)", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs4('42')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs4(42, 43)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs4(42, 43, 44)", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs5()", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs5(42)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs5(42, 43)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs5(42, 43, 44)", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs5('42')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs5(42, '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs5(42, 43, '44')", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs6('44')", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_opt_varargs6(43, '44')", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs6()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs6(43, '44', 45)", env: @env) }
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
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args1(x: 42)", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args1(x: '42')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args1()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args1(x: 42, y: 42)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args1(y: 42)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args1(42)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args1(42, x: '42')", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args2(x: 42, y: '43')", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args2()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args2(x: 42)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args2(x: '42', y: '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args2(42, '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args2(42, x: 42, y: '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args2(x: 42, y: '43', z: 44)", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args3(42, y: '43')", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args3(42, y: 43)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args3()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args3(42, 43, y: 44)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args3(42, y: 43, z: 44)", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args4(42, x: 43, y: '44')", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args4(42, x: 43)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args4(42, y: '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args4()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args4(42, 43, x: 44, y: '45')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args4(42, x: 43, y: '44', z: 45)", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args5(x: 42, y: '43')", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args5(x: 42)", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args5()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args5(x: 42, y: 43)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args5(x: 42, y: 43, z: 44)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args5(3, x: 42, y: 43)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args5(3, x: 42)", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args6(x: 43, y: '44')", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args6(y: '44')", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args6()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args6(x: '43', y: '44')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args6(42, x: 43, y: '44')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args6(x: 43, y: '44', z: 45)", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args7()", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args7(x: 43)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args7(y: '44')", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args7(x: 43, y: '44')", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args7(x: '43', y: '44')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args7(41, x: 43, y: '44')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args7(x: 43, y: '44', z: 45)", env: @env) }
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args8()", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args8(43)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args8(x: :foo)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args8(43, x: :foo)", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args8(y: 'foo')", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args8(43, y: 'foo')", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args8(x: :foo, y: 'foo')", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("_send_named_args8(43, x: :foo, y: 'foo')", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args8(43, 44, x: :foo, y: 'foo')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args8(43, x: 'foo', y: 'foo')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_named_args8(43, x: :foo, y: 'foo', z: 44)", env: @env) }
  end

  def test_send_singleton
    type Fixnum, :_send_singleton, "() -> String"
    assert_equal $__rdl_string_type, do_tc("3._send_singleton", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("3._send_singleton_nexists", env: @env) }
  end

  def test_send_generic
    assert_equal $__rdl_fixnum_type, do_tc("[1,2,3].length", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("{a:1, b:2}.length", env: @env)
    assert_equal $__rdl_string_type, do_tc("String.new.clone", env: @env)
    # TODO test case with other generic
  end

  def test_send_alias
    assert_equal $__rdl_fixnum_type, do_tc("[1,2,3].size", env: @env)
  end

  def test_send_union
    assert_equal RDL::Type::UnionType.new(@tfs, $__rdl_bignum_type), do_tc("(if _any_object then Fixnum.new else String.new end) * 2", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("(if _any_object then Object.new else Fixnum.new end) + 2", env: @env) }
  end

  def test_new
    assert_equal RDL::Type::NominalType.new(B), do_tc("B.new", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("B.new(3)", env: @env) }
  end

  def test_if
    assert_equal @t3n, do_tc("if _any_object then 3 end", env: @env)
    assert_equal @t3n, do_tc("unless _any_object then 3 end", env: @env)
    assert_equal @t34, do_tc("if _any_object then 3 else 4 end", env: @env)
    assert_equal @t34, do_tc("unless _any_object then 3 else 4 end", env: @env)
    assert_equal @ts3, do_tc("if _any_object then 3 else 'three' end", env: @env)
    assert_equal @ts3, do_tc("unless _any_object then 3 else 'three' end", env: @env)
    assert_equal @t3n, do_tc("3 if _any_object", env: @env)
    assert_equal @t3n, do_tc("3 unless _any_object", env: @env)
    assert_equal @t3, do_tc("if true then 3 else 'three' end", env: @env)
    assert_equal @t3, do_tc("if :foo then 3 else 'three' end", env: @env)
    assert_equal $__rdl_string_type, do_tc("if false then 3 else 'three' end", env: @env)
    assert_equal $__rdl_string_type, do_tc("if nil then 3 else 'three' end", env: @env)

    assert_equal @t45, do_tc("x = 'three'; if _any_object then x = 4 else x = 5 end; x", env: @env)
    assert_equal @ts3, do_tc("x = 'three'; if _any_object then x = 3 end; x", env: @env)
    assert_equal @ts3, do_tc("x = 'three'; unless _any_object then x = 3 end; x", env: @env)
    assert_equal @t4n, do_tc("if _any_object then y = 4 end; y", env: @env) # vars are nil if not defined on branch
    assert_equal @t35, do_tc("if _any_object then x = 3; y = 4 else x = 5 end; x", env: @env)
    assert_equal @t4n, do_tc("if _any_object then x = 3; y = 4 else x = 5 end; y", env: @env)
  end

  def test_and_or
    assert_equal @ts3, do_tc("'foo' and 3")
    assert_equal @ts3, do_tc("'foo' && 3")
    assert_equal $__rdl_string_type, do_tc("3 and 'foo'")
    assert_equal $__rdl_nil_type, do_tc("nil and 'foo'")
    assert_equal $__rdl_false_type, do_tc("false and 'foo'")
    assert_equal @ts3, do_tc("(x = 'foo') and (x = 3); x")
    assert_equal $__rdl_string_type, do_tc("(x = 3) and (x = 'foo'); x")
    assert_equal $__rdl_nil_type, do_tc("(x = nil) and (x = 'foo'); x")
    assert_equal $__rdl_false_type, do_tc("(x = false) and (x = 'foo'); x")

    assert_equal @ts3, do_tc("'foo' or 3")
    assert_equal @ts3, do_tc("'foo' || 3")
    assert_equal @t3, do_tc("3 or 'foo'")
    assert_equal @t3, do_tc("nil or 3")
    assert_equal @t3, do_tc("false or 3")
    assert_equal @ts3, do_tc("(x = 'foo') or (x = 3); x")
    assert_equal @t3, do_tc("(x = 3) or (x = 'foo'); x")
    assert_equal @t3, do_tc("(x = nil) or (x = 3); x")
    assert_equal @t3, do_tc("(x = false) or (x = 3); x")
  end

  class C
    type :===, "(Object) -> %bool"
  end

  class D
    type :===, "(String) -> %bool"
  end

  def test_when
    assert_equal @t3, do_tc("case when C.new then 3 end", env: @env)
    assert_equal @t34, do_tc("x = 4; case when _any_object then x = 3 end; x", env: @env)
    assert_equal @ts3, do_tc("case when _any_object then 3 else 'foo' end", env: @env)
    assert_equal @ts3, do_tc("x = 4; case when _any_object then x = 3 else x = 'foo' end; x", env: @env)

    assert_equal $__rdl_string_type, do_tc("case _any_object when C.new then 'foo' end", env: @env)
    assert_equal @ts3, do_tc("x = 3; case _any_object when C.new then x = 'foo' end; x", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("case _any_object when D.new then 'foo' end", env: @env) }
    assert_equal @ts3, do_tc("case _any_object when C.new then 'foo' else 3 end", env: @env)
    assert_equal @ts3, do_tc("x = 4; case _any_object when C.new then x = 'foo' else x = 3 end; x", env: @env)
    assert_equal @ts34, do_tc("case _any_object when C.new then 'foo' when C.new then 4 else 3 end", env: @env)
    assert_equal @ts34, do_tc("x = 5; case _any_object when C.new then x = 'foo' when C.new then x = 4 else x = 3 end; x", env: @env)

    assert_equal @t3, do_tc("case when (x = 3) then 'foo' end; x", env: @env)
    assert_equal @t34, do_tc("case when (x = 3), (x = 4) then 'foo' end; x", env: @env)
    assert_equal @t34, do_tc("case when (x = 3), (x = 4) then 'foo' end; x", env: @env)
    assert_equal @t34, do_tc("case when (x = 4) then x = 3 end; x", env: @env)
    assert_equal @t34, do_tc("x = 5; case when (x = 3) then 'foo' when (x = 4) then 'foo' end; x", env: @env) # first guard always executed!
    assert_equal @t345, do_tc("x = 6; case when (x = 3) then 'foo' when (x = 4) then 'foo' else x = 5 end; x", env: @env)
  end

  def test_while_until
    # TODO these don't do a great job checking control flow
    assert_equal $__rdl_nil_type, do_tc("while true do end")
    assert_equal $__rdl_nil_type, do_tc("until false do end")
    assert_equal $__rdl_nil_type, do_tc("begin end while true")
    assert_equal $__rdl_nil_type, do_tc("begin end until false")
    assert_equal $__rdl_integer_type, do_tc("i = 0; while i < 5 do i = 1 + i end; i")
    assert_equal $__rdl_integer_type, do_tc("i = 0; while i < 5 do i = i + 1 end; i")
    assert_equal $__rdl_integer_type, do_tc("i = 0; until i >= 5 do i = 1 + i end; i")
    assert_equal $__rdl_integer_type, do_tc("i = 0; until i >= 5 do i = i + 1 end; i")
    assert_equal $__rdl_integer_type, do_tc("i = 0; begin i = 1 + i end while i < 5; i")
    assert_equal $__rdl_integer_type, do_tc("i = 0; begin i = i + 1 end while i < 5; i")
    assert_equal $__rdl_integer_type, do_tc("i = 0; begin i = 1 + i end until i >= 5; i")
    assert_equal $__rdl_integer_type, do_tc("i = 0; begin i = i + 1 end until i >= 5; i")

    # break, redo, next, no args
    assert_equal $__rdl_integer_type, do_tc("i = 0; while i < 5 do if i > 2 then break end; i = 1 + i end; i")
    assert_equal $__rdl_parser.scan_str("#T 0"), do_tc("i = 0; while i < 5 do break end; i")
    assert_equal $__rdl_parser.scan_str("#T 0"), do_tc("i = 0; while i < 5 do redo end; i") # infinite loop, ok for typing
    assert_equal $__rdl_parser.scan_str("#T 0"), do_tc("i = 0; while i < 5 do next end; i") # infinite loop, ok for typing
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("i = 0; while i < 5 do retry end; i") }
    assert_equal $__rdl_integer_type, do_tc("i = 0; begin i = i + 1; break if i > 2; end while i < 5; i")
    assert_equal $__rdl_integer_type, do_tc("i = 0; begin i = i + 1; redo if i > 2; end while i < 5; i")
    assert_equal $__rdl_integer_type, do_tc("i = 0; begin i = i + 1; next if i > 2; end while i < 5; i")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("i = 0; begin i = i + 1; retry if i > 2; end while i < 5; i") }

    # break w/arg, next can't take arg
    assert_equal @t3n, do_tc("while _any_object do break 3 end", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("while _any_object do next 3 end", env: @env) }
    assert_equal @t3n, do_tc("begin break 3 end while _any_object", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("begin next 3 end while _any_object", env: @env) }
  end

  def test_for
    assert_equal $__rdl_fixnum_type, do_tc("for i in 1..5 do end; i")
    assert_equal $__rdl_parser.scan_str("#T 1 or 2 or 3 or 4 or 5"), do_tc("for i in [1,2,3,4,5] do end; i")
    assert_equal $__rdl_parser.scan_str("#T Range<Fixnum>"), do_tc("for i in 1..5 do break end", env: @env)
    assert_equal $__rdl_parser.scan_str("#T Range<Fixnum>"), do_tc("for i in 1..5 do next end", env: @env)
    assert_equal $__rdl_parser.scan_str("#T Range<Fixnum>"), do_tc("for i in 1..5 do redo end", env: @env) #infinite loop, ok for typing
    assert_equal $__rdl_parser.scan_str("#T Range<Fixnum> or 3"), do_tc("for i in 1..5 do break 3 end", env: @env)
    assert_equal @tfs, do_tc("for i in 1..5 do next 'three' end; i", env: @env)
  end

  def test_return
    assert self.class.class_eval {
      type "(Fixnum) -> Fixnum", typecheck_now: true
      def return_ff(x)
        return 42
      end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Fixnum) -> Fixnum", typecheck_now: true
        def return_ff2(x)
          return "forty-two"
        end
      }
    }

    assert_equal $__rdl_bot_type, do_tc("return 42", scope: @scopefs)
    assert_equal $__rdl_bot_type, do_tc("if _any_object then return 42 else return 'forty-two' end", env: @env, scope: @scopefs)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("if _any_object then return 42 else return 'forty-two' end", env: @env, scope: @scopef) }
    assert_equal $__rdl_string_type, do_tc("return 42 if _any_object; 'forty-two'", env: @env, scope: @scopef)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("return 'forty-two' if _any_object; 42", env: @env, scope: @scopef) }
  end

  class E
    type :f, '() -> %integer'
    type :f=, '(%integer) -> nil'
  end

  def test_op_asgn
    assert $__rdl_integer_type, do_tc("x = 0; x += 1")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x += 1") }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x = Object.new; x += 1", env: @env) }
    assert_equal $__rdl_nil_type, do_tc("e = E.new; e.f += 1", env: @env) # return type of f=
    assert_equal $__rdl_false_type, do_tc("x &= false") # weird
  end

  def test_and_or_asgn
    self.class.class_eval {
      var_type :@f_and_or_asgn, "Fixnum"
    }
    assert_equal @t3, do_tc("x ||= 3") # weird
    assert_equal $__rdl_nil_type, do_tc("x &&= 3") # weirder
    assert_equal $__rdl_fixnum_type, do_tc("@f_and_or_asgn &&= 4", env: @env)
    assert_equal @t3, do_tc("x = 3; x ||= 'three'")
    assert_equal @ts3, do_tc("x = 'three'; x ||= 3")
    assert_equal $__rdl_nil_type, do_tc("e = E.new; e.f ||= 3", env: @env) # return type of f=
    assert_equal $__rdl_nil_type, do_tc("e = E.new; e.f &&= 3", env: @env) # return type of f=
  end

  def test_masgn
    self.class.class_eval {
      var_type :@f_masgn, "Array<Fixnum>"
    }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x, y = 3") } # allowed in Ruby but probably has surprising behavior
    assert_equal $__rdl_parser.scan_str("#T Array<Fixnum>"), do_tc("a, b = @f_masgn", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("a, b = @f_masgn; a", env: @env)
    assert_equal $__rdl_fixnum_type, do_tc("a, b = @f_masgn; b", env: @env)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("var_type :a, 'String'; a, b = @f_masgn", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("a, b = 1, 2, 3") }
    assert_equal @t3, do_tc("a, b = 3, 'two'; a")
    assert_equal $__rdl_string_type, do_tc("a, b = 3, 'two'; b")
    assert_equal @t3, do_tc("a = [3, 'two']; x, y = a; x")
    assert_equal $__rdl_string_type, do_tc("a = [3, 'two']; x, y = a; y")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("a = [3, 'two']; x, y = a; a.length", env: @env) }
  end

end
