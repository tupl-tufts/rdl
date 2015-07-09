class Numeric
  type :+, '() -> self'
  type :-, '() -> Numeric'
  type :<=>, '(Numeric) -> -1 or 0 or 1 or nil'
  type :abs, '() -> Numeric'
  type :abs2, '() -> %real'
  type :angle, '() -> 0 or ${Math::PI}'
  type :arg, '() -> 0 or ${Math::PI}'
  type :ceil, '() -> Integer'
  type :coerce, '(Numeric) -> [Numeric, Numeric]'
  type :conj, '() -> self'
  rdl_alias :conjugate, :conj
  type :denominator, '() -> Integer'
  post(:denominator) { |r, _| r > 0 }
  type :div, '(Numeric) -> Integer'
  type :divmod, '(Numeric) -> [Numeric, Numeric]'
  type :eql?, '(Numeric) -> %bool'
  type :fdiv, '(Numeric) -> Float'
  type :floor, '() -> Integer'
  type :i, '() -> Complex'
  type :imag, '() -> 0'
  rdl_alias :imaginary, :imag
  # initialize_copy can't be invoked
  type :integer?, '() -> %bool'
  type :magnitude, '() -> Numeric'
  type :modulo, '(Numeric) -> %real'
  type :nonzero?, '() -> self or nil'
  type :numerator, '() -> Integer'
  type :phase, '() -> 0 or ${Math::PI}'
  type :polar, '() -> [Numeric, Numeric]'
  type :quo, '(Integer or Rational) -> Rational'
  type :quo, '(Float) -> Float'
  type :real, '() -> self'
  type :rect, '() -> [Numeric, 0]'
  rdl_alias :rectangular, :rect
  type :remainder, '(Numeric) -> %real'
  type :round, '(?Fixnum "ndigits") -> Integer or Float'
  # singleton_method_added can't be invoked
  #  type :step, # TODO: hash args
  type :to_c, '() -> Complex'
  type :to_int, '() -> Integer'
  type :truncate, '() -> Integer'
  type :zero?, '() -> %bool'
end