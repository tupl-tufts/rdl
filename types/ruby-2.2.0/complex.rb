class Complex
  type 'self.polar', '(abs: Numeric, arg: ?Numeric) -> Complex'
  type 'self.rect', '(real: Numeric, imag: ?Numeric) -> Complex'
  pre('self.rect') { |r, i| r.real? && ((not i) || (i.real?)) }
  rdl_alias 'self.rectangular', 'self.rect'
  type :*, '(Numeric) -> Complex'
  type :**, '(Numeric) -> Complex'
  type :+, '(Numeric) -> Complex'
  type :-, '(Numeric) -> Complex'
  type :-, '() -> Complex'
  type :/, '(Numeric) -> Complex'
  type :==, '(object: %any) -> %bool'
  type :abs, '() -> Numeric'
  post(:abs) { |r, _| r.real? }
  type :abs2, '() -> Numeric'
  post(:abs) { |r, _| r.real? && r > 0 }
  type :angle, '() -> Float'
  type :arg, '() -> Float'
  type :conj, '() -> Complex'
  rdl_alias :conjugate, :conj
  type :denominator, '() -> Integer'
  type :fdiv, '(Numeric) -> Complex'
  type :imag, '() -> Numeric'
  post(:imag) { |r, _| r.real? }
  rdl_alias :imaginary, :imag
  type :inspect, '() -> String'
  type :magnitude, '() -> Numeric'
  post(:magnitude) { |r, _| r.real? }
  type :numerator, '() -> Numeric'
  type :phase, '() -> Float'
  type :polar, '() -> [Integer or Float, Integer or Float]'
  rdl_alias :quo, :/
  type :rationalize, '(eps: ?Numeric) -> Rational'
  type :real, '() -> Numeric'
  post(:real) { |r, _| r.real? }
  type :real?, '() -> FalseClass'
  type :rect, '() -> [Integer or Float, Integer or Float]'
  type :to_c, '() -> self'
  type :to_f, '() -> Float'
  type :to_i, '() -> Integer'
  type :to_r, '() -> Rational'
  type :to_s, '() -> String'
end