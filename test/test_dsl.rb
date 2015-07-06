require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestDsl < Minitest::Test

  class Pair
    def initialize(&blk)
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
    def initialize(val, &blk)
      @val = val
      instance_eval(&blk)
    end

    def left(x, &blk)
      if blk
        @left = Tree.new(x, &blk)
      else
        @left = x
      end
    end

    def right(x, &blk)
      if blk
        @right = Tree.new(x, &blk)
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
    p = Pair.new {
      left 3
      right 4
    }
  end

  def test_tree
    t = Tree.new(2) {
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
  
