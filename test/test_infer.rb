# frozen_string_literal: true

require 'colorize'
require 'coderay'

require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'rdl'
require 'types/core'

# Testing Inference (constraint.rb)
class TestInfer < Minitest::Test
  extend RDL::Annotate

  def setup
    RDL.reset
    RDL::Config.instance.number_mode = true # treat all numeric classes the same

    ### Uncomment below to see test names. Useful for hanging tests.
    # puts "Start #{@NAME}"
  end

  # convert a string to a method type
  def tm(typ)
    RDL::Globals.parser.scan_str('#Q ' + typ)
  end

  def infer_method_type(method)
    RDL.infer self.class, method, time: :test
    RDL.do_infer :test, render_report: false

    types = RDL::Globals.info.get 'TestInfer', method, :type
    assert types.length == 1, msg: 'Expected one solution for type'

    types[0]
  end

  def assert_type_equal(meth, expected_type)
    typ = infer_method_type meth

    ast  = RDL::Typecheck.get_ast(self.class, meth)
    code = CodeRay.scan(ast.loc.expression.source, :ruby).term

    error_str  = 'Given'.yellow + ":\n  #{code}\n\n"
    error_str += 'Expected '.green + expected_type.to_s + "\n"
    error_str += 'Got      '.red + typ.solution.to_s

    assert expected_type == typ.solution, error_str
  end

  def self.should_have_type(meth, typ)
    define_method "test_#{meth}" do
      assert_type_equal meth, tm(typ)
    end
  end

  # ----------------------------------------------------------------------------

  def return_two
    2
  end
  should_have_type :return_two, '() -> Integer'

  def return_two_plus_two
    2 + 2
  end
  should_have_type :return_two_plus_two, '() -> Integer'

  def plus_two(val)
    val + 2
  end
  should_have_type :plus_two, '([ +: (Number) -> ret ]) -> ret'

  def print_it(val)
    puts val
  end
  should_have_type :print_it, '(%dyn) -> nil'

  def return_hash
    { a: 1, b: 2, c: 3 }
  end
  should_have_type :return_hash, '() -> { a: Integer, b: Integer, c: Integer }'

  def return_hash_1
    { a: 1, b: 'b', c: :c }
  end
  should_have_type :return_hash_1, '() -> { a: Integer, b: String, c: :c }'

  def return_hash_dyn(val)
    { a: 1, b: 'b', c: val }
  end
  should_have_type :return_hash_dyn, '(val) -> { a: Integer, b: String, c: val }'

  def concatenate
    "Hello" + " World!"
  end
  should_have_type :concatenate, '() -> String'

  def concatenate_1(val)
    "Hello, " + val
  end
  should_have_type :concatenate_1, '(val) -> ret'

  def repeat
    "a" * 5
  end
  should_have_type :repeat, "() -> String"

  def repeat_n(n)
    "a" * n
  end
  should_have_type :repeat_n, "(Integer) -> String"

  def note(reason, args, ast)
    Diagnostic.new :note, reason, args, ast.loc.expression
  end
  should_have_type :note, '(reason, args, Parser::AST::Node or Parser::Source::Comment) -> Diagnostic'

  def print_note(reason, args, ast)
    puts note(reason, args, ast).render
  end
  should_have_type :print_note, '(reason, args, Parser::AST::Node or Parser::Source::Comment) -> nil'
end
