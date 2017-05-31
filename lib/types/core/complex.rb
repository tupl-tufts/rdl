rdl_nowrap :Complex

type :Complex, :*, '(Integer) -> Complex'
type :Complex, :*, '(Float) -> Complex'
pre(:Complex, :*) { |x| if x.infinite?||x.nan? then !self.imaginary.is_a?(BigDecimal)&&!self.real.is_a?(BigDecimal) else true end}
type :Complex, :*, '(Rational) -> Complex'
type :Complex, :*, '(BigDecimal) -> Complex'
pre(:Complex, :*) {if x.real.is_a?(Float) then !x.real.infinite? && !x.real.nan? elsif x.imaginary.is_a?(Float) then !x.imaginary.infinite? && !x.imaginary.nan? else true end}
type :Complex, :*, '(Complex) -> Complex'
pre(:Complex, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

type :Complex, :**, '(Integer) -> Complex'
type :Complex, :**, '(Float) -> Complex'
type :Complex, :**, '(Rational) -> Complex'
type :Complex, :**, '(BigDecimal x {{ !x.infinite? && !x.nan? && x>=0 }}) -> Complex'
type :Complex, :**, '(Complex) -> Complex'
pre(:Complex, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

type :Complex, :+, '(Integer) -> Complex'
type :Complex, :+, '(Float) -> Complex'
pre(:Complex, :+) { |x| if x.infinite?||x.nan? then !self.real.is_a?(BigDecimal) else true end}
type :Complex, :+, '(Rational) -> Complex'
type :Complex, :+, '(BigDecimal) -> Complex'
pre(:Complex, :+) {if x.real.is_a?(Float) then !x.real.infinite? && !x.real.nan? else true end}
type :Complex, :+, '(Complex) -> Complex'
pre(:Complex, :+) { |x| if (x.real.is_a?(BigDecimal) && self.real.is_a?(Float)) then !(self.real.infinite?||self.real.nan?) elsif x.real.is_a?(Float)&&self.real.is_a?(BigDecimal) then !(x.real.infinite?||x.real.nan?) elsif (x.imaginary.is_a?(BigDecimal) && self.imaginary.is_a?(Float)) then !(self.imaginary.infinite?||self.imaginary.nan?) elsif x.imaginary.is_a?(Float)&&self.imaginary.is_a?(BigDecimal) then !(x.imaginary.infinite?||x.imaginary.nan?) else true end}

type :Complex, :-, '(Integer) -> Complex'
type :Complex, :-, '(Float) -> Complex'
pre(:Complex, :-) { |x| if x.infinite?||x.nan? then !self.real.is_a?(BigDecimal) else true end}
type :Complex, :-, '(Rational) -> Complex'
type :Complex, :-, '(BigDecimal) -> Complex'
pre(:Complex, :-) {if x.real.is_a?(Float) then !x.real.infinite? && !x.real.nan? else true end}
type :Complex, :-, '(Complex) -> Complex'
pre(:Complex, :-) { |x| if (x.real.is_a?(BigDecimal) && self.real.is_a?(Float)) then !(self.real.infinite?||self.real.nan?) elsif x.real.is_a?(Float)&&self.real.is_a?(BigDecimal) then !(x.real.infinite?||x.real.nan?) elsif (x.imaginary.is_a?(BigDecimal) && self.imaginary.is_a?(Float)) then !(self.imaginary.infinite?||self.imaginary.nan?) elsif x.imaginary.is_a?(Float)&&self.imaginary.is_a?(BigDecimal) then !(x.imaginary.infinite?||x.imaginary.nan?) else true end}

type :Complex, :-@, '() -> Complex'

type :Complex, :+@, '() -> Complex'

type :Complex, :/, '(Integer x {{ x!=0 }}) -> Complex'
type :Complex, :/, '(Float x {{ x!=0 }}) -> Complex'
pre(:Complex, :/) { |x| if x.infinte?||x.nan? then !self.real.is_a?(BigDecimal) && !self.imaginary.is_a?(BigDecimal) else true end}
type :Complex, :/, '(Rational x {{ x!=0 }}) -> Complex'
type :Complex, :/, '(BigDecimal x {{ x!=0 }}) -> Complex'
pre(:Complex, :/) { |x| if self.real.is_a?(Float) then !self.real.infinite? && !self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end}
type :Complex, :/, '(Complex x {{ x!=0 }}) -> Complex'
pre(:Complex, :/) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal) || self.real.is_a?(BigDecimal) || self.imaginary .is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && if self.real.is_a?(Float) then !self.real.infinite? && !self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Complex, :==, '(Object) -> %bool'

type :Complex, :abs, '() -> %numeric r {{ r>=0 || (if ((((self.real.is_a? BigDecimal)||(self.real.is_a? Float)) && self.real.nan?) || (((self.imaginary.is_a? BigDecimal)||(self.imaginary.is_a? Float)) && self.imaginary.nan?)) then r.nan? end) }}'

type :Complex, :abs2, '() -> %numeric r {{ r>=0 || (if ((((self.real.is_a? BigDecimal)||(self.real.is_a? Float)) && self.real.nan?) || (((self.imaginary.is_a? BigDecimal)||(self.imaginary.is_a? Float)) && self.imaginary.nan?)) then r.nan? end) }}'

type :Complex, :angle, '() -> Float'

type :Complex, :arg, '() -> Float'

type :Complex, :conj, '() -> Complex'
type :Complex, :conjugate, '() -> Complex'

type :Complex, :denominator, '() -> Integer'

type :Complex, :equal?, '(Object) -> %bool'
type :Complex, :eql?, '(Object) -> %bool'

type :Complex, :fdiv, '(%numeric) -> Complex'
pre(:Complex, :fdiv) { |x| if (self.real.is_a?(Float) && (self.real.infinite? || self.real.nan?))||(self.imaginary.is_a?(Float) && (self.imaginary.infinite? || self.imaginary.nan?)) then !x.is_a?(BigDecimal) && (if x.is_a?(Complex) then !x.real.is_a?(BigDecimal) && !x.imaginary.is_a?(BigDecimal) else true end) else true end}

type :Complex, :hash, '() -> Integer'

type :Complex, :imag, '() -> %real'
type :Complex, :imaginary, '() -> %real'

type :Complex, :inspect, '() -> String'

type :Complex, :magnitude, '() -> %real'

type :Complex, :numerator, '() -> Complex'

type :Complex, :phase, '() -> Float'

type :Complex, :polar, '() -> [%real, %real]'

type :Complex, :quo, '(Integer x {{ x!=0 }}) -> Complex'
type :Complex, :quo, '(Float x {{ x!=0 }}) -> Complex'
pre(:Complex, :quo) { |x| if self.real.is_a?(BigDecimal)||self.imaginary.is_a?(BigDecimal) then !x.infinite? && !x.nan? else true end}
type :Complex, :quo, '(Rational x {{ x!=0 }}) -> Complex'
type :Complex, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
pre(:Complex, :quo) { |x| if self.real.is_a?(Float) then !self.real.infinite?&&!self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end}
type :Complex, :quo, '(Complex x {{ x!=0 }}) -> Complex'
pre(:Complex, :quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal) || self.real.is_a?(BigDecimal) || self.imaginary .is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && if self.real.is_a?(Float) then !self.real.infinite? && !self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

type :Complex, :rationalize, '() -> Rational'
pre(:Complex, :rationalize) { self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

type :Complex, :rationalize, '(%numeric) -> Rational'
pre(:Complex, :rationalize) { |x| self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(Rational) then (if x.is_a?(Float)||x.is_a?(BigDecimal) then !x.infinite? && !x.nan? else true end) else true end && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

type :Complex, :real, '() -> %real'

type :Complex, :real?, '() -> false'

type :Complex, :rect, '() -> [%real, %real]'
type :Complex, :rectangular, '() -> [%real, %real]'

type :Complex, :to_c, '() -> Complex'

type :Complex, :to_f, '() -> Float'
pre(:Complex, :to_f) { self.imaginary==0}

type :Complex, :to_i, '() -> Integer'
pre(:Complex, :to_i) { self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

type :Complex, :to_r, '() -> Rational'
pre(:Complex, :to_r) { self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

type :Complex, :to_s, '() -> String'

type :Complex, :zero?, '() -> %bool'

type :Complex, :coerce, '(%numeric) -> [Complex, Complex]'
