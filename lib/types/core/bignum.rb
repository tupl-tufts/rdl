rdl_nowrap :Bignum

type :Bignum, :%, '(Fixnum x {{ x!=0 }}) -> Fixnum'
type :Bignum, :%, '(Bignum x {{ x!=0 }}) -> %integer'
type :Bignum, :%, '(Float x {{ x!=0 }}) -> Float'
type :Bignum, :%, '(Rational x {{ x!=0 }}) -> Rational'
type :Bignum, :%, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

type :Bignum, :&, '(%integer) -> %integer'

type :Bignum, :*, '(Fixnum) -> %integer'
type :Bignum, :*, '(Bignum) -> Bignum'
type :Bignum, :*, '(Float) -> Float'
type :Bignum, :*, '(Rational) -> Rational'
type :Bignum, :*, '(BigDecimal) -> BigDecimal'
type :Bignum, :*, '(Complex) -> Complex'
pre(:Bignum, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

type :Bignum, :**, '(%integer) -> %numeric'
type :Bignum, :**, '(Float) -> %numeric'
type :Bignum, :**, '(Rational) -> %numeric'
type :Bignum, :**, '(BigDecimal) -> BigDecimal'
pre(:Bignum, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
post(:Bignum, :**) { |r,x| r.real?}
type :Bignum, :**, '(Complex) -> Complex'
pre(:Bignum, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

type :Bignum, :+, '(%integer) -> %integer'
type :Bignum, :+, '(Float) -> Float'
type :Bignum, :+, '(Rational) -> Rational'
type :Bignum, :+, '(BigDecimal) -> BigDecimal'
type :Bignum, :+, '(Complex) -> Complex'

type :Bignum, :-, '(%integer) -> %integer'
type :Bignum, :-, '(Float) -> Float'
type :Bignum, :-, '(Rational) -> Rational'
type :Bignum, :-, '(BigDecimal) -> BigDecimal'
type :Bignum, :-, '(Complex) -> Complex'

type :Bignum, :-@, '() -> %integer'

type :Bignum, :+@, '() -> Bignum'

type :Bignum, :/, '(%integer x {{ x!=0 }}) -> %integer'
type :Bignum, :/, '(Float x {{ x!=0 }}) -> Float'
type :Bignum, :/, '(Rational x {{ x!=0 }}) -> Rational'
type :Bignum, :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
type :Bignum, :/, '(Complex x {{ x!=0 }}) -> Complex'
pre(:Bignum, :/) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Bignum, :<, '(%integer) -> %bool'
type :Bignum, :<, '(Float) -> %bool'
type :Bignum, :<, '(Rational) -> %bool'
type :Bignum, :<, '(BigDecimal) -> %bool'

type :Bignum, :<<, '(Fixnum) -> %integer'

type :Bignum, :<=, '(%integer) -> %bool'
type :Bignum, :<=, '(Float) -> %bool'
type :Bignum, :<=, '(Rational) -> %bool'
type :Bignum, :<=, '(BigDecimal) -> %bool'

type :Bignum, :<=>, '(%integer) -> Object'
post(:Bignum, :<=>) { |r,x| r == -1 || r==0 || r==1}
type :Bignum, :<=>, '(Float) -> Object'
post(:Bignum, :<=>) { |r,x| r == -1 || r==0 || r==1}
type :Bignum, :<=>, '(Rational) -> Object'
post(:Bignum, :<=>) { |r,x| r == -1 || r==0 || r==1}
type :Bignum, :<=>, '(BigDecimal) -> Object'
post(:Bignum, :<=>) { |r,x| r == -1 || r==0 || r==1}

type :Bignum, :==, '(Object) -> %bool'

type :Bignum, :===, '(Object) -> %bool'

type :Bignum, :>, '(%integer) -> %bool'
type :Bignum, :>, '(Float) -> %bool'
type :Bignum, :>, '(Rational) -> %bool'
type :Bignum, :>, '(BigDecimal) -> %bool'

type :Bignum, :>=, '(%integer) -> %bool'
type :Bignum, :>=, '(Float) -> %bool'
type :Bignum, :>=, '(Rational) -> %bool'
type :Bignum, :>=, '(BigDecimal) -> %bool'

type :Bignum, :>>, '(%integer) -> %integer'
post(:Bignum, :>>) { |r,x| r >= 0 }

type :Bignum, :[], '(%integer) -> Fixnum'
post(:Bignum, :[]) { |r,x| r == 0 || r==1}
type :Bignum, :[], '(Rational) -> Fixnum'
post(:Bignum, :[]) { |r,x| r == 0 || r==1}
type :Bignum, :[], '(Float) -> Fixnum'
pre(:Bignum, :[]) { |x| x!=Float::INFINITY && !x.nan? }
post(:Bignum, :[]) { |r,x| r == 0 || r==1}
type :Bignum, :[], '(BigDecimal) -> Fixnum'
pre(:Bignum, :[]) { |x| x!=BigDecimal::INFINITY && !x.nan? }
post(:Bignum, :[]) { |r,x| r == 0 || r==1}

type :Bignum, :^, '(%integer) -> %integer'

type :Bignum, :|, '(%integer) -> %integer'

type :Bignum, :~, '() -> Bignum'

type :Bignum, :abs, '() -> Bignum r {{ r>=0 }}'

type :Bignum, :bit_length, '() -> %integer r {{ r>=0 }}'

type :Bignum, :div, '(%integer x {{ x!=0 }}) -> %integer'
type :Bignum, :div, '(Float x {{ x!=0 && !x.nan? }}) -> %integer'
type :Bignum, :div, '(Rational x {{ x!=0 }}) -> %integer'
type :Bignum, :div, '(BigDecimal x {{ x!=0 && !x.nan?}}) -> %integer'

type :Bignum, :divmod, '(%real) -> [%real, %real]'
pre(:Bignum, :divmod) { |x| x!=0 && if x.is_a?(Float) then !x.nan? else true end}

type :Bignum, :even?, '() -> %bool'

type :Bignum, :fdiv, '(%integer) -> Float'
type :Bignum, :fdiv, '(Float) -> Float'
type :Bignum, :fdiv, '(Rational) -> Float'
type :Bignum, :fdiv, '(BigDecimal) -> BigDecimal'
type :Bignum, :fdiv, '(Complex) -> Complex'
pre(:Bignum, :fdiv) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Bignum, :to_s, '() -> String'
type :Bignum, :inspect, '() -> String'

type :Bignum, :magnitude, '() -> Bignum'
post(:Bignum, :magnitude) { |r,x| r >= 0 }

type :Bignum, :modulo, '(Fixnum x {{ x!=0 }}) -> Fixnum'
type :Bignum, :modulo, '(Bignum x {{ x!=0 }}) -> %integer'
type :Bignum, :modulo, '(Float x {{ x!=0 }}) -> Float'
type :Bignum, :modulo, '(Rational x {{ x!=0 }}) -> Rational'
type :Bignum, :modulo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

type :Bignum, :next, '() -> %integer'

type :Bignum, :odd?, '() -> %bool'

type :Bignum, :size, '() -> %integer'

type :Bignum, :succ, '() -> %integer'

type :Bignum, :to_f, '() -> Float'

type :Bignum, :zero?, '() -> %bool'

type :Bignum, :ceil, '() -> %integer'

type :Bignum, :denominator, '() -> Fixnum r {{ r==1 }}'

type :Bignum, :floor, '() -> %integer'

type :Bignum, :numerator, '() -> Bignum'

type :Bignum, :quo, '(%integer x {{ x!=0 }}) -> Rational'
type :Bignum, :quo, '(Float x {{ x!=0 }}) -> Float'
type :Bignum, :quo, '(Rational x {{ x!=0 }}) -> Rational'
type :Bignum, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
type :Bignum, :quo, '(Complex x {{ x!=0 }}) -> Complex'
pre(:Bignum, :quo) { if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Bignum, :rationalize, '() -> Rational'

type :Bignum, :rationalize, '(%numeric) -> Rational'

type :Bignum, :round, '() -> %integer'

type :Bignum, :round, '(%numeric) -> %numeric'
pre(:Bignum, :round) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

type :Bignum, :to_i, '() -> Bignum'

type :Bignum, :to_r, '() -> Rational'

type :Bignum, :truncate, '() -> %integer'

type :Bignum, :angle, '() -> %numeric'
post(:Bignum, :angle) { |r,x| r == 0 || r == Math::PI}

type :Bignum, :arg, '() -> %numeric'
post(:Bignum, :arg) { |r,x| r == 0 || r == Math::PI}

type :Bignum, :equal?, '(Object) -> %bool'
type :Bignum, :eql?, '(Object) -> %bool'

type :Bignum, :hash, '() -> %integer'

type :Bignum, :phase, '() -> %numeric'

type :Bignum, :abs2, '() -> Bignum r {{ r>=0 }}'

type :Bignum, :conj, '() -> Bignum'
type :Bignum, :conjugate, '() -> Bignum'

type :Bignum, :imag, '() -> Fixnum r {{ r==0 }}'
type :Bignum, :imaginary, '() -> Fixnum r {{ r==0 }}'

type :Bignum, :real, '() -> Bignum'

type :Bignum, :real?, '() -> true'

type :Bignum, :to_c, '() -> Complex r {{ r.imaginary==0 }}'

type :Bignum, :remainder, '(Fixnum x {{ x!=0 }}) -> Fixnum r {{ r>=0 }}'
type :Bignum, :remainder, '(Bignum x {{ x!=0 }}) -> Fixnum r {{ r>=0 }}'
type :Bignum, :remainder, '(Float x {{ x!=0 }}) -> Float'
type :Bignum, :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>=0 }}'
type :Bignum, :remainder, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

type :Bignum, :coerce, '(%integer) -> [%integer, %integer]'
