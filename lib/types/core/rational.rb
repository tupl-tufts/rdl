RDL.nowrap :Rational

RDL.type :Rational, :%, '(Integer) -> Rational'
RDL.pre(:Rational, :%) { |x| x!=0}
RDL.type :Rational, :%, '(Float) -> Float'
RDL.pre(:Rational, :%) { |x| x!=0&&!x.nan?}
RDL.type :Rational, :%, '(Rational) -> Rational'
RDL.pre(:Rational, :%) { |x| x!=0}
RDL.type :Rational, :%, '(BigDecimal) -> BigDecimal'
RDL.pre(:Rational, :%) { |x| x!=0&&!x.nan?}

RDL.type :Rational, :*, '(Integer) -> Rational'
RDL.type :Rational, :*, '(Float) -> Float'
RDL.type :Rational, :*, '(Rational) -> Rational'
RDL.type :Rational, :*, '(BigDecimal) -> BigDecimal'
RDL.type :Rational, :*, '(Complex) -> Complex'
RDL.pre(:Rational, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

RDL.type :Rational, :+, '(Integer) -> Rational'
RDL.type :Rational, :+, '(Float) -> Float'
RDL.type :Rational, :+, '(Rational) -> Rational'
RDL.type :Rational, :+, '(BigDecimal) -> BigDecimal'
RDL.type :Rational, :+, '(Complex) -> Complex'

RDL.type :Rational, :-, '(Integer) -> Rational'
RDL.type :Rational, :-, '(Float) -> Float'
RDL.type :Rational, :-, '(Rational) -> Rational'
RDL.type :Rational, :-, '(BigDecimal) -> BigDecimal'
RDL.type :Rational, :-, '(Complex) -> Complex'

RDL.type :Rational, :-@, '() -> Rational'

RDL.type :Rational, :+@, '() -> Rational'

RDL.type :Rational, :**, '(Integer) -> %numeric'
RDL.type :Rational, :**, '(Float) -> %numeric'
RDL.type :Rational, :**, '(Rational) -> %numeric'
RDL.type :Rational, :**, '(BigDecimal) -> BigDecimal'
RDL.pre(:Rational, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
RDL.post(:Rational, :**) { |r,x| r.real?}
RDL.type :Rational, :**, '(Complex) -> Complex'
RDL.pre(:Rational, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

RDL.type :Rational, :/, '(Integer) -> Rational'
RDL.pre(:Rational, :/) { |x| x!=0}
RDL.type :Rational, :/, '(Float) -> Float'
RDL.pre(:Rational, :/) { |x| x!=0}
RDL.type :Rational, :/, '(Rational) -> Rational'
RDL.pre(:Rational, :/) { |x| x!=0}
RDL.type :Rational, :/, '(BigDecimal) -> BigDecimal'
RDL.pre(:Rational, :/) { |x| x!=0}
RDL.type :Rational, :/, '(Complex) -> Complex'
RDL.pre(:Rational, :/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Rational, :<, '(Integer) -> %bool'
RDL.type :Rational, :<, '(Float) -> %bool'
RDL.pre(:Rational, :<) { |x| !x.nan?}
RDL.type :Rational, :<, '(Rational) -> %bool'
RDL.type :Rational, :<, '(BigDecimal) -> %bool'
RDL.pre(:Rational, :<) { |x| !x.nan?}

RDL.type :Rational, :<=, '(Integer) -> %bool'
RDL.type :Rational, :<=, '(Float) -> %bool'
RDL.pre(:Rational, :<=) { |x| !x.nan?}
RDL.type :Rational, :<=, '(Rational) -> %bool'
RDL.type :Rational, :<=, '(BigDecimal) -> %bool'
RDL.pre(:Rational, :<=) { |x| !x.nan?}

RDL.type :Rational, :>, '(Integer) -> %bool'
RDL.type :Rational, :>, '(Float) -> %bool'
RDL.pre(:Rational, :>) { |x| !x.nan?}
RDL.type :Rational, :>, '(Rational) -> %bool'
RDL.type :Rational, :>, '(BigDecimal) -> %bool'
RDL.pre(:Rational, :>) { |x| !x.nan?}

RDL.type :Rational, :>=, '(Integer) -> %bool'
RDL.type :Rational, :>=, '(Float) -> %bool'
RDL.pre(:Rational, :>=) { |x| !x.nan?}
RDL.type :Rational, :>=, '(Rational) -> %bool'
RDL.type :Rational, :>=, '(BigDecimal) -> %bool'
RDL.pre(:Rational, :>=) { |x| !x.nan?}

RDL.type :Rational, :<=>, '(Integer) -> Object'
RDL.post(:Rational, :<=>) { |r,x| r == -1 || r==0 || r==1}
RDL.type :Rational, :<=>, '(Float) -> Object'
RDL.post(:Rational, :<=>) { |r,x| r == -1 || r==0 || r==1}
RDL.type :Rational, :<=>, '(Rational) -> Object'
RDL.post(:Rational, :<=>) { |r,x| r == -1 || r==0 || r==1}
RDL.type :Rational, :<=>, '(BigDecimal) -> Object'
RDL.post(:Rational, :<=>) { |r,x| r == -1 || r==0 || r==1}

RDL.type :Rational, :==, '(Object) -> %bool'

RDL.type :Rational, :abs, '() -> Rational'
RDL.post(:Rational, :abs) { |r,x| r >= 0 }

RDL.type :Rational, :abs2, '() -> Rational'
RDL.post(:Rational, :abs2) { |r,x| r >= 0 }

RDL.type :Rational, :angle, '() -> %numeric'
RDL.post(:Rational, :angle) { |r,x| r == 0 || r == Math::PI}

RDL.type :Rational, :arg, '() -> %numeric'
RDL.post(:Rational, :arg) { |r,x| r == 0 || r == Math::PI}

RDL.type :Rational, :div, '(Integer) -> Integer'
RDL.pre(:Rational, :div) { |x| x!=0}
RDL.type :Rational, :div, '(Float) -> Integer'
RDL.pre(:Rational, :div) { |x| x!=0 && !x.nan?}
RDL.type :Rational, :div, '(Rational) -> Integer'
RDL.pre(:Rational, :div) { |x| x!=0}
RDL.type :Rational, :div, '(BigDecimal) -> Integer'
RDL.pre(:Rational, :div) { |x| x!=0 && !x.nan?}

RDL.type :Rational, :modulo, '(Integer) -> Rational'
RDL.pre(:Rational, :modulo) { |x| x!=0}
RDL.type :Rational, :modulo, '(Float) -> Float'
RDL.pre(:Rational, :modulo) { |x| x!=0&&!x.nan?}
RDL.type :Rational, :modulo, '(Rational) -> Rational'
RDL.pre(:Rational, :modulo) { |x| x!=0}
RDL.type :Rational, :modulo, '(BigDecimal) -> BigDecimal'
RDL.pre(:Rational, :modulo) { |x| x!=0&&!x.nan?}

RDL.type :Rational, :ceil, '() -> Integer'
RDL.type :Rational, :ceil, '(Integer) -> %numeric'

RDL.type :Rational, :denominator, '() -> Integer'
RDL.post(:Rational, :denominator) { |r,x| r > 0 }

RDL.type :Rational, :divmod, '(%real) -> [%real, %real]'
RDL.pre(:Rational, :divmod) { |x| x!=0 && if x.is_a?(BigDecimal) then !x.nan? else true end}

RDL.type :Rational, :equal?, '(Object) -> %bool'

RDL.type :Rational, :fdiv, '(Integer) -> Float'
RDL.type :Rational, :fdiv, '(Float) -> Float'
RDL.type :Rational, :fdiv, '(Rational) -> Float'
RDL.type :Rational, :fdiv, '(BigDecimal) -> Float'
RDL.type :Rational, :fdiv, '(Complex) -> Float'
RDL.pre(:Rational, :fdiv) { |x| x.imaginary==0 && x.real.class != Float}

RDL.type :Rational, :floor, '() -> Integer'

RDL.type :Rational, :floor, '(Integer) -> %numeric'

RDL.type :Rational, :hash, '() -> Integer'

RDL.type :Rational, :inspect, '() -> String'

RDL.type :Rational, :numerator, '() -> Integer'

RDL.type :Rational, :phase, '() -> %numeric'

RDL.type :Rational, :quo, '(Integer) -> Rational'
RDL.pre(:Rational, :quo) { |x| x!=0}
RDL.type :Rational, :quo, '(Float) -> Float'
RDL.pre(:Rational, :quo) { |x| x!=0}
RDL.type :Rational, :quo, '(Rational) -> Rational'
RDL.pre(:Rational, :quo) { |x| x!=0}
RDL.type :Rational, :quo, '(BigDecimal) -> BigDecimal'
RDL.pre(:Rational, :quo) { |x| x!=0}
RDL.type :Rational, :quo, '(Complex) -> Complex'
RDL.pre(:Rational, :quo) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Rational, :rationalize, '() -> Rational'

RDL.type :Rational, :rationalize, '(%numeric) -> Rational'
RDL.pre(:Rational, :quo) { |x| if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end}

RDL.type :Rational, :round, '() -> Integer'

RDL.type :Rational, :round, '(Integer) -> %numeric'

RDL.type :Rational, :to_f, '() -> Float'
RDL.pre(:Rational, :to_f) { self<=Float::MAX}

RDL.type :Rational, :to_i, '() -> Integer'

RDL.type :Rational, :to_r, '() -> Rational'

RDL.type :Rational, :to_s, '() -> String'

RDL.type :Rational, :truncate, '() -> Integer'

RDL.type :Rational, :truncate, '(Integer) -> Rational'

RDL.type :Rational, :zero?, '() -> %bool'

RDL.type :Rational, :conj, '() -> Rational'
RDL.type :Rational, :conjugate, '() -> Rational'

RDL.type :Rational, :imag, '() -> Integer'
RDL.post(:Rational, :imag) { |r,x| r == 0 }
RDL.type :Rational, :imaginary, '() -> Integer'
RDL.post(:Rational, :imaginary) { |r,x| r == 0 }

RDL.type :Rational, :real, '() -> Rational'

RDL.type :Rational, :real?, '() -> true'

RDL.type :Rational, :to_c, '() -> Complex'
RDL.post(:Rational, :to_c) { |r,x| r.imaginary == 0 }

RDL.type :Rational, :coerce, '(Integer) -> [Rational, Rational]'
RDL.type :Rational, :coerce, '(Float) -> [Float, Float]'
RDL.type :Rational, :coerce, '(Rational) -> [Rational, Rational]'
RDL.type :Rational, :coerce, '(Complex) -> [%numeric, %numeric]'
