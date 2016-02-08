class Rational < Numeric
  rdl_nowrap

  type :%, '(Integer) -> Rational'
  pre(:%) { |x| x!=0}
  type :%, '(Float) -> Float'
  pre(:%) { |x| x!=0&&!x.nan?}
  type :%, '(Rational) -> Rational'
  pre(:%) { |x| x!=0}
  type :%, '(BigDecimal) -> BigDecimal'
  pre(:%) { |x| x!=0&&!x.nan?}

  type :*, '(Integer) -> Rational'
  type :*, '(Float) -> Float'
  type :*, '(Rational) -> Rational'
  type :*, '(BigDecimal) -> BigDecimal'
  type :*, '(Complex) -> Complex'
  pre(:*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

  type :+, '(Integer) -> Rational'
  type :+, '(Float) -> Float'
  type :+, '(Rational) -> Rational'
  type :+, '(BigDecimal) -> BigDecimal'
  type :+, '(Complex) -> Complex'

  type :-, '(Integer) -> Rational'
  type :-, '(Float) -> Float'
  type :-, '(Rational) -> Rational'
  type :-, '(BigDecimal) -> BigDecimal'
  type :-, '(Complex) -> Complex'

  type :-, '() -> Rational'

  type :**, '(Integer) -> Numeric'
  type :**, '(Float) -> Numeric'
  type :**, '(Rational) -> Numeric'
  type :**, '(BigDecimal) -> BigDecimal'
  pre(:**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
  post(:**) { |r,x| r.real?}
  type :**, '(Complex) -> Complex'
  pre(:**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

  type :/, '(Integer) -> Rational'
  pre(:/) { |x| x!=0}
  type :/, '(Float) -> Float'
  pre(:/) { |x| x!=0}
  type :/, '(Rational) -> Rational'
  pre(:/) { |x| x!=0}
  type :/, '(BigDecimal) -> BigDecimal'
  pre(:/) { |x| x!=0}
  type :/, '(Complex) -> Complex'
  pre(:/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :<, '(Integer) -> %bool'
  type :<, '(Float) -> %bool'
  pre(:<) { |x| !x.nan?}
  type :<, '(Rational) -> %bool'
  type :<, '(BigDecimal) -> %bool'
  pre(:<) { |x| !x.nan?}

  type :<=, '(Integer) -> %bool'
  type :<=, '(Float) -> %bool'
  pre(:<=) { |x| !x.nan?}
  type :<=, '(Rational) -> %bool'
  type :<=, '(BigDecimal) -> %bool'
  pre(:<=) { |x| !x.nan?}

  type :>, '(Integer) -> %bool'
  type :>, '(Float) -> %bool'
  pre(:>) { |x| !x.nan?}
  type :>, '(Rational) -> %bool'
  type :>, '(BigDecimal) -> %bool'
  pre(:>) { |x| !x.nan?}

  type :>=, '(Integer) -> %bool'
  type :>=, '(Float) -> %bool'
  pre(:>=) { |x| !x.nan?}
  type :>=, '(Rational) -> %bool'
  type :>=, '(BigDecimal) -> %bool'
  pre(:>=) { |x| !x.nan?}

  type :<=>, '(Integer) -> Object'
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

  type :angle, '() -> Numeric'
  post(:angle) { |r,x| r == 0 || r == Math::PI}

  type :arg, '() -> Numeric'
  post(:arg) { |r,x| r == 0 || r == Math::PI}

  type :div, '(Fixnum) -> Integer'
  pre(:div) { |x| x!=0}
  type :div, '(Bignum) -> Integer'
  pre(:div) { |x| x!=0}
  type :div, '(Float) -> Integer'
  pre(:div) { |x| x!=0 && !x.nan?}
  type :div, '(Rational) -> Integer'
  pre(:div) { |x| x!=0}
  type :div, '(BigDecimal) -> Integer'
  pre(:div) { |x| x!=0 && !x.nan?}

  type :modulo, '(Integer) -> Rational'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(Float) -> Float'
  pre(:modulo) { |x| x!=0&&!x.nan?}
  type :modulo, '(Rational) -> Rational'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(BigDecimal) -> BigDecimal'
  pre(:modulo) { |x| x!=0&&!x.nan?}

  type :ceil, '() -> Integer'
  type :ceil, '(Integer) -> Numeric'

  type :denominator, '() -> Integer'
  post(:denominator) { |r,x| r > 0 }

  type :divmod, '(%real) -> [%real, %real]'
  pre(:divmod) { |x| x!=0 && if x.is_a?(BigDecimal) then !x.nan? else true end}

  type :equal?, '(Object) -> %bool'

  type :fdiv, '(Integer) -> Float'
  type :fdiv, '(Float) -> Float'
  type :fdiv, '(Rational) -> Float'
  type :fdiv, '(BigDecimal) -> Float'
  type :fdiv, '(Complex) -> Float'
  pre(:fdiv) { |x| x.imaginary==0 && x.real.class != Float}

  type :floor, '() -> Integer'

  type :floor, '(Integer) -> Numeric'

  type :hash, '() -> Integer'

  type :inspect, '() -> String'

  type :numerator, '() -> Integer'

  type :phase, '() -> Numeric'

  type :quo, '(Integer) -> Rational'
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

  type :rationalize, '(Numeric) -> Rational'
  pre(:quo) { |x| if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end}

  type :round, '() -> Integer'

  type :round, '(Integer) -> Numeric'

  type :to_f, '() -> Float'
  pre(:to_f) { self<=Float::MAX}

  type :to_i, '() -> Integer'

  type :to_r, '() -> Rational'

  type :to_s, '() -> String'

  type :truncate, '() -> Integer'

  type :truncate, '(Integer) -> Rational'

  type :zero?, '() -> %bool'

  type :conj, '() -> Rational'
  type :conjugate, '() -> Rational'

  type :imag, '() -> Fixnum'
  post(:imag) { |r,x| r == 0 }
  type :imaginary, '() -> Fixnum'
  post(:imaginary) { |r,x| r == 0 }

  type :real, '() -> Rational'

  type :real?, '() -> TrueClass'

  type :to_c, '() -> Complex'
  post(:to_c) { |r,x| r.imaginary == 0 }

  type :coerce, '(Integer) -> [Rational, Rational]'
  type :coerce, '(Float) -> [Float, Float]'
  type :coerce, '(Rational) -> [Rational, Rational]'
  type :coerce, '(Complex) -> [Numeric, Numeric]'
end
