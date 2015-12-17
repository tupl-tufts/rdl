class Complex
  rdl_nowrap

  type 'self.polar', '(%real abs, ?%real arg) -> Complex'
  type 'self.rect', '(%real real, ?%real imag) -> Complex'
  pre('self.rect') { |r, i| (not i) || (i.real?) }
  rdl_alias 'self.rectangular', 'self.rect'
  type :*, '(Numeric) -> Complex'
  type :**, '(Numeric) -> Complex'
  type :+, '(Numeric) -> Complex'
  type :-, '(Numeric) -> Complex'
  type :-, '() -> Complex'
  type :/, '(Numeric) -> Complex'
  type :==, '(%any object) -> %bool'
  type :abs, '() -> %real'
  post(:abs) { |r| r >= 0 }
  type :abs2, '() -> %real'
  post(:abs2) { |r| r >= 0 }
  type :angle, '() -> Float'
  type :arg, '() -> Float'
  type :conj, '() -> Complex'
  rdl_alias :conjugate, :conj
  type :denominator, '() -> Integer'
  type :fdiv, '(Numeric) -> Complex'
  type :imag, '() -> %real'
  rdl_alias :imaginary, :imag
  type :inspect, '() -> String'
  type :magnitude, '() -> %real'
  type :numerator, '() -> Numeric'
  type :phase, '() -> Float'
  type :polar, '() -> [%real, %real]'
  rdl_alias :quo, :/
  type :rationalize, '(?Numeric eps) -> Rational'
  type :real, '() -> %real'
  type :real?, '() -> FalseClass'
  type :rect, '() -> [%real, %real]'
  type :to_c, '() -> self'
  type :to_f, '() -> Float'
  type :to_i, '() -> Integer'
  type :to_r, '() -> Rational'
  type :to_s, '() -> String'
end
