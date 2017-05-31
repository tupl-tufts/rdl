rdl_nowrap :Float

type :Float, :%, '(Integer x {{ x != 0 }}) -> Float'
type :Float, :%, '(Float x {{ x != 0 }}) -> Float'
type :Float, :%, '(Rational x {{ x != 0 }}) -> Float'
type :Float, :%, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> BigDecimal'

type :Float, :*, '(Integer) -> Float'
type :Float, :*, '(Float) -> Float'
type :Float, :*, '(Rational) -> Float'
type :Float, :*, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> BigDecimal'
type :Float, :*, '(Complex) -> Complex'
pre(:Float, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

type :Float, :**, '(Integer) -> Float'
type :Float, :**, '(Float) -> %numeric'
type :Float, :**, '(Rational) -> %numeric'
type :Float, :**, '(BigDecimal) -> BigDecimal'
pre(:Float, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
post(:Float, :**) { |x| x.real?}
type :Float, :**, '(Complex) -> Complex'
pre(:Float, :**) { |x| x != 0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end}

type :Float, :+, '(Integer) -> Float'
type :Float, :+, '(Float) -> Float'
type :Float, :+, '(Rational) -> Float'
type :Float, :+, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> BigDecimal'
type :Float, :+, '(Complex) -> Complex'
pre(:Float, :+) { |x| if x.real.is_a?(BigDecimal) then self!=Float::INFINITY && !(self.nan?) else true end}

type :Float, :-, '(Integer) -> Float'
type :Float, :-, '(Float) -> Float'
type :Float, :-, '(Rational) -> Float'
type :Float, :-, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> BigDecimal'
type :Float, :-, '(Complex) -> Complex'
pre(:Float, :-) { |x| if x.real.is_a?(BigDecimal) then self!=Float::INFINITY && !(self.nan?) else true end}

type :Float, :-@, '() -> Float'

type :Float, :+@, '() -> Float'

type :Float, :/, '(Integer x {{ x != 0 }}) -> Float'
type :Float, :/, '(Float x {{ x != 0 }}) -> Float'
type :Float, :/, '(Rational x {{ x != 0 }}) -> Float'
type :Float, :/, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> BigDecimal'
type :Float, :/, '(Complex x {{ x != 0 }}) -> Complex'
pre(:Float, :/) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Float, :<, '(Integer) -> %bool'
type :Float, :<, '(Float) -> %bool'
type :Float, :<, '(Rational) -> %bool'
type :Float, :<, '(BigDecimal x {{ !self.nan? && !self.infinite? }}) -> %bool'

type :Float, :<=, '(Integer) -> %bool'
type :Float, :<=, '(Float) -> %bool'
type :Float, :<=, '(Rational) -> %bool'
type :Float, :<=, '(BigDecimal x {{ !self.nan? && !self.infinite? }}) -> %bool'

type :Float, :<=>, '(Integer) -> Object'
post(:Float, :<=>) { |x| x == -1 || x==0 || x==1}
type :Float, :<=>, '(Float) -> Object'
post(:Float, :<=>) { |x| x == -1 || x==0 || x==1}
type :Float, :<=>, '(Rational) -> Object'
post(:Float, :<=>) { |x| x == -1 || x==0 || x==1}
type :Float, :<=>, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> Object'
post(:Float, :<=>) { |x| x == -1 || x==0 || x==1}

type :Float, :==, '(Object) -> %bool'
pre(:Float, :==) { |x| if (x.is_a?(BigDecimal)) then (!self.nan? && self!=Float::INFINITY) else true end}

type :Float, :===, '(Object) -> %bool'
pre(:Float, :===) { |x| if (x.is_a?(BigDecimal)) then (!self.nan? && self!=Float::INFINITY) else true end}

type :Float, :>, '(Integer) -> %bool'
type :Float, :>, '(Float) -> %bool'
type :Float, :>, '(Rational) -> %bool'
type :Float, :>, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> %bool'

type :Float, :>=, '(Integer) -> %bool'
type :Float, :>=, '(Float) -> %bool'
type :Float, :>=, '(Rational) -> %bool'
type :Float, :>=, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> %bool'

type :Float, :abs, '() -> Float r {{ r>=0 || (if self.nan? then r.nan? end) }}'

type :Float, :abs2, '() -> Float r {{ r>=0 || (if self.nan? then r.nan? end) }}'

type :Float, :div, '(Integer x {{ x != 0 && !self.infinite? && !self.nan? }}) -> Integer'
type :Float, :div, '(Float x {{ x != 0 && !self.infinite? && !self.nan? }}) -> Integer'
type :Float, :div, '(Rational x {{ x != 0 && !self.infinite? && !self.nan? }}) -> Integer'
type :Float, :div, '(BigDecimal x {{ x != 0 && !x.nan? && !self.infinite? && !self.nan? }}) -> Integer'

type :Float, :divmod, '(%real) -> [%real, %real]'
pre(:Float, :divmod) { |x| x != 0 && if x.is_a?(Float) then !x.nan? else true end && self!=Float::INFINITY && !self.nan?}

type :Float, :angle, '() -> %numeric'
post(:Float, :angle) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

type :Float, :arg, '() -> %numeric'
post(:Float, :arg) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

type :Float, :ceil, '() -> Integer'
pre(:Float, :ceil) { !self.infinite? && !self.nan?}

type :Float, :coerce, '(%real) -> [Float, Float]'

type :Float, :denominator, '() -> Integer r {{ r>0 }}'

type :Float, :equal?, '(Object) -> %bool'

type :Float, :eql?, '(Object) -> %bool'

type :Float, :fdiv, '(Integer) -> Float'
type :Float, :fdiv, '(Float) -> Float'
type :Float, :fdiv, '(Rational) -> Float'
type :Float, :fdiv, '(BigDecimal x {{ !self.infinite? && !self.nan? }}) -> BigDecimal'
type :Float, :fdiv, '(Complex) -> Complex'
pre(:Float, :fdiv) { |x| x != 0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Float, :finite?, '() -> %bool'

type :Float, :floor, '() -> Integer'
pre(:Float, :ceil) { !self.infinite? && !self.nan?}

type :Float, :hash, '() -> Integer'

type :Float, :infinite?, '() -> Object'
post(:Float, :infinite?) { |r,x| r == -1 || r == 1 || r == nil }

type :Float, :to_s, '() -> String'
type :Float, :inspect, '() -> String'

type :Float, :magnitude, '() -> Float'
post(:Float, :magnitude) { |r,x| r>=0 }

type :Float, :modulo, '(Integer x {{ x != 0 }}) -> Float'
type :Float, :modulo, '(Float x {{ x != 0 }}) -> Float'
type :Float, :modulo, '(Rational x {{ x != 0 }}) -> Float'
type :Float, :modulo, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> BigDecimal'

type :Float, :nan?, '() -> %bool'

type :Float, :next_float, '() -> Float'

type :Float, :numerator, '() -> Integer'

type :Float, :phase, '() -> %numeric'
post(:Float, :phase) { |r,x| r == 0 || r == Math::PI || r == Float::NAN}

type :Float, :prev_float, '() -> Float'

type :Float, :quo, '(Integer x {{ x != 0 }}) -> Float'
type :Float, :quo, '(Float x {{ x != 0 }}) -> Float'
type :Float, :quo, '(Rational x {{ x != 0 }}) -> Float'
type :Float, :quo, '(BigDecimal x {{ x != 0 && !self.infinite? && !self.nan? }}) -> BigDecimal'
type :Float, :quo, '(Complex x {{ x != 0 }}) -> Complex'
pre(:Float, :quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && self!=Float::INFINITY && !(self.nan?) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Float, :rationalize, '() -> Rational'
pre(:Float, :rationalize) { !self.infinite? && !self.nan?}

type :Float, :rationalize, '(%numeric) -> Rational'
pre(:Float, :rationalize) { |x| if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end}

type :Float, :round, '() -> Integer'
pre(:Float, :round) { !self.infinite? && !self.nan?}

type :Float, :round, '(%numeric) -> %numeric'
pre(:Float, :round) { |x| x != 0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

type :Float, :to_f, '() -> Float'

type :Float, :to_i, '() -> Integer'
pre(:Float, :to_i) { !self.infinite? && !self.nan?}

type :Float, :to_int, '() -> Integer'
pre(:Float, :to_int) { !self.infinite? && !self.nan?}

type :Float, :to_r, '() -> Rational'
pre(:Float, :to_r) { !self.infinite? && !self.nan?}

type :Float, :truncate, '() -> Integer'

type :Float, :zero?, '() -> %bool'

type :Float, :conj, '() -> Float'
type :Float, :conjugate, '() -> Float'

type :Float, :imag, '() -> Integer r {{ r==0 }}'
type :Float, :imaginary, '() -> Integer r {{ r==0 }}'

type :Float, :real, '() -> Float'

type :Float, :real?, '() -> true'

type :Float, :to_c, '() -> Complex r {{ r.imaginary == 0 }}'

type :Float, :coerce, '(%numeric) -> [Float, Float]'
pre(:Float, :coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
