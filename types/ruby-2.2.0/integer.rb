class Integer
  nowrap

  rdl_alias :ceil, :to_i
  type :chr, '(?Encoding) -> String'
  type :denominator, '() -> 1'
  type :downto, '(Integer limit) { (Integer) -> %any } -> self'
  type :downto, '(Integer limit) -> Enumerator<Integer>'
  type :even?, '() -> %bool'
  type :gcd, '(Integer) -> Integer'
  type :gcdlcm, '(Integer) -> [Integer, Integer]'
  rdl_alias :floor, :to_i
  type :integer?, '() -> TrueClass'
  type :lcm, '(Integer) -> Integer'
  type :next, '() -> Integer'
  type :numerator, '() -> self'
  type :odd?, '() -> %bool'
  type :ord, '() -> self'
  type :pred, '() -> Integer'
  type :rationalize, '(?%any eps) -> Rational'
  type :round, '(?Fixnum ndigits) -> Integer or Float'
  rdl_alias :succ, :next
  type :times, '() { (Integer) -> %any } -> self'
  type :times, '() -> Enumerator<Integer>'
  type :to_i, '() -> Integer'
  rdl_alias :to_int, :to_i
  type :to_r, '() -> Rational'
  rdl_alias :truncate, :to_i
  type :upto, '(Integer limit) { (Integer) -> %any } -> self'
  type :upto, '(Integer limit) -> Enumerator<Integer>'
end