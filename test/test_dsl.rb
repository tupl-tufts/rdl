require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestDsl < Minitest::Test

  class Pair

    # dsl {
    #   type :left, '(Fixnum) -> Fixnum'
    #   type :right, '(Fixnum) -> Fixnum'
    # }
    def entry(&blk)
      instance_eval(&blk)
    end

    def left(x)
      @left = x
    end

    def right(x)
      @right = x
    end

    def get
      [@left, @right]
    end
  end

  class Tree

    # dsl :tree { # recursive DSL
    #   type :left, '(Fixnum) -> Fixnum'
    #   dsl :left, :tree
    #   type :right, '(Fixnum) -> Fixnum'
    #   dsl :right, :tree
    # }
    def entry(val, &blk)
      @val = val
      instance_eval(&blk)
    end

    def left(x, &blk)
      if blk
        @left = Tree.new.entry(x, &blk)
      else
        @left = x
      end
    end

    def right(x, &blk)
      if blk
        @right = Tree.new.entry(x, &blk)
      else
        @right = x
      end
    end

    def get
      l = @left.instance_of?(Tree) ? @left.get : @left
      r = @right.instance_of?(Tree) ? @right.get : @right
      [@val, l, r]
    end
  end

  def test_pair
    _ = Pair.new.entry {
      left 3
      right 4
    }
  end

  def test_tree
    _ = Tree.new.entry(2) {
      left(3)
      right(4) {
        left(5) {
          left(6)
          right(7)
        }
        right(8)
      }
    }
  end
end
