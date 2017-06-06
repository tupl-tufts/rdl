RDL.nowrap :Fixnum

RDL.type :Fixnum, :%, '(Fixnum x {{ x!=0 }}) -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :%, '(Bignum x {{ x!=0 }}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :%, '(Float x {{ x!=0 }}) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :%, '(Rational x {{ x!=0}}) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :%, '(BigDecimal x {{ x!=0}}) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :&, '(Integer) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :*, '(Integer) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :*, '(Float) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :*, '(Rational) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :*, '(BigDecimal) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :*, '(Complex) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Fixnum, :*, version: RDL::Globals::FIXBIG_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

RDL.type :Fixnum, :**, '(Integer) -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :**, '(Float) -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :**, '(Rational) -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :**, '(BigDecimal) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Fixnum, :**, version: RDL::Globals::FIXBIG_VERSIONS) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
RDL.post(:Fixnum, :**, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r.real?}
RDL.type :Fixnum, :**, '(Complex) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Fixnum, :**, version: RDL::Globals::FIXBIG_VERSIONS) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

RDL.type :Fixnum, :+, '(Integer) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :+, '(Float) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :+, '(Rational) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :+, '(BigDecimal) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :+, '(Complex) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :-, '(Integer) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :-, '(Float) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :-, '(Rational) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :-, '(BigDecimal) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :-, '(Complex) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :-@, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :+@, '() -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :/, '(Integer x {{ x!=0 }}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :/, '(Float x {{ x!=0 }}) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :/, '(Rational x {{ x!=0 }}) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :/, '(Complex x {{ x!=0 }}) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Fixnum, :/, version: RDL::Globals::FIXBIG_VERSIONS) { if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Fixnum, :<, '(Integer) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :<, '(Float) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :<, '(Rational) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :<, '(BigDecimal) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :<<, '(Fixnum) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :<=, '(Integer) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :<=, '(Float) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :<=, '(Rational) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :<=, '(BigDecimal) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :<=>, '(Integer) -> Object', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Fixnum, :<=>, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
RDL.type :Fixnum, :<=>, '(Float) -> Object', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Fixnum, :<=>, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
RDL.type :Fixnum, :<=>, '(Rational) -> Object', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Fixnum, :<=>, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}
RDL.type :Fixnum, :<=>, '(BigDecimal) -> Object', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Fixnum, :<=>, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == -1 || r==0 || r==1}

RDL.type :Fixnum, :==, '(Object) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :===, '(Object) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :>, '(Integer) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :>, '(Float) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :>, '(Rational) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :>, '(BigDecimal) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :>=, '(Integer) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :>=, '(Float) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :>=, '(Rational) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :>=, '(BigDecimal) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :>>, '(Integer) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Fixnum, :>>, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r >= 0 }

RDL.type :Fixnum, :[], '(Integer) -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Fixnum, :[], version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}
RDL.type :Fixnum, :[], '(Rational) -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Fixnum, :[], version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}
RDL.type :Fixnum, :[], '(Float) -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Fixnum, :[], version: RDL::Globals::FIXBIG_VERSIONS) { |x| x!=Float::INFINITY && !x.nan? }
RDL.post(:Fixnum, :[], version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}
RDL.type :Fixnum, :[], '(BigDecimal) -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Fixnum, :[], version: RDL::Globals::FIXBIG_VERSIONS) { |x| x!=BigDecimal::INFINITY && !x.nan? }
RDL.post(:Fixnum, :[], version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r==1}

RDL.type :Fixnum, :^, '(Integer) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :|, '(Integer) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :~, '() -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :abs, '() -> Integer r {{ r>=0 }}', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :bit_length, '() -> Fixnum r {{ r>=0 }}', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :div, '(Fixnum x {{ x!=0 }}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :div, '(Bignum x {{ x!=0 }}) -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :div, '(Float x {{ x!=0 && !x.nan? }}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :div, '(Rational x {{ x!=0 }}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :div, '(BigDecimal x {{ x!=0 && !x.nan? }}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :divmod, '(%real x {{ x!=0 }}) -> [%real, %real]', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Fixnum, :divmod, version: RDL::Globals::FIXBIG_VERSIONS) { |x| if x.is_a?(Float) then !x.nan? else true end}

RDL.type :Fixnum, :even?, '() -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :fdiv, '(Integer) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :fdiv, '(Float) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :fdiv, '(Rational) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :fdiv, '(BigDecimal) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :fdiv, '(Complex) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Fixnum, :fdiv, version: RDL::Globals::FIXBIG_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Fixnum, :to_s, '() -> String', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :inspect, '() -> String', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :magnitude, '() -> Integer r {{ r>=0 }}', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :modulo, '(Fixnum x {{ x!=0 }}) -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :modulo, '(Bignum x {{ x!=0 }}) -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :modulo, '(Float x {{ x!=0 }}) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :modulo, '(Rational x {{ x!=0 }}) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :modulo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :next, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :odd?, '() -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :size, '() -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :succ, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :to_f, '() -> Float', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :zero?, '() -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :ceil, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :denominator, '() -> Fixnum r {{ r==1 }}', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :floor, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :numerator, '() -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :quo, '(Integer x {{ x!=0 }}) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :quo, '(Float x {{ x!=0 }}) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :quo, '(Rational x {{ x!=0 }}) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :quo, '(Complex x {{ x!=0 }}) -> Complex', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Fixnum, :quo, version: RDL::Globals::FIXBIG_VERSIONS) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Fixnum, :rationalize, '() -> Rational', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :rationalize, '(%numeric) -> Rational', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :round, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :round, '(%numeric) -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Fixnum, :round, version: RDL::Globals::FIXBIG_VERSIONS) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

RDL.type :Fixnum, :to_i, '() -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :to_r, '() -> Rational', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :truncate, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :angle, '() -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Fixnum, :angle, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r == Math::PI}

RDL.type :Fixnum, :arg, '() -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS
RDL.post(:Fixnum, :arg, version: RDL::Globals::FIXBIG_VERSIONS) { |r,x| r == 0 || r == Math::PI}

RDL.type :Fixnum, :equal?, '(Object) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :eql?, '(Object) -> %bool', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :hash, '() -> Integer', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :phase, '() -> %numeric', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :abs2, '() -> Integer r {{ r>=0 }}', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :conj, '() -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :conjugate, '() -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :imag, '() -> Fixnum r {{ r==0 }}', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :imaginary, '() -> Fixnum r {{ r==0 }}', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :real, '() -> Fixnum', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :real?, '() -> true', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :to_c, '() -> Complex r {{ r.imaginary == 0 }}', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :remainder, '(Fixnum x {{ x!=0 }}) -> Fixnum r {{ r>0 }}', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :remainder, '(Bignum x {{ x!=0 }}) -> Fixnum r {{ r>0 }}', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :remainder, '(Float x {{ x!=0 }}) -> Float', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>0 }}', version: RDL::Globals::FIXBIG_VERSIONS
RDL.type :Fixnum, :remainder, '(BigDecimal x {{ x=0 }}) -> BigDecimal', version: RDL::Globals::FIXBIG_VERSIONS

RDL.type :Fixnum, :coerce, '(%numeric) -> [%real, %real]', version: RDL::Globals::FIXBIG_VERSIONS
RDL.pre(:Fixnum, :coerce, version: RDL::Globals::FIXBIG_VERSIONS) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
