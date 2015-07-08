module Math
  type 'self.acos', '(x: Float or Integer) -> Float'
  pre('self.acos') { |x| -1 <= x && x <= 1 }
  post('self.acos') { |r, _| 0 <= r && r <= Math::PI }
  type 'self.acosh', '(x: Float or Integer) -> Float'
  pre('self.acosh') { |x| 1 <= x }
  post('self.acosh') { |r, _| 0 <= r }
  type 'self.asin', '(x: Float or Integer) -> Float'
  pre('self.asin') { |x| -1 <= x && x <= 1 }
  post('self.asin') { |r, _| -Math::PI/2 <= r && r <= Math::PI/2 }
  type 'self.asinh', '(x: Float or Integer) -> Float'
  type 'self.atan', '(x: Float or Integer) -> Float'
  post('self.atan') { |r, _| -Math::PI/2 <= r && r <= Math::PI/2 }
  type 'self.atan2', '(y: Float or Integer, x: Float or Integer) -> Float'
  post('self.atan2') { |r, _| -Math::PI <= r && r <= Math::PI }
  type 'self.atanh', '(x: Float or Integer) -> Float'
  pre('self.atanh') { |x| -1 < x && x < 1 }
  type 'self.cbrt', '(x: Integer or Float) -> Float'
  pre('self.cbrt') { |x| 0 <= x }
  post('self.cbrt') { |x| 0 <= x }
  type 'self.cos', '(x: Float or Integer) -> Float'
  post('self.cos') { |r, _| -1 <= r && r <= 1 }
  type 'self.cosh', '(x: Float or Integer) -> Float'
  post('self.cosh') { |r, _| 1 <= r }
  type 'self.erf', '(x: Float or Integer) -> Float'
  post('self.erf') { |r, _| -1 < r && r < 1 }
  type 'self.erfc', '(x: Float or Integer) -> Float'
  post('self.erfc') { |r, _| 0 < r && r < 2 }
  type 'self.exp', '(x: Float or Integer) -> Float'
  post('self.exp') { |r, _| 0 < r }
  type 'self.frexp', '(x: Float or Integer) -> [Float or Integer, Float or Integer]'
  type 'self.gamma', '(x: Float or Integer) -> Float'
  type 'self.hypot', '(x: Float or Integer, y: Float or Integer) -> Float'
  type 'self.ldexp', '(fraction: Float or Integer, exponent: Float or Integer) -> Float'
  type 'self.lgamma', '(x: Float or Integer) -> -1 or 1 or Float'
  type 'self.log', '(x: Float or Integer, base: ?(Float or Integer)) -> Float'
  type 'self.log10', '(x: Float or Integer) -> Float'
  pre('self.log10') { |x| 0 < x }
  type 'self.log2', '(x: Float or Integer) -> Float'
  pre('self.log2') { |x| 0 < x }
  type 'self.sin', '(x: Float or Integer) -> Float'
  post('self.sin') { |r, _| -1 <= r && r <= 1 }
  type 'self.sinh', '(x: Float or Integer) -> Float'
  type 'self.sqrt', '(x: Float or Integer) -> Float'
  pre('self.sqrt') { |x| 0 <= x }
  post('self.sqrt') { |r, _| 0 <= r }
  type 'self.tan', '(x: Float or Integer) -> Float'
  type 'self.tanh', '(x: Float or Integer) -> Float'
  post('self.tanh') { |r, _| -1 < r && r < 1 }

end