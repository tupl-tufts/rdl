rdl_nowrap :Math

type :Math, 'self.acos', '(%real x) -> Float'
pre(:Math, 'self.acos') { |x| -1 <= x && x <= 1 }
post(:Math, 'self.acos') { |r, _| 0 <= r && r <= Math::PI }
type :Math, 'self.acosh', '(%real x) -> Float'
pre(:Math, 'self.acosh') { |x| 1 <= x }
post(:Math, 'self.acosh') { |r, _| 0 <= r }
type :Math, 'self.asin', '(%real x) -> Float'
pre(:Math, 'self.asin') { |x| -1 <= x && x <= 1 }
post(:Math, 'self.asin') { |r, _| -Math::PI/2 <= r && r <= Math::PI/2 }
type :Math, 'self.asinh', '(%real x) -> Float'
type :Math, 'self.atan', '(%real x) -> Float'
post(:Math, 'self.atan') { |r, _| -Math::PI/2 <= r && r <= Math::PI/2 }
type :Math, 'self.atan2', '(%real y, %real x) -> Float'
post(:Math, 'self.atan2') { |r, _| -Math::PI <= r && r <= Math::PI }
type :Math, 'self.atanh', '(%real x) -> Float'
pre(:Math, 'self.atanh') { |x| -1 < x && x < 1 }
type :Math, 'self.cbrt', '(%real x) -> Float'
pre(:Math, 'self.cbrt') { |x| 0 <= x }
post(:Math, 'self.cbrt') { |x| 0 <= x }
type :Math, 'self.cos', '(%real x) -> Float'
post(:Math, 'self.cos') { |r, _| -1 <= r && r <= 1 }
type :Math, 'self.cosh', '(%real x) -> Float'
post(:Math, 'self.cosh') { |r, _| 1 <= r }
type :Math, 'self.erf', '(%real x) -> Float'
post(:Math, 'self.erf') { |r, _| -1 < r && r < 1 }
type :Math, 'self.erfc', '(%real x) -> Float'
post(:Math, 'self.erfc') { |r, _| 0 < r && r < 2 }
type :Math, 'self.exp', '(%real x) -> Float'
post(:Math, 'self.exp') { |r, _| 0 < r }
type :Math, 'self.frexp', '(%real x) -> [%real, %real]'
type :Math, 'self.gamma', '(%real x) -> Float'
type :Math, 'self.hypot', '(%real x, %real y) -> Float'
type :Math, 'self.ldexp', '(%real fraction, %real exponent) -> Float'
type :Math, 'self.lgamma', '(%real x) -> -1 or 1 or Float'
type :Math, 'self.log', '(%real x, ?(%real) base) -> Float'
type :Math, 'self.log10', '(%real x) -> Float'
pre(:Math, 'self.log10') { |x| 0 < x }
type :Math, 'self.log2', '(%real x) -> Float'
pre(:Math, 'self.log2') { |x| 0 < x }
type :Math, 'self.sin', '(%real x) -> Float'
post(:Math, 'self.sin') { |r, _| -1 <= r && r <= 1 }
type :Math, 'self.sinh', '(%real x) -> Float'
type :Math, 'self.sqrt', '(%real x) -> Float'
pre(:Math, 'self.sqrt') { |x| 0 <= x }
post(:Math, 'self.sqrt') { |r, _| 0 <= r }
type :Math, 'self.tan', '(%real x) -> Float'
type :Math, 'self.tanh', '(%real x) -> Float'
post(:Math, 'self.tanh') { |r, _| -1 < r && r < 1 }
