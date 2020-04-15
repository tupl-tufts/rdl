# frozen_string_literal: true

require 'pry'

require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'rdl'
require 'types/core'

# module Kernel
#   def _descc
#     ObjectSpace.each_object(Class).select { |klass| klass < self }
#   end
# end

class TestInfer < Minitest::Test
  extend RDL::Annotate

  def setup
    RDL.reset
    RDL::Config.instance.number_mode = true  # treat all numeric classes the same

    ### Uncomment below to see test names. Useful for hanging tests.
    puts "Start #{@NAME}"
  end

  # # [+ a +] is the environment, a map from symbols to types; empty if omitted
  # # [+ expr +] is a string containing the expression to typecheck
  # # returns the type of the expression
  # def do_tc(expr, scope: Hash.new, env: RDL::Typecheck::Env.new)
  #   ast = Parser::CurrentRuby.parse expr
  #   t = RDL::Globals.types[:bot]
  #   return t
  # end

  # convert arg string to a type
  def tt(typ)
    RDL::Globals.parser.scan_str('#T ' + typ)
  end

  # convert a string to a method type
  def tm(typ)
    RDL::Globals.parser.scan_str('#Q ' + typ)
  end

  def infer_method_type(method)
    RDL.infer self.class, method, time: :test
    RDL.do_infer :test

    types = RDL::Globals.info.get "TestInfer", method, :type
    assert types.length == 1, msg: 'Expected one solution for type'

    types[0]
  end

  # ----------------------------------------------------------------------------

  def return_two
    2
  end

  def test_return_two
    typ = infer_method_type :return_two
    assert_equal typ.solution, tm('() -> Integer')
  end

  # ----------------------------------------------------------------------------

  def simple(val)
    val + 2
  end

  # TODO: Why does running more than one of these tests crash?
  def test_simple
    # expected_results = { ["TestInfer", :simple] => '([ +: (Number) -> XXX ]) -> XXX' }
    typ = infer_method_type :simple

    assert typ.args.length == 1
    assert typ.args[0].solution <= tt('[ +: (Integer) -> ret ]')
  end
end

# Wanted:
# p types[0].args[0].solution
# p types[0].ret.solution
