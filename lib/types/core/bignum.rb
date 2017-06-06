RDL.nowrap :Bignum

RDL.type :Bignum, :%, '(Fixnum x {{ x!=0 }}) -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :%, '(Bignum x {{ x!=0 }}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :%, '(Float x {{ x!=0 }}) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :%, '(Rational x {{ x!=0 }}) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :%, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :&, '(Integer) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :*, '(Fixnum) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :*, '(Bignum) -> Bignum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :*, '(Float) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :*, '(Rational) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :*, '(BigDecimal) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :*, '(Complex) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Bignum, :*, version: RDL::Globals::FIXBIG_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

RDL.type :Bignum, :**, '(Integer) -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :**, '(Float) -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :**, '(Rational) -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :**, '(BigDecimal) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Bignum, :**, version: RDL::Globals::FIXBIG_VERSIONS) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
RDL.post(:Bignum, :**, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r.real?}
RDL.type :Bignum, :**, '(Complex) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Bignum, :**, version: RDL::Globals::FIXBIG_VERSIONS) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

RDL.type :Bignum, :+, '(Integer) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :+, '(Float) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :+, '(Rational) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :+, '(BigDecimal) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :+, '(Complex) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :-, '(Integer) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :-, '(Float) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :-, '(Rational) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :-, '(BigDecimal) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :-, '(Complex) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :-@, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :+@, '() -> Bignum', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :/, '(Integer x {{ x!=0 }}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :/, '(Float x {{ x!=0 }}) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :/, '(Rational x {{ x!=0 }}) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :/, '(Complex x {{ x!=0 }}) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Bignum, :/, version: RDL::Globals::FIXBIG_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Bignum, :<, '(Integer) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :<, '(Float) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :<, '(Rational) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :<, '(BigDecimal) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :<<, '(Fixnum) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :<=, '(Integer) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :<=, '(Float) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :<=, '(Rational) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :<=, '(BigDecimal) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :<=>, '(Integer) -> Object', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Bignum, :<=>, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
RDL.type :Bignum, :<=>, '(Float) -> Object', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Bignum, :<=>, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
RDL.type :Bignum, :<=>, '(Rational) -> Object', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Bignum, :<=>, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
RDL.type :Bignum, :<=>, '(BigDecimal) -> Object', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Bignum, :<=>, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}

RDL.type :Bignum, :==, '(Object) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :===, '(Object) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :>, '(Integer) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :>, '(Float) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :>, '(Rational) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :>, '(BigDecimal) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :>=, '(Integer) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :>=, '(Float) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :>=, '(Rational) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :>=, '(BigDecimal) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :>>, '(Integer) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Bignum, :>>, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r >= 0 }

RDL.type :Bignum, :[], '(Integer) -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Bignum, :[], version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}
RDL.type :Bignum, :[], '(Rational) -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Bignum, :[], version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}
RDL.type :Bignum, :[], '(Float) -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Bignum, :[], version: RDL::Globals::FIXBIG_VERSIONS) { |x| x!=Float::INFINITY && !x.nan? }
RDL.post(:Bignum, :[], version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}
RDL.type :Bignum, :[], '(BigDecimal) -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Bignum, :[], version: RDL::Globals::FIXBIG_VERSIONS) { |x| x!=BigDecimal::INFINITY && !x.nan? }
RDL.post(:Bignum, :[], version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}

RDL.type :Bignum, :^, '(Integer) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :|, '(Integer) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :~, '() -> Bignum', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :abs, '() -> Bignum r {{ r>=0 }}', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :bit_length, '() -> Integer r {{ r>=0 }}', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :div, '(Integer x {{ x!=0 }}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :div, '(Float x {{ x!=0 && !x.nan? }}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :div, '(Rational x {{ x!=0 }}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :div, '(BigDecimal x {{ x!=0 && !x.nan?}}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :divmod, '(%real) -> [%real, %real]', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Bignum, :divmod, version: RDL::Globals::FIXBIG_VERSIONS) { |x| x!=0 && if x.is_a?(Float) then !x.nan? else true end}

RDL.type :Bignum, :even?, '() -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :fdiv, '(Integer) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :fdiv, '(Float) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :fdiv, '(Rational) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :fdiv, '(BigDecimal) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :fdiv, '(Complex) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Bignum, :fdiv, version: RDL::Globals::FIXBIG_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Bignum, :to_s, '() -> String', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :inspect, '() -> String', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :magnitude, '() -> Bignum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Bignum, :magnitude, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r >= 0 }

RDL.type :Bignum, :modulo, '(Fixnum x {{ x!=0 }}) -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :modulo, '(Bignum x {{ x!=0 }}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :modulo, '(Float x {{ x!=0 }}) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :modulo, '(Rational x {{ x!=0 }}) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :modulo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :next, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :odd?, '() -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :size, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :succ, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :to_f, '() -> Float', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :zero?, '() -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :ceil, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :denominator, '() -> Fixnum r {{ r==1 }}', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :floor, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :numerator, '() -> Bignum', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :quo, '(Integer x {{ x!=0 }}) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :quo, '(Float x {{ x!=0 }}) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :quo, '(Rational x {{ x!=0 }}) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :quo, '(Complex x {{ x!=0 }}) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Bignum, :quo, version: RDL::Globals::FIXBIG_VERSIONS) { if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Bignum, :rationalize, '() -> Rational', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :rationalize, '(%numeric) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :round, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :round, '(%numeric) -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Bignum, :round, version: RDL::Globals::FIXBIG_VERSIONS) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

RDL.type :Bignum, :to_i, '() -> Bignum', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :to_r, '() -> Rational', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :truncate, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :angle, '() -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Bignum, :angle, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r == Math::PI}

RDL.type :Bignum, :arg, '() -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Bignum, :arg, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r == Math::PI}

RDL.type :Bignum, :equal?, '(Object) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :eql?, '(Object) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :hash, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :phase, '() -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :abs2, '() -> Bignum r {{ r>=0 }}', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :conj, '() -> Bignum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :conjugate, '() -> Bignum', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :imag, '() -> Fixnum r {{ r==0 }}', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :imaginary, '() -> Fixnum r {{ r==0 }}', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :real, '() -> Bignum', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :real?, '() -> true', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :to_c, '() -> Complex r {{ r.imaginary==0 }}', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :remainder, '(Fixnum x {{ x!=0 }}) -> Fixnum r {{ r>=0 }}', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :remainder, '(Bignum x {{ x!=0 }}) -> Fixnum r {{ r>=0 }}', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :remainder, '(Float x {{ x!=0 }}) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>=0 }}', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Bignum, :remainder, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Bignum, :coerce, '(Integer) -> [Integer, Integer]', version: RDL::Globals::FIXBIG_VERSIONS
