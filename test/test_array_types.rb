require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'
require 'types/core'

class TestArrayTypes < Minitest::Test
  extend RDL::Annotate

  def test_failures
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :append_fail1 }
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :assign_fail1 }
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :assign_fail2 }
  end

  type '() -> 2', typecheck: :now
  def access_test1()
    x = [1, 2, 3]
    x[1]
  end

  type '(Array<Integer>) -> Integer', typecheck: :now
  def access_test2(x)
    x[5]
  end

  type '([2, String, Float], Integer) -> Integer or String or Float', typecheck: :now
  def access_test3(x, y)
    x[y]
  end

  type '(Array) -> t', typecheck: :now
  def access_test4(a)
    a[3]
  end

  type '([1,2,3]) -> Array<3 or 2 or 1>', typecheck: :now
  def access_test5(a)
    a[1..4]
  end

  type '(Array<Integer>) -> Array<Integer>', typecheck: :now
  def access_test6(a)
    a[1..4]
  end

  type '([1,2,3]) -> [2,3]', typecheck: :now
  def access_test7(a)
    a[1, 9]
  end

  type '([1,2,3]) -> 2', typecheck: :now
  def fetch_test1(a)
    a[1]
  end

  type '([1,2,3]) -> 1', typecheck: :now
  def first_test1(a)
    a.first
  end

  type '([1,2,3], Integer) -> Array<3 or 2 or 1>', typecheck: :now
  def first_test2(a, i)
    a.first(i)
  end

  type '() -> [1,2,3,1,2,3]', typecheck: :now
  def mult_test1
    [1,2,3]*2
  end

  type '([1,2,3], Integer) -> Array<3 or 2 or 1>', typecheck: :now
  def mult_test2(a, i)
    a * i
  end

  type '([1,2,3]) -> 3', typecheck: :now
  def count_test1(a)
    a.count
  end

  type '(Array<Integer>) -> Integer', typecheck: :now
  def count_test2(a)
    a.count
  end

  type '([1,2,3]) -> [1,2,3,4]', typecheck: :now
  def append_test1(a)
    a << 4
  end

  type '(Array<Integer>) -> Array<Integer>', typecheck: :now
  def append_test2(a)
    a << 5
  end

  type '([1,2,3]) -> [1,2,3,4,5]', typecheck: :now
  def push_test1(a)
    a.push(4, 5)
  end

  type :append_callee, '([1,2,3]) -> %bool'

  type '([1,2,3]) -> %bool', typecheck: :append_fail1
  def append_fail_test1(a)
    append_callee(a)
    a << 4
    true
  end
  
  type '([1,2,3], [4,5,String]) -> [1,2,3,4,5,String]', typecheck: :now
  def plus_test1(x, y)
    x+y
  end

  type '([Integer,Integer,Integer], Array<String>) -> Array<Integer or String>', typecheck: :now
  def plus_test2(x, y)
    x+y
  end

  type '([1,2,3], Array) -> Array', typecheck: :now
  def plus_test3(x, y)
    x + y
  end

  type '(Array<String>, Array) -> Array', typecheck: :now
  def plus_test4(x, y)
    x + y
  end

  type '([1,2,3]) -> true', typecheck: :now
  def include_test1(x)
    x.include?(1)
  end

  type '([1,2,Integer]) -> %bool', typecheck: :now
  def include_test2(x)
    x.include?(4)
  end

  type '(Array<Integer>) -> %bool', typecheck: :now
  def include_test3(x)
    x.include?(42)
  end

  type '([1,2,3]) -> 2', typecheck: :now
  def slice_test1(x)
    x.slice(1)
  end

  type '([1,2,3]) -> [2,3]', typecheck: :now
  def slice_test2(x)
    x.slice(1,2)
  end

  type '([1,2,3]) -> [1,4 or 2,3]', typecheck: :now
  def assign_test1(x)
    x[1] = 4
    x
  end

  type '(Integer, [1,2,3]) -> Array<1 or 2 or 3 or String>', typecheck: :now
  def assign_test2(i, x)
    x[i] = "hi"
    x
  end

  type '(Array<Integer>) -> Array<Integer>', typecheck: :now
  def assign_test3(x)
    x[1] = 2
    x
  end

  type :assign_callee, '([1,2,3]) -> %bool'

  type '([1,2,3]) -> 2', typecheck: :now
  def assign_test4(x)
    assign_callee(x)
    x[1] = 2
  end

  type '([1,2,3]) -> %any', typecheck: :assign_fail1
  def assign_fail_test1(x)
    assign_callee
    x[1] = 100
  end

  type '(Array<Integer>) -> %any', typecheck: :assign_fail2
  def assign_fail_test2(x)
    x[1] = "hi"
  end

  type '([1,2,3]) -> false', typecheck: :now
  def empty_test1(x)
    x.empty?
  end

  type '(Array<Integer>) -> %bool', typecheck: :now
  def empty_test2(x)
    x.empty?
  end

  type '([1,2,3]) -> 1', typecheck: :now
  def index_test1(x)
    x.index(2)
  end

  type '([1,2,3], Integer) -> Integer', typecheck: :now
  def index_test2(x, y)
    x.index(y)
  end

  type '([1,Integer,3], 2) -> Integer', typecheck: :now
  def index_test3(x, y)
    x.index(y)
  end

  type '([1,2,3]) -> [3,2,1]', typecheck: :now
  def reverse_test1(x)
    x.reverse
  end

  type '([1,2,3]) -> [1,2,3]', typecheck: :now
  def reverse_test2(x)
    x.reverse
    x
  end

  type '([1,2,3]) -> [3 or 1,2,1 or 3]', typecheck: :now
  def reverse_test3(x)
    x.reverse!
    x
  end

end

