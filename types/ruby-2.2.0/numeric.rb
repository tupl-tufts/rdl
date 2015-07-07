class Numeric
  type :modulo, '(Numeric) -> Numeric'
  post(:modulo) { |r, _| r.real? } # Return value real
  type :+, '() -> self'
  type :-, '() -> Numeric'
  type :<=>, '(Numeric) -> -1 or 0 or 1 or nil'
  type :abs, '() -> Numeric'
  type :abs2, '() -> Numeric'
  post(:abs2) { |r, _| r.real? } # Return value real
  type :angle, '() -> 0 or Float' # Float is pi
  type :arg, '() -> 0 or Float' # Float is pi
  type :ceil, '() -> Integer'
  type :coerce, '(Numeric) -> [Numeric, Numeric]'
  type :conj, '() -> self'
  rdl_alias :conjugate, :conj
  type :denominator, '() -> Integer'
  post(:denominator) { |r, _| r > 0 } # Return is always positive
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
  type :modulo, '(Numeric) -> Numeric'
  post(:modulo) { |r, _| r.real? } # Return value real
  type :nonzero?, '() -> self or nil'
  type :numerator, '() -> Integer'
  type :phase, '() -> 0 or Float' # Float is pi
  type :polar, '() -> [Numeric, Numeric]'
  type :quo, '(Integer or Rational) -> Rational'
  type :quo, '(Float) -> Float'
  type :real, '() -> self'
  type :rect, '() -> [Numeric, 0]'
  rdl_alias :rectangular, :rect
  type :remainder, '(Numeric) -> Numeric'
  post(:remainder) { |r, _| r.real? } # Return value real
  type :round, '(ndigits: ?Fixnum) -> Integer or Float'
  # singleton_method_added can't be invoked
  #  type :step, # TODO: hash args
  type :to_c, '() -> Complex'
  type :to_int, '() -> Integer'
  type :truncate, '() -> Integer'
  type :zero?, '() -> %bool'
end