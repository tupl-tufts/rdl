require 'test/unit'
require_relative '../lib/rdl.rb'

class A_spec
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

class B_spec
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

class Pair_spec
  extend RDL

  attr_reader :trace

  def initialize(&block)
    $trace = []
    instance_eval(&block)
  end

  def left(x)
    $trace.push :left, x
    @left = x
  end

  def right(x)
    $trace.push :right, x
    @right = x
  end

  def get
    [@left, @right]
  end

  spec :initialize do
    dsl do
      spec :left do
        pre_task { |x| $trace.push :pre_task_left, x }
        post_task { |r, x| $trace.push :post_task_left, r, x }
      end
      spec :right do
        pre_task { |x| $trace.push :pre_task_right, x }
        post_task { |r, x| $trace.push :post_task_right, r, x }
      end
    end
  end

end

class Pair
  extend RDL

  attr_reader :left, :right

  keyword :initialize do
    dsl do
      keyword :left do
        post_task { |left| @left = left }
      end
      keyword :right do
        post_task { |right| @right = right }
      end
    end
  end
end

class RDLTest < Test::Unit::TestCase

  def test_spec_pre_post_task
    a = A_spec.new
    a.foo 3
    assert_equal a.trace, [:pre_task, 3, :foo, 3, :post_task, 4, 3]
  end

  def test_spec_pre_post_cond
    b = B_spec.new
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

 def test_pair_spec
   p = Pair_spec.new { left 3; right 4 }
   puts p.inspect
   assert_equal [3,4], p.get
 end
end
