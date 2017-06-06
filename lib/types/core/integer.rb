RDL.nowrap :Integer

RDL.type :Integer, :%, '(Integer x {{ x!=0 }}) -> Integer'
RDL.type :Integer, :%, '(Float x {{ x!=0 }}) -> Float'
RDL.type :Integer, :%, '(Rational x {{ x!=0 }}) -> Rational'
RDL.type :Integer, :%, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

RDL.type :Integer, :&, '(Integer) -> Integer'

RDL.type :Integer, :*, '(Integer) -> Integer'
RDL.type :Integer, :*, '(Float) -> Float'
RDL.type :Integer, :*, '(Rational) -> Rational'
RDL.type :Integer, :*, '(BigDecimal) -> BigDecimal'
RDL.type :Integer, :*, '(Complex) -> Complex'
RDL.pre(:Integer, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

RDL.type :Integer, :**, '(Integer) -> %numeric'
RDL.type :Integer, :**, '(Float) -> %numeric'
RDL.type :Integer, :**, '(Rational) -> %numeric'
RDL.type :Integer, :**, '(BigDecimal) -> BigDecimal'
RDL.pre(:Integer, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
RDL.post(:Integer, :**) { |r,x| r.real?}
RDL.type :Integer, :**, '(Complex) -> Complex'
RDL.pre(:Integer, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

RDL.type :Integer, :+, '(Integer) -> Integer'
RDL.type :Integer, :+, '(Float) -> Float'
RDL.type :Integer, :+, '(Rational) -> Rational'
RDL.type :Integer, :+, '(BigDecimal) -> BigDecimal'
RDL.type :Integer, :+, '(Complex) -> Complex'

RDL.type :Integer, :-, '(Integer) -> Integer'
RDL.type :Integer, :-, '(Float) -> Float'
RDL.type :Integer, :-, '(Rational) -> Rational'
RDL.type :Integer, :-, '(BigDecimal) -> BigDecimal'
RDL.type :Integer, :-, '(Complex) -> Complex'

RDL.type :Integer, :-@, '() -> Integer'

RDL.type :Integer, :+@, '() -> Integer'

RDL.type :Integer, :/, '(Integer x {{ x!=0 }}) -> Integer'
RDL.type :Integer, :/, '(Float x {{ x!=0 }}) -> Float'
RDL.type :Integer, :/, '(Rational x {{ x!=0 }}) -> Rational'
RDL.type :Integer, :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
RDL.type :Integer, :/, '(Complex x {{ x!=0 }}) -> Complex'
RDL.pre(:Integer, :/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Integer, :<, '(Integer) -> %bool'
RDL.type :Integer, :<, '(Float) -> %bool'
RDL.type :Integer, :<, '(Rational) -> %bool'
RDL.type :Integer, :<, '(BigDecimal) -> %bool'

RDL.type :Integer, :<<, '(Integer) -> Integer'

RDL.type :Integer, :<=, '(Integer) -> %bool'
RDL.type :Integer, :<=, '(Float) -> %bool'
RDL.type :Integer, :<=, '(Rational) -> %bool'
RDL.type :Integer, :<=, '(BigDecimal) -> %bool'

RDL.type :Integer, :<=>, '(Integer) -> Object'
RDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
RDL.type :Integer, :<=>, '(Float) -> Object'
RDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
RDL.type :Integer, :<=>, '(Rational) -> Object'
RDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
RDL.type :Integer, :<=>, '(BigDecimal) -> Object'
RDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }

RDL.type :Integer, :==, '(Object) -> %bool'

RDL.type :Integer, :===, '(Object) -> %bool'

RDL.type :Integer, :>, '(Integer) -> %bool'
RDL.type :Integer, :>, '(Float) -> %bool'
RDL.type :Integer, :>, '(Rational) -> %bool'
RDL.type :Integer, :>, '(BigDecimal) -> %bool'

RDL.type :Integer, :>=, '(Integer) -> %bool'
RDL.type :Integer, :>=, '(Float) -> %bool'
RDL.type :Integer, :>=, '(Rational) -> %bool'
RDL.type :Integer, :>=, '(BigDecimal) -> %bool'

RDL.type :Integer, :>>, '(Integer) -> Integer r {{ r >= 0 }}'

RDL.type :Integer, :[], '(Integer) -> Integer'
RDL.post(:Integer, :[]) { |r,x| r == 0 || r==1}
RDL.type :Integer, :[], '(Rational) -> Integer'
RDL.post(:Integer, :[]) { |r,x| r == 0 || r==1}
RDL.type :Integer, :[], '(Float) -> Integer'
RDL.pre(:Integer, :[]) { |x| x != Float::INFINITY && !x.nan? }
RDL.post(:Integer, :[]) { |r,x| r == 0 || r==1}
RDL.type :Integer, :[], '(BigDecimal) -> Integer'
RDL.pre(:Integer, :[]) { |x| x != BigDecimal::INFINITY && !x.nan? }
RDL.post(:Integer, :[]) { |r,x| r == 0 || r == 1 }

RDL.type :Integer, :^, '(Integer) -> Integer'

RDL.type :Integer, :|, '(Integer) -> Integer'

RDL.type :Integer, :~, '() -> Integer'

RDL.type :Integer, :abs, '() -> Integer r {{ r>=0 }}'

RDL.type :Integer, :bit_length, '() -> Integer r {{ r>=0 }}'

RDL.type :Integer, :div, '(Integer x {{ x!=0 }}) -> Integer'
RDL.type :Integer, :div, '(Float x {{ x!=0 && !x.nan? }}) -> Integer'
RDL.type :Integer, :div, '(Rational x {{ x!=0 }}) -> Integer'
RDL.type :Integer, :div, '(BigDecimal x {{ x!=0 && !x.nan? }}) -> Integer'

RDL.type :Integer, :divmod, '(%real x {{ x!=0 }}) -> [%real, %real]'
RDL.pre(:Integer, :divmod) { |x| if x.is_a?(Float) then !x.nan? else true end}

RDL.type :Integer, :fdiv, '(Integer) -> Float'
RDL.type :Integer, :fdiv, '(Float) -> Float'
RDL.type :Integer, :fdiv, '(Rational) -> Float'
RDL.type :Integer, :fdiv, '(BigDecimal) -> BigDecimal'
RDL.type :Integer, :fdiv, '(Complex) -> Complex'
RDL.pre(:Integer, :fdiv) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Integer, :to_s, '() -> String'
RDL.type :Integer, :inspect, '() -> String'

RDL.type :Integer, :magnitude, '() -> Integer r {{ r>=0 }}'

RDL.type :Integer, :modulo, '(Integer x {{ x!=0 }}) -> Integer'
RDL.type :Integer, :modulo, '(Float x {{ x!=0 }}) -> Float'
RDL.type :Integer, :modulo, '(Rational x {{ x!=0 }}) -> Rational'
RDL.type :Integer, :modulo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

RDL.type :Integer, :quo, '(Integer x {{ x!=0 }}) -> Rational'
RDL.type :Integer, :quo, '(Float x {{ x!=0 }}) -> Float'
RDL.type :Integer, :quo, '(Rational x {{ x!=0 }}) -> Rational'
RDL.type :Integer, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
RDL.type :Integer, :quo, '(Complex x {{ x!=0 }}) -> Complex'
RDL.pre(:Integer, :quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Integer, :abs2, '() -> Integer r {{ r>=0 }}'
RDL.type :Integer, :angle, '() -> %numeric'
RDL.post(:Integer, :angle) { |r,x| r == 0 || r == Math::PI}
RDL.type :Integer, :arg, '() -> %numeric'
RDL.post(:Integer, :arg) { |r,x| r == 0 || r == Math::PI}
RDL.type :Integer, :equal?, '(Object) -> %bool'
RDL.type :Integer, :eql?, '(Object) -> %bool'
RDL.type :Integer, :hash, '() -> Integer'
RDL.type :Integer, :ceil, '() -> Integer'
RDL.type :Integer, :chr, '(Encoding) -> String'
RDL.type :Integer, :coerce, '(%numeric) -> [%real, %real]'
RDL.pre(:Integer, :coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
RDL.type :Integer, :conj, '() -> Integer'
RDL.type :Integer, :conjugate, '() -> Integer'
RDL.type :Integer, :denominator, '() -> Integer'
RDL.post(:Integer, :denominator) { |r,x| r == 1 }
RDL.type :Integer, :downto, '(Integer) { (Integer) -> %any } -> Integer'
RDL.type :Integer, :downto, '(Integer limit) -> Enumerator<Integer>'
RDL.type :Integer, :even?, '() -> %bool'
RDL.type :Integer, :gcd, '(Integer) -> Integer'
RDL.type :Integer, :gcdlcm, '(Integer) -> [Integer, Integer]'
RDL.type :Integer, :floor, '() -> Integer'
RDL.type :Integer, :imag, '() -> Integer r {{ r==0 }}'
RDL.type :Integer, :imaginary, '() -> Integer r {{ r==0 }}'
RDL.type :Integer, :integer?, '() -> true'
RDL.type :Integer, :lcm, '(Integer) -> Integer'
RDL.type :Integer, :next, '() -> Integer'
RDL.type :Integer, :numerator, '() -> Integer'
RDL.type :Integer, :odd?, '() -> %bool'
RDL.type :Integer, :ord, '() -> Integer'
RDL.type :Integer, :phase, '() -> %numeric'
RDL.type :Integer, :pred, '() -> Integer'
RDL.type :Integer, :rationalize, '() -> Rational'
RDL.type :Integer, :rationalize, '(%numeric) -> Rational'
RDL.type :Integer, :real, '() -> Integer'
RDL.type :Integer, :real?, '() -> true'
RDL.type :Integer, :remainder, '(Integer x {{ x!=0 }}) -> Integer r {{ r>=0 }}'
RDL.type :Integer, :remainder, '(Float x {{ x!=0 }}) -> Float'
RDL.type :Integer, :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>=0 }}'
RDL.type :Integer, :remainder, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
RDL.type :Integer, :round, '() -> Integer'
RDL.type :Integer, :round, '(%numeric) -> %numeric'
RDL.pre(:Integer, :round) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].
RDL.type :Integer, :size, '() -> Integer'
RDL.type :Integer, :succ, '() -> Integer'
RDL.type :Integer, :times, '() { (Integer) -> %any } -> Integer'
RDL.type :Integer, :times, '() -> Enumerator<Integer>'
RDL.type :Integer, :to_c, '() -> Complex r {{ r.imaginary==0 }}'
RDL.type :Integer, :to_f, '() -> Float'
RDL.type :Integer, :to_i, '() -> Integer'
RDL.type :Integer, :to_int, '() -> Integer'
RDL.type :Integer, :to_r, '() -> Rational'
RDL.type :Integer, :truncate, '() -> Integer'
RDL.type :Integer, :upto, '(Integer) { (Integer) -> %any } -> Integer'
RDL.type :Integer, :upto, '(Integer) -> Enumerator<Integer>'
RDL.type :Integer, :zero?, '() -> %bool'
