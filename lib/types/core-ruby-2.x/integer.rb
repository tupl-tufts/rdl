class Integer < Numeric
  rdl_nowrap

  type :%, '(Fixnum x {{ x!=0 }}) -> Fixnum'
  type :%, '(Bignum x {{ x!=0 }}) -> %integer'
  type :%, '(Float x {{ x!=0 }}) -> Float'
  type :%, '(Rational x {{ x!=0 }}) -> Rational'
  type :%, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

  type :&, '(%integer) -> Fixnum'

  type :*, '(%integer) -> %integer'
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

  type :/, '(%integer x {{ x!=0 }}) -> %integer'
  type :/, '(Float x {{ x!=0 }}) -> Float'
  type :/, '(Rational x {{ x!=0 }}) -> Rational'
  type :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
  type :/, '(Complex x {{ x!=0 }}) -> Complex'
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
  post(:<=>) { |r,x| r == -1 || r == 0 || r == 1 }
  type :<=>, '(Float) -> Object'
  post(:<=>) { |r,x| r == -1 || r == 0 || r == 1 }
  type :<=>, '(Rational) -> Object'
  post(:<=>) { |r,x| r == -1 || r == 0 || r == 1 }
  type :<=>, '(BigDecimal) -> Object'
  post(:<=>) { |r,x| r == -1 || r == 0 || r == 1 }

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

  type :>>, '(%integer) -> %integer r {{ r >= 0 }}'

  type :[], '(%integer) -> Fixnum'
  post(:[]) { |r,x| r == 0 || r==1}
  type :[], '(Rational) -> Fixnum'
  post(:[]) { |r,x| r == 0 || r==1}
  type :[], '(Float) -> Fixnum'
  pre(:[]) { |x| x != Float::INFINITY && !x.nan? }
  post(:[]) { |r,x| r == 0 || r==1}
  type :[], '(BigDecimal) -> Fixnum'
  pre(:[]) { |x| x != BigDecimal::INFINITY && !x.nan? }
  post(:[]) { |r,x| r == 0 || r == 1 }

  type :^, '(%integer) -> %integer'

  type :|, '(%integer) -> %integer'

  type :~, '() -> %integer'

  type :abs, '() -> %integer r {{ r>=0 }}'

  type :bit_length, '() -> %integer r {{ r>=0 }}'

  type :div, '(%integer x {{ x!=0 }}) -> %integer'
  type :div, '(Float x {{ x!=0 && !x.nan? }}) -> %integer'
  type :div, '(Rational x {{ x!=0 }}) -> %integer'
  type :div, '(BigDecimal x {{ x!=0 && !x.nan? }}) -> %integer'

  type :divmod, '(%real x {{ x!=0 }}) -> [%real, %real]'
  pre(:divmod) { |x| if x.is_a?(Float) then !x.nan? else true end}

  type :fdiv, '(%integer) -> Float'
  type :fdiv, '(Float) -> Float'
  type :fdiv, '(Rational) -> Float'
  type :fdiv, '(BigDecimal) -> BigDecimal'
  type :fdiv, '(Complex) -> Complex'
  pre(:fdiv) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :to_s, '() -> String'
  type :inspect, '() -> String'

  type :magnitude, '() -> %integer r {{ r>=0 }}'

  type :modulo, '(Fixnum x {{ x!=0 }}) -> Fixnum'
  type :modulo, '(Bignum x {{ x!=0 }}) -> %integer'
  type :modulo, '(Float x {{ x!=0 }}) -> Float'
  type :modulo, '(Rational x {{ x!=0 }}) -> Rational'
  type :modulo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'

  type :quo, '(%integer x {{ x!=0 }}) -> Rational'
  type :quo, '(Float x {{ x!=0 }}) -> Float'
  type :quo, '(Rational x {{ x!=0 }}) -> Rational'
  type :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
  type :quo, '(Complex x {{ x!=0 }}) -> Complex'
  pre(:quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :abs2, '() -> %integer r {{ r>=0 }}'
  type :angle, '() -> %numeric'
  post(:angle) { |r,x| r == 0 || r == Math::PI}
  type :arg, '() -> %numeric'
  post(:arg) { |r,x| r == 0 || r == Math::PI}
  type :equal?, '(Object) -> %bool'
  type :eql?, '(Object) -> %bool'
  type :hash, '() -> %integer'
  type :ceil, '() -> %integer'
  type :chr, '(Encoding) -> String'
  type :coerce, '(%numeric) -> [%real, %real]'
  pre(:coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
  type :conj, '() -> %integer'
  type :conjugate, '() -> %integer'
  type :denominator, '() -> Fixnum'
  post(:denominator) { |r,x| r == 1 }
  type :downto, '(%integer) { (%integer) -> %any } -> %integer'
  type :downto, '(%integer limit) -> Enumerator<%integer>'
  type :even?, '() -> %bool'
  type :gcd, '(%integer) -> %integer'
  type :gcdlcm, '(%integer) -> [%integer, %integer]'
  type :floor, '() -> %integer'
  type :imag, '() -> Fixnum r {{ r==0 }}'
  type :imaginary, '() -> Fixnum r {{ r==0 }}'
  type :integer?, '() -> true'
  type :lcm, '(%integer) -> %integer'
  type :next, '() -> %integer'
  type :numerator, '() -> %integer'
  type :odd?, '() -> %bool'
  type :ord, '() -> %integer'
  type :phase, '() -> %numeric'
  type :pred, '() -> %integer'
  type :rationalize, '() -> Rational'
  type :rationalize, '(%numeric) -> Rational'
  type :real, '() -> %integer'
  type :real?, '() -> true'
  type :remainder, '(Fixnum x {{ x!=0 }}) -> Fixnum r {{ r>=0 }}'
  type :remainder, '(Bignum x {{ x!=0 }}) -> Fixnum r {{ r>=0 }}'
  type :remainder, '(Float x {{ x!=0 }}) -> Float'
  type :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>=0 }}'
  type :remainder, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
  type :round, '() -> %integer'
  type :round, '(%numeric) -> %numeric'
  pre(:round) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].
  type :size, '() -> %integer'
  type :succ, '() -> %integer'
  type :times, '() { (%integer) -> %any } -> %integer'
  type :times, '() -> Enumerator<%integer>'
  type :to_c, '() -> Complex r {{ r.imaginary==0 }}'
  type :to_f, '() -> Float'
  type :to_i, '() -> %integer'
  type :to_int, '() -> %integer'
  type :to_r, '() -> Rational'
  type :truncate, '() -> %integer'
  type :upto, '(%integer) { (%integer) -> %any } -> %integer'
  type :upto, '(%integer) -> Enumerator<%integer>'
  type :zero?, '() -> %bool'
end
