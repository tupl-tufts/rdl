require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestRefinement < Minitest::Test
  include RDL::Type
  include RDL::Contract
  extend RDL::Annotate

  module TestModule
    refine Array do
      extend RDL::Annotate
      refine_type :foo, '(Boolean) -> Boolean', typecheck: :later
      def foo(v)
        v.to_s
      end
    end
  end
  RDL.using_type self, TestModule

  def test_uging_type
    before_count = RDL::RefinementSet.class_variable_get(:@@refinement_connections).size
    RDL.using_type self, TestModule
    after_count = RDL::RefinementSet.class_variable_get(:@@refinement_connections).size
    assert before_count == after_count - 1
  end

  using TestModule

  class Test
    extend RDL::Annotate

    type '() -> String', typecheck: :later
    def test
      [].foo("1")
    end
  end

  def test_refine_type
    assert_raises RDL::Typecheck::StaticTypeError do
      Test.new.test
      RDL.do_typecheck :later
    end
  end
end
