RDL.nowrap :BigDecimal

RDL.type :BigDecimal, :%, '(%numeric) -> BigDecimal'
RDL.pre(:BigDecimal, :%) { |x| x!=0&&(if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end)}

RDL.type :BigDecimal, :+, '(Integer) -> BigDecimal'
RDL.type :BigDecimal, :+, '(Float x {{ !x.infinite? && !x.nan? }}) -> BigDecimal'
RDL.type :BigDecimal, :+, '(Rational) -> BigDecimal'
RDL.type :BigDecimal, :+, '(BigDecimal) -> BigDecimal'
RDL.type :BigDecimal, :+, '(Complex) -> Complex'
RDL.pre(:BigDecimal, :+) { |x| if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end}

RDL.type :BigDecimal, :-, '(Integer) -> BigDecimal'
RDL.type :BigDecimal, :-, '(Float x {{ !x.infinite? && !x.nan? }}) -> BigDecimal'
RDL.type :BigDecimal, :-, '(Rational) -> BigDecimal'
RDL.type :BigDecimal, :-, '(BigDecimal) -> BigDecimal'
RDL.type :BigDecimal, :-, '(Complex) -> Complex'
RDL.pre(:BigDecimal, :-) { |x| if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end}

RDL.type :BigDecimal, :-@, '() -> BigDecimal'

RDL.type :BigDecimal, :+@, '() -> BigDecimal'

RDL.type :BigDecimal, :*, '(Integer) -> BigDecimal'
RDL.type :BigDecimal, :*, '(Float x {{ !x.infinite? && !x.nan? }}) -> BigDecimal'
RDL.type :BigDecimal, :*, '(Rational) -> BigDecimal'
RDL.type :BigDecimal, :*, '(BigDecimal) -> BigDecimal'
RDL.type :BigDecimal, :*, '(Complex) -> Complex'
RDL.pre(:BigDecimal, :*) { |x| if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end}

RDL.type :BigDecimal, :**, '(Integer) -> BigDecimal'
RDL.type :BigDecimal, :**, '(Float) -> BigDecimal'
RDL.pre(:BigDecimal, :**) { |x| x!=Float::INFINITY && !x.nan? && if(self<0) then x<=-1||x>=0 else true end}
RDL.type :BigDecimal, :**, '(Rational) -> BigDecimal'
RDL.pre(:BigDecimal, :**) { |x| if(self<0) then x<=-1||x>=0 else true end}
RDL.type :BigDecimal, :**, '(BigDecimal) -> BigDecimal'
RDL.pre(:BigDecimal, :**) { |x| x!=BigDecimal::INFINITY && if(self<0) then x<=-1||x>=0 else true end}

RDL.type :BigDecimal, :/, '(Integer x {{ x!=0 }}) -> BigDecimal'
RDL.type :BigDecimal, :/, '(Float x {{ x!=0 && !x.infinite? && !x.nan? }}) -> BigDecimal'
RDL.type :BigDecimal, :/, '(Rational x {{ x!=0 }}) -> BigDecimal'
RDL.type :BigDecimal, :/, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
RDL.type :BigDecimal, :/, '(Complex x {{ x!=0 }}) -> Complex'
RDL.pre(:BigDecimal, :/) { |x| if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end && if x.imaginary.is_a?(Float) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end && if (x.real.is_a?(Rational)) then !x.imaginary.nan? else true end}

RDL.type :BigDecimal, :<, '(Integer) -> %bool'
RDL.type :BigDecimal, :<, '(Float x {{ !x.nan? && !x.infinite? }}) -> %bool'
RDL.type :BigDecimal, :<, '(Rational) -> %bool'
RDL.type :BigDecimal, :<, '(BigDecimal) -> %bool'

RDL.type :BigDecimal, :<=, '(Integer) -> %bool'
RDL.type :BigDecimal, :<=, '(Float x {{ !x.nan? && !x.infinite }}) -> %bool'
RDL.type :BigDecimal, :<=, '(Rational) -> %bool'
RDL.type :BigDecimal, :<=, '(BigDecimal) -> %bool'

RDL.type :BigDecimal, :>, '(Integer) -> %bool'
RDL.type :BigDecimal, :>, '(Float x {{ !x.nan? && !x.infinite? }}) -> %bool'
RDL.type :BigDecimal, :>, '(Rational) -> %bool'
RDL.type :BigDecimal, :>, '(BigDecimal) -> %bool'

RDL.type :BigDecimal, :>=, '(Integer) -> %bool'
RDL.type :BigDecimal, :>=, '(Float x {{ !x.nan? && !x.infinite? }}) -> %bool'
RDL.type :BigDecimal, :>=, '(Rational) -> %bool'
RDL.type :BigDecimal, :>=, '(BigDecimal) -> %bool'

RDL.type :BigDecimal, :==, '(Object) -> %bool'
RDL.pre(:BigDecimal, :==) { |x| if (x.is_a?(Float)) then (!x.nan? && x!=Float::INFINITY) else true end}

RDL.type :BigDecimal, :===, '(Object) -> %bool'
RDL.pre(:BigDecimal, :===) { |x| if (x.is_a?(Float)) then (!x.nan? && x!=Float::INFINITY) else true end}

RDL.type :BigDecimal, :<=>, '(Integer) -> Object'
RDL.post(:BigDecimal, :<=>) { |r,x| r == -1 || r==0 || r==1}
RDL.type :BigDecimal, :<=>, '(Float) -> Object'
RDL.pre(:BigDecimal, :<=>) { |x| !x.nan? && x!=Float::INFINITY}
RDL.post(:BigDecimal, :<=>) { |r,x| r == -1 || r==0 || r==1}
RDL.type :BigDecimal, :<=>, '(Rational) -> Object'
RDL.post(:BigDecimal, :<=>) { |r,x| r == -1 || r==0 || r==1}
RDL.type :BigDecimal, :<=>, '(BigDecimal) -> Object'
RDL.post(:BigDecimal, :<=>) { |r,x| r == -1 || r==0 || r==1}

RDL.type :BigDecimal, :abs, '() -> BigDecimal r {{ r>=0 || (if r.nan? then self.nan? end) }}'

RDL.type :BigDecimal, :abs2, '() -> BigDecimal r {{ r>=0 || (if r.nan? then self.nan? end) }}'

RDL.type :BigDecimal, :angle, '() -> %numeric'
RDL.post(:BigDecimal, :angle) { |r,x| r == 0 || r == Math::PI}

RDL.type :BigDecimal, :arg, '() -> %numeric'
RDL.post(:BigDecimal, :arg) { |r,x| r == 0 || r == Math::PI}

RDL.type :BigDecimal, :ceil, '() -> Integer'
RDL.pre(:BigDecimal, :ceil) { !self.infinite? && !self.nan?}

RDL.type :BigDecimal, :conj, '() -> BigDecimal'
RDL.type :BigDecimal, :conjugate, '() -> BigDecimal'

RDL.type :BigDecimal, :denominator, '() -> Integer'
RDL.pre(:BigDecimal, :denominator) { !self.infinite? && !self.nan?}
RDL.post(:BigDecimal, :denominator) { |r,x| r>0}

RDL.type :BigDecimal, :div, '(Integer x {{ x!=0 && !self.infinite? && !self.nan? }}) -> Integer'
RDL.type :BigDecimal, :div, '(Float x {{ x!=0 && !self.infinite? && !self.nan? && !x.infinite? && !x.nan? }}) -> Integer'
RDL.type :BigDecimal, :div, '(Rational x {{ x!=0 && !self.infinite? && !self.nan? }}) -> Integer'
RDL.type :BigDecimal, :div, '(BigDecimal x {{ x!=0 && !self.infinite? && !self.nan? && !x.infinite? && !x.nan? }}) -> Integer'

RDL.type :BigDecimal, :divmod, '(%real) -> [%real, %real]'
RDL.pre(:BigDecimal, :divmod) { |x| x!=0 && if x.is_a?(Float) then !x.nan? && x!=Float::INFINITY else true end}

RDL.type :BigDecimal, :equal?, '(Object) -> %bool'
RDL.type :BigDecimal, :eql?, '(Object) -> %bool'

RDL.type :BigDecimal, :fdiv, '(Integer) -> Float'
RDL.type :BigDecimal, :fdiv, '(Float) -> Float'
RDL.type :BigDecimal, :fdiv, '(Rational) -> Float'
RDL.type :BigDecimal, :fdiv, '(BigDecimal) -> BigDecimal'
RDL.type :BigDecimal, :fdiv, '(Complex) -> Complex'
RDL.pre(:BigDecimal, :fdiv) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :BigDecimal, :finite?, '() -> %bool'

RDL.type :BigDecimal, :floor, '() -> Integer'
RDL.pre(:BigDecimal, :floor) { !self.infinite? && !self.nan?}

RDL.type :BigDecimal, :hash, '() -> Integer'

RDL.type :BigDecimal, :imag, '() -> Integer r {{ r==0 }}'
RDL.type :BigDecimal, :imaginary, '() -> Integer r {{ r==0 }}'

RDL.type :BigDecimal, :infinite?, '() -> NilClass or Integer'

RDL.type :BigDecimal, :to_s, '() -> String'
RDL.type :BigDecimal, :inspect, '() -> String'

RDL.type :BigDecimal, :magnitude, '() -> BigDecimal r {{ r>=0 }}'

RDL.type :BigDecimal, :modulo, '(%numeric) -> BigDecimal'
RDL.pre(:BigDecimal, :modulo) { |x| x!=0&&(if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end)}

RDL.type :BigDecimal, :nan?, '() -> %bool'

RDL.type :BigDecimal, :numerator, '() -> Integer'
RDL.pre(:BigDecimal, :numerator) { !self.infinite? && !self.nan?}

RDL.type :BigDecimal, :phase, '() -> %numeric'

RDL.type :BigDecimal, :quo, '(Integer x {{ x!=0 }}) -> BigDecimal'
RDL.type :BigDecimal, :quo, '(Float x {{ x!=0 && !x.infinite? && !x.nan?}}) -> BigDecimal'
RDL.type :BigDecimal, :quo, '(Rational x {{ x!=0 }}) -> BigDecimal'
RDL.type :BigDecimal, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
RDL.type :BigDecimal, :quo, '(Complex) -> Complex'
RDL.pre(:BigDecimal, :quo) { |x| x!=0 && if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end && if x.imaginary.is_a?(Float) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end && if (x.real.is_a?(Rational)) then !x.imaginary.nan? else true end}

RDL.type :BigDecimal, :real, '() -> BigDecimal'

RDL.type :BigDecimal, :real?, '() -> true'

RDL.type :BigDecimal, :round, '() -> Integer'
RDL.pre(:BigDecimal, :round) { !self.infinite? && !self.nan?}

RDL.type :BigDecimal, :round, '(Integer) -> BigDecimal' #Also, x must be in range [-2**31, 2**31].

RDL.type :BigDecimal, :to_f, '() -> Float'
RDL.pre(:BigDecimal, :to_f) { self<=Float::MAX}

RDL.type :BigDecimal, :to_i, '() -> Integer'
RDL.pre(:BigDecimal, :to_i) { !self.infinite? && !self.nan?}
RDL.type :BigDecimal, :to_int, '() -> Integer'
RDL.pre(:BigDecimal, :to_int) { !self.infinite? && !self.nan?}

RDL.type :BigDecimal, :to_r, '() -> Rational'
RDL.pre(:BigDecimal, :to_r) { !self.infinite? && !self.nan?}

RDL.type :BigDecimal, :to_c, '() -> Complex r {{ r.imaginary == 0 }}'
RDL.post(:BigDecimal, :to_c) { |r,x| r.imaginary == 0 }

RDL.type :BigDecimal, :truncate, '() -> Integer'

RDL.type :BigDecimal, :truncate, '(Integer) -> Rational' #Also, x must be in range [-2**31, 2**31].

RDL.type :BigDecimal, :zero?, '() -> %bool'

RDL.type :BigDecimal, :precs, '() -> [Integer, Integer]'

RDL.type :BigDecimal, :split, '() -> [Integer, String, Integer, Integer]'

RDL.type :BigDecimal, :remainder, '(%real) -> BigDecimal'
RDL.pre(:BigDecimal, :remainder) { |x| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

RDL.type :BigDecimal, :fix, '() -> BigDecimal'

RDL.type :BigDecimal, :frac, '() -> BigDecimal'

RDL.type :BigDecimal, :power, '(Integer) -> BigDecimal'
RDL.type :BigDecimal, :power, '(Float) -> BigDecimal'
RDL.pre(:BigDecimal, :power) { |x| x!=Float::INFINITY && !x.nan? && if(self<0) then x<=-1||x>=0 else true end}
RDL.type :BigDecimal, :power, '(Rational) -> BigDecimal'
RDL.pre(:BigDecimal, :power) { |x| if(self<0) then x<=-1||x>=0 else true end}
RDL.type :BigDecimal, :power, '(BigDecimal) -> BigDecimal'
RDL.pre(:BigDecimal, :power) { |x| x!=BigDecimal::INFINITY && if(self<0) then x<=-1||x>=0 else true end}

RDL.type :BigDecimal, :nonzero?, '() -> Object'

RDL.type :BigDecimal, :exponent, '() -> Integer'

RDL.type :BigDecimal, :sign, '() -> Integer'

RDL.type :BigDecimal, :_dump, '() -> String'

RDL.type :BigDecimal, :sqrt, '(Integer) -> BigDecimal'
RDL.pre(:BigDecimal, :sqrt) { self>=0}

RDL.type :BigDecimal, :add, '(%real, Integer) -> BigDecimal'
RDL.pre(:BigDecimal, :add) { |x,y| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

RDL.type :BigDecimal, :sub, '(%real, Integer) -> BigDecimal'
RDL.pre(:BigDecimal, :sub) { |x,y| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

RDL.type :BigDecimal, :mult, '(%real, Integer) -> BigDecimal'
RDL.pre(:BigDecimal, :mult) { |x,y| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

RDL.type :BigDecimal, :coerce, '(%real) -> [BigDecimal, BigDecimal]'
RDL.pre(:BigDecimal, :coerce) { |x| if x.is_a?(Float) then !x.nan? && !x.finite? else true end}
