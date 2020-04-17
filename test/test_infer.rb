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

  def simple(val)
    val + 2
  end
  should_have_type :simple, '([ +: (Number) -> %dyn ]) -> %dyn'
end
