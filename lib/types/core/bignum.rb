rdl_nowrap :Bignum

type :Bignum, :%, '(Fixnum x {{ x!=0 }}) -> Fixnum', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :%, '(Bignum x {{ x!=0 }}) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :%, '(Float x {{ x!=0 }}) -> Float', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :%, '(Rational x {{ x!=0 }}) -> Rational', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :%, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :&, '(Integer) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :*, '(Fixnum) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :*, '(Bignum) -> Bignum', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :*, '(Float) -> Float', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :*, '(Rational) -> Rational', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :*, '(BigDecimal) -> BigDecimal', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :*, '(Complex) -> Complex', version: RDL::PRE_INTMERGE_VERSIONS
pre(:Bignum, :*, version: RDL::PRE_INTMERGE_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

type :Bignum, :**, '(Integer) -> %numeric', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :**, '(Float) -> %numeric', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :**, '(Rational) -> %numeric', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :**, '(BigDecimal) -> BigDecimal', version: RDL::PRE_INTMERGE_VERSIONS
pre(:Bignum, :**, version: RDL::PRE_INTMERGE_VERSIONS) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
post(:Bignum, :**, version: RDL::PRE_INTMERGE_VERSIONS) { |r,x| r.real?}
type :Bignum, :**, '(Complex) -> Complex', version: RDL::PRE_INTMERGE_VERSIONS
pre(:Bignum, :**, version: RDL::PRE_INTMERGE_VERSIONS) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

type :Bignum, :+, '(Integer) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :+, '(Float) -> Float', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :+, '(Rational) -> Rational', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :+, '(BigDecimal) -> BigDecimal', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :+, '(Complex) -> Complex', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :-, '(Integer) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :-, '(Float) -> Float', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :-, '(Rational) -> Rational', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :-, '(BigDecimal) -> BigDecimal', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :-, '(Complex) -> Complex', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :-@, '() -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :+@, '() -> Bignum', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :/, '(Integer x {{ x!=0 }}) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :/, '(Float x {{ x!=0 }}) -> Float', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :/, '(Rational x {{ x!=0 }}) -> Rational', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :/, '(Complex x {{ x!=0 }}) -> Complex', version: RDL::PRE_INTMERGE_VERSIONS
pre(:Bignum, :/, version: RDL::PRE_INTMERGE_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Bignum, :<, '(Integer) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :<, '(Float) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :<, '(Rational) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :<, '(BigDecimal) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :<<, '(Fixnum) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :<=, '(Integer) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :<=, '(Float) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :<=, '(Rational) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :<=, '(BigDecimal) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :<=>, '(Integer) -> Object', version: RDL::PRE_INTMERGE_VERSIONS
post(:Bignum, :<=>, version: RDL::PRE_INTMERGE_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
type :Bignum, :<=>, '(Float) -> Object', version: RDL::PRE_INTMERGE_VERSIONS
post(:Bignum, :<=>, version: RDL::PRE_INTMERGE_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
type :Bignum, :<=>, '(Rational) -> Object', version: RDL::PRE_INTMERGE_VERSIONS
post(:Bignum, :<=>, version: RDL::PRE_INTMERGE_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
type :Bignum, :<=>, '(BigDecimal) -> Object', version: RDL::PRE_INTMERGE_VERSIONS
post(:Bignum, :<=>, version: RDL::PRE_INTMERGE_VERSIONS) { |r,x| r == -1 || r==0 || r==1}

type :Bignum, :==, '(Object) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :===, '(Object) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :>, '(Integer) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :>, '(Float) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :>, '(Rational) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :>, '(BigDecimal) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :>=, '(Integer) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :>=, '(Float) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :>=, '(Rational) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :>=, '(BigDecimal) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :>>, '(Integer) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS
post(:Bignum, :>>, version: RDL::PRE_INTMERGE_VERSIONS) { |r,x| r >= 0 }

type :Bignum, :[], '(Integer) -> Fixnum', version: RDL::PRE_INTMERGE_VERSIONS
post(:Bignum, :[], version: RDL::PRE_INTMERGE_VERSIONS) { |r,x| r == 0 || r==1}
type :Bignum, :[], '(Rational) -> Fixnum', version: RDL::PRE_INTMERGE_VERSIONS
post(:Bignum, :[], version: RDL::PRE_INTMERGE_VERSIONS) { |r,x| r == 0 || r==1}
type :Bignum, :[], '(Float) -> Fixnum', version: RDL::PRE_INTMERGE_VERSIONS
pre(:Bignum, :[], version: RDL::PRE_INTMERGE_VERSIONS) { |x| x!=Float::INFINITY && !x.nan? }
post(:Bignum, :[], version: RDL::PRE_INTMERGE_VERSIONS) { |r,x| r == 0 || r==1}
type :Bignum, :[], '(BigDecimal) -> Fixnum', version: RDL::PRE_INTMERGE_VERSIONS
pre(:Bignum, :[], version: RDL::PRE_INTMERGE_VERSIONS) { |x| x!=BigDecimal::INFINITY && !x.nan? }
post(:Bignum, :[], version: RDL::PRE_INTMERGE_VERSIONS) { |r,x| r == 0 || r==1}

type :Bignum, :^, '(Integer) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :|, '(Integer) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :~, '() -> Bignum', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :abs, '() -> Bignum r {{ r>=0 }}', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :bit_length, '() -> Integer r {{ r>=0 }}', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :div, '(Integer x {{ x!=0 }}) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :div, '(Float x {{ x!=0 && !x.nan? }}) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :div, '(Rational x {{ x!=0 }}) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :div, '(BigDecimal x {{ x!=0 && !x.nan?}}) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :divmod, '(%real) -> [%real, %real]', version: RDL::PRE_INTMERGE_VERSIONS
pre(:Bignum, :divmod, version: RDL::PRE_INTMERGE_VERSIONS) { |x| x!=0 && if x.is_a?(Float) then !x.nan? else true end}

type :Bignum, :even?, '() -> %bool', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :fdiv, '(Integer) -> Float', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :fdiv, '(Float) -> Float', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :fdiv, '(Rational) -> Float', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :fdiv, '(BigDecimal) -> BigDecimal', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :fdiv, '(Complex) -> Complex', version: RDL::PRE_INTMERGE_VERSIONS
pre(:Bignum, :fdiv, version: RDL::PRE_INTMERGE_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Bignum, :to_s, '() -> String', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :inspect, '() -> String', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :magnitude, '() -> Bignum', version: RDL::PRE_INTMERGE_VERSIONS
post(:Bignum, :magnitude, version: RDL::PRE_INTMERGE_VERSIONS) { |r,x| r >= 0 }

type :Bignum, :modulo, '(Fixnum x {{ x!=0 }}) -> Fixnum', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :modulo, '(Bignum x {{ x!=0 }}) -> Integer', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :modulo, '(Float x {{ x!=0 }}) -> Float', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :modulo, '(Rational x {{ x!=0 }}) -> Rational', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :modulo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :next, '() -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :odd?, '() -> %bool', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :size, '() -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :succ, '() -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :to_f, '() -> Float', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :zero?, '() -> %bool', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :ceil, '() -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :denominator, '() -> Fixnum r {{ r==1 }}', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :floor, '() -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :numerator, '() -> Bignum', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :quo, '(Integer x {{ x!=0 }}) -> Rational', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :quo, '(Float x {{ x!=0 }}) -> Float', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :quo, '(Rational x {{ x!=0 }}) -> Rational', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :quo, '(Complex x {{ x!=0 }}) -> Complex', version: RDL::PRE_INTMERGE_VERSIONS
pre(:Bignum, :quo, version: RDL::PRE_INTMERGE_VERSIONS) { if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Bignum, :rationalize, '() -> Rational', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :rationalize, '(%numeric) -> Rational', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :round, '() -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :round, '(%numeric) -> %numeric', version: RDL::PRE_INTMERGE_VERSIONS
pre(:Bignum, :round, version: RDL::PRE_INTMERGE_VERSIONS) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

type :Bignum, :to_i, '() -> Bignum', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :to_r, '() -> Rational', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :truncate, '() -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :angle, '() -> %numeric', version: RDL::PRE_INTMERGE_VERSIONS
post(:Bignum, :angle, version: RDL::PRE_INTMERGE_VERSIONS) { |r,x| r == 0 || r == Math::PI}

type :Bignum, :arg, '() -> %numeric', version: RDL::PRE_INTMERGE_VERSIONS
post(:Bignum, :arg, version: RDL::PRE_INTMERGE_VERSIONS) { |r,x| r == 0 || r == Math::PI}

type :Bignum, :equal?, '(Object) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :eql?, '(Object) -> %bool', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :hash, '() -> Integer', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :phase, '() -> %numeric', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :abs2, '() -> Bignum r {{ r>=0 }}', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :conj, '() -> Bignum', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :conjugate, '() -> Bignum', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :imag, '() -> Fixnum r {{ r==0 }}', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :imaginary, '() -> Fixnum r {{ r==0 }}', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :real, '() -> Bignum', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :real?, '() -> true', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :to_c, '() -> Complex r {{ r.imaginary==0 }}', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :remainder, '(Fixnum x {{ x!=0 }}) -> Fixnum r {{ r>=0 }}', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :remainder, '(Bignum x {{ x!=0 }}) -> Fixnum r {{ r>=0 }}', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :remainder, '(Float x {{ x!=0 }}) -> Float', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>=0 }}', version: RDL::PRE_INTMERGE_VERSIONS
type :Bignum, :remainder, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: RDL::PRE_INTMERGE_VERSIONS

type :Bignum, :coerce, '(Integer) -> [Integer, Integer]', version: RDL::PRE_INTMERGE_VERSIONS
