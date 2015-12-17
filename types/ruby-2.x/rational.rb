class Rational
  rdl_nowrap

  type :*, '(Numeric) -> Numeric'
  type :**, '(Numeric) -> Numeric'
  type :+, '(Numeric) -> Numeric'
  type :-, '(Numeric) -> Numeric'
  type :/, '(Numeric) -> Numeric'
  type :<=>, '(Numeric) -> -1 or 0 or 1 or nil'
  type :==, '(%any object) -> %bool'
  type :ceil, '() -> Integer'
  type :ceil, '(Fixnum precision) -> Rational'
  type :denominator, '() -> Integer'
  post(:denominator) { |r, _| r > 0 }
  type :fdiv, '(Numeric) -> Float'
  type :floor, '() -> Integer'
  type :floor, '(Fixnum precision) -> Rational'
  type :inspect, '() -> String'
  type :numerator, '() -> Integer'
  rdl_alias :quo, :/
  type :rationalize, '() -> self'
  type :rationalize, '(Numeric eps) -> Rational'
  type :round, '() -> Integer'
  type :round, '(Fixnum precision) -> Rational'
  type :to_f, '() -> Float'
  type :to_i, '() -> Integer'
  type :to_r, '() -> self'
  type :to_s, '() -> String'
  type :truncate, '() -> Integer'
  type :truncate, '(Fixnum precision) -> Rational'
end
