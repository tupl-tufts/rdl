class Float < Numeric
  rdl_nowrap

  type :%, '(Integer) -> Float'
  pre(:%) { |x| x!=0}
  type :%, '(Float) -> Float'
  pre(:%) { |x| x!=0}
  type :%, '(Rational) -> Float'
  pre(:%) { |x| x!=0}
  type :%, '(BigDecimal) -> BigDecimal'
  pre(:%) { |x| x!=0 && self !=Float::INFINITY && !self.nan?}

  type :*, '(Integer) -> Float'
  type :*, '(Float) -> Float'
  type :*, '(Rational) -> Float'
  type :*, '(BigDecimal) -> BigDecimal'
  pre(:*) { self!=Float::INFINITY && !(self.nan?)}
  type :*, '(Complex) -> Complex'
  pre(:*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

  type :**, '(Integer) -> Float'
  type :**, '(Float) -> Numeric'
  type :**, '(Rational) -> Numeric'
  type :**, '(BigDecimal) -> BigDecimal'
  pre(:**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
  post(:**) { |x| x.real?}
  type :**, '(Complex) -> Complex'
  pre(:**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end}

  type :+, '(Integer) -> Float'
  type :+, '(Float) -> Float'
  type :+, '(Rational) -> Float'
  type :+, '(BigDecimal) -> BigDecimal'
  pre(:+) { self!=Float::INFINITY && !(self.nan?)}
  type :+, '(Complex) -> Complex'
  pre(:+) { |x| if x.real.is_a?(BigDecimal) then self!=Float::INFINITY && !(self.nan?) else true end}

  type :-, '(Integer) -> Float'
  type :-, '(Float) -> Float'
  type :-, '(Rational) -> Float'
  type :-, '(BigDecimal) -> BigDecimal'
  pre(:-) { self!=Float::INFINITY && !(self.nan?)}
  type :-, '(Complex) -> Complex'
  pre(:-) { |x| if x.real.is_a?(BigDecimal) then self!=Float::INFINITY && !(self.nan?) else true end}

  type :-, '() -> Float'

  type :/, '(Integer) -> Float'
  pre(:/) { |x| x!=0}
  type :/, '(Float) -> Float'
  pre(:/) { |x| x!=0}
  type :/, '(Rational) -> Float'
  pre(:/) { |x| x!=0}
  type :/, '(BigDecimal) -> BigDecimal'
  pre(:/) { |x| x!=0 && self!=Float::INFINITY && !self.nan?}
  type :/, '(Complex) -> Complex'
  pre(:/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :<, '(Integer) -> %bool' 
  type :<, '(Float) -> %bool'
  type :<, '(Rational) -> %bool'
  type :<, '(BigDecimal) -> %bool'
  pre(:<) { !self.nan? && self!=Float::INFINITY}

  type :<=, '(Integer) -> %bool'
  type :<=, '(Float) -> %bool'
  type :<=, '(Rational) -> %bool'
  type :<=, '(BigDecimal) -> %bool'
  pre(:<=) { !self.nan? && self!=Float::INFINITY}

  type :<=>, '(Integer) -> Object'
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

  type :>, '(Integer) -> %bool'
  type :>, '(Float) -> %bool'
  type :>, '(Rational) -> %bool'
  type :>, '(BigDecimal) -> %bool'
  pre(:>) { !self.nan? && self!=Float::INFINITY}

  type :>=, '(Integer) -> %bool'
  type :>=, '(Float) -> %bool'
  type :>=, '(Rational) -> %bool'
  type :>=, '(BigDecimal) -> %bool'
  pre(:>=) { !self.nan? && self!=Float::INFINITY}

  type :abs, '() -> Float'
  post(:abs) { |x| x >= 0 }

  type :abs2, '() -> Float'
  post(:abs2) { |x| x >= 0 }

  type :div, '(Fixnum) -> Integer'
  pre(:div) { |x| x!=0 && self!=Float::INFINITY && !self.nan?}
  type :div, '(Bignum) -> Integer'
  pre(:div) { |x| x!=0 && self!=Float::INFINITY && !self.nan?}
  type :div, '(Float) -> Integer'
  pre(:div) { |x| x!=0 && self!=Float::INFINITY && !self.nan?}
  type :div, '(Rational) -> Integer'
  pre(:div) { |x| x!=0 && self!=Float::INFINITY && !self.nan?}
  type :div, '(BigDecimal) -> Integer'
  pre(:div) { |x| x!=0 && !x.nan? && self!=Float::INFINITY && !self.nan?}

  type :divmod, '(%real) -> [%real, %real]'
  pre(:divmod) { |x| x!=0 && if x.is_a?(Float) then !x.nan? else true end && self!=Float::INFINITY && !self.nan?}

  type :angle, '() -> Numeric'
  post(:angle) { |x| x == 0 || x == Math::PI || x == Float::NAN}

  type :arg, '() -> Numeric'
  post(:arg) { |x| x == 0 || x == Math::PI || x == Float::NAN}

  type :ceil, '() -> Integer'
  pre(:ceil) { self!=Float::INFINITY && !self.nan?}

  type :coerce, '(%real) -> [Float, Float]'

  type :denominator, '() -> Integer'
  post(:denominator) { |r| r > 0 }

  type :equal?, '(Object) -> %bool'

  type :eql?, '(Object) -> %bool' 

  type :fdiv, '(Integer) -> Float'
  type :fdiv, '(Float) -> Float'
  type :fdiv, '(Rational) -> Float'
  type :fdiv, '(BigDecimal) -> BigDecimal'
  pre(:fdiv) { self!=Float::INFINITY && !self.nan?}
  type :fdiv, '(Complex) -> Complex'
  pre(:fdiv) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :finite?, '() -> %bool'

  type :floor, '() -> Integer'
  pre(:ceil) { self!=Float::INFINITY && !self.nan?}

  type :hash, '() -> Integer'

  type :infinite?, '() -> Object'
  post(:infinite?) { |x| x == -1 || x == 1 || x == nil }

  type :to_s, '() -> String'
  type :inspect, '() -> String'

  type :magnitude, '() -> Float'
  post(:magnitude) { |x| x>=0 }

  type :modulo, '(Integer) -> Float'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(Float) -> Float'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(Rational) -> Float'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(BigDecimal) -> BigDecimal'
  pre(:modulo) { |x| x!=0 && self!=Float::INFINITY && !self.nan?}

  type :nan?, '() -> %bool'

  type :next_float, '() -> Float'

  type :numerator, '() -> Integer'

  type :phase, '() -> Numeric'
  post(:angle) { |x| x == 0 || x == Math::PI || x == Float::NAN}

  type :prev_float, '() -> Float'

  type :quo, '(Integer) -> Float'
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

  type :rationalize, '(Numeric) -> Rational'
  pre(:rationalize) { |x| if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end}

  type :round, '() -> Integer'
  pre(:round) { self!=Float::INFINITY && !self.nan?}

  type :round, '(Numeric) -> Numeric'
  pre(:round) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

  type :to_f, '() -> Float'

  type :to_i, '() -> Integer'
  pre(:to_i) { self!=Float::INFINITY && !self.nan?}

  type :to_int, '() -> Integer'
  pre(:to_int) { self!=Float::INFINITY && !self.nan?}

  type :to_r, '() -> Rational'
  pre(:to_r) { self!=Float::INFINITY && !self.nan?}

  type :truncate, '() -> Integer'

  type :zero?, '() -> %bool'

  type :conj, '() -> Float'
  type :conjugate, '() -> Float'

  type :imag, '() -> Fixnum'
  post(:imag) { |x| x == 0 }
  type :imaginary, '() -> Fixnum'
  post(:imaginary) { |x| x == 0 }

  type :real, '() -> Float'

  type :real?, '() -> TrueClass'

  type :to_c, '() -> Complex'
  post(:to_c) { |x| x.imaginary == 0 }

  type :coerce, '(Numeric) -> [Float, Float]'
  pre(:coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
end
