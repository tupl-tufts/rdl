require 'minitest/autorun'
require_relative '../lib/rdl.rb'
#require_relative '../types/ruby-2.2.2/core/enumerable.rb'
#require_relative '../types/ruby-2.2.2/stdlib/set.rb'

class TestStdlibTypes < Minitest::Test

  def test_set
    skip "Not working yet"
    # From the Ruby stdlib documentation
    s1 = Set.new [1, 2]                   # -> #<Set: {1, 2}>
    s2 = [1, 2].to_set                    # -> #<Set: {1, 2}>
    s1 == s2                              # -> true
    s1.add("foo")                         # -> #<Set: {1, 2, "foo"}>
    s1.merge([2, 6])                      # -> #<Set: {1, 2, "foo", 6}>
    s1.subset? s2                         # -> false
    s2.subset? s1                         # -> true
    Set[1, 2, 3].disjoint? Set[3, 4] # => false
    Set[1, 2, 3].disjoint? Set[4, 5] # => true
    numbers = Set[1, 3, 4, 6, 9, 10, 11]
    set = numbers.divide { |i,j| (i - j).abs == 1 }
    Set[1, 2, 3].intersect? Set[4, 5] # => false
    Set[1, 2, 3].intersect? Set[3, 4] # => true
  end
end