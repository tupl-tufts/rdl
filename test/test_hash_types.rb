require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'
require 'types/core'


class TestHashTypes < Minitest::Test
  extend RDL::Annotate

  def test_failures
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :access_fail1 }
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :access_fail2 }
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :assign_fail1 }
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :assign_fail2 }
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :assign_fail3 }
    assert_raises(RDL::Typecheck::StaticTypeError) { RDL.do_typecheck :create_fail1 }
  end


  type '({bar: Integer, baz: String}) -> String', typecheck: :now
  def access_test1(x)
    x[:baz]
  end
  
  type '({bar: Integer, baz: String}) -> {bar: Integer, baz: String}', typecheck: :now
  def access_test2(x)
    x[:baz]
    x
  end

  type '(Symbol, {bar: Integer, baz: String}) -> String or Integer', typecheck: :now
  def access_test3(y, x)
    x[y]
  end

  type '(Hash) -> v', typecheck: :now
  def access_test4(x)
    x[:blah]
  end

  type '(Hash<Symbol, Integer or String>) -> Integer or String', typecheck: :now
  def access_test5(x)
    x[:baz]
  end

  type '({ foo: 1, Symbol: String }) -> 1 or String', typecheck: :now
  def access_test6(x)
    x[:blah]
  end

  type '({bar: Integer, baz: String}) -> Integer', typecheck: :access_fail1
  def access_fail_test1(x)
    x[:baz]
  end
  
  type '(Hash<Symbol, Integer or String>) -> Integer', typecheck: :access_fail2
  def access_fail_test2(x)
    x[:baz]
  end

  type '({ bar: 1, baz: 2 }) -> :bar', typecheck: :now
  def key_test1(x)
    x.key(1)
  end

  type '({ bar: Integer, baz: String }) -> Symbol', typecheck: :now
  def key_test2(x)
    x.key(1)
  end

  type '(Hash<Symbol, Integer>) -> Symbol', typecheck: :now
  def key_test3(x)
    x.key(1)
  end

  type '({ bar: Integer, baz: String }) -> { bar: Integer, baz: String, foo: Integer }', typecheck: :now
  def merge_test1(x)
    x.merge({ foo: 1 })
  end

  type '({ bar: Integer, baz: String }) -> { bar: String, baz: String }', typecheck: :now
  def merge_test2(x)
    x.merge({ bar: 'hi' })
  end

  type '(Hash<Integer, String>, { bar: Integer, baz: String }) -> Hash<Integer or Symbol, Integer or String>', typecheck: :now
  def merge_test3(x, y)
    x.merge(y)
  end

  type '(Hash<Integer, String>, { bar: Integer, baz: String }) -> Hash<Integer or Symbol, Integer or String>', typecheck: :now
  def merge_test4(x, y)
    y.merge(x)
  end

  type '(Hash<Integer, String>, Hash<Symbol, Integer>) -> Hash<Integer or Symbol, String or Integer>', typecheck: :now
  def merge_test5(x, y)
    x.merge(y)
  end

  type '(Hash<Integer, String>, Hash<Symbol, Integer>) -> Hash<Integer or Symbol, String or Integer>', typecheck: :now
  def merge_test6(x, y)
    y.merge(x)
  end
  
  type '(Hash, { bar: Integer, baz: String }) -> Hash', typecheck: :now
  def merge_test7(x, y)
    x.merge(y)
  end

  type '(Hash, { bar: Integer, baz: String }) -> Hash', typecheck: :now
  def merge_test8(x, y)
    y.merge(x)
  end

  type '(Hash, Hash<Integer, String>) -> Hash', typecheck: :now
  def merge_test9(x, y)
    x.merge(y)
  end

  type '(Hash, Hash<Integer, String>) -> Hash', typecheck: :now
  def merge_test10(x, y)
    y.merge(x)
  end

  type '({ bar: Integer, baz: String}) -> 2', typecheck: :now
  def length_test1(x)
    x.length
  end

  type '(Hash<Integer, String>) -> Integer', typecheck: :now
  def length_test2(x)
    x.length
  end

  type '({ hi: 1}) -> false', typecheck: :now
  def empty_test1(x)
    x.empty?
  end

  type '() -> true', typecheck: :now
  def empty_test2()
    x = {}
    x.empty?
  end

  type '(Hash) -> %bool', typecheck: :now
  def empty_test3(x)
    x.empty?
  end

  type '(Hash<Symbol, String>) -> %bool', typecheck: :now
  def empty_test4(x)
    x.empty?
  end

  type '({ baz: Integer, 1 => 2 }) -> [:baz, 1]', typecheck: :now
  def keys_test1(x)
    x.keys
  end

  type '(Hash<Symbol, Integer>) -> Array<Symbol>', typecheck: :now
  def keys_test2(x)
    x.keys
  end


  type '({ foo: Integer }) -> { foo: Integer, bar: String }', typecheck: :now
  def assign_test1(x)
    x[:bar] = "2"
    x
  end

  type '(Hash<Symbol, Integer>) -> Integer', typecheck: :now
  def assign_test2(x)
    x[:blah] = 42
    x[:foo]
  end

  type '() -> Integer', typecheck: :now
  def assign_test3()
    x = {foo: 1, bar: 2, baz: 3}
    x[:bar] = 3
  end

  type '({foo: Integer}) -> 42', typecheck: :now
  def assign_test4(x)
    x[:bar] = 42
    x[:bar]
  end

  type '(Integer, { foo: String }) -> Hash<Symbol or Integer, String or Integer>', typecheck: :now
  def assign_test5(i, x)
    x[i] = i
    x
  end

  type '({ foo: 1 }) -> { foo: 1 or 2 }', typecheck: :now
  def assign_test6(x)
    x[:foo] = 2
    x
  end

  type :hash_callee, '({ foo: 1 or 2 }) -> %bool'

  type '({ foo: 1 }) -> { foo: 1 or 2 }', typecheck: :now
  def assign_test7(x)
    hash_callee(x)
    x[:foo] = 2
    x
  end

  type '({ foo: 1 }) -> String', typecheck: :assign_fail1
  def assign_fail_test1(x)
    hash_callee(x)
    x[:foo] = "2"
  end

  type '(Hash<Symbol, Integer>) -> %any', typecheck: :assign_fail2
  def assign_fail_test2(x)
    x[:blah] = 'hi'
  end

  type '(Hash<Symbol, Integer>) -> %any', typecheck: :assign_fail3
  def assign_fail_test3(x)
    x['string'] = 2
  end

  type '({ foo: 1, bar: String }) -> [:bar, String]', typecheck: :now
  def assoc_test1(x)
    x.assoc(:bar)
  end

  type '(Symbol, { foo: 1, bar: String }) -> [Symbol, Integer or String]', typecheck: :now
  def assoc_test2(y, x)
    x.assoc(y)
  end

  type '(Hash<Symbol, Integer>) -> [Symbol, Integer]'
  def assoc_test3(x)
    x.assoc(42)
  end

  type '({ foo: 1 }) -> true', typecheck: :now
  def has_key_test1(x)
    x.has_key?(:foo)
  end

  type '({ foo: 1 }) -> false', typecheck: :now
  def has_key_test2(x)
    x.has_key?(:bar)
  end

  type '(Symbol, { foo: 1 }) -> %bool', typecheck: :now
  def has_key_test3(y, x)
    x.has_key?(y)
  end

  type '(Symbol, Hash<Symbol, Integer>) -> %bool', typecheck: :now
  def has_key_test4(y, x)
    x.has_key?(y)
  end

  type '(String) -> { a: 1, b: String }', typecheck: :now
  def create_test1(x)
    Hash[:a, 1, :b, x]
  end

  type '() -> %any', typecheck: :create_fail1
  def create_fail_test1
    Hash[1, 2, 3]
  end

  type '({ foo: 1, bar: 2 }) -> 1', typecheck: :now
  def delete_test1(x)
    x.delete(:foo)
  end

  type '({ foo: 1, bar: 2 }) -> { foo: 1, bar: 2 }', typecheck: :now
  def delete_test2(x)
    x.delete(:foo)
    x
  end

  type '(Symbol, {foo: 1, bar: 2}) -> 1 or 2', typecheck: :now
  def delete_test3(s, x)
    x.delete(s)
  end

  type '(Symbol, Hash<Symbol, Integer>) -> Integer', typecheck: :now
  def delete_test4(s, x)
    x.delete(s)
  end

  type '(Symbol, { foo: 1 }) -> Integer or String'
  def delete_test5(s, x)
    x.delete(s) { |i| "hi" }
  end

  type '({ foo: 1, bar: String, baz: Integer }) -> [1, String]', typecheck: :now
  def values_at_test1(x)
    x.values_at(:foo, :bar)
  end

  type '(Symbol, { foo: 1, bar: String, baz: Integer }) -> Array<Integer or String>', typecheck: :now
  def values_at_test2(s, x)
    x.values_at(:foo, s)
  end

  type '({ foo: 1, Symbol: String, baz: Integer }) -> Array<Integer or String>', typecheck: :now
  def values_at_test3(x)
    x.values_at(:foo, :blah)
  end

end
