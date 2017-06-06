RDL.nowrap :Math

RDL.type :Math, 'self.acos', '(%real x) -> Float'
RDL.pre(:Math, 'self.acos') { |x| -1 <= x && x <= 1 }
RDL.post(:Math, 'self.acos') { |r, _| 0 <= r && r <= Math::PI }
RDL.type :Math, 'self.acosh', '(%real x) -> Float'
RDL.pre(:Math, 'self.acosh') { |x| 1 <= x }
RDL.post(:Math, 'self.acosh') { |r, _| 0 <= r }
RDL.type :Math, 'self.asin', '(%real x) -> Float'
RDL.pre(:Math, 'self.asin') { |x| -1 <= x && x <= 1 }
RDL.post(:Math, 'self.asin') { |r, _| -Math::PI/2 <= r && r <= Math::PI/2 }
RDL.type :Math, 'self.asinh', '(%real x) -> Float'
RDL.type :Math, 'self.atan', '(%real x) -> Float'
RDL.post(:Math, 'self.atan') { |r, _| -Math::PI/2 <= r && r <= Math::PI/2 }
RDL.type :Math, 'self.atan2', '(%real y, %real x) -> Float'
RDL.post(:Math, 'self.atan2') { |r, _| -Math::PI <= r && r <= Math::PI }
RDL.type :Math, 'self.atanh', '(%real x) -> Float'
RDL.pre(:Math, 'self.atanh') { |x| -1 < x && x < 1 }
RDL.type :Math, 'self.cbrt', '(%real x) -> Float'
RDL.pre(:Math, 'self.cbrt') { |x| 0 <= x }
RDL.post(:Math, 'self.cbrt') { |x| 0 <= x }
RDL.type :Math, 'self.cos', '(%real x) -> Float'
RDL.post(:Math, 'self.cos') { |r, _| -1 <= r && r <= 1 }
RDL.type :Math, 'self.cosh', '(%real x) -> Float'
RDL.post(:Math, 'self.cosh') { |r, _| 1 <= r }
RDL.type :Math, 'self.erf', '(%real x) -> Float'
RDL.post(:Math, 'self.erf') { |r, _| -1 < r && r < 1 }
RDL.type :Math, 'self.erfc', '(%real x) -> Float'
RDL.post(:Math, 'self.erfc') { |r, _| 0 < r && r < 2 }
RDL.type :Math, 'self.exp', '(%real x) -> Float'
RDL.post(:Math, 'self.exp') { |r, _| 0 < r }
RDL.type :Math, 'self.frexp', '(%real x) -> [%real, %real]'
RDL.type :Math, 'self.gamma', '(%real x) -> Float'
RDL.type :Math, 'self.hypot', '(%real x, %real y) -> Float'
RDL.type :Math, 'self.ldexp', '(%real fraction, %real exponent) -> Float'
RDL.type :Math, 'self.lgamma', '(%real x) -> -1 or 1 or Float'
RDL.type :Math, 'self.log', '(%real x, ?(%real) base) -> Float'
RDL.type :Math, 'self.log10', '(%real x) -> Float'
RDL.pre(:Math, 'self.log10') { |x| 0 < x }
RDL.type :Math, 'self.log2', '(%real x) -> Float'
RDL.pre(:Math, 'self.log2') { |x| 0 < x }
RDL.type :Math, 'self.sin', '(%real x) -> Float'
RDL.post(:Math, 'self.sin') { |r, _| -1 <= r && r <= 1 }
RDL.type :Math, 'self.sinh', '(%real x) -> Float'
RDL.type :Math, 'self.sqrt', '(%real x) -> Float'
RDL.pre(:Math, 'self.sqrt') { |x| 0 <= x }
RDL.post(:Math, 'self.sqrt') { |r, _| 0 <= r }
RDL.type :Math, 'self.tan', '(%real x) -> Float'
RDL.type :Math, 'self.tanh', '(%real x) -> Float'
RDL.post(:Math, 'self.tanh') { |r, _| -1 < r && r < 1 }
