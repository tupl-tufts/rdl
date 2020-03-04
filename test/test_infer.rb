require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'
require 'types/core'

class TestTypecheck < Minitest::Test
  extend RDL::Annotate

  def setup
    RDL.reset
  end

  # [+ a +] is the environment, a map from symbols to types; empty if omitted
  # [+ expr +] is a string containing the expression to typecheck
  # returns the type of the expression
  def do_tc(expr, scope: Hash.new, env: RDL::Typecheck::Env.new)
    ast = Parser::CurrentRuby.parse expr
    t = RDL::Globals.types[:bot]
    return t
  end

  # convert arg string to a type
  def tt(t)
    RDL::Globals.parser.scan_str('#T ' + t)
  end
end
