class Bignum < Integer
  rdl_nowrap

  type :%, '(Fixnum) -> Fixnum'
  pre(:%) { |x| x!=0}
  type :%, '(Bignum) -> %integer'
  pre(:%) { |x| x!=0}
  type :%, '(Float) -> Float'
  pre(:%) { |x| x!=0}
  type :%, '(Rational) -> Rational'
  pre(:%) { |x| x!=0}
  type :%, '(BigDecimal) -> BigDecimal'
  pre(:%) { |x| x!=0}

  type :&, '(%integer) -> Fixnum'

  type :*, '(Fixnum) -> %integer'
  type :*, '(Bignum) -> Bignum'
  type :*, '(Float) -> Float'
  type :*, '(Rational) -> Rational'
  type :*, '(BigDecimal) -> BigDecimal'
  type :*, '(Complex) -> Complex'
  pre(:*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

  type :**, '(%integer) -> %numeric'
  type :**, '(Float) -> %numeric'
  type :**, '(Rational) -> %numeric'
  type :**, '(BigDecimal) -> BigDecimal'
  pre(:**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
  post(:**) { |r,x| r.real?}
  type :**, '(Complex) -> Complex'
  pre(:**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

  type :+, '(%integer) -> %integer'
  type :+, '(Float) -> Float'
  type :+, '(Rational) -> Rational'
  type :+, '(BigDecimal) -> BigDecimal'
  type :+, '(Complex) -> Complex'

  type :-, '(%integer) -> %integer'
  type :-, '(Float) -> Float'
  type :-, '(Rational) -> Rational'
  type :-, '(BigDecimal) -> BigDecimal'
  type :-, '(Complex) -> Complex'

  type :-, '() -> %integer'

  type :/, '(%integer) -> %integer'
  pre(:/) { |x| x!=0}
  type :/, '(Float) -> Float'
  pre(:/) { |x| x!=0}
  type :/, '(Rational) -> Rational'
  pre(:/) { |x| x!=0}
  type :/, '(BigDecimal) -> BigDecimal'
  pre(:/) { |x| x!=0}
  type :/, '(Complex) -> Complex'
  pre(:/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :<, '(%integer) -> %bool'
  type :<, '(Float) -> %bool'
  type :<, '(Rational) -> %bool'
  type :<, '(BigDecimal) -> %bool'

  type :<<, '(Fixnum) -> %integer'

  type :<=, '(%integer) -> %bool'
  type :<=, '(Float) -> %bool'
  type :<=, '(Rational) -> %bool'
  type :<=, '(BigDecimal) -> %bool'

  type :<=>, '(%integer) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(Float) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(Rational) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(BigDecimal) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}

  type :==, '(Object) -> %bool'

  type :===, '(Object) -> %bool'

  type :>, '(%integer) -> %bool'
  type :>, '(Float) -> %bool'
  type :>, '(Rational) -> %bool'
  type :>, '(BigDecimal) -> %bool'

  type :>=, '(%integer) -> %bool'
  type :>=, '(Float) -> %bool'
  type :>=, '(Rational) -> %bool'
  type :>=, '(BigDecimal) -> %bool'

  type :>>, '(%integer) -> %integer'
  post(:>>) { |r,x| r >= 0 }

  type :[], '(%integer) -> Fixnum'
  post(:[]) { |r,x| r == 0 || r==1}
  type :[], '(Rational) -> Fixnum'
  post(:[]) { |r,x| r == 0 || r==1}
  type :[], '(Float) -> Fixnum'
  pre(:[]) { |x| x!=Float::INFINITY && !x.nan? }
  post(:[]) { |r,x| r == 0 || r==1}
  type :[], '(BigDecimal) -> Fixnum'
  pre(:[]) { |x| x!=BigDecimal::INFINITY && !x.nan? }
  post(:[]) { |r,x| r == 0 || r==1}

  type :^, '(%integer) -> %integer'

  type :|, '(%integer) -> %integer'

  type :~, '() -> Bignum'

  type :abs, '() -> Bignum'
  post(:abs) { |r,x| r >= 0 }

  type :bit_length, '() -> %integer'
  post(:bit_length) { |r,x| r >= 0 }

  type :div, '(%integer) -> %integer'
  pre(:div) { |x| x!=0}
  type :div, '(Float) -> %integer'
  pre(:div) { |x| x!=0 && !x.nan?}
  type :div, '(Rational) -> %integer'
  pre(:div) { |x| x!=0}
  type :div, '(BigDecimal) -> %integer'
  pre(:div) { |x| x!=0 && !x.nan?}

  type :divmod, '(%real) -> [%real, %real]'
  pre(:divmod) { |x| x!=0 && if x.is_a?(Float) then !x.nan? else true end}

  type :even?, '() -> %bool'

  type :fdiv, '(%integer) -> Float'
  type :fdiv, '(Float) -> Float'
  type :fdiv, '(Rational) -> Float'
  type :fdiv, '(BigDecimal) -> BigDecimal'
  type :fdiv, '(Complex) -> Complex'
  pre(:fdiv) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :to_s, '() -> String'
  type :inspect, '() -> String'

  type :magnitude, '() -> Bignum'
  post(:magnitude) { |r,x| r >= 0 }

  type :modulo, '(Fixnum) -> Fixnum'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(Bignum) -> %integer'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(Float) -> Float'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(Rational) -> Rational'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(BigDecimal) -> BigDecimal'
  pre(:modulo) { |x| x!=0}

  type :next, '() -> %integer'

  type :odd?, '() -> %bool'

  type :size, '() -> %integer'

  type :succ, '() -> %integer'

  type :to_f, '() -> Float'

  type :zero?, '() -> %bool'

  type :ceil, '() -> %integer'

  type :denominator, '() -> Fixnum'
  post(:denominator) { |r,x| r == 1 }

  type :floor, '() -> %integer'

  type :numerator, '() -> Bignum'

  type :quo, '(%integer) -> Rational'
  pre(:quo) { |x| x!=0}
  type :quo, '(Float) -> Float'
  pre(:quo) { |x| x!=0}
  type :quo, '(Rational) -> Rational'
  pre(:quo) { |x| x!=0}
  type :quo, '(BigDecimal) -> BigDecimal'
  pre(:quo) { |x| x!=0}
  type :quo, '(Complex) -> Complex'
  pre(:quo) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :rationalize, '() -> Rational'

  type :rationalize, '(%numeric) -> Rational'

  type :round, '() -> %integer'

  type :round, '(%numeric) -> %numeric'
  pre(:round) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

  type :to_i, '() -> Bignum'

  type :to_r, '() -> Rational'

  type :truncate, '() -> %integer'

  type :angle, '() -> %numeric'
  post(:angle) { |r,x| r == 0 || r == Math::PI}

  type :arg, '() -> %numeric'
  post(:arg) { |r,x| r == 0 || r == Math::PI}

  type :equal?, '(Object) -> %bool'
  type :eql?, '(Object) -> %bool'

  type :hash, '() -> %integer'

  type :phase, '() -> %numeric'

  type :abs2, '() -> Bignum'
  post(:abs2) { |r,x| r >= 0 }

  type :conj, '() -> Bignum'
  type :conjugate, '() -> Bignum'

  type :imag, '() -> Fixnum'
  post(:imag) { |r,x| r == 0 }
  type :imaginary, '() -> Fixnum'
  post(:imaginary) { |r,x| r == 0 }

  type :real, '() -> Bignum'

  type :real?, '() -> true'

  type :to_c, '() -> Complex'
  post(:to_c) { |r,x| r.imaginary == 0 }

  type :remainder, '(Fixnum) -> Fixnum'
  pre(:remainder) { |x| x!=0}
  post(:remainder) { |r,x| r>0}
  type :remainder, '(Bignum) -> Fixnum'
  pre(:remainder) { |x| x!=0}
  post(:remainder) { |r,x| r>0}
  type :remainder, '(Float) -> Float'
  pre(:remainder) { |x| x!=0}
  type :remainder, '(Rational) -> Rational'
  pre(:remainder) { |x| x!=0}
  post(:remainder) { |r,x| r>0}
  type :remainder, '(BigDecimal) -> BigDecimal'
  pre(:remainder) { |x| x!=0}

  type :coerce, '(%integer) -> [%integer, %integer]'
end
