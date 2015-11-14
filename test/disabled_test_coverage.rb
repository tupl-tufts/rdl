require 'set'
require 'abbrev'
require 'base64'
require 'benchmark'
require 'bigdecimal'
require 'bigdecimal/math'
require 'coverage.so'

require 'minitest/autorun'
require_relative '../lib/rdl.rb'
require_relative '../lib/rdl_types.rb'

RDL::Config.instance.profile_stats

class Dummy
  def self.each
  end
  def each
  end
end

class TestStdlibTypes < Minitest::Test

  def test_abbrev
    assert_raises(RDL::Type::TypeError) { s0 = Abbrev.abbrev 5}
    # From the Ruby stdlib documentation
    s1 = Abbrev.abbrev(['ruby']) # -> {"ruby"=>"ruby", "rub"=>"ruby", "ru"=>"ruby", "r"=>"ruby"}
    ev = {"ruby"=>"ruby", "rub"=>"ruby", "ru"=>"ruby", "r"=>"ruby"}
    assert_equal(s1,ev)
    # Other tests
    assert_raises(RDL::Type::TypeError) { s2 = Abbrev.abbrev Dummy.new }
  end

  def test_base64
    # From the Ruby stdlib documentation
    e0 = Base64.encode64('Send reinforcements') # -> "U2VuZCByZWluZm9yY2VtZW50cw==\n"
    d0 = Base64.decode64(e0) # -> "Send reinforcements"
    #assert_equal(e0,d0)
    e1 = Base64.strict_encode64('Send reinforcements')
    d1 = Base64.strict_decode64(e1)
    #assert_equal(e1,d1)
    e2 = Base64.urlsafe_encode64('Send reinforcements')
    d2 = Base64.urlsafe_decode64(e2)
    #assert_equal(e2,d2)
  end

  def test_benchmark
    skip "Skip these because they print to stdout"
    # From the Ruby stdlib documentation
    Benchmark.measure { "a"*1_000_000_000 }
    n = 5000000
    Benchmark.bm do |x|
      x.report { for i in 1..n; a = "1"; end }
      x.report { n.times do   ; a = "1"; end }
      x.report { 1.upto(n) do ; a = "1"; end }
    end
    Benchmark.bm(7) do |x|
      x.report("for:")   { for i in 1..n; a = "1"; end }
      x.report("times:") { n.times do   ; a = "1"; end }
      x.report("upto:")  { 1.upto(n) do ; a = "1"; end }
    end
    array = (1..1000000).map { rand }
    Benchmark.bmbm do |x|
      #x.report("sort!") { array.dup.sort! } # TODO this causes a hang
      #x.report("sort")  { array.dup.sort  }
    end
    Benchmark.benchmark(Benchmark::CAPTION, 7, Benchmark::FORMAT, ">total:", ">avg:") do |x|
      tf = x.report("for:")   { for i in 1..n; a = "1"; end }
      tt = x.report("times:") { n.times do   ; a = "1"; end }
      tu = x.report("upto:")  { 1.upto(n) do ; a = "1"; end }
      [tf+tt+tu, (tf+tt+tu)/3]
    end
  end

  def test_bigdecimal
    # From the RUby stdlib documentation
    BigDecimal.save_exception_mode do
      BigDecimal.mode(BigDecimal::EXCEPTION_OVERFLOW, false)
      BigDecimal.mode(BigDecimal::EXCEPTION_NaN, false)

      BigDecimal.new(BigDecimal('Infinity'))
      BigDecimal.new(BigDecimal('-Infinity'))
      BigDecimal(BigDecimal.new('NaN'))
    end
    BigDecimal.save_limit do
      BigDecimal.limit(200)
    end
    BigDecimal.save_rounding_mode do
      BigDecimal.mode(BigDecimal::ROUND_MODE, :up)
    end
    # Additional test calls for coverage
    BigDecimal.double_fig
    BigDecimal.limit(5)
    BigDecimal.mode(BigDecimal::EXCEPTION_NaN, true)
    BigDecimal.mode(BigDecimal::EXCEPTION_NaN, false)
    BigDecimal.mode(BigDecimal::EXCEPTION_NaN)
    BigDecimal.ver
    
    # TODO
  end

  def test_bigmath
    # From the Ruby stdlib documentation
    BigMath.E(10)
    BigMath.PI(10)
    BigMath.atan(BigDecimal.new('-1'), 16)
    BigMath.cos(BigMath.PI(4), 16)
    BigMath.sin(BigMath.PI(5)/4, 5)
    BigMath.sqrt(BigDecimal.new('2'), 16)
  end

  def test_coverage
    Coverage.start
    Coverage.result
    #Coverage.result # TODO This cannot be typechecked
  end
  
  def test_set
    assert_raises(RDL::Type::TypeError) { s6 = Set.new(1,2) }
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