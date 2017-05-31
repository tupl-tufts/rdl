rdl_nowrap :Integer

type :Integer, :%, '(Integer x {{ x!=0 }}) -> Integer'
type :Integer, :%, '(Float x {{ x!=0 }}) -> Float'
type :Integer, :%, '(Rational x {{ x!=0 }}) -> Rational'
type :Integer, :%, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

type :Integer, :&, '(Integer) -> Integer'

type :Integer, :*, '(Integer) -> Integer'
type :Integer, :*, '(Float) -> Float'
type :Integer, :*, '(Rational) -> Rational'
type :Integer, :*, '(BigDecimal) -> BigDecimal'
type :Integer, :*, '(Complex) -> Complex'
pre(:Integer, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

type :Integer, :**, '(Integer) -> %numeric'
type :Integer, :**, '(Float) -> %numeric'
type :Integer, :**, '(Rational) -> %numeric'
type :Integer, :**, '(BigDecimal) -> BigDecimal'
pre(:Integer, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
post(:Integer, :**) { |r,x| r.real?}
type :Integer, :**, '(Complex) -> Complex'
pre(:Integer, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

type :Integer, :+, '(Integer) -> Integer'
type :Integer, :+, '(Float) -> Float'
type :Integer, :+, '(Rational) -> Rational'
type :Integer, :+, '(BigDecimal) -> BigDecimal'
type :Integer, :+, '(Complex) -> Complex'

type :Integer, :-, '(Integer) -> Integer'
type :Integer, :-, '(Float) -> Float'
type :Integer, :-, '(Rational) -> Rational'
type :Integer, :-, '(BigDecimal) -> BigDecimal'
type :Integer, :-, '(Complex) -> Complex'

type :Integer, :-@, '() -> Integer'

type :Integer, :+@, '() -> Integer'

type :Integer, :/, '(Integer x {{ x!=0 }}) -> Integer'
type :Integer, :/, '(Float x {{ x!=0 }}) -> Float'
type :Integer, :/, '(Rational x {{ x!=0 }}) -> Rational'
type :Integer, :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
type :Integer, :/, '(Complex x {{ x!=0 }}) -> Complex'
pre(:Integer, :/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Integer, :<, '(Integer) -> %bool'
type :Integer, :<, '(Float) -> %bool'
type :Integer, :<, '(Rational) -> %bool'
type :Integer, :<, '(BigDecimal) -> %bool'

type :Integer, :<<, '(Integer) -> Integer'

type :Integer, :<=, '(Integer) -> %bool'
type :Integer, :<=, '(Float) -> %bool'
type :Integer, :<=, '(Rational) -> %bool'
type :Integer, :<=, '(BigDecimal) -> %bool'

type :Integer, :<=>, '(Integer) -> Object'
post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
type :Integer, :<=>, '(Float) -> Object'
post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
type :Integer, :<=>, '(Rational) -> Object'
post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
type :Integer, :<=>, '(BigDecimal) -> Object'
post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }

type :Integer, :==, '(Object) -> %bool'

type :Integer, :===, '(Object) -> %bool'

type :Integer, :>, '(Integer) -> %bool'
type :Integer, :>, '(Float) -> %bool'
type :Integer, :>, '(Rational) -> %bool'
type :Integer, :>, '(BigDecimal) -> %bool'

type :Integer, :>=, '(Integer) -> %bool'
type :Integer, :>=, '(Float) -> %bool'
type :Integer, :>=, '(Rational) -> %bool'
type :Integer, :>=, '(BigDecimal) -> %bool'

type :Integer, :>>, '(Integer) -> Integer r {{ r >= 0 }}'

type :Integer, :[], '(Integer) -> Integer'
post(:Integer, :[]) { |r,x| r == 0 || r==1}
type :Integer, :[], '(Rational) -> Integer'
post(:Integer, :[]) { |r,x| r == 0 || r==1}
type :Integer, :[], '(Float) -> Integer'
pre(:Integer, :[]) { |x| x != Float::INFINITY && !x.nan? }
post(:Integer, :[]) { |r,x| r == 0 || r==1}
type :Integer, :[], '(BigDecimal) -> Integer'
pre(:Integer, :[]) { |x| x != BigDecimal::INFINITY && !x.nan? }
post(:Integer, :[]) { |r,x| r == 0 || r == 1 }

type :Integer, :^, '(Integer) -> Integer'

type :Integer, :|, '(Integer) -> Integer'

type :Integer, :~, '() -> Integer'

type :Integer, :abs, '() -> Integer r {{ r>=0 }}'

type :Integer, :bit_length, '() -> Integer r {{ r>=0 }}'

type :Integer, :div, '(Integer x {{ x!=0 }}) -> Integer'
type :Integer, :div, '(Float x {{ x!=0 && !x.nan? }}) -> Integer'
type :Integer, :div, '(Rational x {{ x!=0 }}) -> Integer'
type :Integer, :div, '(BigDecimal x {{ x!=0 && !x.nan? }}) -> Integer'

type :Integer, :divmod, '(%real x {{ x!=0 }}) -> [%real, %real]'
pre(:Integer, :divmod) { |x| if x.is_a?(Float) then !x.nan? else true end}

type :Integer, :fdiv, '(Integer) -> Float'
type :Integer, :fdiv, '(Float) -> Float'
type :Integer, :fdiv, '(Rational) -> Float'
type :Integer, :fdiv, '(BigDecimal) -> BigDecimal'
type :Integer, :fdiv, '(Complex) -> Complex'
pre(:Integer, :fdiv) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Integer, :to_s, '() -> String'
type :Integer, :inspect, '() -> String'

type :Integer, :magnitude, '() -> Integer r {{ r>=0 }}'

type :Integer, :modulo, '(Integer x {{ x!=0 }}) -> Integer'
type :Integer, :modulo, '(Float x {{ x!=0 }}) -> Float'
type :Integer, :modulo, '(Rational x {{ x!=0 }}) -> Rational'
type :Integer, :modulo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

type :Integer, :quo, '(Integer x {{ x!=0 }}) -> Rational'
type :Integer, :quo, '(Float x {{ x!=0 }}) -> Float'
type :Integer, :quo, '(Rational x {{ x!=0 }}) -> Rational'
type :Integer, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
type :Integer, :quo, '(Complex x {{ x!=0 }}) -> Complex'
pre(:Integer, :quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Integer, :abs2, '() -> Integer r {{ r>=0 }}'
type :Integer, :angle, '() -> %numeric'
post(:Integer, :angle) { |r,x| r == 0 || r == Math::PI}
type :Integer, :arg, '() -> %numeric'
post(:Integer, :arg) { |r,x| r == 0 || r == Math::PI}
type :Integer, :equal?, '(Object) -> %bool'
type :Integer, :eql?, '(Object) -> %bool'
type :Integer, :hash, '() -> Integer'
type :Integer, :ceil, '() -> Integer'
type :Integer, :chr, '(Encoding) -> String'
type :Integer, :coerce, '(%numeric) -> [%real, %real]'
pre(:Integer, :coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
type :Integer, :conj, '() -> Integer'
type :Integer, :conjugate, '() -> Integer'
type :Integer, :denominator, '() -> Integer'
post(:Integer, :denominator) { |r,x| r == 1 }
type :Integer, :downto, '(Integer) { (Integer) -> %any } -> Integer'
type :Integer, :downto, '(Integer limit) -> Enumerator<Integer>'
type :Integer, :even?, '() -> %bool'
type :Integer, :gcd, '(Integer) -> Integer'
type :Integer, :gcdlcm, '(Integer) -> [Integer, Integer]'
type :Integer, :floor, '() -> Integer'
type :Integer, :imag, '() -> Integer r {{ r==0 }}'
type :Integer, :imaginary, '() -> Integer r {{ r==0 }}'
type :Integer, :integer?, '() -> true'
type :Integer, :lcm, '(Integer) -> Integer'
type :Integer, :next, '() -> Integer'
type :Integer, :numerator, '() -> Integer'
type :Integer, :odd?, '() -> %bool'
type :Integer, :ord, '() -> Integer'
type :Integer, :phase, '() -> %numeric'
type :Integer, :pred, '() -> Integer'
type :Integer, :rationalize, '() -> Rational'
type :Integer, :rationalize, '(%numeric) -> Rational'
type :Integer, :real, '() -> Integer'
type :Integer, :real?, '() -> true'
type :Integer, :remainder, '(Integer x {{ x!=0 }}) -> Integer r {{ r>=0 }}'
type :Integer, :remainder, '(Float x {{ x!=0 }}) -> Float'
type :Integer, :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>=0 }}'
type :Integer, :remainder, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
type :Integer, :round, '() -> Integer'
type :Integer, :round, '(%numeric) -> %numeric'
pre(:Integer, :round) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].
type :Integer, :size, '() -> Integer'
type :Integer, :succ, '() -> Integer'
type :Integer, :times, '() { (Integer) -> %any } -> Integer'
type :Integer, :times, '() -> Enumerator<Integer>'
type :Integer, :to_c, '() -> Complex r {{ r.imaginary==0 }}'
type :Integer, :to_f, '() -> Float'
type :Integer, :to_i, '() -> Integer'
type :Integer, :to_int, '() -> Integer'
type :Integer, :to_r, '() -> Rational'
type :Integer, :truncate, '() -> Integer'
type :Integer, :upto, '(Integer) { (Integer) -> %any } -> Integer'
type :Integer, :upto, '(Integer) -> Enumerator<Integer>'
type :Integer, :zero?, '() -> %bool'
