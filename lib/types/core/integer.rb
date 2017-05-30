rdl_nowrap :Integer

type :Integer, :%, '(Fixnum x {{ x!=0 }}) -> Fixnum'
type :Integer, :%, '(Bignum x {{ x!=0 }}) -> %integer'
type :Integer, :%, '(Float x {{ x!=0 }}) -> Float'
type :Integer, :%, '(Rational x {{ x!=0 }}) -> Rational'
type :Integer, :%, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

type :Integer, :&, '(%integer) -> Fixnum'

type :Integer, :*, '(%integer) -> %integer'
type :Integer, :*, '(Float) -> Float'
type :Integer, :*, '(Rational) -> Rational'
type :Integer, :*, '(BigDecimal) -> BigDecimal'
type :Integer, :*, '(Complex) -> Complex'
pre(:Integer, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

type :Integer, :**, '(%integer) -> %numeric'
type :Integer, :**, '(Float) -> %numeric'
type :Integer, :**, '(Rational) -> %numeric'
type :Integer, :**, '(BigDecimal) -> BigDecimal'
pre(:Integer, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
post(:Integer, :**) { |r,x| r.real?}
type :Integer, :**, '(Complex) -> Complex'
pre(:Integer, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

type :Integer, :+, '(%integer) -> %integer'
type :Integer, :+, '(Float) -> Float'
type :Integer, :+, '(Rational) -> Rational'
type :Integer, :+, '(BigDecimal) -> BigDecimal'
type :Integer, :+, '(Complex) -> Complex'

type :Integer, :-, '(%integer) -> %integer'
type :Integer, :-, '(Float) -> Float'
type :Integer, :-, '(Rational) -> Rational'
type :Integer, :-, '(BigDecimal) -> BigDecimal'
type :Integer, :-, '(Complex) -> Complex'

type :Integer, :-@, '() -> %integer'

type :Integer, :+@, '() -> %integer'

type :Integer, :/, '(%integer x {{ x!=0 }}) -> %integer'
type :Integer, :/, '(Float x {{ x!=0 }}) -> Float'
type :Integer, :/, '(Rational x {{ x!=0 }}) -> Rational'
type :Integer, :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
type :Integer, :/, '(Complex x {{ x!=0 }}) -> Complex'
pre(:Integer, :/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Integer, :<, '(%integer) -> %bool'
type :Integer, :<, '(Float) -> %bool'
type :Integer, :<, '(Rational) -> %bool'
type :Integer, :<, '(BigDecimal) -> %bool'

type :Integer, :<<, '(Fixnum) -> %integer'

type :Integer, :<=, '(%integer) -> %bool'
type :Integer, :<=, '(Float) -> %bool'
type :Integer, :<=, '(Rational) -> %bool'
type :Integer, :<=, '(BigDecimal) -> %bool'

type :Integer, :<=>, '(%integer) -> Object'
post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
type :Integer, :<=>, '(Float) -> Object'
post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
type :Integer, :<=>, '(Rational) -> Object'
post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
type :Integer, :<=>, '(BigDecimal) -> Object'
post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }

type :Integer, :==, '(Object) -> %bool'

type :Integer, :===, '(Object) -> %bool'

type :Integer, :>, '(%integer) -> %bool'
type :Integer, :>, '(Float) -> %bool'
type :Integer, :>, '(Rational) -> %bool'
type :Integer, :>, '(BigDecimal) -> %bool'

type :Integer, :>=, '(%integer) -> %bool'
type :Integer, :>=, '(Float) -> %bool'
type :Integer, :>=, '(Rational) -> %bool'
type :Integer, :>=, '(BigDecimal) -> %bool'

type :Integer, :>>, '(%integer) -> %integer r {{ r >= 0 }}'

type :Integer, :[], '(%integer) -> Fixnum'
post(:Integer, :[]) { |r,x| r == 0 || r==1}
type :Integer, :[], '(Rational) -> Fixnum'
post(:Integer, :[]) { |r,x| r == 0 || r==1}
type :Integer, :[], '(Float) -> Fixnum'
pre(:Integer, :[]) { |x| x != Float::INFINITY && !x.nan? }
post(:Integer, :[]) { |r,x| r == 0 || r==1}
type :Integer, :[], '(BigDecimal) -> Fixnum'
pre(:Integer, :[]) { |x| x != BigDecimal::INFINITY && !x.nan? }
post(:Integer, :[]) { |r,x| r == 0 || r == 1 }

type :Integer, :^, '(%integer) -> %integer'

type :Integer, :|, '(%integer) -> %integer'

type :Integer, :~, '() -> %integer'

type :Integer, :abs, '() -> %integer r {{ r>=0 }}'

type :Integer, :bit_length, '() -> %integer r {{ r>=0 }}'

type :Integer, :div, '(%integer x {{ x!=0 }}) -> %integer'
type :Integer, :div, '(Float x {{ x!=0 && !x.nan? }}) -> %integer'
type :Integer, :div, '(Rational x {{ x!=0 }}) -> %integer'
type :Integer, :div, '(BigDecimal x {{ x!=0 && !x.nan? }}) -> %integer'

type :Integer, :divmod, '(%real x {{ x!=0 }}) -> [%real, %real]'
pre(:Integer, :divmod) { |x| if x.is_a?(Float) then !x.nan? else true end}

type :Integer, :fdiv, '(%integer) -> Float'
type :Integer, :fdiv, '(Float) -> Float'
type :Integer, :fdiv, '(Rational) -> Float'
type :Integer, :fdiv, '(BigDecimal) -> BigDecimal'
type :Integer, :fdiv, '(Complex) -> Complex'
pre(:Integer, :fdiv) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Integer, :to_s, '() -> String'
type :Integer, :inspect, '() -> String'

type :Integer, :magnitude, '() -> %integer r {{ r>=0 }}'

type :Integer, :modulo, '(Fixnum x {{ x!=0 }}) -> Fixnum'
type :Integer, :modulo, '(Bignum x {{ x!=0 }}) -> %integer'
type :Integer, :modulo, '(Float x {{ x!=0 }}) -> Float'
type :Integer, :modulo, '(Rational x {{ x!=0 }}) -> Rational'
type :Integer, :modulo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

type :Integer, :quo, '(%integer x {{ x!=0 }}) -> Rational'
type :Integer, :quo, '(Float x {{ x!=0 }}) -> Float'
type :Integer, :quo, '(Rational x {{ x!=0 }}) -> Rational'
type :Integer, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
type :Integer, :quo, '(Complex x {{ x!=0 }}) -> Complex'
pre(:Integer, :quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Integer, :abs2, '() -> %integer r {{ r>=0 }}'
type :Integer, :angle, '() -> %numeric'
post(:Integer, :angle) { |r,x| r == 0 || r == Math::PI}
type :Integer, :arg, '() -> %numeric'
post(:Integer, :arg) { |r,x| r == 0 || r == Math::PI}
type :Integer, :equal?, '(Object) -> %bool'
type :Integer, :eql?, '(Object) -> %bool'
type :Integer, :hash, '() -> %integer'
type :Integer, :ceil, '() -> %integer'
type :Integer, :chr, '(Encoding) -> String'
type :Integer, :coerce, '(%numeric) -> [%real, %real]'
pre(:Integer, :coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
type :Integer, :conj, '() -> %integer'
type :Integer, :conjugate, '() -> %integer'
type :Integer, :denominator, '() -> Fixnum'
post(:Integer, :denominator) { |r,x| r == 1 }
type :Integer, :downto, '(%integer) { (%integer) -> %any } -> %integer'
type :Integer, :downto, '(%integer limit) -> Enumerator<%integer>'
type :Integer, :even?, '() -> %bool'
type :Integer, :gcd, '(%integer) -> %integer'
type :Integer, :gcdlcm, '(%integer) -> [%integer, %integer]'
type :Integer, :floor, '() -> %integer'
type :Integer, :imag, '() -> Fixnum r {{ r==0 }}'
type :Integer, :imaginary, '() -> Fixnum r {{ r==0 }}'
type :Integer, :integer?, '() -> true'
type :Integer, :lcm, '(%integer) -> %integer'
type :Integer, :next, '() -> %integer'
type :Integer, :numerator, '() -> %integer'
type :Integer, :odd?, '() -> %bool'
type :Integer, :ord, '() -> %integer'
type :Integer, :phase, '() -> %numeric'
type :Integer, :pred, '() -> %integer'
type :Integer, :rationalize, '() -> Rational'
type :Integer, :rationalize, '(%numeric) -> Rational'
type :Integer, :real, '() -> %integer'
type :Integer, :real?, '() -> true'
type :Integer, :remainder, '(Fixnum x {{ x!=0 }}) -> Fixnum r {{ r>=0 }}'
type :Integer, :remainder, '(Bignum x {{ x!=0 }}) -> Fixnum r {{ r>=0 }}'
type :Integer, :remainder, '(Float x {{ x!=0 }}) -> Float'
type :Integer, :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>=0 }}'
type :Integer, :remainder, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
type :Integer, :round, '() -> %integer'
type :Integer, :round, '(%numeric) -> %numeric'
pre(:Integer, :round) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].
type :Integer, :size, '() -> %integer'
type :Integer, :succ, '() -> %integer'
type :Integer, :times, '() { (%integer) -> %any } -> %integer'
type :Integer, :times, '() -> Enumerator<%integer>'
type :Integer, :to_c, '() -> Complex r {{ r.imaginary==0 }}'
type :Integer, :to_f, '() -> Float'
type :Integer, :to_i, '() -> %integer'
type :Integer, :to_int, '() -> %integer'
type :Integer, :to_r, '() -> Rational'
type :Integer, :truncate, '() -> %integer'
type :Integer, :upto, '(%integer) { (%integer) -> %any } -> %integer'
type :Integer, :upto, '(%integer) -> Enumerator<%integer>'
type :Integer, :zero?, '() -> %bool'
