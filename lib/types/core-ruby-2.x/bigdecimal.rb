class BigDecimal < Numeric
  rdl_nowrap

  type :%, '(%numeric) -> BigDecimal'
  pre(:%) { |x| x!=0&&(if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end)}

  type :+, '(%integer) -> BigDecimal'
  type :+, '(Float x {{ !x.infinite? && !x.nan? }}) -> BigDecimal'
  type :+, '(Rational) -> BigDecimal'
  type :+, '(BigDecimal) -> BigDecimal'
  type :+, '(Complex) -> Complex'
  pre(:+) { |x| if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end}

  type :-, '(%integer) -> BigDecimal'
  type :-, '(Float x {{ !x.infinite? && !x.nan? }}) -> BigDecimal'
  type :-, '(Rational) -> BigDecimal'
  type :-, '(BigDecimal) -> BigDecimal'
  type :-, '(Complex) -> Complex'
  pre(:-) { |x| if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end}

  type :-, '() -> BigDecimal'

  type :*, '(%integer) -> BigDecimal'
  type :*, '(Float x {{ !x.infinite? && !x.nan? }}) -> BigDecimal'
  type :*, '(Rational) -> BigDecimal'
  type :*, '(BigDecimal) -> BigDecimal'
  type :*, '(Complex) -> Complex'
  pre(:*) { |x| if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end}

  type :**, '(%integer) -> BigDecimal'
  type :**, '(Float) -> BigDecimal'
  pre(:**) { |x| x!=Float::INFINITY && !x.nan? && if(self<0) then x<=-1||x>=0 else true end}
  type :**, '(Rational) -> BigDecimal'
  pre(:**) { |x| if(self<0) then x<=-1||x>=0 else true end}
  type :**, '(BigDecimal) -> BigDecimal'
  pre(:**) { |x| x!=BigDecimal::INFINITY && if(self<0) then x<=-1||x>=0 else true end}

  type :/, '(%integer x {{ x!=0 }}) -> BigDecimal'
  type :/, '(Float x {{ x!=0 && !x.infinite? && !x.nan? }}) -> BigDecimal'
  type :/, '(Rational x {{ x!=0 }}) -> BigDecimal'
  type :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
  type :/, '(Complex x {{ x!=0 }}) -> Complex'
  pre(:/) { |x| if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end && if x.imaginary.is_a?(Float) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end && if (x.real.is_a?(Rational)) then !x.imaginary.nan? else true end}

  type :<, '(%integer) -> %bool'
  type :<, '(Float x {{ !x.nan? && !x.infinite? }}) -> %bool'
  type :<, '(Rational) -> %bool'
  type :<, '(BigDecimal) -> %bool'

  type :<=, '(%integer) -> %bool'
  type :<=, '(Float x {{ !x.nan? && !x.infinite }}) -> %bool'
  type :<=, '(Rational) -> %bool'
  type :<=, '(BigDecimal) -> %bool'

  type :>, '(%integer) -> %bool'
  type :>, '(Float x {{ !x.nan? && !x.infinite? }}) -> %bool'
  type :>, '(Rational) -> %bool'
  type :>, '(BigDecimal) -> %bool'

  type :>=, '(%integer) -> %bool'
  type :>=, '(Float x {{ !x.nan? && !x.infinite? }}) -> %bool'
  type :>=, '(Rational) -> %bool'
  type :>=, '(BigDecimal) -> %bool'

  type :==, '(Object) -> %bool'
  pre(:==) { |x| if (x.is_a?(Float)) then (!x.nan? && x!=Float::INFINITY) else true end}

  type :===, '(Object) -> %bool'
  pre(:===) { |x| if (x.is_a?(Float)) then (!x.nan? && x!=Float::INFINITY) else true end}

  type :<=>, '(%integer) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(Float) -> Object'
  pre(:<=>) { |x| !x.nan? && x!=Float::INFINITY}
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(Rational) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(BigDecimal) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}

  type :abs, '() -> BigDecimal r {{ r>=0 }}'

  type :abs2, '() -> BigDecimal r {{ r>=0 }}'

  type :angle, '() -> %numeric'
  post(:angle) { |r,x| r == 0 || r == Math::PI}

  type :arg, '() -> %numeric'
  post(:arg) { |r,x| r == 0 || r == Math::PI}

  type :ceil, '() -> %integer'
  pre(:ceil) { !self.ininite? && !self.nan?}

  type :conj, '() -> BigDecimal'
  type :conjugate, '() -> BigDecimal'

  type :denominator, '() -> %integer'
  pre(:denominator) { !self.ininite? && !self.nan?}
  post(:denominator) { |r,x| r>0}

  type :div, '(Fixnum x {{ x!=0 && !self.infinite? && !self.nan? }}) -> %integer'
  type :div, '(Bignum x {{ x!=0 && !self.infinite? && !self.nan? }}) -> %integer'
  type :div, '(Float x {{ x!=0 && !self.infinite? && !self.nan? && !x.infinite? && !x.nan? }}) -> %integer'
  type :div, '(Rational x {{ x!=0 && !self.infinite? && !self.nan? }}) -> %integer'
  type :div, '(BigDecimal x {{ x!=0 && !self.infinite? && !self.nan? && !x.infinite? && !x.nan? }}) -> %integer'

  type :divmod, '(%real) -> [%real, %real]'
  pre(:divmod) { |x| x!=0 && if x.is_a?(Float) then !x.nan? && x!=Float::INFINITY else true end}

  type :equal?, '(Object) -> %bool'
  type :eql?, '(Object) -> %bool'

  type :fdiv, '(%integer) -> Float'
  type :fdiv, '(Float) -> Float'
  type :fdiv, '(Rational) -> Float'
  type :fdiv, '(BigDecimal) -> BigDecimal'
  type :fdiv, '(Complex) -> Complex'
  pre(:fdiv) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :finite?, '() -> %bool'

  type :floor, '() -> %integer'
  pre(:floor) { !self.infinite? && !self.nan?}

  type :hash, '() -> %integer'

  type :imag, '() -> Fixnum r {{ r==0 }}'
  type :imaginary, '() -> Fixnum r {{ r==0 }}'

  type :infinite?, '() -> %bool'

  type :to_s, '() -> String'
  type :inspect, '() -> String'

  type :magnitude, '() -> BigDecimal r {{ r>=0 }}'

  type :modulo, '(%numeric) -> BigDecimal'
  pre(:modulo) { |x| x!=0&&(if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end)}

  type :nan?, '() -> %bool'

  type :numerator, '() -> %integer'
  pre(:numerator) { !self.infinite? && !self.nan?}

  type :phase, '() -> %numeric'

  type :quo, '(%integer x {{ x!=0 }}) -> BigDecimal'
  type :quo, '(Float x {{ x!=0 && !x.infinite? && !x.nan?}}) -> BigDecimal'
  type :quo, '(Rational x {{ x!=0 }}) -> BigDecimal'
  type :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
  type :quo, '(Complex) -> Complex'
  pre(:quo) { |x| x!=0 && if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end && if x.imaginary.is_a?(Float) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end && if (x.real.is_a?(Rational)) then !x.imaginary.nan? else true end}

  type :real, '() -> BigDecimal'

  type :real?, '() -> true'

  type :round, '() -> %integer'
  pre(:round) { !self.infinite? && !self.nan?}

  type :round, '(Fixnum) -> BigDecimal' #Also, x must be in range [-2**31, 2**31].

  type :to_f, '() -> Float'
  pre(:to_f) { self<=Float::MAX}

  type :to_i, '() -> %integer'
  pre(:to_i) { !self.infinite? && !self.nan?}
  type :to_int, '() -> %integer'
  pre(:to_int) { !self.infinite? && !self.nan?}

  type :to_r, '() -> Rational'
  pre(:to_r) { !self.infinite? && !self.nan?}

  type :to_c, '() -> Complex r {{ r.imaginary == 0 }}'
  post(:to_c) { |r,x| r.imaginary == 0 }

  type :truncate, '() -> %integer'

  type :truncate, '(Fixnum) -> Rational' #Also, x must be in range [-2**31, 2**31].

  type :zero?, '() -> %bool'

  type :precs, '() -> [%integer, %integer]'

  type :split, '() -> [Fixnum, String, %integer, %integer]'

  type :remainder, '(%real) -> BigDecimal'
  pre(:remainder) { |x| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

  type :fix, '() -> BigDecimal'

  type :frac, '() -> BigDecimal'

  type :power, '(%integer) -> BigDecimal'
  type :power, '(Float) -> BigDecimal'
  pre(:power) { |x| x!=Float::INFINITY && !x.nan? && if(self<0) then x<=-1||x>=0 else true end}
  type :power, '(Rational) -> BigDecimal'
  pre(:power) { |x| if(self<0) then x<=-1||x>=0 else true end}
  type :power, '(BigDecimal) -> BigDecimal'
  pre(:power) { |x| x!=BigDecimal::INFINITY && if(self<0) then x<=-1||x>=0 else true end}

  type :nonzero?, '() -> Object'

  type :exponent, '() -> %integer'

  type :sign, '() -> Fixnum'

  type :_dump, '() -> String'

  type :sqrt, '(Fixnum) -> BigDecimal'
  pre(:sqrt) { self>=0}

  type :add, '(%real, Fixnum) -> BigDecimal'
  pre(:add) { |x,y| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

  type :sub, '(%real, Fixnum) -> BigDecimal'
  pre(:sub) { |x,y| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

  type :mult, '(%real, Fixnum) -> BigDecimal'
  pre(:mult) { |x,y| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

  type :coerce, '(%real) -> [BigDecimal, BigDecimal]'
  pre(:coerce) { |x| if x.is_a?(Float) then !x.nan? && !x.finite? else true end}
end
