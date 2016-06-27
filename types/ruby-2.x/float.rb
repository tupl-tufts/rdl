class Float < Numeric
  rdl_nowrap

  type :%, '(%integer) -> Float'
  pre(:%) { |x| x!=0}
  type :%, '(Float) -> Float'
  pre(:%) { |x| x!=0}
  type :%, '(Rational) -> Float'
  pre(:%) { |x| x!=0}
  type :%, '(BigDecimal) -> BigDecimal'
  pre(:%) { |x| x!=0 && self !=Float::INFINITY && !self.nan?}

  type :*, '(%integer) -> Float'
  type :*, '(Float) -> Float'
  type :*, '(Rational) -> Float'
  type :*, '(BigDecimal) -> BigDecimal'
  pre(:*) { self!=Float::INFINITY && !(self.nan?)}
  type :*, '(Complex) -> Complex'
  pre(:*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

  type :**, '(%integer) -> Float'
  type :**, '(Float) -> %numeric'
  type :**, '(Rational) -> %numeric'
  type :**, '(BigDecimal) -> BigDecimal'
  pre(:**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
  post(:**) { |x| x.real?}
  type :**, '(Complex) -> Complex'
  pre(:**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end}

  type :+, '(%integer) -> Float'
  type :+, '(Float) -> Float'
  type :+, '(Rational) -> Float'
  type :+, '(BigDecimal) -> BigDecimal'
  pre(:+) { self!=Float::INFINITY && !(self.nan?)}
  type :+, '(Complex) -> Complex'
  pre(:+) { |x| if x.real.is_a?(BigDecimal) then self!=Float::INFINITY && !(self.nan?) else true end}

  type :-, '(%integer) -> Float'
  type :-, '(Float) -> Float'
  type :-, '(Rational) -> Float'
  type :-, '(BigDecimal) -> BigDecimal'
  pre(:-) { self!=Float::INFINITY && !(self.nan?)}
  type :-, '(Complex) -> Complex'
  pre(:-) { |x| if x.real.is_a?(BigDecimal) then self!=Float::INFINITY && !(self.nan?) else true end}

  type :-, '() -> Float'

  type :/, '(%integer) -> Float'
  pre(:/) { |x| x!=0}
  type :/, '(Float) -> Float'
  pre(:/) { |x| x!=0}
  type :/, '(Rational) -> Float'
  pre(:/) { |x| x!=0}
  type :/, '(BigDecimal) -> BigDecimal'
  pre(:/) { |x| x!=0 && self!=Float::INFINITY && !self.nan?}
  type :/, '(Complex) -> Complex'
  pre(:/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :<, '(%integer) -> %bool'
  type :<, '(Float) -> %bool'
  type :<, '(Rational) -> %bool'
  type :<, '(BigDecimal) -> %bool'
  pre(:<) { !self.nan? && self!=Float::INFINITY}

  type :<=, '(%integer) -> %bool'
  type :<=, '(Float) -> %bool'
  type :<=, '(Rational) -> %bool'
  type :<=, '(BigDecimal) -> %bool'
  pre(:<=) { !self.nan? && self!=Float::INFINITY}

  type :<=>, '(%integer) -> Object'
  post(:<=>) { |x| x == -1 || x==0 || x==1}
  type :<=>, '(Float) -> Object'
  post(:<=>) { |x| x == -1 || x==0 || x==1}
  type :<=>, '(Rational) -> Object'
  post(:<=>) { |x| x == -1 || x==0 || x==1}
  type :<=>, '(BigDecimal) -> Object'
  pre(:<=>) { !self.nan? && self!=Float::INFINITY}
  post(:<=>) { |x| x == -1 || x==0 || x==1}

  type :==, '(Object) -> %bool'
  pre(:==) { |x| if (x.is_a?(BigDecimal)) then (!self.nan? && self!=Float::INFINITY) else true end}

  type :===, '(Object) -> %bool'
  pre(:===) { |x| if (x.is_a?(BigDecimal)) then (!self.nan? && self!=Float::INFINITY) else true end}

  type :>, '(%integer) -> %bool'
  type :>, '(Float) -> %bool'
  type :>, '(Rational) -> %bool'
  type :>, '(BigDecimal) -> %bool'
  pre(:>) { !self.nan? && self!=Float::INFINITY}

  type :>=, '(%integer) -> %bool'
  type :>=, '(Float) -> %bool'
  type :>=, '(Rational) -> %bool'
  type :>=, '(BigDecimal) -> %bool'
  pre(:>=) { !self.nan? && self!=Float::INFINITY}

  type :abs, '() -> Float'
  post(:abs) { |x| x >= 0 }

  type :abs2, '() -> Float'
  post(:abs2) { |x| x >= 0 }

  type :div, '(Fixnum) -> %integer'
  pre(:div) { |x| x!=0 && self!=Float::INFINITY && !self.nan?}
  type :div, '(Bignum) -> %integer'
  pre(:div) { |x| x!=0 && self!=Float::INFINITY && !self.nan?}
  type :div, '(Float) -> %integer'
  pre(:div) { |x| x!=0 && self!=Float::INFINITY && !self.nan?}
  type :div, '(Rational) -> %integer'
  pre(:div) { |x| x!=0 && self!=Float::INFINITY && !self.nan?}
  type :div, '(BigDecimal) -> %integer'
  pre(:div) { |x| x!=0 && !x.nan? && self!=Float::INFINITY && !self.nan?}

  type :divmod, '(%real) -> [%real, %real]'
  pre(:divmod) { |x| x!=0 && if x.is_a?(Float) then !x.nan? else true end && self!=Float::INFINITY && !self.nan?}

  type :angle, '() -> %numeric'
  post(:angle) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

  type :arg, '() -> %numeric'
  post(:arg) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

  type :ceil, '() -> %integer'
  pre(:ceil) { self!=Float::INFINITY && !self.nan?}

  type :coerce, '(%real) -> [Float, Float]'

  type :denominator, '() -> %integer'
  post(:denominator) { |r,x| r > 0 }

  type :equal?, '(Object) -> %bool'

  type :eql?, '(Object) -> %bool'

  type :fdiv, '(%integer) -> Float'
  type :fdiv, '(Float) -> Float'
  type :fdiv, '(Rational) -> Float'
  type :fdiv, '(BigDecimal) -> BigDecimal'
  pre(:fdiv) { self!=Float::INFINITY && !self.nan?}
  type :fdiv, '(Complex) -> Complex'
  pre(:fdiv) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :finite?, '() -> %bool'

  type :floor, '() -> %integer'
  pre(:ceil) { self!=Float::INFINITY && !self.nan?}

  type :hash, '() -> %integer'

  type :infinite?, '() -> Object'
  post(:infinite?) { |r,x| r == -1 || r == 1 || r == nil }

  type :to_s, '() -> String'
  type :inspect, '() -> String'

  type :magnitude, '() -> Float'
  post(:magnitude) { |r,x| r>=0 }

  type :modulo, '(%integer) -> Float'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(Float) -> Float'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(Rational) -> Float'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(BigDecimal) -> BigDecimal'
  pre(:modulo) { |x| x!=0 && self!=Float::INFINITY && !self.nan?}

  type :nan?, '() -> %bool'

  type :next_float, '() -> Float'

  type :numerator, '() -> %integer'

  type :phase, '() -> %numeric'
  post(:phase) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

  type :prev_float, '() -> Float'

  type :quo, '(%integer) -> Float'
  pre(:quo) { |x| x!=0}
  type :quo, '(Float) -> Float'
  pre(:quo) { |x| x!=0}
  type :quo, '(Rational) -> Float'
  pre(:quo) { |x| x!=0}
  type :quo, '(BigDecimal) -> BigDecimal'
  pre(:quo) { |x| x!=0 && self!=Float::INFINITY && !self.nan?}
  type :quo, '(Complex) -> Complex'
  pre(:quo) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :rationalize, '() -> Rational'
  pre(:rationalize) { self!=Float::INFINITY && !self.nan?}

  type :rationalize, '(%numeric) -> Rational'
  pre(:rationalize) { |x| if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end}

  type :round, '() -> %integer'
  pre(:round) { self!=Float::INFINITY && !self.nan?}

  type :round, '(%numeric) -> %numeric'
  pre(:round) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

  type :to_f, '() -> Float'

  type :to_i, '() -> %integer'
  pre(:to_i) { self!=Float::INFINITY && !self.nan?}

  type :to_int, '() -> %integer'
  pre(:to_int) { self!=Float::INFINITY && !self.nan?}

  type :to_r, '() -> Rational'
  pre(:to_r) { self!=Float::INFINITY && !self.nan?}

  type :truncate, '() -> %integer'

  type :zero?, '() -> %bool'

  type :conj, '() -> Float'
  type :conjugate, '() -> Float'

  type :imag, '() -> Fixnum'
  post(:imag) { |r,x| r == 0 }
  type :imaginary, '() -> Fixnum'
  post(:imaginary) { |r,x| r == 0 }

  type :real, '() -> Float'

  type :real?, '() -> true'

  type :to_c, '() -> Complex'
  post(:to_c) { |r,x| r.imaginary == 0 }

  type :coerce, '(%numeric) -> [Float, Float]'
  pre(:coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
end
