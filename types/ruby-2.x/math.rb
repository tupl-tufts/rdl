module Math
  rdl_nowrap

  type 'self.acos', '(%real x) -> Float'
  pre('self.acos') { |x| -1 <= x && x <= 1 }
  post('self.acos') { |r, _| 0 <= r && r <= Math::PI }
  type 'self.acosh', '(%real x) -> Float'
  pre('self.acosh') { |x| 1 <= x }
  post('self.acosh') { |r, _| 0 <= r }
  type 'self.asin', '(%real x) -> Float'
  pre('self.asin') { |x| -1 <= x && x <= 1 }
  post('self.asin') { |r, _| -Math::PI/2 <= r && r <= Math::PI/2 }
  type 'self.asinh', '(%real x) -> Float'
  type 'self.atan', '(%real x) -> Float'
  post('self.atan') { |r, _| -Math::PI/2 <= r && r <= Math::PI/2 }
  type 'self.atan2', '(%real y, %real x) -> Float'
  post('self.atan2') { |r, _| -Math::PI <= r && r <= Math::PI }
  type 'self.atanh', '(%real x) -> Float'
  pre('self.atanh') { |x| -1 < x && x < 1 }
  type 'self.cbrt', '(%real x) -> Float'
  pre('self.cbrt') { |x| 0 <= x }
  post('self.cbrt') { |x| 0 <= x }
  type 'self.cos', '(%real x) -> Float'
  post('self.cos') { |r, _| -1 <= r && r <= 1 }
  type 'self.cosh', '(%real x) -> Float'
  post('self.cosh') { |r, _| 1 <= r }
  type 'self.erf', '(%real x) -> Float'
  post('self.erf') { |r, _| -1 < r && r < 1 }
  type 'self.erfc', '(%real x) -> Float'
  post('self.erfc') { |r, _| 0 < r && r < 2 }
  type 'self.exp', '(%real x) -> Float'
  post('self.exp') { |r, _| 0 < r }
  type 'self.frexp', '(%real x) -> [%real, %real]'
  type 'self.gamma', '(%real x) -> Float'
  type 'self.hypot', '(%real x, %real y) -> Float'
  type 'self.ldexp', '(%real fraction, %real exponent) -> Float'
  type 'self.lgamma', '(%real x) -> -1 or 1 or Float'
  type 'self.log', '(%real x, ?(%real) base) -> Float'
  type 'self.log10', '(%real x) -> Float'
  pre('self.log10') { |x| 0 < x }
  type 'self.log2', '(%real x) -> Float'
  pre('self.log2') { |x| 0 < x }
  type 'self.sin', '(%real x) -> Float'
  post('self.sin') { |r, _| -1 <= r && r <= 1 }
  type 'self.sinh', '(%real x) -> Float'
  type 'self.sqrt', '(%real x) -> Float'
  pre('self.sqrt') { |x| 0 <= x }
  post('self.sqrt') { |r, _| 0 <= r }
  type 'self.tan', '(%real x) -> Float'
  type 'self.tanh', '(%real x) -> Float'
  post('self.tanh') { |r, _| -1 < r && r < 1 }

end
