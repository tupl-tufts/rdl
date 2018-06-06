require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'
require 'types/core'

class N1
  class N2
    extend RDL::Annotate
    def self.foo
      :sym
    end
   type 'self.foo', '() -> :sym'

    def self.foo2
      :sym2
    end
    type 'self.foo2', '() -> :sym2'

    def self.nf
      N2.foo
    end
    type 'self.nf', '() -> :sym', typecheck: :call

    def nf2
      N2.foo2
    end
    type :nf2, '() -> :sym2', typecheck: :call
  end

  class N3
    extend RDL::Annotate
    def nf3
      N2.foo
    end
    type :nf3, '() -> :sym', typecheck: :call
  end
end

class N4
  extend RDL::Annotate
  class N5
    extend RDL::Annotate
    type :bar, '() -> :B'
    def bar
      :B
    end
  end
end

class N5
  extend RDL::Annotate
  type :bar, '() -> :A'
  def bar
    :A
  end
end

class N4
  class << self
    extend RDL::Annotate
    def foo
      N5.new.bar
    end
  end
  type 'self.foo', '() -> :B', typecheck: :call
end

class TestTypecheckC
  extend RDL::Annotate
  type 'self.bar', '() -> Integer or String ret'
  type 'self.foo', '() -> :A'
  type 'foo', '() -> Integer'
  type '(Integer) -> self'
  def initialize(x); end
end

class TestTypecheckD
end

class TestTypecheckE
  extend RDL::Annotate
  type '(Integer) -> self', typecheck: :einit
  def initialize(x)
    x
  end
end

class TestTypecheckF
  extend RDL::Annotate
  type '(Integer) -> F', typecheck: :finit
  def initialize(x)
    x
  end
end

module TestTypecheckM
  extend RDL::Annotate
  type 'self.foo', '() -> :B'
end

class TestTypecheckOuter
  class A
    class B
      class C
      end
    end
  end
end

class X
  extend RDL::Annotate
end
class Y
  extend RDL::Annotate
end

class MethodMissing1
  extend RDL::Annotate
  type '() -> String', typecheck: :later_mm1
  def foo()
    bar()
  end

  type '(Symbol, *%any) -> String', typecheck: :later_mm1
  def method_missing(name, *_)
    name.to_s
  end
end

class MethodMissing2
  extend RDL::Annotate
  type '() -> Integer', typecheck: :later_mm2
  def foo()
    bar()
  end

  type '(Symbol, *%any) -> String', typecheck: :later_mm2
  def method_missing(name, *_)
    name.to_s
  end
end

class SingletonInheritA
  extend RDL::Annotate
  type 'self.foo', '(Integer) -> Integer'
end

class SingletonInheritB < SingletonInheritA; end


class TestTypecheck < Minitest::Test
  extend RDL::Annotate
  type :_any_object, "() -> Object" # a method that could return true or false

  def setup
    @t3 = RDL::Type::SingletonType.new 3
    @t4 = RDL::Type::SingletonType.new 4
    @t5 = RDL::Type::SingletonType.new 5
    @t34 = RDL::Type::UnionType.new(@t3, @t4)
    @t45 = RDL::Type::UnionType.new(@t4, @t5)
    @t35 = RDL::Type::UnionType.new(@t3, @t5)
    @t345 = RDL::Type::UnionType.new(@t34, @t5)
    @ts3 = RDL::Type::UnionType.new(RDL::Globals.types[:string], @t3)
    @ts34 = RDL::Type::UnionType.new(@ts3, @t4)
    @t3n = RDL::Type::UnionType.new(@t3, RDL::Globals.types[:nil])
    @t4n = RDL::Type::UnionType.new(@t4, RDL::Globals.types[:nil])
    @env = RDL::Typecheck::Env.new(self: tt("TestTypecheck"))
    @scopef = { tret: RDL::Globals.types[:integer] }
    @tfs = RDL::Type::UnionType.new(RDL::Globals.types[:integer], RDL::Globals.types[:string])
    @scopefs = { tret: @tfs, tblock: nil }
    ### Uncomment below to see test names. Useful for hanging tests.
    #puts "Start #{@NAME}"
  end

  # [+ a +] is the environment, a map from symbols to types; empty if omitted
  # [+ expr +] is a string containing the expression to typecheck
  # returns the type of the expression
  def do_tc(expr, scope: Hash.new, env: RDL::Typecheck::Env.new)
    ast = Parser::CurrentRuby.parse expr
    _, t = RDL::Typecheck.tc scope, env, ast
    return t
  end

  # convert arg string to a type
  def tt(t)
    RDL::Globals.parser.scan_str('#T ' + t)
  end

  def test_def
    self.class.class_eval {
      type "(Integer) -> Integer", typecheck: :now
      def def_ff(x) x; end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) -> Integer", typecheck: :now
        def def_fs(x) "42"; end
      }
    }

    self.class.class_eval {
      type "(Integer) -> Integer", typecheck: :now
      def def_ff2(x) x; end
    }
    assert_equal 42, def_ff2(42)

    self.class.class_eval {
      type "(Integer) -> Integer", typecheck: :call
      def def_fs2(x) "42"; end
    }
    assert_raises(RDL::Typecheck::StaticTypeError) { def_fs2(42) }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) -> Integer", typecheck: :now
        def def_ff3(x, y) 42; end
      }
    }

    self.class.class_eval {
      type "(Integer) -> Integer", typecheck: :later1
      def def_ff4(x, y) 42; end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :later1 }
  end

  def test_def_post
    self.class.class_eval {
      def def_ffp(x) x; end
      type :def_ffp, "(Integer) -> Integer", typecheck: :now, wrap: false
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        def def_fsp(x) "42"; end
        type :def_fsp, "(Integer) -> Integer", typecheck: :now, wrap: false
      }
    }

    self.class.class_eval {
      def def_ff2p(x) x; end
      type :def_ff2p, "(Integer) -> Integer", typecheck: :now, wrap: false
    }
    assert_equal 42, def_ff2p(42)

    self.class.class_eval {
      def def_fs2p(x) "42"; end
      type :def_fs2p, "(Integer) -> Integer", typecheck: :call
    }
    assert_raises(RDL::Typecheck::StaticTypeError) { def_fs2p(42) }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        def def_ff3p(x, y) 42; end
        type :def_ff3p, "(Integer) -> Integer", typecheck: :now, wrap: false
      }
    }

    self.class.class_eval {
      def def_ff4p(x, y) 42; end
      type :def_ff4p, "(Integer) -> Integer", typecheck: :later2, wrap: false
    }
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :later2 }
  end

  def test_defs
    self.class.class_eval {
      type "(Integer) -> Class", typecheck: :now
      def self.defs_ff(x) self; end
    }

    self.class.class_eval {
      type "() -> Class", typecheck: :now
      def self.defs_nn() defs_ff(42); end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Class", typecheck: :now
        def self.defs_other() fdsakjfhds(42); end
      }
    }

    self.class.class_eval {
      type "(Integer) -> Integer", typecheck: :later4
      def self.defs_ff2(x, y) 42; end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :later4 }
  end

  def test_singleton_method_const
    X.class_eval {
      type '(Integer) -> Integer'
      def foo(x) x; end
    }
    Y.class_eval {
      type '(Integer) -> Integer', typecheck: :later5
      def self.bar(x) a = X.new; a.foo(x); end
    }
    self.class.class_eval { RDL.do_typecheck :later5 }
  end

  def test_lits
    assert do_tc("nil") <= RDL::Globals.types[:nil]
    assert do_tc("true") <= RDL::Globals.types[:true]
    assert do_tc("false") <= RDL::Globals.types[:false]
    assert do_tc("42") <= tt("42")
    assert do_tc("123456789123456789123456789") <= RDL::Globals.types[:integer]
    assert do_tc("3.14") <= tt("3.14")
    assert do_tc("1i") <= RDL::Globals.types[:complex]
    assert do_tc("2.0r") <= RDL::Globals.types[:rational]
    assert do_tc("'42'") <= RDL::Globals.types[:string]
    assert do_tc("\"42\"") <= RDL::Globals.types[:string]
    assert do_tc(":foo") <= tt(":foo")
  end

  def test_empty
    self.class.class_eval {
      type "() -> nil", typecheck: :now
      def empty() end
    }
  end

  def test_dstr_xstr
    # Hard to read if these are inside of strings, so leave like this
    self.class.class_eval {
      type "() -> String", typecheck: :now
      def dstr() "Foo #{42} Bar #{43}"; end

      type "() -> String", typecheck: :now
      def xstr() `ls #{42}`; end
    }
  end

  def test_seq
    assert do_tc("_ = 42; _ = 43; 'foo'") <= RDL::Globals.types[:string]
  end

  def test_dsym
    # Hard to read if these are inside of strings, so leave like this
    self.class.class_eval {
      type "() -> Symbol", typecheck: :now
      def dsym() :"foo#{42}"; end
    }
  end

  def test_regexp
    assert do_tc("/foo/") <= RDL::Globals.types[:regexp]

    self.class.class_eval {
      # Hard to read if these are inside of strings, so leave like this
      type "() -> Regexp", typecheck: :now
      def regexp2() /foo#{42}bar#{"baz"}/i; end
    }
  end

  def test_tuple
    assert do_tc("[true, '42']") <= tt("[TrueClass, String]")
    assert do_tc("[42, '42']") <= tt("[42, String]")
  end

  def test_hash
    assert do_tc("{x: true, y: false}") <= tt("{x: TrueClass, y: FalseClass}")
    assert do_tc("{'a' => 1, 'b' => 2}") <= tt("Hash<String, 1 or 2>")
    assert do_tc("{1 => 'a', 2 => 'b'}") <= tt("{1 => String, 2 => String}")
    assert do_tc("{}") <= tt("{}")
  end

  def test_range
    assert do_tc("1..5") <= tt("Range<Integer>")
    assert do_tc("1...5") <= tt("Range<Integer>")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("1..'foo'") }
  end

  def test_self
    # These need to be inside an actual class
    self.class.class_eval {
      type "() -> self", typecheck: :now
      def self1() self; end
    }

    self.class.class_eval {
      type "() -> self", typecheck: :now
      def self2() TestTypecheck.new; end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> self", typecheck: :now
        def self3() Object.new; end
      }
    }
  end

  def test_nth_back
    assert do_tc("$4") <= RDL::Globals.types[:string]
    assert do_tc("$+") <= RDL::Globals.types[:string]
  end

  def test_const
    assert do_tc("String", env: @env) <= tt("${String}")

    t = RDL::Type::SingletonType.new(TestTypecheckOuter)
    assert_equal t, do_tc("TestTypecheckOuter", env: @env)
    t = RDL::Type::SingletonType.new(TestTypecheckOuter::A)
    assert_equal t, do_tc("TestTypecheckOuter::A", env: @env)
    t = RDL::Type::SingletonType.new(TestTypecheckOuter::A::B::C)
    assert_equal t, do_tc("TestTypecheckOuter::A::B::C", env: @env)

    self.class.class_eval {
      const_set(:CONST_STRING, 'string')

      type '() -> String', typecheck: :now
      def const1() CONST_STRING; end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '() -> Integer', typecheck: :now
        def const2() CONST_STRING; end
      }
    }
  end

  def test_defined
    assert do_tc("defined?(x)") <= RDL::Globals.types[:string]
  end

  def test_lvar
    self.class.class_eval {
      type "(Integer, String) -> Integer", typecheck: :now
      def lvar1(x, y) x; end
    }

    self.class.class_eval {
      type "(Integer, String) -> String", typecheck: :now
      def lvar2(x, y) y; end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      # really a send
      self.class.class_eval {
        type "(Integer, String) -> String", typecheck: :now
        def lvar3(x, y) z; end
      }
    }
  end

  def test_lvasgn
    assert do_tc("x = 42; x") <=  tt("42")
    assert do_tc("x = 42; y = x; y") <=  tt("42")
    assert do_tc("x = y = 42; x") <=  tt("42")
    assert do_tc("x = x") <= RDL::Globals.types[:nil] # weird behavior - lhs bound to nil always before assignment!
  end

  def test_lvar_type
    # var_type arg type and formattests
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("RDL.var_type :x", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("RDL.var_type :x, 3", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("RDL.var_type 'x', 'Integer'", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("RDL.var_type :@x, 'Integer'", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("RDL.var_type :x, 'Fluffy Bunny'", env: @env) }

    assert do_tc("RDL.var_type :x, 'Integer'; x = 3; x", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("RDL.var_type :x, 'Integer'; x = 'three'", env: @env) }
    self.class.class_eval {
      type "(Integer) -> nil", typecheck: :now
      def lvar_type_ff(x) x = 42; nil; end
    }
    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) -> nil", typecheck: :now
        def lvar_type_ff2(x) x = "forty-two"; nil; end
      }
    }
  end

  def test_ivar_ivasgn
    self.class.class_eval {
      extend RDL::Annotate
      var_type :@foo, "Integer"
      var_type :@@foo, "Integer"
      var_type :$test_ivar_ivasgn_global, "Integer"
      var_type :@object, "Object"
    }

    assert do_tc("@foo", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("@@foo", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("$test_ivar_ivasgn_global") <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@bar", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@bar", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@@bar", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("$_test_ivar_ivasgn_global_2") }

    assert do_tc("@foo = 3", env: @env) <= @t3
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@foo = 'three'", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@bar = 'three'", env: @env) }
    assert do_tc("@@foo = 3", env: @env) <= @t3
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@@foo = 'three'", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("@@bar = 'three'", env: @env) }
    assert do_tc("$test_ivar_ivasgn_global = 3") <= @t3
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("$test_ivar_ivasgn_global = 'three'") }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("$test_ivar_ivasgn_global_2 = 'three'") }
    assert do_tc("@object = 3", env: @env) <= @t3 # type of assignment is type of rhs
  end

  def test_send_basic
    self.class.class_eval {
      type :_send_basic2, "() -> Integer"
      type :_send_basic3, "(Integer) -> Integer"
      type :_send_basic4, "(Integer, String) -> Integer"
      type "self._send_basic5", "(Integer) -> Integer"
    }

    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("z", env: @env) }
    assert do_tc("_send_basic2", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_basic3(42)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_basic3('42')", env: @env) }
    assert do_tc("_send_basic4(42, '42')", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_basic4(42, 43)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_basic4('42', '43')", env: @env) }
    assert do_tc("TestTypecheck._send_basic5(42)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("TestTypecheck._send_basic5('42')", env: @env) }
    assert do_tc("puts 42", env: @env) <= RDL::Globals.types[:nil]
  end

  class A
    extend RDL::Annotate
    type :_send_inherit1, "() -> Integer"
  end
  class B < A
  end

  def test_send_inter
    self.class.class_eval {
      type :_send_inter1, "(Integer) -> Integer"
      type :_send_inter1, "(String) -> String"
    }
    assert do_tc("_send_inter1(42)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_inter1('42')", env: @env) <= RDL::Globals.types[:string]

    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_inter1(:forty_two)", env: @env) }
  end

  def test_send_opt_varargs
    # from test_type_contract.rb
    self.class.class_eval {
      type :_send_opt_varargs1, "(Integer, ?Integer) -> Integer"
      type :_send_opt_varargs2, "(Integer, *Integer) -> Integer"
      type :_send_opt_varargs3, "(Integer, ?Integer, ?Integer, *Integer) -> Integer"
      type :_send_opt_varargs4, "(?Integer) -> Integer"
      type :_send_opt_varargs5, "(*Integer) -> Integer"
      type :_send_opt_varargs6, "(?Integer, String) -> Integer"
      type :_send_opt_varargs7, "(Integer, *String, Integer) -> Integer"
    }
    assert do_tc("_send_opt_varargs1(42)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs1(42, 43)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs1()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs1(42, 43, 44)", env: @env) }
    assert do_tc("_send_opt_varargs2(42)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs2(42, 43)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs2(42, 43, 44)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs2(42, 43, 44, 45)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs2()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs2('42')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs2(42, '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs2(42, 43, '44')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs2(42, 43, 44, '45')", env: @env) }
    assert do_tc("_send_opt_varargs3(42)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs3(42, 43)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs3(42, 43, 44)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs3(42, 43, 45)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs3(42, 43, 46)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs3()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs3('42')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs3(42, '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs3(42, 43, '44')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs3(42, 43, 44, '45')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs3(42, 43, 44, 45, '46')", env: @env) }
    assert do_tc("_send_opt_varargs4()", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs4(42)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs4('42')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs4(42, 43)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs4(42, 43, 44)", env: @env) }
    assert do_tc("_send_opt_varargs5()", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs5(42)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs5(42, 43)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs5(42, 43, 44)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs5('42')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs5(42, '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs5(42, 43, '44')", env: @env) }
    assert do_tc("_send_opt_varargs6('44')", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs6(43, '44')", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs6()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { assert do_tc("_send_opt_varargs6(43, '44', 45)", env: @env) }
    assert do_tc("_send_opt_varargs7(42, 43)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs7(42, 'foo', 43)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_opt_varargs7(42, 'foo', 'bar', 43)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_opt_varargs7", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_opt_varargs7('42')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_opt_varargs7(42)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_opt_varargs7(42, '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_opt_varargs7(42, '43', '44')", env: @env) }
  end

  def test_send_named_args
    # from test_type_contract.rb
    self.class.class_eval {
      type :_send_named_args1, "(x: Integer) -> Integer"
      type :_send_named_args2, "(x: Integer, y: String) -> Integer"
      type :_send_named_args3, "(Integer, y: String) -> Integer"
      type :_send_named_args4, "(Integer, x: Integer, y: String) -> Integer"
      type :_send_named_args5, "(x: Integer, y: ?String) -> Integer"
      type :_send_named_args6, "(x: ?Integer, y: String) -> Integer"
      type :_send_named_args7, "(x: ?Integer, y: ?String) -> Integer"
      type :_send_named_args8, "(?Integer, x: ?Symbol, y: ?String) -> Integer"
      type :_send_named_args9, "(Integer, x: String, y: Integer, **Float) -> Integer"
    }
    assert do_tc("_send_named_args1(x: 42)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args1(x: '42')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args1()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args1(x: 42, y: 42)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args1(y: 42)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args1(42)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args1(42, x: '42')", env: @env) }
    assert do_tc("_send_named_args2(x: 42, y: '43')", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args2()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args2(x: 42)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args2(x: '42', y: '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args2(42, '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args2(42, x: 42, y: '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args2(x: 42, y: '43', z: 44)", env: @env) }
    assert do_tc("_send_named_args3(42, y: '43')", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args3(42, y: 43)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args3()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args3(42, 43, y: 44)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args3(42, y: 43, z: 44)", env: @env) }
    assert do_tc("_send_named_args4(42, x: 43, y: '44')", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args4(42, x: 43)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args4(42, y: '43')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args4()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args4(42, 43, x: 44, y: '45')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args4(42, x: 43, y: '44', z: 45)", env: @env) }
    assert do_tc("_send_named_args5(x: 42, y: '43')", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args5(x: 42)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args5()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args5(x: 42, y: 43)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args5(x: 42, y: 43, z: 44)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args5(3, x: 42, y: 43)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args5(3, x: 42)", env: @env) }
    assert do_tc("_send_named_args6(x: 43, y: '44')", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args6(y: '44')", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args6()", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args6(x: '43', y: '44')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args6(42, x: 43, y: '44')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args6(x: 43, y: '44', z: 45)", env: @env) }
    assert do_tc("_send_named_args7()", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args7(x: 43)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args7(y: '44')", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args7(x: 43, y: '44')", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args7(x: '43', y: '44')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args7(41, x: 43, y: '44')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args7(x: 43, y: '44', z: 45)", env: @env) }
    assert do_tc("_send_named_args8()", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args8(43)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args8(x: :foo)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args8(43, x: :foo)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args8(y: 'foo')", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args8(43, y: 'foo')", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args8(x: :foo, y: 'foo')", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args8(43, x: :foo, y: 'foo')", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args8(43, 44, x: :foo, y: 'foo')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args8(43, x: 'foo', y: 'foo')", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args8(43, x: :foo, y: 'foo', z: 44)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args9", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args9(43)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args9(43, x: 'foo')", env: @env) }
    assert do_tc("_send_named_args9(43, x:'foo', y: 44)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args9(43, x:'foo', y: 44, pi: 3.14)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("_send_named_args9(43, x:'foo', y: 44, pi: 3.14, e: 2.72)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args9(43, x: 'foo', y: 44, pi: 3)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_named_args9(43, x: 'foo', y: 44, pi: 3.14, e: 3)", env: @env) }
  end

  def test_send_singleton
    RDL.type Integer, :_send_singleton, "() -> String"
    assert do_tc("3._send_singleton", env: @env) <= RDL::Globals.types[:string]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("3._send_singleton_nexists", env: @env) }
  end

  def test_send_generic
    assert do_tc("[1,2,3].length", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("{a:1, b:2}.length", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("String.new.clone", env: @env) <= RDL::Globals.types[:string]
    # TODO test case with other generic
  end

  def test_send_alias
    assert do_tc("[1,2,3].size", env: @env) <= RDL::Globals.types[:integer]
  end

  def test_send_block
    self.class.class_eval {
      type :_send_block1, "(Integer) { (Integer) -> Integer } -> Integer"
      type :_send_block2, "(Integer) -> Integer"
    }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_block1(42)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_block2(42) { |x| x + 1 }", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_block1(42) { |x, y| x + y }", env: @env) }
    assert do_tc("_send_block1(42) { |x| x }", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_send_block1(42) { |x| 'forty-two' }", env: @env) }
    self.class.class_eval {
      type "() -> 1", typecheck: :now
      def _send_blockd1
        x = 1; _send_block1(42) { |y| x }; x
      end
    }
    self.class.class_eval {
      type "() -> 1 or String", typecheck: :now
      def _send_blockd2
        x = 1; _send_block1(42) { |y| x = 'one'; y}; x
      end
    }
    self.class.class_eval {
      type "() -> Integer or String", typecheck: :now
      def _send_blockd3
        x = 'one'; _send_block1(42) { |y| for x in 1..5 do end; y }; x
      end
    }
  end

  def test_send_method_generic
    self.class.class_eval {
      type :_send_method_generic1, '(t) -> t'
      type :_send_method_generic2, '(t, u) -> t or u'
      type :_send_method_generic3, '() { (u) -> Integer } -> Integer'
      type :_send_method_generic4, '(t) { (t) -> t } -> t'
      type :_send_method_generic5, '() { (u) -> u } -> u'
      type :_send_method_generic6, '() { (Integer) -> u } -> u'
    }    
    assert do_tc('_send_method_generic1 3', env: @env) <= @t3
    assert do_tc('_send_method_generic1 "foo"', env: @env) <= RDL::Globals.types[:string]
    assert do_tc('_send_method_generic2 3, "foo"', env: @env) <= tt("3 or String")
    assert do_tc('_send_method_generic3 { |x| 42 }', env: @env) <= RDL::Globals.types[:integer]
    assert do_tc('_send_method_generic4(42) { |x| x }', env: @env) <= tt("42")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc('_send_method_generic4(42) { |x| "foo" }', env: @env) }
    assert do_tc('_send_method_generic5 { |x| x }', env: @env) <= tt("u") # not possible to implement _send_method_generic5!
    assert do_tc('_send_method_generic5 { |x| 3 }', env: @env) <= tt("3") # weird example, but can pick u=3
    assert do_tc('_send_method_generic6 { |x| "foo" }', env: @env) <= RDL::Globals.types[:string]
    assert do_tc('[1,2,3].index(Object.new)', env: @env) <= tt("Integer")
    assert do_tc('[1, 2, 3].map { |y| y.to_s }', env: @env) <= tt("Array<String>")
  end

  def test_send_union
    self.class.class_eval {
      type :_send_union1, "(Integer) -> Float"
      type :_send_union1, "(String) -> Rational"
    }
    assert do_tc("(if _any_object then Integer.new else String.new end) * 2", env: @env) <= RDL::Type::UnionType.new(@tfs, RDL::Globals.types[:integer])
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("(if _any_object then Object.new else Integer.new end) + 2", env: @env) }
    assert do_tc("if _any_object then x = Integer.new else x = String.new end; _send_union1(x)", env: @env) <= tt("Float or Rational")
  end

  def test_send_splat
    self.class.class_eval {
      type :_send_splat1, "(Integer, String, Integer, String) -> Integer"
      type :_send_splat2, "(String, *Integer, Float) -> Integer"
      type :_send_splat_fa, "() -> Array<Integer>"
    }
    assert do_tc("x = ['foo', 42]; _send_splat1(1, *x, 'bar')", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("x = _send_splat_fa; _send_splat2('foo', *x, 3.14)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x = _send_splat_fa; _send_splat1(*x, 'foo', 2, 'bar')", env: @env) }
  end


  def test_yield
    self.class.class_eval {
      type "(Integer) { (Integer) -> Integer } -> Integer", typecheck: :now
      def _yield1(x)
        yield x
      end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) { (Integer) -> Integer } -> Integer", typecheck: :now
        def _yield2(x)
          yield 'forty-two'
        end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) { (Integer) -> String } -> Integer", typecheck: :now
        def _yield3(x)
          yield 42
        end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) -> Integer", typecheck: :now
        def _yield4(x)
          yield 42
        end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) { (Integer) { (Integer) -> Integer } -> Integer } -> Integer", typecheck: :now
        def _yield5(x)
          yield 42
        end
      }
    }
  end

  def test_block_arg
    self.class.class_eval {
      type "(Integer) { (Integer) -> Integer } -> Integer", typecheck: :now
      def _block_arg1(x, &blk)
        blk.call x
      end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) { (Integer) -> Integer } -> Integer", typecheck: :now
        def _block_arg2(x, &blk)
          blk.call 'forty-two'
        end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) { (Integer) -> String } -> Integer", typecheck: :now
        def _block_arg3(x, &foo)
          foo.call 42
        end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) -> Integer", typecheck: :now
        def _block_arg4(x, &blk)
          blk.call 42
        end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) { (Integer) { (Integer) -> Integer } -> Integer } -> Integer", typecheck: :now
        def _block_arg5(x, &blk)
          blk.call 42
        end
      }
    }

    self.class.class_eval {
      type :_block_arg6, "(Integer) { (Integer) -> Integer } -> Integer"
      type "() { (Integer) -> Integer } -> Integer", typecheck: :now
      def _block_arg7(&blk)
        _block_arg6(42, &blk)
      end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() { (Integer) -> String } -> Integer", typecheck: :now
        def _block_arg8(&blk)
          _block_arg6(42, &blk)
        end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "() -> Integer", typecheck: :now
        def _block_arg9()
          _block_arg6(42, &(1+2))
        end
      }
    }

    self.class.class_eval {
      type :_block_arg10, "(Integer) -> Integer"
      type :_block_arg11, "(Integer) -> String"
    }
    assert do_tc("_block_arg6(42, &:_block_arg10)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_block_arg6(42, &:_block_arg11)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("_block_arg6(42, &:_block_arg_does_not_exist)", env: @env) }
  end

  # class Sup1
  #   type '(Integer) -> Integer', typecheck: :call
  #   def foo(y)
  #     return y
  #   end
  # end
  #
  # class Sup2 < Sup1
  #   type '(Integer) -> Integer', typecheck: :call
  #   def foo(x)
  #     super(x+1)
  #   end
  # end
  #
  # def test_super
  #   assert_equal 43, Sup2.new.foo(42)
  # end

  def test_new
    assert do_tc("B.new", env: @env) <= RDL::Type::NominalType.new(TestTypecheck::B)
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("B.new(3)", env: @env) }
  end

  def test_if
    assert do_tc("if _any_object then 3 end", env: @env) <= @t3n
    assert do_tc("unless _any_object then 3 end", env: @env) <= @t3n
    assert do_tc("if _any_object then 3 else 4 end", env: @env) <= @t34
    assert do_tc("unless _any_object then 3 else 4 end", env: @env) <= @t34
    assert do_tc("if _any_object then 3 else 'three' end", env: @env) <= @ts3
    assert do_tc("unless _any_object then 3 else 'three' end", env: @env) <= @ts3
    assert do_tc("3 if _any_object", env: @env) <= @t3n
    assert do_tc("3 unless _any_object", env: @env) <= @t3n
    assert do_tc("if true then 3 else 'three' end", env: @env) <= @t3
    assert do_tc("if :foo then 3 else 'three' end", env: @env) <= @t3
    assert do_tc("if false then 3 else 'three' end", env: @env) <= RDL::Globals.types[:string]
    assert do_tc("if nil then 3 else 'three' end", env: @env) <= RDL::Globals.types[:string]

    assert do_tc("x = 'three'; if _any_object then x = 4 else x = 5 end; x", env: @env) <= @t45
    assert do_tc("x = 'three'; if _any_object then x = 3 end; x", env: @env) <= @ts3
    assert do_tc("x = 'three'; unless _any_object then x = 3 end; x", env: @env) <= @ts3
    assert do_tc("if _any_object then y = 4 end; y", env: @env) # vars are nil if not defined on branch <= @t4n
    assert do_tc("if _any_object then x = 3; y = 4 else x = 5 end; x", env: @env) <= @t35
    assert do_tc("if _any_object then x = 3; y = 4 else x = 5 end; y", env: @env) <= @t4n
  end

  def test_and_or
    assert do_tc("'foo' and 3") <= @ts3
    assert do_tc("'foo' && 3") <= @ts3
    assert do_tc("3 and 'foo'") <= RDL::Globals.types[:string]
    assert do_tc("nil and 'foo'") <= RDL::Globals.types[:nil]
    assert do_tc("false and 'foo'") <= RDL::Globals.types[:false]
    assert do_tc("(x = 'foo') and (x = 3); x") <= @ts3
    assert do_tc("(x = 3) and (x = 'foo'); x") <= RDL::Globals.types[:string]
    assert do_tc("(x = nil) and (x = 'foo'); x") <= RDL::Globals.types[:nil]
    assert do_tc("(x = false) and (x = 'foo'); x") <= RDL::Globals.types[:false]

    assert do_tc("'foo' or 3") <= @ts3
    assert do_tc("'foo' || 3") <= @ts3
    assert do_tc("3 or 'foo'") <= @t3
    assert do_tc("nil or 3") <= @t3
    assert do_tc("false or 3") <= @t3
    assert do_tc("(x = 'foo') or (x = 3); x") <= @ts3
    assert do_tc("(x = 3) or (x = 'foo'); x") <= @t3
    assert do_tc("(x = nil) or (x = 3); x") <= @t3
    assert do_tc("(x = false) or (x = 3); x") <= @t3
  end

  class C
    extend RDL::Annotate
    type :===, "(Object) -> %bool"
  end

  class D
    extend RDL::Annotate
    type :===, "(String) -> %bool"
  end

  def test_when
    assert do_tc("case when C.new then 3 end", env: @env) <= @t3
    assert do_tc("x = 4; case when _any_object then x = 3 end; x", env: @env) <= @t34
    assert do_tc("case when _any_object then 3 else 'foo' end", env: @env) <= @ts3
    assert do_tc("x = 4; case when _any_object then x = 3 else x = 'foo' end; x", env: @env) <= @ts3

    assert do_tc("case _any_object when C.new then 'foo' end", env: @env) <= RDL::Globals.types[:string]
    assert do_tc("x = 3; case _any_object when C.new then x = 'foo' end; x", env: @env) <= @ts3
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("case _any_object when D.new then 'foo' end", env: @env) }
    assert do_tc("case _any_object when C.new then 'foo' else 3 end", env: @env) <= @ts3
    assert do_tc("x = 4; case _any_object when C.new then x = 'foo' else x = 3 end; x", env: @env) <= @ts3
    assert do_tc("case _any_object when C.new then 'foo' when C.new then 4 else 3 end", env: @env) <= @ts34
    assert do_tc("x = 5; case _any_object when C.new then x = 'foo' when C.new then x = 4 else x = 3 end; x", env: @env) <= @ts34

    assert do_tc("case when (x = 3) then 'foo' end; x", env: @env) <= @t3
    assert do_tc("case when (x = 3), (x = 4) then 'foo' end; x", env: @env) <= @t34
    assert do_tc("case when (x = 3), (x = 4) then 'foo' end; x", env: @env) <= @t34
    assert do_tc("case when (x = 4) then x = 3 end; x", env: @env) <= @t34
    assert do_tc("x = 5; case when (x = 3) then 'foo' when (x = 4) then 'foo' end; x", env: @env) # first guard always executed! <= @t34
    assert do_tc("x = 6; case when (x = 3) then 'foo' when (x = 4) then 'foo' else x = 5 end; x", env: @env) <= @t345
  end

  def test_while_until
    # TODO these don't do a great job checking control flow
    assert do_tc("while true do end") <= RDL::Globals.types[:nil]
    assert do_tc("until false do end") <= RDL::Globals.types[:nil]
    assert do_tc("begin end while true") <= RDL::Globals.types[:nil]
    assert do_tc("begin end until false") <= RDL::Globals.types[:nil]

    assert do_tc("i = 0; while i < 5 do i = 1 + i end; i") <= RDL::Globals.types[:integer]
    assert do_tc("i = 0; while i < 5 do i = i + 1 end; i") <= RDL::Globals.types[:integer]
    assert do_tc("i = 0; until i >= 5 do i = 1 + i end; i") <= RDL::Globals.types[:integer]
    assert do_tc("i = 0; until i >= 5 do i = i + 1 end; i") <= RDL::Globals.types[:integer]
    assert do_tc("i = 0; begin i = 1 + i end while i < 5; i") <= RDL::Globals.types[:integer]
    assert do_tc("i = 0; begin i = i + 1 end while i < 5; i") <= RDL::Globals.types[:integer]
    assert do_tc("i = 0; begin i = 1 + i end until i >= 5; i") <= RDL::Globals.types[:integer]
    assert do_tc("i = 0; begin i = i + 1 end until i >= 5; i") <= RDL::Globals.types[:integer]

    # break, redo, next, no args
#    assert do_tc("i = 0; while i < 5 do if i > 2 then break end; i = 1 + i end; i") <= RDL::Globals.types[:integer]
#    assert do_tc("i = 0; while i < 5 do break end; i") <= tt("0")
#    assert do_tc("i = 0; while i < 5 do redo end; i") # infinite loop, ok for typing <= tt("0")
#     assert do_tc("i = 0; while i < 5 do next end; i") # infinite loop, ok for typing <= tt("0")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("i = 0; while i < 5 do retry end; i") }
    assert do_tc("i = 0; begin i = i + 1; break if i > 2; end while i < 5; i") <= RDL::Globals.types[:integer]
    assert do_tc("i = 0; begin i = i + 1; redo if i > 2; end while i < 5; i") <= RDL::Globals.types[:integer]
    assert do_tc("i = 0; begin i = i + 1; next if i > 2; end while i < 5; i") <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("i = 0; begin i = i + 1; retry if i > 2; end while i < 5; i") }

    # break w/arg, next can't take arg
    assert do_tc("while _any_object do break 3 end", env: @env) <= @t3n
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("while _any_object do next 3 end", env: @env) }
    assert do_tc("begin break 3 end while _any_object", env: @env) <= @t3n
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("begin next 3 end while _any_object", env: @env) }

  end

  def test_for
    assert do_tc("for i in 1..5 do end; i") <= RDL::Globals.types[:integer]
    assert do_tc("for i in [1,2,3,4,5] do end; i") <= tt("1 or 2 or 3 or 4 or 5")
    ## TODO: figure out why above fails to terminate
    assert do_tc("for i in 1..5 do break end", env: @env) <= tt("Range<Integer>")
    assert do_tc("for i in 1..5 do next end", env: @env) <= tt("Range<Integer>")
    assert do_tc("for i in 1..5 do redo end", env: @env) <= tt("Range<Integer>") #infinite loop, ok for typing
    assert do_tc("for i in 1..5 do break 3 end", env: @env) <= tt("Range<Integer> or 3")
    assert do_tc("for i in 1..5 do next 'three' end; i", env: @env) <= @tfs
  end

  def test_return
    assert self.class.class_eval {
      type "(Integer) -> Integer", typecheck: :now
      def return_ff(x)
        return 42
      end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) -> Integer", typecheck: :now
        def return_ff2(x)
          return "forty-two"
        end
      }
    }

    assert do_tc("return 42", scope: @scopefs) <= RDL::Globals.types[:bot]
    assert do_tc("if _any_object then return 42 else return 'forty-two' end", env: @env, scope: @scopefs) <= RDL::Globals.types[:bot]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("if _any_object then return 42 else return 'forty-two' end", env: @env, scope: @scopef) }
    assert do_tc("return 42 if _any_object; 'forty-two'", env: @env, scope: @scopef) <= RDL::Globals.types[:string]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("return 'forty-two' if _any_object; 42", env: @env, scope: @scopef) }
  end

  class E
    extend RDL::Annotate
    type :f, '() -> Integer'
    type :f=, '(Integer) -> nil'
  end

  def test_op_asgn
    assert RDL::Globals.types[:integer], do_tc("x = 0; x += 1")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x += 1") }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x = Object.new; x += 1", env: @env) }
    assert do_tc("e = E.new; e.f += 1", env: @env) <= RDL::Globals.types[:nil] # return type of f=
    assert do_tc("x &= false") <= RDL::Globals.types[:false] # weird
    assert do_tc("h = {}; h = RDL.type_cast(h, 'Hash<Symbol, String>', force: true); h[:a] = ''; h[:a] += 's'", env: @env) <= RDL::Globals.types[:string]
  end

  def test_and_or_asgn
    self.class.class_eval {
      var_type :@f_and_or_asgn, "Integer"
    }
    assert do_tc("x ||= 3") <= @t3 # weird
    assert do_tc("x &&= 3") <= RDL::Globals.types[:nil] # weirder
    assert do_tc("@f_and_or_asgn &&= 4", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("x = 3; x ||= 'three'") <= @t3
    assert do_tc("x = 'three'; x ||= 3") <= @ts3
    assert do_tc("e = E.new; e.f ||= 3", env: @env) <= RDL::Globals.types[:nil] # return type of f=
    assert do_tc("e = E.new; e.f &&= 3", env: @env) <= RDL::Globals.types[:nil] # return type of f=
  end

  def test_masgn
    self.class.class_eval {
      var_type :@f_masgn, "Array<Integer>"
    }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x, y = 3") } # allowed in Ruby but probably has surprising behavior
    assert do_tc("a, b = @f_masgn", env: @env) <= tt("Array<Integer>")
    assert do_tc("a, b = @f_masgn; a", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("a, b = @f_masgn; b", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("var_type :a, 'String'; a, b = @f_masgn", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("a, b = 1, 2, 3") }
    assert do_tc("a, b = 3, 'two'; a") <= @t3
    assert do_tc("a, b = 3, 'two'; b") <= RDL::Globals.types[:string]
    assert do_tc("a = [3, 'two']; x, y = a; x") <= @t3
    assert do_tc("a = [3, 'two']; x, y = a; y") <= RDL::Globals.types[:string]
    #assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("a = [3, 'two']; x, y = a; a.length", env: @env) }
    ## the above works after computational type changes

    # w/send
    assert do_tc("e = E.new; e.f, b = 1, 2; b", env: @env) <= tt("2")
    assert do_tc("e = E.new; e.f, b = @f_masgn; b", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("@f_masgn[3], y = 1, 2", env: @env) <= tt("[1, 2]")

    # w/splat
   assert do_tc("*x = [1, 2, 3]") <= tt("[1, 2, 3]")
   assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("*x = 1") } # allowed in Ruby, but why would you write this code?

    # w/splat on right
    assert do_tc("x, *y = [1, 2, 3]; x") <= tt("1")
    assert do_tc("x, *y = [1, 2, 3]; y") <= tt("[2, 3]")
    assert do_tc("x, *y = [1]; x") <= tt("1")
    assert do_tc("x, *y = [1]; y") <= tt("[]")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x, *y = 1") } # allowed in Ruby, but hard to justify, so RDL error
    assert do_tc("x, *y = @f_masgn; x", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("x, *y = @f_masgn; y", env: @env) <= tt("Array<Integer>")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x, y, *z = [1]") } # works in Ruby, but confusing so RDL reports error

    # w/splat on left
    assert do_tc("*x, y = [1, 2, 3]; x") <= tt("[1, 2]")
    assert do_tc("*x, y = [1, 2, 3]; y") <= tt("3")
    assert do_tc("*x, y = [1]; x") <= tt("[]")
    assert do_tc("*x, y = [1]; y") <= tt("1")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("*x, y = 1") } # as above
    assert do_tc("*x, y = @f_masgn; x", env: @env) <= tt("Array<Integer>")
    assert do_tc("*x, y = @f_masgn; y", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("*x, y, z = [1]") } # as above

    # w/splat in middle
    assert do_tc("x, *y, z = [1, 2]; x") <= tt("1")
    assert do_tc("x, *y, z = [1, 2]; y") <= tt("[]")
    assert do_tc("x, *y, z = [1, 2]; z") <= tt("2")
    assert do_tc("x, *y, z = [1, 2, 3, 4]; x") <= tt("1")
    assert do_tc("x, *y, z = [1, 2, 3, 4]; y") <= tt("[2, 3]")
    assert do_tc("x, *y, z = [1, 2, 3, 4]; z") <= tt("4")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x, *y, z = 1") } # as above
    assert do_tc("x, *y, z = @f_masgn; x", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("x, *y, z = @f_masgn; y", env: @env) <= tt("Array<Integer>")
    assert do_tc("x, *y, z = @f_masgn; z", env: @env) <= RDL::Globals.types[:integer]
  end

  def test_cast
    assert do_tc("RDL.type_cast(1 + 2, 'Integer')", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("RDL.type_cast(1, 'Integer', 42)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("RDL.type_cast(1, Integer)", env: @env) }
    assert do_tc("RDL.type_cast(1 + 2, 'Integer', force: true)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("RDL.type_cast(1 + 2, 'Integer', force: false)", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("RDL.type_cast(1 + 2, 'Integer', force: :blah)", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("RDL.type_cast(1 + 2, 'Integer', forc: true)", env: @env) }
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("RDL.type_cast(1 + 2, 'Fluffy Bunny')") }
  end

  def test_instantiate
    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer, Integer) -> Array<Integer>", typecheck: :now
        def def_inst_fail(x, y) a = Array.new(x,y); a; end
      }
    }
    assert (
      self.class.class_eval {
        type "(Integer, Integer) -> Array<Integer>", typecheck: :now
        def def_inst_pass(x, y) a = Array.new(x,y); RDL.instantiate!(a, "Integer"); a; end
      }
    )

    # below works with computational types
    #assert_raises(RDL::Typecheck::StaticTypeError) {
    assert (
      self.class.class_eval {
        type "(Integer) -> Integer", typecheck: :now
        def def_inst_hash_fail(x) hash = {}; hash["test"] = x; hash["test"]; end
      }
    )
#     }

=begin
   # below works with computational types
    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) -> Integer", typecheck: :now
        def def_inst_hash_fail2(x) hash = {}; hash.instantiate("Integer", "String") ; hash["test"] = x; hash["test"]; end
      }
    }
=end
    assert(
      self.class.class_eval {
        type "(Integer) -> Integer", typecheck: :now
        def def_inst_hash_pass(x) hash = {}; RDL.instantiate!(hash, String, Integer); hash["test"] = x; hash["test"]; end
      }
    )
    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) -> Integer", typecheck: :now
        def def_inst_no_param(x) RDL.instantiate!(x, Integer); end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Integer) -> Integer", typecheck: :now
        def def_inst_num_args(x) a = Array.new(x, x); RDL.instatntiate!(a, Integer, Integer, Integer); end
      }
    }
  end

  def test_rescue_ensure

    assert do_tc("begin 3; rescue; 4; end") <= @t3 # rescue clause can never be executed
    assert do_tc("begin puts 'foo'; 3; rescue; 4; end", env: @env) <= @t34
    assert do_tc("begin puts 'foo'; 3; rescue => e; e; end", env: @env) <= tt("StandardError or 3")
    assert do_tc("begin puts 'foo'; 3; rescue RuntimeError => e; e; end", env: @env) <= tt("RuntimeError or 3")
    assert do_tc("begin puts 'foo'; 3; else; 4; end", env: @env) <= tt("4") # parser discards else clause!
    assert do_tc("begin puts 'foo'; 3; rescue RuntimeError => e; e; rescue ArgumentError => x; x; end", env: @env) <= tt("RuntimeError or ArgumentError or 3")
    assert do_tc("begin puts 'foo'; 3; rescue RuntimeError => e; e; rescue ArgumentError => x; x; else 42; end", env: @env) <= tt("RuntimeError or ArgumentError or 42 or 3")
    assert do_tc("begin puts 'foo'; 3; rescue RuntimeError, ArgumentError => e; e; end", env: @env) <= tt("RuntimeError or ArgumentError or 3")
    assert do_tc("tries = 0; begin puts 'foo'; x = 1; rescue; tries = tries + 1; retry unless tries > 5; x = 'one'; end; x", env: @env) <= tt("1 or String")
    assert do_tc("begin 3; ensure 4; end", env: @env) <= @t3
    assert do_tc("begin x = 3; ensure x = 4; end; x", env: @env) <= @t4
    assert do_tc("begin puts 'foo'; x = 3; rescue; x = 4; ensure x = 5; end; x", env: @env) <= @t5
    assert do_tc("begin puts 'foo'; 3; rescue; 4; ensure 5; end", env: @env) <= @t34

  end

  class SubArray < Array
  end

  class SubHash < Hash
  end

  def test_array_splat
    self.class.class_eval {
      type :_splataf, "() -> Array<Integer>"
      type :_splatas, "() -> Array<String>"
      type :_splathsf, "() -> Hash<Symbol, Integer>"
    }
    assert do_tc("x = *1") <= tt("[1]")
    assert do_tc("x = [1, *2, 3]") <= tt("[1, 2, 3]")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x = [1, *Object.new, 3]", env: @env) } # the Object might or might not be an array...
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x = [1, *SubArray.new, 3]", env: @env) } # the SubArray is an Array, but unclear how to splat
    assert do_tc("x = *[1]") <= tt("[1]")
    assert do_tc("x = *[1, 2, 3]") <= tt("[1, 2, 3]")
    assert do_tc("x = [1, *[2], 3]") <= tt("[1, 2, 3]")
    assert do_tc("x = [1, *[2, 3], 4]") <= tt("[1, 2, 3, 4]")
    assert do_tc("x = [1, *[2, *[3]], 4]") <= tt("[1, 2, 3, 4]")
    assert do_tc("x = [1, [2, *[3]], 4]") <= tt("[1, [2, 3], 4]")
    assert do_tc("x = [*[1,2], *[3,4]]") <= tt("[1, 2, 3, 4]")
    assert do_tc("x = *nil") <= tt("[]")
    assert do_tc("x = [1, *nil, 2]") <= tt("[1, 2]")
    assert do_tc("x = *{a: 1}") <= tt("[[:a, 1]]")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x = [1, *SubHash.new, 3]", env: @env) } # the SubHash is an Hash, but unclear how to splat
    assert do_tc("x = *{a: 1, b: 2, c: 3}") <= tt("[[:a, 1], [:b, 2], [:c, 3]]")
    assert do_tc("x = [1, *{a: 2}, 3]") <= tt("[1, [:a, 2], 3]")
    assert do_tc("y = [2]; x = [1, *y, 3]; ") <= tt("[1, 2, 3]")
    #assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("y = [2]; x = [1, *y, 3]; y.length") }
    # the above works after computational type changes
    assert do_tc("y = {a: 2}; x = [1, *y, 3]") <= tt("[1, [:a, 2], 3]")
    #assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("y = {a: 2}; x = [1, *y, 3]; y.length") }
    # the above works after computational type changes

    assert do_tc("x = *_splataf", env: @env) <= tt("Array<Integer>")
    assert do_tc("x = [1, *_splataf, 2]", env: @env) <= tt("Array<Integer>")
    assert do_tc("x = [*_splataf, *_splataf]", env: @env) <= tt("Array<Integer>")
    assert do_tc("x = [*_splataf, *_splatas]", env: @env) <= tt("Array<Integer or String>")
    assert do_tc("x = [1, *_splataf, 2, *_splatas, 3]", env: @env) <= tt("Array<Integer or String>")
    assert do_tc("x = [1, *_splataf, 2, *_splatas, 3.0]", env: @env) <= tt("Array<Integer or String or 3.0>")
    assert do_tc("x = *_splathsf", env: @env) <= tt("Array<[Symbol, Integer]>")
    assert do_tc("x = [1, *_splathsf, 3]", env: @env) <= tt("Array<1 or 3 or [Symbol, Integer]>")
  end

  def test_hash_kwsplat
    self.class.class_eval {
      type :_kwsplathsf, "() -> Hash<Symbol, Integer>"
      type :_kwsplathos, "() -> Hash<Float, String>"
    }
    assert do_tc("x = {a: 1, **{b: 2}}") <= tt("{a: 1, b: 2}")
    assert do_tc("x = {a: 1, **{}}") <= tt("{a: 1}")
    assert do_tc("x = {a: 1, **{b: 2}, c: 3}") <= tt("{a: 1, b: 2, c: 3}")
    assert do_tc("x = {a: 1, **{b: 2}, **{c: 3}}") <= tt("{a: 1, b: 2, c: 3}")
    assert do_tc("x = {a: 1, **{b: 2, c: 3}}") <= tt("{a: 1, b: 2, c: 3}")
    assert do_tc("x = {**{a: 1}, b: 2, **{c: 3}}") <= tt("{a: 1, b: 2, c: 3}")
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x = {a: 1, **Object.new}", env: @env) } # may or may not be hash
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("x = {a: 1, **SubHash.new}", env: @env) } # is a how, but unclear how to splat
    #assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("y = {b: 2}; x = {a: 1, **y}; y.length") }
    # the above works after computational type changes

    assert do_tc("x = {**_kwsplathsf}", env: @env) <= tt("Hash<Symbol, Integer>")
    assert do_tc("x = {**_kwsplathsf, **_kwsplathos}", env: @env) <= tt("Hash<Symbol or Float, Integer or String>")
    assert do_tc("x = {a: 1, **_kwsplathsf, b: 2}", env: @env) <= tt("Hash<Symbol, Integer>")
    assert do_tc("x = {'a' => 1, **_kwsplathsf, b: 'two'}", env: @env) <= tt("Hash<Symbol or String, Integer or String>")
  end

  def test_attr_etc
    self.class.class_eval {
      attr_reader_type :f_attr_reader, "Integer", :f_attr_reader2, "String"
      attr_writer_type :f_attr_writer, "Integer"
      attr_type :f_attr, "Integer"
      attr_accessor_type :f_attr_accessor, "Integer"
    }
    assert do_tc("@f_attr_reader", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("TestTypecheck.new.f_attr_reader", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("TestTypecheck.new.f_attr_reader = 4", env: @env) }
    assert do_tc("@f_attr_reader2", env: @env) <= RDL::Globals.types[:string]
    assert do_tc("TestTypecheck.new.f_attr_reader2", env: @env) <= RDL::Globals.types[:string]

    assert do_tc("@f_attr", env: @env) # same as attr_reader <= RDL::Globals.types[:integer]
    assert do_tc("TestTypecheck.new.f_attr", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("TestTypecheck.new.f_attr = 42", env: @env) }

    assert do_tc("@f_attr_writer = 3", env: @env) <= @t3
    assert do_tc("TestTypecheck.new.f_attr_writer = 3", env: @env) <= RDL::Globals.types[:integer]
    assert_raises(RDL::Typecheck::StaticTypeError) { do_tc("TestTypecheck.new.f_attr_writer", env: @env) }

    assert do_tc("@f_attr_accessor", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("TestTypecheck.new.f_attr_accessor", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("TestTypecheck.new.f_attr_accessor = 42", env: @env) <= RDL::Globals.types[:integer]
  end

  # test code where we know different stuff about types on difference branches
  def test_typeful_branches
    assert do_tc("x = Object.new; case x when String; x.length; end", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("x = Object.new; case x when String, Array; x.length; end", env: @env) <= RDL::Globals.types[:integer]
    assert do_tc("x = String.new; case x when String; 3; when Integer; 4; end", env: @env) <= @t3
  end

  def test_context_typecheck
    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '() -> Integer', typecheck: :now
        def context_typecheck1
          context_tc_in_context1 # should fail
        end
      }
    }
    RDL::Globals.info.add(self.class, :context_typecheck2, :context_types, [self.class, :context_tc_in_context2, RDL::Globals.parser.scan_str('() -> Integer')])
    self.class.class_eval {
      type '() -> Integer', typecheck: :now
      def context_typecheck2
        context_tc_in_context2 # should not fail since method defined in context
      end
    }
  end

  def test_optional_varargs_mapping
    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(?Integer) -> Integer', typecheck: :now
        def _optional_varargs_mapping1(x)
          42
        end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(Integer) -> Integer', typecheck: :now
        def _optional_varargs_mapping2(x=42)
          x
        end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(*Integer) -> Integer', typecheck: :now
        def _optional_varargs_mapping3(x=42)
          x
        end
      }
    }

    self.class.class_eval {
      type '(?Integer) -> Integer', typecheck: :now
      def _optional_varargs_mapping4(x=42)
        x
      end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(?Integer) -> Integer', typecheck: :now
        def _optional_varargs_mapping5(x='forty-two')
          42
        end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(Integer) -> Integer', typecheck: :now
        def _optional_varargs_mapping6(*x)
          42
        end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(?Integer) -> Integer', typecheck: :now
        def _optional_varargs_mapping7(*x)
          42
        end
      }
    }

    self.class.class_eval {
      type '(*Integer) -> Array<Integer>', typecheck: :now
      def _optional_varargs_mapping8(*x)
        x
      end
    }

    self.class.class_eval {
      type '(?Integer x) -> Integer', typecheck: :now
      def _optional_varargs_mapping9(x=42)
        x
      end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(?Integer x) -> Integer', typecheck: :now
        def _optional_varargs_mapping10(x='hi')
          x
        end
      }
    }

  end

  def test_kw_mapping
    self.class.class_eval {
      type '(kw: Integer) -> Integer', typecheck: :now
      def _kw_mapping1(kw:)
        kw
      end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(Integer) -> Integer', typecheck: :now
        def _kw_mapping2(kw:)
          kw
        end
      }
    }

    self.class.class_eval {
      type '(kw: Integer) -> Integer', typecheck: :now
      def _kw_mapping3(kw_args) # slightly awkward example
        kw_args[:kw]
      end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(kw: Integer) -> Integer', typecheck: :now
        def _kw_mapping4(kw: 42)
          kw
        end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(kw: ?Integer) -> Integer', typecheck: :now
        def _kw_mapping5(kw:)
          kw
        end
      }
    }

    self.class.class_eval {
      type '(kw: ?Integer) -> Integer', typecheck: :now
      def _kw_mapping6(kw: 42)
        kw
      end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(kw: ?Integer) -> Integer', typecheck: :now
        def _kw_mapping7(kw: 'forty-two')
          kw
        end
      }
    }

    self.class.class_eval {
      type '(kw1: Integer, kw2: Integer) -> Integer', typecheck: :now
      def _kw_mapping8(kw1:, kw2:)
        kw1
      end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(kw1: Integer, kw2: Integer, kw3: Integer) -> Integer', typecheck: :now
        def _kw_mapping9(kw2:)
          kw1
        end
      }
    }

    self.class.class_eval {
      type '(kw1: Integer, kw2: Integer, **String) -> String', typecheck: :now
      def _kw_mapping10(kw1:, kw2:, **kws)
        kws[:foo]
      end
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(kw1: Integer, kw2: Integer) -> String', typecheck: :now
        def _kw_mapping11(kw1:, kw2:, **kws)
          kws[:foo]
        end
      }
    }

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(kw1: Integer, kw2: Integer, **String) -> Integer', typecheck: :now
        def _kw_mapping12(kw1:, kw2:)
          kw1
        end
      }
    }

  end

  def test_class_call
    TestTypecheckE.class_eval {
      type '(Integer) -> Class', typecheck: :now
      def call_class1(x)
        x.class
      end
      type '() -> TestTypecheckE', typecheck: :now
      def call_class2
        self.class.new(1)
      end
    }
    t = do_tc("3.14.class", env: @env)
    assert t <= RDL::Type::SingletonType.new(Float)
    t2 = do_tc("TestTypecheckE.class", env: @env)
    assert t2 <= RDL::Type::SingletonType.new(Class)
    t3 = do_tc("[1,2,3].class", env: @env)
    assert t3 <= RDL::Type::SingletonType.new(Array)
  end

  def test_singleton
    assert_equal ':A', do_tc("TestTypecheckC.foo", env: @env).to_s
    assert_equal ':B', do_tc("TestTypecheckM.foo", env: @env).to_s
  end

  def test_annotated_ret
    assert do_tc("TestTypecheckC.bar", env: @env) <= tt('Integer or String')
  end

  def test_constructor
    t = do_tc("TestTypecheckC.new(1)", env: @env)
    assert_equal 'TestTypecheckC', t.to_s


    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type '(Integer) -> Integer', typecheck: :now
        def self.def_bad_new_call(x)
          TestTypecheckC.new()
          x
        end
      }
    }

    RDL.do_typecheck :einit

    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :finit }

    t = do_tc("TestTypecheckD.new", env: @env)
    t2 = RDL::Type::NominalType.new TestTypecheckD
    assert_equal t2, t

    self.class.class_eval {
      type '(Integer) -> Integer', typecheck: :now
      def self.def_call_to_initialize(x)
        c = TestTypecheckC.new(x)
        c.foo
      end
    }
  end

  def test_nil_return
    self.class.class_eval {
      type "(%any) -> NilClass", typecheck: :now
      def self.def_nil_ret(x) return; end
    }
    self.class.class_eval {
      type "(Integer) -> :A or NilClass", typecheck: :now
      def self.def_nil_ret_2(x)
        if x > 0
          :A
        else
          return
        end
      end
    }
  end

  def test_method_missing
    skip "method_missing not supported yet"
    RDL.do_typecheck :later_mm1
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :later_mm2 }
  end

  def test_nested
    r = N1::N2.foo
    assert_equal :sym, r

    r = N1::N2.nf
    assert_equal :sym, r

    r = N1::N2.foo2
    assert_equal :sym2, r

    r = N1::N3.new.nf3
    assert_equal :sym, r

    r = N4.foo
    assert_equal :B, r
  end

  def test_super
    self.class.class_eval "class SA0; end"
    self.class.class_eval "class SA1 < SA0; end"

    TestTypecheck::SA0.class_eval do
      extend RDL::Annotate
      def self.foo; :a0; end
      def bar(x); 1 + x; end
      def baz(x); 1 + x; end
      type 'self.foo', '() -> :a0'
      type 'bar', '(Integer) -> Integer'
      type 'baz', '(Integer) -> Integer'
    end
    TestTypecheck::SA1.class_eval do
      extend RDL::Annotate
      def self.foo; super; end
      def bar(x); super(x); end
      def baz(x); super; end
      type 'self.foo', '() -> :a0', typecheck: :call
      type :bar, '(Integer) -> Integer', typecheck: :call
      type :baz, '(Integer) -> Integer', typecheck: :call
    end

    r = TestTypecheck::SA1.foo
    assert_equal :a0, r

    r = TestTypecheck::SA1.new.bar 1
    assert_equal 2, r

    r = TestTypecheck::SA1.new.baz 1
    assert_equal 2, r
  end


  def test_case_when_nil_body
    self.class.class_eval "class A5; end"
    TestTypecheck::A5.class_eval do
      extend RDL::Annotate
      def foo(x)
        case x
        when :a
        when :b
        end
      end
      type(:foo, '(Symbol) -> NilClass', {:typecheck => :call})
    end

    assert_nil TestTypecheck::A5.new.foo(:a)
  end

  module ModuleNesting
    module Foo
      extend RDL::Annotate
      MYFOO = 'foo'
      type '() -> String', :typecheck => :call
      def self.foo
        MYFOO
      end
    end
    module Bar
      extend RDL::Annotate
      type '() -> NilClass', :typecheck => :call
      def self.bar
        TestTypecheck::ModuleNesting::Foo.foo
        Foo.foo
        Foo::MYFOO
        nil
      end
    end
    class Baz
      extend RDL::Annotate
      type '() -> NilClass', :typecheck => :call
      def self.baz
        TestTypecheck::ModuleNesting::Foo.foo
        Foo.foo
        Foo::MYFOO
        nil
      end
      type '() -> NilClass', :typecheck => :call
      def baz
        TestTypecheck::ModuleNesting::Foo.foo
        Foo.foo
        Foo::MYFOO
        nil
      end
    end

    class Parent
      MY_CONST = 'foo'
    end
    module Mixin
      MY_MIXIN_CONST = 'bar'
    end
    class Child < Parent
      include Mixin
      extend RDL::Annotate
      type '() -> String', :typecheck => :call
      def self.no_context
        MY_CONST
      end
      type '() -> String', :typecheck => :call
      def self.parent_context
        Parent::MY_CONST
      end
      type '() -> String', :typecheck => :call
      def self.mixin
        MY_MIXIN_CONST
      end
    end
  end

  def test_module_nesting
    assert_nil ModuleNesting::Bar.bar
    assert_nil ModuleNesting::Baz.baz
    assert_nil ModuleNesting::Baz.new.baz
    assert_equal 'foo', ModuleNesting::Child.no_context
    assert_equal 'foo', ModuleNesting::Child.parent_context
    assert_equal 'bar', ModuleNesting::Child.mixin
  end
    
  def test_module_fully_qualfieds_calls
    self.class.class_eval "module FullyQualfied; end"
    FullyQualfied.class_eval do
      extend RDL::Annotate
      type '() -> nil', :typecheck => :call
      def self.foo
        TestTypecheck::FullyQualfied.bar
      end
      type '() -> nil', :typecheck => :call
      def self.bar
      end
    end

    assert_nil FullyQualfied.foo
  end

  def test_grandparent_with_type
    self.class.class_eval "class GrandParentWithType; end"
    self.class.class_eval "class ParentWithoutType < GrandParentWithType; end"
    self.class.class_eval "class ChildWithoutType < ParentWithoutType; end"
    GrandParentWithType.class_eval do
      extend RDL::Annotate
      type '(Integer) -> nil', typecheck: :call
      def foo(x); end
    end

    ParentWithoutType.class_eval do
      def foo(x); end
    end

    ChildWithoutType.class_eval do
      def foo(x); end
    end

    assert_nil ChildWithoutType.new.foo(1)
  end
    
  def test_object_sing_method
    assert_raises(RDL::Typecheck::StaticTypeError) {
      Object.class_eval do
        extend RDL::Annotate
        type '(Integer) -> String', typecheck: :now
        def self.add_one(x)
          x+1
        end
      end
    }
  end
    
  def test_raise_typechecks
    self.class.class_eval "module RaiseTypechecks; end"
    RaiseTypechecks.class_eval do
      extend RDL::Annotate
      type '() -> nil', :typecheck => :call
      def self.foo
        raise "strings are good"
      end

      type '() -> nil', :typecheck => :call
      def self.bar
        raise RuntimeError.new, "so are two-args"
      end

      type '() -> nil', :typecheck => :call
      def self.baz
        raise RuntimeError, "and just class is ok"
      end
    end

    assert_raises(RuntimeError) do
      RaiseTypechecks.foo
    end
    assert_raises(RuntimeError) do
      RaiseTypechecks.bar
    end
    assert_raises(RuntimeError) do
      RaiseTypechecks.baz
    end
  end

  def test_sing_method_inheritence
    self.class.class_eval do
      type '(Integer) -> Integer', typecheck: :now
      def calls_inherited_sing_meth(x)
        SingletonInheritB.foo(x)
      end
    end
  end


  def test_comp_types
    self.class.class_eval "class CompTypes; end"
    CompTypes.class_eval do
      ### Tests where return type is computed
      extend RDL::Annotate
      type :bar, '(Integer or String) -> ``gen_return_type(targs)``'
      def self.gen_return_type(targs)
        raise RDL::Typecheck::StaticTypeError, "Unexpected number of arguments to bar." unless targs.size == 1
        if targs[0] == RDL::Globals.types[:integer]
          return RDL::Globals.types[:string]
        elsif targs[0] == RDL::Globals.types[:string]
          return RDL::Globals.types[:integer]
        else
          raise RDL::Typecheck::StaticTypeError, "Unexpected input type."
        end
      end

      type '(Integer) -> String', typecheck: :now
      def uses_bar1(x)
        bar(x)
      end

      type '(String) -> Integer', typecheck: :now
      def uses_bar2(x)
        bar(x)
      end
    end

    assert_raises(RDL::Typecheck::StaticTypeError) {
      CompTypes.class_eval do
          type '(String) -> String', typecheck: :now
          def uses_bar3(x)
            bar(x)
          end
      end
    }

    CompTypes.class_eval do
      ### Tests where input type is computed
      type :baz, '(Integer or String, ``gen_input_type(targs)``) -> Integer'

      def self.gen_input_type(targs)
        raise RDL::Typecheck::StaticTypeError, "Unexpected number of arguments to bar." unless targs.size == 2
        if targs[0] == RDL::Globals.types[:integer]
          return RDL::Globals.types[:string]
        elsif targs[0] == RDL::Globals.types[:string]
          return RDL::Globals.types[:integer]
        else
          raise RDL::Typecheck::StaticTypeError, "Unexpected input type."
        end    
      end

      type '(Integer, String) -> Integer', typecheck: :now
      def uses_baz1(x, y)
        baz(x, y)
      end

      type '(String, Integer) -> Integer', typecheck: :now
      def uses_baz2(x, y)
        baz(x, y)
      end
    end

    assert_raises(RDL::Typecheck::StaticTypeError) {
      CompTypes.class_eval do
        type '(Integer, Integer) -> Integer', typecheck: :now
        def uses_baz3(x, y)
          baz(x, y)
        end
      end
    }

  end
end
