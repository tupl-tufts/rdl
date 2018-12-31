require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'
require 'types/core'


class TestBoundTypes < Minitest::Test
  extend RDL::Annotate

  def test_failures
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :fail1 }
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :fail2 }
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :fail3 }
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :fail4 }
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :fail5 }
  end

  type :uses_bound, "(t<::Integer) -> ``if t.is_a?(RDL::Type::SingletonType) then RDL::Globals.types[:integer] else RDL::Globals.types[:string] end``"

  type :uses_bound_twice, "(t<::Integer, p<::Integer) -> ``if t==p then RDL::Globals.types[:integer] else RDL::Globals.types[:string] end``"

  type :uses_optional, "(?String, t<::Integer) -> ``if t.is_a?(RDL::Type::SingletonType) then RDL::Globals.types[:integer] else RDL::Globals.types[:string] end``"

  type "(Integer) -> String", typecheck: :now
  def calls_bound1(x)
    uses_bound(x)
  end

  type "(1) -> Integer", typecheck: :now
  def calls_bound2(x)
    uses_bound(x)
  end

  type "(Integer) -> Integer", typecheck: :fail1
  def calls_bound3(x)
    uses_bound(x)
  end

  type "(1) -> String", typecheck: :fail2
  def calls_bound4(x)
    uses_bound(x)
  end

  type "(1, 1) -> Integer", typecheck: :now
  def calls_bound5(x, y)
    uses_bound_twice(x, y)
  end

  type "(1, 2) -> String", typecheck: :now
  def calls_bound6(x, y)
    uses_bound_twice(x, y)
  end

  type "(1, 2) -> Integer", typecheck: :fail3
  def calls_bound7(x, y)
    uses_bound_twice(x, y)
  end

  type "(1) -> Integer", typecheck: :now
  def calls_bound8(x)
    uses_optional(x)
  end

  type "(1) -> Integer", typecheck: :now
  def calls_bound9(x)
    uses_optional('x', x)
  end

  type "(1) -> String", typecheck: :fail4
  def calls_bound10(x)
    uses_optional('x', x)
  end

  type "(1) -> String", typecheck: :fail5
  def calls_bound11(x)
    uses_optional(x)
  end

  
end
