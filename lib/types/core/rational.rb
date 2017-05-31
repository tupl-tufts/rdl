rdl_nowrap :Rational

type :Rational, :%, '(Integer) -> Rational'
pre(:Rational, :%) { |x| x!=0}
type :Rational, :%, '(Float) -> Float'
pre(:Rational, :%) { |x| x!=0&&!x.nan?}
type :Rational, :%, '(Rational) -> Rational'
pre(:Rational, :%) { |x| x!=0}
type :Rational, :%, '(BigDecimal) -> BigDecimal'
pre(:Rational, :%) { |x| x!=0&&!x.nan?}

type :Rational, :*, '(Integer) -> Rational'
type :Rational, :*, '(Float) -> Float'
type :Rational, :*, '(Rational) -> Rational'
type :Rational, :*, '(BigDecimal) -> BigDecimal'
type :Rational, :*, '(Complex) -> Complex'
pre(:Rational, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

type :Rational, :+, '(Integer) -> Rational'
type :Rational, :+, '(Float) -> Float'
type :Rational, :+, '(Rational) -> Rational'
type :Rational, :+, '(BigDecimal) -> BigDecimal'
type :Rational, :+, '(Complex) -> Complex'

type :Rational, :-, '(Integer) -> Rational'
type :Rational, :-, '(Float) -> Float'
type :Rational, :-, '(Rational) -> Rational'
type :Rational, :-, '(BigDecimal) -> BigDecimal'
type :Rational, :-, '(Complex) -> Complex'

type :Rational, :-@, '() -> Rational'

type :Rational, :+@, '() -> Rational'

type :Rational, :**, '(Integer) -> %numeric'
type :Rational, :**, '(Float) -> %numeric'
type :Rational, :**, '(Rational) -> %numeric'
type :Rational, :**, '(BigDecimal) -> BigDecimal'
pre(:Rational, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
post(:Rational, :**) { |r,x| r.real?}
type :Rational, :**, '(Complex) -> Complex'
pre(:Rational, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

type :Rational, :/, '(Integer) -> Rational'
pre(:Rational, :/) { |x| x!=0}
type :Rational, :/, '(Float) -> Float'
pre(:Rational, :/) { |x| x!=0}
type :Rational, :/, '(Rational) -> Rational'
pre(:Rational, :/) { |x| x!=0}
type :Rational, :/, '(BigDecimal) -> BigDecimal'
pre(:Rational, :/) { |x| x!=0}
type :Rational, :/, '(Complex) -> Complex'
pre(:Rational, :/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Rational, :<, '(Integer) -> %bool'
type :Rational, :<, '(Float) -> %bool'
pre(:Rational, :<) { |x| !x.nan?}
type :Rational, :<, '(Rational) -> %bool'
type :Rational, :<, '(BigDecimal) -> %bool'
pre(:Rational, :<) { |x| !x.nan?}

type :Rational, :<=, '(Integer) -> %bool'
type :Rational, :<=, '(Float) -> %bool'
pre(:Rational, :<=) { |x| !x.nan?}
type :Rational, :<=, '(Rational) -> %bool'
type :Rational, :<=, '(BigDecimal) -> %bool'
pre(:Rational, :<=) { |x| !x.nan?}

type :Rational, :>, '(Integer) -> %bool'
type :Rational, :>, '(Float) -> %bool'
pre(:Rational, :>) { |x| !x.nan?}
type :Rational, :>, '(Rational) -> %bool'
type :Rational, :>, '(BigDecimal) -> %bool'
pre(:Rational, :>) { |x| !x.nan?}

type :Rational, :>=, '(Integer) -> %bool'
type :Rational, :>=, '(Float) -> %bool'
pre(:Rational, :>=) { |x| !x.nan?}
type :Rational, :>=, '(Rational) -> %bool'
type :Rational, :>=, '(BigDecimal) -> %bool'
pre(:Rational, :>=) { |x| !x.nan?}

type :Rational, :<=>, '(Integer) -> Object'
post(:Rational, :<=>) { |r,x| r == -1 || r==0 || r==1}
type :Rational, :<=>, '(Float) -> Object'
post(:Rational, :<=>) { |r,x| r == -1 || r==0 || r==1}
type :Rational, :<=>, '(Rational) -> Object'
post(:Rational, :<=>) { |r,x| r == -1 || r==0 || r==1}
type :Rational, :<=>, '(BigDecimal) -> Object'
post(:Rational, :<=>) { |r,x| r == -1 || r==0 || r==1}

type :Rational, :==, '(Object) -> %bool'

type :Rational, :abs, '() -> Rational'
post(:Rational, :abs) { |r,x| r >= 0 }

type :Rational, :abs2, '() -> Rational'
post(:Rational, :abs2) { |r,x| r >= 0 }

type :Rational, :angle, '() -> %numeric'
post(:Rational, :angle) { |r,x| r == 0 || r == Math::PI}

type :Rational, :arg, '() -> %numeric'
post(:Rational, :arg) { |r,x| r == 0 || r == Math::PI}

type :Rational, :div, '(Integer) -> Integer'
pre(:Rational, :div) { |x| x!=0}
type :Rational, :div, '(Float) -> Integer'
pre(:Rational, :div) { |x| x!=0 && !x.nan?}
type :Rational, :div, '(Rational) -> Integer'
pre(:Rational, :div) { |x| x!=0}
type :Rational, :div, '(BigDecimal) -> Integer'
pre(:Rational, :div) { |x| x!=0 && !x.nan?}

type :Rational, :modulo, '(Integer) -> Rational'
pre(:Rational, :modulo) { |x| x!=0}
type :Rational, :modulo, '(Float) -> Float'
pre(:Rational, :modulo) { |x| x!=0&&!x.nan?}
type :Rational, :modulo, '(Rational) -> Rational'
pre(:Rational, :modulo) { |x| x!=0}
type :Rational, :modulo, '(BigDecimal) -> BigDecimal'
pre(:Rational, :modulo) { |x| x!=0&&!x.nan?}

type :Rational, :ceil, '() -> Integer'
type :Rational, :ceil, '(Integer) -> %numeric'

type :Rational, :denominator, '() -> Integer'
post(:Rational, :denominator) { |r,x| r > 0 }

type :Rational, :divmod, '(%real) -> [%real, %real]'
pre(:Rational, :divmod) { |x| x!=0 && if x.is_a?(BigDecimal) then !x.nan? else true end}

type :Rational, :equal?, '(Object) -> %bool'

type :Rational, :fdiv, '(Integer) -> Float'
type :Rational, :fdiv, '(Float) -> Float'
type :Rational, :fdiv, '(Rational) -> Float'
type :Rational, :fdiv, '(BigDecimal) -> Float'
type :Rational, :fdiv, '(Complex) -> Float'
pre(:Rational, :fdiv) { |x| x.imaginary==0 && x.real.class != Float}

type :Rational, :floor, '() -> Integer'

type :Rational, :floor, '(Integer) -> %numeric'

type :Rational, :hash, '() -> Integer'

type :Rational, :inspect, '() -> String'

type :Rational, :numerator, '() -> Integer'

type :Rational, :phase, '() -> %numeric'

type :Rational, :quo, '(Integer) -> Rational'
pre(:Rational, :quo) { |x| x!=0}
type :Rational, :quo, '(Float) -> Float'
pre(:Rational, :quo) { |x| x!=0}
type :Rational, :quo, '(Rational) -> Rational'
pre(:Rational, :quo) { |x| x!=0}
type :Rational, :quo, '(BigDecimal) -> BigDecimal'
pre(:Rational, :quo) { |x| x!=0}
type :Rational, :quo, '(Complex) -> Complex'
pre(:Rational, :quo) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Rational, :rationalize, '() -> Rational'

type :Rational, :rationalize, '(%numeric) -> Rational'
pre(:Rational, :quo) { |x| if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end}

type :Rational, :round, '() -> Integer'

type :Rational, :round, '(Integer) -> %numeric'

type :Rational, :to_f, '() -> Float'
pre(:Rational, :to_f) { self<=Float::MAX}

type :Rational, :to_i, '() -> Integer'

type :Rational, :to_r, '() -> Rational'

type :Rational, :to_s, '() -> String'

type :Rational, :truncate, '() -> Integer'

type :Rational, :truncate, '(Integer) -> Rational'

type :Rational, :zero?, '() -> %bool'

type :Rational, :conj, '() -> Rational'
type :Rational, :conjugate, '() -> Rational'

type :Rational, :imag, '() -> Integer'
post(:Rational, :imag) { |r,x| r == 0 }
type :Rational, :imaginary, '() -> Integer'
post(:Rational, :imaginary) { |r,x| r == 0 }

type :Rational, :real, '() -> Rational'

type :Rational, :real?, '() -> true'

type :Rational, :to_c, '() -> Complex'
post(:Rational, :to_c) { |r,x| r.imaginary == 0 }

type :Rational, :coerce, '(Integer) -> [Rational, Rational]'
type :Rational, :coerce, '(Float) -> [Float, Float]'
type :Rational, :coerce, '(Rational) -> [Rational, Rational]'
type :Rational, :coerce, '(Complex) -> [%numeric, %numeric]'
