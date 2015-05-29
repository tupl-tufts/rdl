require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TypeTest < Minitest::Test
  include RDL::Type

  # Nil
  # Top
  # "A"
  # :foo
  # var "a"
  # +
  # &
  # named arg
  # opt
  # vararg
  # Tuple<...>
  # Array<...>
  # Hash<...>
  # [...]
  # Method...
  
  def test_le_basic
    t1 = NilType.new
    t2 = TopType.new
    t3 = NominalType.new "A"
    t4 = SymbolType.new :foo
    t5 = VarType.new "a"
    t6 = UnionType.new t3, t4
    t7 = IntersectionType.new t3, t4
    t9 = GenericType.new t3, t4, t5
    assert (t1 <= t1)
    assert (t1 <= t2)
    assert (t1 <= t3)
    assert (t1 <= t4)
    assert (t1 <= t5)
    assert (t1 <= t6)
    assert (t1 <= t7)
    assert (t1 <= t9)
    assert (not (t2 <= t1))
    assert (not (t3 <= t1))
    assert (not (t4 <= t1))
    assert (not (t5 <= t1))
    assert (not (t6 <= t1))
    assert (not (t7 <= t1))
    assert (not (t9 <= t1))
    assert (t3 <= t2)
    assert (t4 <= t2)
    assert (t5 <= t2)
    assert (t6 <= t2)
    assert (t7 <= t2)
    assert (t9 <= t2)
  end
  
end
