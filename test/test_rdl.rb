require 'test/unit'
require 'rdl'

class A
  extend RDL

  attr_accessor :trace

  def initialize
    @trace = []
  end

  def foo(x)
    @trace.push :foo, x
    x + 1
  end

  spec :foo do
    pre_task { |x| @trace.push :pre_task, x }
    post_task { |r, x| @trace.push :post_task, r, x }
  end
end

class A_keyword
  extend RDL

  attr_accessor :trace

  def initialize
    @trace = []
  end

  keyword :foo do
    action do |x|
      @trace.push :foo, x
      x + 1
    end

    pre_task { |x| @trace.push :pre_task, x }
    post_task { |r, x| @trace.push :post_task, r, x }
  end
end

class B
  extend RDL

  def foo(x)
    x - 1
  end

  spec :foo do
    pre_cond "pre_cond" do |x| x > 0 end
    post_cond "post_cond" do |r, x| r > 1 end
  end
end

class B_keyword
  extend RDL

  keyword :foo do
    action do |x|
      x - 1
    end

    pre_cond "pre_cond" do |x| x > 0 end
    post_cond "post_cond" do |r, x| r > 1 end
  end
end

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

  def test_spec_pre_post_task
    a = A.new
    a.foo 3
    assert_equal a.trace, [:pre_task, 3, :foo, 3, :post_task, 4, 3]
  end

  def test_spec_pre_post_cond
    b = B.new
    b.foo 5
    assert_raise RDL::Spec::PreConditionFailure do b.foo 0 end
    assert_raise RDL::Spec::PostConditionFailure do b.foo 2 end
  end

  def test_keyword_pre_post_task
    a = A_keyword.new
    a.foo 3
    assert_equal a.trace, [:pre_task, 3, :foo, 3, :post_task, 4, 3]
  end

  def test_keyword_pre_post_cond
    b = B_keyword.new
    b.foo 5
    assert_raise RDL::Spec::PreConditionFailure do b.foo 0 end
    assert_raise RDL::Spec::PostConditionFailure do b.foo 2 end
  end


#  def test_box
#    b = Box.new
#    b.set_x 3
#    assert_equal 3, b.x
#  end

#  def test_pair
#    p = Pair.new { left 3; right 4 }
#    puts p.inspect
#    assert_equal 3, p.left
#    assert_equal 4, p.right
#  end
end
