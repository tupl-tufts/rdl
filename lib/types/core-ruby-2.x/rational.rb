class Rational < Numeric
  rdl_nowrap

  type :%, '(%integer) -> Rational'
  pre(:%) { |x| x!=0}
  type :%, '(Float) -> Float'
  pre(:%) { |x| x!=0&&!x.nan?}
  type :%, '(Rational) -> Rational'
  pre(:%) { |x| x!=0}
  type :%, '(BigDecimal) -> BigDecimal'
  pre(:%) { |x| x!=0&&!x.nan?}

  type :*, '(%integer) -> Rational'
  type :*, '(Float) -> Float'
  type :*, '(Rational) -> Rational'
  type :*, '(BigDecimal) -> BigDecimal'
  type :*, '(Complex) -> Complex'
  pre(:*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

  type :+, '(%integer) -> Rational'
  type :+, '(Float) -> Float'
  type :+, '(Rational) -> Rational'
  type :+, '(BigDecimal) -> BigDecimal'
  type :+, '(Complex) -> Complex'

  type :-, '(%integer) -> Rational'
  type :-, '(Float) -> Float'
  type :-, '(Rational) -> Rational'
  type :-, '(BigDecimal) -> BigDecimal'
  type :-, '(Complex) -> Complex'

  type :-, '() -> Rational'

  type :**, '(%integer) -> %numeric'
  type :**, '(Float) -> %numeric'
  type :**, '(Rational) -> %numeric'
  type :**, '(BigDecimal) -> BigDecimal'
  pre(:**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
  post(:**) { |r,x| r.real?}
  type :**, '(Complex) -> Complex'
  pre(:**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

  type :/, '(%integer) -> Rational'
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
  pre(:<) { |x| !x.nan?}
  type :<, '(Rational) -> %bool'
  type :<, '(BigDecimal) -> %bool'
  pre(:<) { |x| !x.nan?}

  type :<=, '(%integer) -> %bool'
  type :<=, '(Float) -> %bool'
  pre(:<=) { |x| !x.nan?}
  type :<=, '(Rational) -> %bool'
  type :<=, '(BigDecimal) -> %bool'
  pre(:<=) { |x| !x.nan?}

  type :>, '(%integer) -> %bool'
  type :>, '(Float) -> %bool'
  pre(:>) { |x| !x.nan?}
  type :>, '(Rational) -> %bool'
  type :>, '(BigDecimal) -> %bool'
  pre(:>) { |x| !x.nan?}

  type :>=, '(%integer) -> %bool'
  type :>=, '(Float) -> %bool'
  pre(:>=) { |x| !x.nan?}
  type :>=, '(Rational) -> %bool'
  type :>=, '(BigDecimal) -> %bool'
  pre(:>=) { |x| !x.nan?}

  type :<=>, '(%integer) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(Float) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(Rational) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(BigDecimal) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}

  type :==, '(Object) -> %bool'

  type :abs, '() -> Rational'
  post(:abs) { |r,x| r >= 0 }

  type :abs2, '() -> Rational'
  post(:abs2) { |r,x| r >= 0 }

  type :angle, '() -> %numeric'
  post(:angle) { |r,x| r == 0 || r == Math::PI}

  type :arg, '() -> %numeric'
  post(:arg) { |r,x| r == 0 || r == Math::PI}

  type :div, '(Fixnum) -> %integer'
  pre(:div) { |x| x!=0}
  type :div, '(Bignum) -> %integer'
  pre(:div) { |x| x!=0}
  type :div, '(Float) -> %integer'
  pre(:div) { |x| x!=0 && !x.nan?}
  type :div, '(Rational) -> %integer'
  pre(:div) { |x| x!=0}
  type :div, '(BigDecimal) -> %integer'
  pre(:div) { |x| x!=0 && !x.nan?}

  type :modulo, '(%integer) -> Rational'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(Float) -> Float'
  pre(:modulo) { |x| x!=0&&!x.nan?}
  type :modulo, '(Rational) -> Rational'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(BigDecimal) -> BigDecimal'
  pre(:modulo) { |x| x!=0&&!x.nan?}

  type :ceil, '() -> %integer'
  type :ceil, '(%integer) -> %numeric'

  type :denominator, '() -> %integer'
  post(:denominator) { |r,x| r > 0 }

  type :divmod, '(%real) -> [%real, %real]'
  pre(:divmod) { |x| x!=0 && if x.is_a?(BigDecimal) then !x.nan? else true end}

  type :equal?, '(Object) -> %bool'

  type :fdiv, '(%integer) -> Float'
  type :fdiv, '(Float) -> Float'
  type :fdiv, '(Rational) -> Float'
  type :fdiv, '(BigDecimal) -> Float'
  type :fdiv, '(Complex) -> Float'
  pre(:fdiv) { |x| x.imaginary==0 && x.real.class != Float}

  type :floor, '() -> %integer'

  type :floor, '(%integer) -> %numeric'

  type :hash, '() -> %integer'

  type :inspect, '() -> String'

  type :numerator, '() -> %integer'

  type :phase, '() -> %numeric'

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
  pre(:quo) { |x| if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end}

  type :round, '() -> %integer'

  type :round, '(%integer) -> %numeric'

  type :to_f, '() -> Float'
  pre(:to_f) { self<=Float::MAX}

  type :to_i, '() -> %integer'

  type :to_r, '() -> Rational'

  type :to_s, '() -> String'

  type :truncate, '() -> %integer'

  type :truncate, '(%integer) -> Rational'

  type :zero?, '() -> %bool'

  type :conj, '() -> Rational'
  type :conjugate, '() -> Rational'

  type :imag, '() -> Fixnum'
  post(:imag) { |r,x| r == 0 }
  type :imaginary, '() -> Fixnum'
  post(:imaginary) { |r,x| r == 0 }

  type :real, '() -> Rational'

  type :real?, '() -> true'

  type :to_c, '() -> Complex'
  post(:to_c) { |r,x| r.imaginary == 0 }

  type :coerce, '(%integer) -> [Rational, Rational]'
  type :coerce, '(Float) -> [Float, Float]'
  type :coerce, '(Rational) -> [Rational, Rational]'
  type :coerce, '(Complex) -> [%numeric, %numeric]'
end
