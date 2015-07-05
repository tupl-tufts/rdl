require 'minitest/autorun'
require_relative '../lib/rdl.rb'
require_relative '../types/ruby-2.2.2/core.rb'
require_relative '../types/ruby-2.2.2/stdlib/set.rb'

class TestStdlibTypes < Minitest::Test

  def test_set
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
    # Some more tests, just to make sure type checking doesn't cause crashes
    s3 = s1 - s2
    s1.proper_subset? s2
    s1.superset? s2
    s1 ^ s2
    s1.add?("bar")
    h = s1.classify { |x| x.size }
    s2.clear
    s4 = s1.map { |x| 42 }
    s1.delete "foo"
    s1.delete? "bar"
    s1.delete_if { |x| false }
    s1.each { |x| nil }
    s1.empty?
    s1.member? 42
    s1.intersection [1,2,3]
    s1.keep_if { |x| true }
    s1.size
    s1.difference [1,2,3]
    s1.to_a
    s5 = s1 + s2
  end
end