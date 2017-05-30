rdl_nowrap :Fixnum

type :Fixnum, :%, '(Fixnum x {{ x!=0 }}) -> Fixnum'
type :Fixnum, :%, '(Bignum x {{ x!=0 }}) -> %integer'
type :Fixnum, :%, '(Float x {{ x!=0 }}) -> Float'
type :Fixnum, :%, '(Rational x {{ x!=0}}) -> Rational'
type :Fixnum, :%, '(BigDecimal x {{ x!=0}}) -> BigDecimal'

type :Fixnum, :&, '(%integer) -> %integer'

type :Fixnum, :*, '(%integer) -> %integer'
type :Fixnum, :*, '(Float) -> Float'
type :Fixnum, :*, '(Rational) -> Rational'
type :Fixnum, :*, '(BigDecimal) -> BigDecimal'
type :Fixnum, :*, '(Complex) -> Complex'
pre(:Fixnum, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

type :Fixnum, :**, '(%integer) -> %numeric'
type :Fixnum, :**, '(Float) -> %numeric'
type :Fixnum, :**, '(Rational) -> %numeric'
type :Fixnum, :**, '(BigDecimal) -> BigDecimal'
pre(:Fixnum, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
post(:Fixnum, :**) { |r,x| r.real?}
type :Fixnum, :**, '(Complex) -> Complex'
pre(:Fixnum, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

type :Fixnum, :+, '(%integer) -> %integer'
type :Fixnum, :+, '(Float) -> Float'
type :Fixnum, :+, '(Rational) -> Rational'
type :Fixnum, :+, '(BigDecimal) -> BigDecimal'
type :Fixnum, :+, '(Complex) -> Complex'

type :Fixnum, :-, '(%integer) -> %integer'
type :Fixnum, :-, '(Float) -> Float'
type :Fixnum, :-, '(Rational) -> Rational'
type :Fixnum, :-, '(BigDecimal) -> BigDecimal'
type :Fixnum, :-, '(Complex) -> Complex'

type :Fixnum, :-@, '() -> %integer'

type :Fixnum, :+@, '() -> Fixnum'

type :Fixnum, :/, '(%integer x {{ x!=0 }}) -> %integer'
type :Fixnum, :/, '(Float x {{ x!=0 }}) -> Float'
type :Fixnum, :/, '(Rational x {{ x!=0 }}) -> Rational'
type :Fixnum, :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
type :Fixnum, :/, '(Complex x {{ x!=0 }}) -> Complex'
pre(:Fixnum, :/) { if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Fixnum, :<, '(%integer) -> %bool'
type :Fixnum, :<, '(Float) -> %bool'
type :Fixnum, :<, '(Rational) -> %bool'
type :Fixnum, :<, '(BigDecimal) -> %bool'

type :Fixnum, :<<, '(Fixnum) -> %integer'

type :Fixnum, :<=, '(%integer) -> %bool'
type :Fixnum, :<=, '(Float) -> %bool'
type :Fixnum, :<=, '(Rational) -> %bool'
type :Fixnum, :<=, '(BigDecimal) -> %bool'

type :Fixnum, :<=>, '(%integer) -> Object'
post(:Fixnum, :<=>) { |r,x| r == -1 || r==0 || r==1}
type :Fixnum, :<=>, '(Float) -> Object'
post(:Fixnum, :<=>) { |r,x| r == -1 || r==0 || r==1}
type :Fixnum, :<=>, '(Rational) -> Object'
post(:Fixnum, :<=>) { |r,x| r == -1 || r==0 || r==1}
type :Fixnum, :<=>, '(BigDecimal) -> Object'
post(:Fixnum, :<=>) { |r,x| r == -1 || r==0 || r==1}

type :Fixnum, :==, '(Object) -> %bool'

type :Fixnum, :===, '(Object) -> %bool'

type :Fixnum, :>, '(%integer) -> %bool'
type :Fixnum, :>, '(Float) -> %bool'
type :Fixnum, :>, '(Rational) -> %bool'
type :Fixnum, :>, '(BigDecimal) -> %bool'

type :Fixnum, :>=, '(%integer) -> %bool'
type :Fixnum, :>=, '(Float) -> %bool'
type :Fixnum, :>=, '(Rational) -> %bool'
type :Fixnum, :>=, '(BigDecimal) -> %bool'

type :Fixnum, :>>, '(%integer) -> %integer'
post(:Fixnum, :>>) { |r,x| r >= 0 }

type :Fixnum, :[], '(%integer) -> Fixnum'
post(:Fixnum, :[]) { |r,x| r == 0 || r==1}
type :Fixnum, :[], '(Rational) -> Fixnum'
post(:Fixnum, :[]) { |r,x| r == 0 || r==1}
type :Fixnum, :[], '(Float) -> Fixnum'
pre(:Fixnum, :[]) { |x| x!=Float::INFINITY && !x.nan? }
post(:Fixnum, :[]) { |r,x| r == 0 || r==1}
type :Fixnum, :[], '(BigDecimal) -> Fixnum'
pre(:Fixnum, :[]) { |x| x!=BigDecimal::INFINITY && !x.nan? }
post(:Fixnum, :[]) { |r,x| r == 0 || r==1}

type :Fixnum, :^, '(%integer) -> %integer'

type :Fixnum, :|, '(%integer) -> %integer'

type :Fixnum, :~, '() -> Fixnum'

type :Fixnum, :abs, '() -> %integer r {{ r>=0 }}'

type :Fixnum, :bit_length, '() -> Fixnum r {{ r>=0 }}'

type :Fixnum, :div, '(Fixnum x {{ x!=0 }}) -> %integer'
type :Fixnum, :div, '(Bignum x {{ x!=0 }}) -> Fixnum'
type :Fixnum, :div, '(Float x {{ x!=0 && !x.nan? }}) -> %integer'
type :Fixnum, :div, '(Rational x {{ x!=0 }}) -> %integer'
type :Fixnum, :div, '(BigDecimal x {{ x!=0 && !x.nan? }}) -> %integer'

type :Fixnum, :divmod, '(%real x {{ x!=0 }}) -> [%real, %real]'
pre(:Fixnum, :divmod) { |x| if x.is_a?(Float) then !x.nan? else true end}

type :Fixnum, :even?, '() -> %bool'

type :Fixnum, :fdiv, '(%integer) -> Float'
type :Fixnum, :fdiv, '(Float) -> Float'
type :Fixnum, :fdiv, '(Rational) -> Float'
type :Fixnum, :fdiv, '(BigDecimal) -> BigDecimal'
type :Fixnum, :fdiv, '(Complex) -> Complex'
pre(:Fixnum, :fdiv) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Fixnum, :to_s, '() -> String'
type :Fixnum, :inspect, '() -> String'

type :Fixnum, :magnitude, '() -> %integer r {{ r>=0 }}'

type :Fixnum, :modulo, '(Fixnum x {{ x!=0 }}) -> Fixnum'
type :Fixnum, :modulo, '(Bignum x {{ x!=0 }}) -> %integer'
type :Fixnum, :modulo, '(Float x {{ x!=0 }}) -> Float'
type :Fixnum, :modulo, '(Rational x {{ x!=0 }}) -> Rational'
type :Fixnum, :modulo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

type :Fixnum, :next, '() -> %integer'

type :Fixnum, :odd?, '() -> %bool'

type :Fixnum, :size, '() -> Fixnum'

type :Fixnum, :succ, '() -> %integer'

type :Fixnum, :to_f, '() -> Float'

type :Fixnum, :zero?, '() -> %bool'

type :Fixnum, :ceil, '() -> %integer'

type :Fixnum, :denominator, '() -> Fixnum r {{ r==1 }}'

type :Fixnum, :floor, '() -> %integer'
type :Fixnum, :numerator, '() -> Fixnum'

type :Fixnum, :quo, '(%integer x {{ x!=0 }}) -> Rational'
type :Fixnum, :quo, '(Float x {{ x!=0 }}) -> Float'
type :Fixnum, :quo, '(Rational x {{ x!=0 }}) -> Rational'
type :Fixnum, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
type :Fixnum, :quo, '(Complex x {{ x!=0 }}) -> Complex'
pre(:Fixnum, :quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Fixnum, :rationalize, '() -> Rational'

type :Fixnum, :rationalize, '(%numeric) -> Rational'

type :Fixnum, :round, '() -> %integer'

type :Fixnum, :round, '(%numeric) -> %numeric'
pre(:Fixnum, :round) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

type :Fixnum, :to_i, '() -> Fixnum'

type :Fixnum, :to_r, '() -> Rational'

type :Fixnum, :truncate, '() -> %integer'

type :Fixnum, :angle, '() -> %numeric'
post(:Fixnum, :angle) { |r,x| r == 0 || r == Math::PI}

type :Fixnum, :arg, '() -> %numeric'
post(:Fixnum, :arg) { |r,x| r == 0 || r == Math::PI}

type :Fixnum, :equal?, '(Object) -> %bool'
type :Fixnum, :eql?, '(Object) -> %bool'

type :Fixnum, :hash, '() -> %integer'

type :Fixnum, :phase, '() -> %numeric'

type :Fixnum, :abs2, '() -> %integer r {{ r>=0}}'

type :Fixnum, :conj, '() -> Fixnum'
type :Fixnum, :conjugate, '() -> Fixnum'

type :Fixnum, :imag, '() -> Fixnum r {{ r==0 }}'
type :Fixnum, :imaginary, '() -> Fixnum r {{ r==0 }}'

type :Fixnum, :real, '() -> Fixnum'

type :Fixnum, :real?, '() -> true'

type :Fixnum, :to_c, '() -> Complex r {{ r.imaginary == 0 }}'

type :Fixnum, :remainder, '(Fixnum x {{ x!=0 }}) -> Fixnum r {{ r>0 }}'
type :Fixnum, :remainder, '(Bignum x {{ x!=0 }}) -> Fixnum r {{ r>0 }}'
type :Fixnum, :remainder, '(Float x {{ x!=0 }}) -> Float'
type :Fixnum, :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>0 }}'
type :Fixnum, :remainder, '(BigDecimal x {{ x=0 }}) -> BigDecimal'

type :Fixnum, :coerce, '(%numeric) -> [%real, %real]'
pre(:Fixnum, :coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
