class Float < Numeric
  rdl_nowrap

  type :%, '(%integer x {{ x != 0 }}) -> Float'
  type :%, '(Float x {{ x != 0 }}) -> Float'
  type :%, '(Rational x {{ x != 0 }}) -> Float'
  type :%, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> BigDecimal'

  type :*, '(%integer) -> Float'
  type :*, '(Float) -> Float'
  type :*, '(Rational) -> Float'
  type :*, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> BigDecimal'
  type :*, '(Complex) -> Complex'
  pre(:*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

  type :**, '(%integer) -> Float'
  type :**, '(Float) -> %numeric'
  type :**, '(Rational) -> %numeric'
  type :**, '(BigDecimal) -> BigDecimal'
  pre(:**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
  post(:**) { |x| x.real?}
  type :**, '(Complex) -> Complex'
  pre(:**) { |x| x != 0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end}

  type :+, '(%integer) -> Float'
  type :+, '(Float) -> Float'
  type :+, '(Rational) -> Float'
  type :+, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> BigDecimal'
  type :+, '(Complex) -> Complex'
  pre(:+) { |x| if x.real.is_a?(BigDecimal) then self!=Float::INFINITY && !(self.nan?) else true end}

  type :-, '(%integer) -> Float'
  type :-, '(Float) -> Float'
  type :-, '(Rational) -> Float'
  type :-, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> BigDecimal'
  type :-, '(Complex) -> Complex'
  pre(:-) { |x| if x.real.is_a?(BigDecimal) then self!=Float::INFINITY && !(self.nan?) else true end}

  type :-, '() -> Float'

  type :/, '(%integer x {{ x != 0 }}) -> Float'
  type :/, '(Float x {{ x != 0 }}) -> Float'
  type :/, '(Rational x {{ x != 0 }}) -> Float'
  type :/, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> BigDecimal'
  type :/, '(Complex x {{ x != 0 }}) -> Complex'
  pre(:/) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :<, '(%integer) -> %bool'
  type :<, '(Float) -> %bool'
  type :<, '(Rational) -> %bool'
  type :<, '(BigDecimal x {{ !self.nan? && !self.infinite? }}) -> %bool'

  type :<=, '(%integer) -> %bool'
  type :<=, '(Float) -> %bool'
  type :<=, '(Rational) -> %bool'
  type :<=, '(BigDecimal x {{ !self.nan? && !self.infinite? }}) -> %bool'

  type :<=>, '(%integer) -> Object'
  post(:<=>) { |x| x == -1 || x==0 || x==1}
  type :<=>, '(Float) -> Object'
  post(:<=>) { |x| x == -1 || x==0 || x==1}
  type :<=>, '(Rational) -> Object'
  post(:<=>) { |x| x == -1 || x==0 || x==1}
  type :<=>, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> Object'
  post(:<=>) { |x| x == -1 || x==0 || x==1}

  type :==, '(Object) -> %bool'
  pre(:==) { |x| if (x.is_a?(BigDecimal)) then (!self.nan? && self!=Float::INFINITY) else true end}

  type :===, '(Object) -> %bool'
  pre(:===) { |x| if (x.is_a?(BigDecimal)) then (!self.nan? && self!=Float::INFINITY) else true end}

  type :>, '(%integer) -> %bool'
  type :>, '(Float) -> %bool'
  type :>, '(Rational) -> %bool'
  type :>, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> %bool'

  type :>=, '(%integer) -> %bool'
  type :>=, '(Float) -> %bool'
  type :>=, '(Rational) -> %bool'
  type :>=, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> %bool'

  type :abs, '() -> Float r {{ r>=0 }}'

  type :abs2, '() -> Float r {{ r>=0 }}'

  type :div, '(%integer x {{ x != 0 && !self.infinite? && !self.nan? }}) -> %integer'
  type :div, '(Float x {{ x != 0 && !self.infinite? && !self.nan? }}) -> %integer'
  type :div, '(Rational x {{ x != 0 && !self.infinite? && !self.nan? }}) -> %integer'
  type :div, '(BigDecimal x {{ x != 0 && !x.nan? && !self.infinite? && !self.nan? }}) -> %integer'

  type :divmod, '(%real) -> [%real, %real]'
  pre(:divmod) { |x| x != 0 && if x.is_a?(Float) then !x.nan? else true end && self!=Float::INFINITY && !self.nan?}

  type :angle, '() -> %numeric'
  post(:angle) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

  type :arg, '() -> %numeric'
  post(:arg) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

  type :ceil, '() -> %integer'
  pre(:ceil) { !self.infinite? && !self.nan?}

  type :coerce, '(%real) -> [Float, Float]'

  type :denominator, '() -> %integer r {{ r>0 }}'

  type :equal?, '(Object) -> %bool'

  type :eql?, '(Object) -> %bool'

  type :fdiv, '(%integer) -> Float'
  type :fdiv, '(Float) -> Float'
  type :fdiv, '(Rational) -> Float'
  type :fdiv, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> BigDecimal'
  type :fdiv, '(Complex) -> Complex'
  pre(:fdiv) { |x| x != 0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :finite?, '() -> %bool'

  type :floor, '() -> %integer'
  pre(:ceil) { !self.infinite? && !self.nan?}

  type :hash, '() -> %integer'

  type :infinite?, '() -> Object'
  post(:infinite?) { |r,x| r == -1 || r == 1 || r == nil }

  type :to_s, '() -> String'
  type :inspect, '() -> String'

  type :magnitude, '() -> Float'
  post(:magnitude) { |r,x| r>=0 }

  type :modulo, '(%integer x {{ x != 0 }}) -> Float'
  type :modulo, '(Float x {{ x != 0 }}) -> Float'
  type :modulo, '(Rational x {{ x != 0 }}) -> Float'
  type :modulo, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> BigDecimal'

  type :nan?, '() -> %bool'

  type :next_float, '() -> Float'

  type :numerator, '() -> %integer'

  type :phase, '() -> %numeric'
  post(:phase) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

  type :prev_float, '() -> Float'

  type :quo, '(%integer x {{ x != 0 }}) -> Float'
  type :quo, '(Float x {{ x != 0 }}) -> Float'
  type :quo, '(Rational x {{ x != 0 }}) -> Float'
  type :quo, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> BigDecimal'
  type :quo, '(Complex x {{ x != 0 }}) -> Complex'
  pre(:quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :rationalize, '() -> Rational'
  pre(:rationalize) { !self.infinite? && !self.nan?}

  type :rationalize, '(%numeric) -> Rational'
  pre(:rationalize) { |x| if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end}

  type :round, '() -> %integer'
  pre(:round) { !self.infinite? && !self.nan?}

  type :round, '(%numeric) -> %numeric'
  pre(:round) { |x| x != 0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

  type :to_f, '() -> Float'

  type :to_i, '() -> %integer'
  pre(:to_i) { !self.infinite? && !self.nan?}

  type :to_int, '() -> %integer'
  pre(:to_int) { !self.infinite? && !self.nan?}

  type :to_r, '() -> Rational'
  pre(:to_r) { !self.infinite? && !self.nan?}

  type :truncate, '() -> %integer'

  type :zero?, '() -> %bool'

  type :conj, '() -> Float'
  type :conjugate, '() -> Float'

  type :imag, '() -> Fixnum r {{ r==0 }}'
  type :imaginary, '() -> Fixnum r {{ r==0 }}'

  type :real, '() -> Float'

  type :real?, '() -> true'

  type :to_c, '() -> Complex r {{ r.imaginary == 0 }}'

  type :coerce, '(%numeric) -> [Float, Float]'
  pre(:coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
end
