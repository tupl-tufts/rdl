require 'pry'

require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/lib"
require 'rdl'
require 'types/core'

class Infer
  extend RDL::Annotate

  # # [+ a +] is the environment, a map from symbols to types; empty if omitted
  # # [+ expr +] is a string containing the expression to typecheck
  # # returns the type of the expression
  # def do_tc(expr, scope: Hash.new, env: RDL::Typecheck::Env.new)
  #   ast = Parser::CurrentRuby.parse expr
  #   t = RDL::Globals.types[:bot]
  #   return t
  # end

  # # convert arg string to a type
  # def tt(t)
  #   RDL::Globals.parser.scan_str('#T ' + t)
  # end


  def simple(x)
    return x + 2
  end

  def self.test_simple_infer
    infer(self, :simple, time: :test)

    RDL.do_infer :test

    types = RDL::Globals.info.get("TestInfer", "simple", :type)

    puts "Solution:"
    p types
    # p types[0].args[0].solution
    # p types[0].ret.solution
    puts "---------"

    return true
  end
end

Infer.test_simple_infer
