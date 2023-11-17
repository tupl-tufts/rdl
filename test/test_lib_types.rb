require 'set'
require 'abbrev'
require 'base64'
require 'benchmark'
require 'bigdecimal'
require 'bigdecimal/math'
require 'coverage.so'
require 'uri'

require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'
require 'types/core'

class Dummy
  def self.each
  end
  def each
  end
end

class TestStdlibTypes < Minitest::Test

  def test_abbrev
    skip "Skip when nowrap is enabled"
    assert_raises(RDL::Type::TypeError) { Abbrev.abbrev 5}
    # From the Ruby stdlib documentation
    s1 = Abbrev.abbrev(['ruby']) # -> {"ruby"=>"ruby", "rub"=>"ruby", "ru"=>"ruby", "r"=>"ruby"}
    ev = {"ruby"=>"ruby", "rub"=>"ruby", "ru"=>"ruby", "r"=>"ruby"}
    assert_equal(s1, ev)
    # Other tests
    assert_raises(RDL::Type::TypeError) { Abbrev.abbrev Dummy.new }
  end

  def test_base64
    skip "Skip when nowrap is enabled"
    # From the Ruby stdlib documentation
    e0 = Base64.encode64('Send reinforcements') # -> "U2VuZCByZWluZm9yY2VtZW50cw==\n"
    Base64.decode64(e0) # -> "Send reinforcements"
    #assert_equal(e0,d0)
    e1 = Base64.strict_encode64('Send reinforcements')
    Base64.strict_decode64(e1)
    #assert_equal(e1,d1)
    e2 = Base64.urlsafe_encode64('Send reinforcements')
    Base64.urlsafe_decode64(e2)
    #assert_equal(e2,d2)
  end

  def test_benchmark
    skip "Skip these because they print to stdout"
    # From the Ruby stdlib documentation
    Benchmark.measure { "a"*1_000_000_000 }
    n = 5000000
    Benchmark.bm do |x|
      x.report { for i in 1..n; a = i; a; end }
      x.report { n.times do   ; a = "1"; a; end }
      x.report { 1.upto(n) do ; a = "1"; a; end }
    end
    Benchmark.bm(7) do |x|
      x.report("for:")   { for i in 1..n; a = i; a; end }
      x.report("times:") { n.times do   ; a = "1"; a; end }
      x.report("upto:")  { 1.upto(n) do ; a = "1"; a; end }
    end
    _ = (1..1000000).map { rand }
    Benchmark.bmbm do |x|
      #x.report("sort!") { array.dup.sort! } # TODO this causes a hang
      #x.report("sort")  { array.dup.sort  }
    end
    Benchmark.benchmark(Benchmark::CAPTION, 7, Benchmark::FORMAT, ">total:", ">avg:") do |x|
      tf = x.report("for:")   { for i in 1..n; a = i; a; end }
      tt = x.report("times:") { n.times do   ; a = "1"; a; end }
      tu = x.report("upto:")  { 1.upto(n) do ; a = "1"; a; end }
      [tf+tt+tu, (tf+tt+tu)/3]
    end
  end

  def test_bigdecimal
    skip "Skip when nowrap is enabled"
    # From the RUby stdlib documentation
    BigDecimal.save_exception_mode do
      BigDecimal.mode(BigDecimal::EXCEPTION_OVERFLOW, false)
      BigDecimal.mode(BigDecimal::EXCEPTION_NaN, false)

      BigDecimal(BigDecimal('Infinity'))
      BigDecimal(BigDecimal('-Infinity'))
      BigDecimal(BigDecimal('NaN'))
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
    BigMath.atan(BigDecimal('-1'), 16)
    BigMath.cos(BigMath.PI(4), 16)
    BigMath.sin(BigMath.PI(5)/4, 5)
    BigMath.sqrt(BigDecimal('2'), 16)
  end

  def test_class
    Dummy.allocate
    Dummy.new
    Dummy.superclass
  end

  def test_coverage
    skip "Skip when nowrap is enabled"
    Coverage.start
    Coverage.result
    #Coverage.result # TODO This cannot be typechecked
  end

  def test_exception
    e1 = Exception.new
    _ = (e1 == 5)
    tmp = e1.backtrace
    e1.backtrace_locations
    e1.cause
    e1.exception
    e1.inspect
    e1.message
    e1.set_backtrace(tmp)
    e1.to_s
  end

  def test_set
    skip "Skip when nowrap is enabled"
    assert_raises(RDL::Type::TypeError) { _ = Set.new(1,2) }
    # From the Ruby stdlib documentation
    s1 = Set.new [1, 2]                   # -> #<Set: {1, 2}>
    s2 = [1, 2].to_set                    # -> #<Set: {1, 2}>
    _ = (s1 == s2)                        # -> true
    s1.add("foo")                         # -> #<Set: {1, 2, "foo"}>
    s1.merge([2, 6])                      # -> #<Set: {1, 2, "foo", 6}>
    s1.subset? s2                         # -> false
    s2.subset? s1                         # -> true
    Set[1, 2, 3].disjoint? Set[3, 4] # => false
    Set[1, 2, 3].disjoint? Set[4, 5] # => true
    numbers = Set[1, 3, 4, 6, 9, 10, 11]
    _ = numbers.divide { |i,j| (i - j).abs == 1 }
    Set[1, 2, 3].intersect? Set[4, 5] # => false
    Set[1, 2, 3].intersect? Set[3, 4] # => true
    # Some more tests, just to make sure type checking doesn't cause crashes
    _ = s1 - s2
    s1.proper_subset? s2
    s1.superset? s2
    _ = s1 ^ s2
    s1.add?("bar")
    _ = s1.classify { |x| x.size }
    s2.clear
    _ = s1.map { |x| 42 }
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
    _ = s1 + s2
  end

  def test_uri
    URI.decode_www_form("a=1&a=2&b=3")
    URI.encode_www_form([["q", "ruby"], ["lang", "en"]]) # Internally uses _component
    URI.encode_www_form("q" => "ruby", "lang" => "en")
    URI.encode_www_form("q" => ["ruby", "perl"], "lang" => "en")
    URI.encode_www_form([["q", "ruby"], ["q", "perl"], ["lang", "en"]])
#    URI.extract("text here http://foo.example.org/bla and here mailto:test@example.com and here also.")
    URI.join("http://example.com/","main.rbx")
    URI.parse("http://www.ruby-lang.org/")
    URI.scheme_list
    URI.split("http://www.ruby-lang.org/")
#    enc_uri = URI.escape("http://example.com/?a=\11\15")
#    URI.unescape(enc_uri)
  end
end
