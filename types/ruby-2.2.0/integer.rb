class Integer
  rdl_alias :ceil, :to_i
  type :chr, '(?Encoding) -> String'
  type :denominator, '() -> 1'
  type :downto, '(limit: Integer) { (Integer) -> %any } -> self'
  type :downto, '(limit: Integer) -> Enumerator<Integer>'
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
  type :rationalize, '(eps: ?%any) -> Rational'
  type :round, '(ndigits: ?Fixnum) -> Integer or Float'
  rdl_alias :succ, :next
  type :times, '() { (Integer) -> %any } -> self'
  type :times, '() -> Enumerator<Integer>'
  type :to_i, '() -> Integer'
  rdl_alias :to_int, :to_i
  type :to_r, '() -> Rational'
  rdl_alias :truncate, :to_i
  type :upto, '(limit: Integer) { (Integer) -> %any } -> self'
  type :upto, '(limit: Integer) -> Enumerator<Integer>'
end