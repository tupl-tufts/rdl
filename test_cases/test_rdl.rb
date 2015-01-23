require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class RDLTest < Minitest::Test

#####################################################################

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
      pre_cond { |x| @trace.push :pre_cond, x }
      post_cond { |r, x| @trace.push :post_cond, r, x }
    end
  end

  def test_spec_pre_post_cond
    a = A_spec.new
    a.foo 3
    assert_equal a.trace, [:pre_cond, 3, :foo, 3, :post_cond, 4, 3]
  end

#####################################################################

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

  def test_spec_pre_post_cond
    b = B_spec.new
    b.foo 5
    assert_raises RDL::Spec::PreConditionFailure do b.foo 0 end
    assert_raises RDL::Spec::PostConditionFailure do b.foo 2 end
  end

#####################################################################

  class A_keyword
    extend RDL

    attr_accessor :trace

    def initialize
      @trace = []
    end

    dsl do
    keyword :foo do
      action do |x|
        @trace.push :foo, x
        x + 1
      end

      pre_cond { |x| @trace.push :pre_cond, x }
      post_cond { |r, x| @trace.push :post_cond, r, x }
    end
    end

  end

  def test_keyword_pre_post_cond
    a = A_keyword.new
    a.foo 3
    assert_equal a.trace, [:pre_cond, 3, :foo, 3, :post_cond, 4, 3]
  end

#####################################################################

  class B_keyword
    extend RDL

    dsl do
    keyword :foo do
      action do |x|
        x - 1
      end

      pre_cond "pre_cond" do |x| x > 0 end
      post_cond "post_cond" do |r, x| r > 1 end
    end
    end
  end

  def test_keyword_pre_post_cond
    b = B_keyword.new
    b.foo 5
    assert_raises RDL::Spec::PreConditionFailure do b.foo 0 end
    assert_raises RDL::Spec::PostConditionFailure do b.foo 2 end
  end

#####################################################################
=begin
  class Pair_spec
    extend RDL

    def initialize(&block)
      $trace = []
      instance_eval(&block)
    end

    def left(x)
      $trace.push :left, x
      @left = x
      -1
    end

    def right(x)
      $trace.push :right, x
      @right = x
      -1
    end

    def get
      [@left, @right]
    end

    spec :initialize do
        spec :left do
          pre_cond { |x| $trace.push :pre_cond_left, x }
          post_cond { |r, x| $trace.push :post_cond_left, r, x }
        end
        spec :right do
          pre_cond { |x| $trace.push :pre_cond_right, x }
          post_cond { |r, x| $trace.push :post_cond_right, r, x }
        end
    end
  end

  def test_pair_spec
    p = Pair_spec.new { left 3; right 4 }
    assert_equal [3,4], p.get
    assert_equal [:pre_cond_left, 3, :left, 3, :post_cond_left, -1, 3,
                  :pre_cond_right, 4, :right, 4, :post_cond_right, -1, 4], $trace
  end
=end
#####################################################################

  class Pair
    extend RDL

    attr_accessor :pair

    def get
      [@left, @right]
    end

    dsl do
    keyword :initialize do
      dsl do
        keyword :left do
          post_cond { |r, left| @left = left }
        end
        keyword :right do
          post_cond { |r, right| @right = right }
        end
      end
      post_cond { |r| @pair = [(r.instance_eval "@left"), (r.instance_eval "@right")] }
    end
    end
  end

 def test_pair
   p = Pair.new { left 3; right 4 }
   assert_equal [3,4], p.pair
 end

#####################################################################

end

# dsl_from, Dsl.new
# Spec.new
# arg
# ret
# ret_dep
# merge, and
