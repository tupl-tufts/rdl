require 'test/unit'
require 'rdl'

class Box
  extend RDL

  attr_reader :x

  keyword :set_x do
    action { |x| @x = x }
  end

end

class Pair
  extend RDL

  attr_reader :left, :right

  keyword :initialize do
    dsl do
      keyword :left do
        action { |left| @left = left }
      end
      keyword :right do
        action { |right| @right = right }
      end
    end
  end
end

class RDLTest < Test::Unit::TestCase

  def test_box
    b = Box.new
    b.set_x 3
    assert_equal 3, b.x
  end

  def test_pair
    p = Pair.new { left 3; right 4 }
    puts p.inspect
    assert_equal 3, p.left
    assert_equal 4, p.right
  end

  def test_null
    assert 1
  end
end
