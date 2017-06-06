RDL.nowrap :Complex

RDL.type :Complex, :*, '(Integer) -> Complex'
RDL.type :Complex, :*, '(Float) -> Complex'
RDL.pre(:Complex, :*) { |x| if x.infinite?||x.nan? then !self.imaginary.is_a?(BigDecimal)&&!self.real.is_a?(BigDecimal) else true end}
RDL.type :Complex, :*, '(Rational) -> Complex'
RDL.type :Complex, :*, '(BigDecimal) -> Complex'
RDL.pre(:Complex, :*) {if x.real.is_a?(Float) then !x.real.infinite? && !x.real.nan? elsif x.imaginary.is_a?(Float) then !x.imaginary.infinite? && !x.imaginary.nan? else true end}
RDL.type :Complex, :*, '(Complex) -> Complex'
RDL.pre(:Complex, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

RDL.type :Complex, :**, '(Integer) -> Complex'
RDL.type :Complex, :**, '(Float) -> Complex'
RDL.type :Complex, :**, '(Rational) -> Complex'
RDL.type :Complex, :**, '(BigDecimal x {{ !x.infinite? && !x.nan? && x>=0 }}) -> Complex'
RDL.type :Complex, :**, '(Complex) -> Complex'
RDL.pre(:Complex, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

RDL.type :Complex, :+, '(Integer) -> Complex'
RDL.type :Complex, :+, '(Float) -> Complex'
RDL.pre(:Complex, :+) { |x| if x.infinite?||x.nan? then !self.real.is_a?(BigDecimal) else true end}
RDL.type :Complex, :+, '(Rational) -> Complex'
RDL.type :Complex, :+, '(BigDecimal) -> Complex'
RDL.pre(:Complex, :+) {if x.real.is_a?(Float) then !x.real.infinite? && !x.real.nan? else true end}
RDL.type :Complex, :+, '(Complex) -> Complex'
RDL.pre(:Complex, :+) { |x| if (x.real.is_a?(BigDecimal) && self.real.is_a?(Float)) then !(self.real.infinite?||self.real.nan?) elsif x.real.is_a?(Float)&&self.real.is_a?(BigDecimal) then !(x.real.infinite?||x.real.nan?) elsif (x.imaginary.is_a?(BigDecimal) && self.imaginary.is_a?(Float)) then !(self.imaginary.infinite?||self.imaginary.nan?) elsif x.imaginary.is_a?(Float)&&self.imaginary.is_a?(BigDecimal) then !(x.imaginary.infinite?||x.imaginary.nan?) else true end}

RDL.type :Complex, :-, '(Integer) -> Complex'
RDL.type :Complex, :-, '(Float) -> Complex'
RDL.pre(:Complex, :-) { |x| if x.infinite?||x.nan? then !self.real.is_a?(BigDecimal) else true end}
RDL.type :Complex, :-, '(Rational) -> Complex'
RDL.type :Complex, :-, '(BigDecimal) -> Complex'
RDL.pre(:Complex, :-) {if x.real.is_a?(Float) then !x.real.infinite? && !x.real.nan? else true end}
RDL.type :Complex, :-, '(Complex) -> Complex'
RDL.pre(:Complex, :-) { |x| if (x.real.is_a?(BigDecimal) && self.real.is_a?(Float)) then !(self.real.infinite?||self.real.nan?) elsif x.real.is_a?(Float)&&self.real.is_a?(BigDecimal) then !(x.real.infinite?||x.real.nan?) elsif (x.imaginary.is_a?(BigDecimal) && self.imaginary.is_a?(Float)) then !(self.imaginary.infinite?||self.imaginary.nan?) elsif x.imaginary.is_a?(Float)&&self.imaginary.is_a?(BigDecimal) then !(x.imaginary.infinite?||x.imaginary.nan?) else true end}

RDL.type :Complex, :-@, '() -> Complex'

RDL.type :Complex, :+@, '() -> Complex'

RDL.type :Complex, :/, '(Integer x {{ x!=0 }}) -> Complex'
RDL.type :Complex, :/, '(Float x {{ x!=0 }}) -> Complex'
RDL.pre(:Complex, :/) { |x| if x.infinte?||x.nan? then !self.real.is_a?(BigDecimal) && !self.imaginary.is_a?(BigDecimal) else true end}
RDL.type :Complex, :/, '(Rational x {{ x!=0 }}) -> Complex'
RDL.type :Complex, :/, '(BigDecimal x {{ x!=0 }}) -> Complex'
RDL.pre(:Complex, :/) { |x| if self.real.is_a?(Float) then !self.real.infinite? && !self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end}
RDL.type :Complex, :/, '(Complex x {{ x!=0 }}) -> Complex'
RDL.pre(:Complex, :/) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal) || self.real.is_a?(BigDecimal) || self.imaginary .is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && if self.real.is_a?(Float) then !self.real.infinite? && !self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Complex, :==, '(Object) -> %bool'

RDL.type :Complex, :abs, '() -> %numeric r {{ r>=0 || (if ((((self.real.is_a? BigDecimal)||(self.real.is_a? Float)) && self.real.nan?) || (((self.imaginary.is_a? BigDecimal)||(self.imaginary.is_a? Float)) && self.imaginary.nan?)) then r.nan? end) }}'

RDL.type :Complex, :abs2, '() -> %numeric r {{ r>=0 || (if ((((self.real.is_a? BigDecimal)||(self.real.is_a? Float)) && self.real.nan?) || (((self.imaginary.is_a? BigDecimal)||(self.imaginary.is_a? Float)) && self.imaginary.nan?)) then r.nan? end) }}'

RDL.type :Complex, :angle, '() -> Float'

RDL.type :Complex, :arg, '() -> Float'

RDL.type :Complex, :conj, '() -> Complex'
RDL.type :Complex, :conjugate, '() -> Complex'

RDL.type :Complex, :denominator, '() -> Integer'

RDL.type :Complex, :equal?, '(Object) -> %bool'
RDL.type :Complex, :eql?, '(Object) -> %bool'

RDL.type :Complex, :fdiv, '(%numeric) -> Complex'
RDL.pre(:Complex, :fdiv) { |x| if (self.real.is_a?(Float) && (self.real.infinite? || self.real.nan?))||(self.imaginary.is_a?(Float) && (self.imaginary.infinite? || self.imaginary.nan?)) then !x.is_a?(BigDecimal) && (if x.is_a?(Complex) then !x.real.is_a?(BigDecimal) && !x.imaginary.is_a?(BigDecimal) else true end) else true end}

RDL.type :Complex, :hash, '() -> Integer'

RDL.type :Complex, :imag, '() -> %real'
RDL.type :Complex, :imaginary, '() -> %real'

RDL.type :Complex, :inspect, '() -> String'

RDL.type :Complex, :magnitude, '() -> %real'

RDL.type :Complex, :numerator, '() -> Complex'

RDL.type :Complex, :phase, '() -> Float'

RDL.type :Complex, :polar, '() -> [%real, %real]'

RDL.type :Complex, :quo, '(Integer x {{ x!=0 }}) -> Complex'
RDL.type :Complex, :quo, '(Float x {{ x!=0 }}) -> Complex'
RDL.pre(:Complex, :quo) { |x| if self.real.is_a?(BigDecimal)||self.imaginary.is_a?(BigDecimal) then !x.infinite? && !x.nan? else true end}
RDL.type :Complex, :quo, '(Rational x {{ x!=0 }}) -> Complex'
RDL.type :Complex, :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
RDL.pre(:Complex, :quo) { |x| if self.real.is_a?(Float) then !self.real.infinite?&&!self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end}
RDL.type :Complex, :quo, '(Complex x {{ x!=0 }}) -> Complex'
RDL.pre(:Complex, :quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal) || self.real.is_a?(BigDecimal) || self.imaginary .is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && if self.real.is_a?(Float) then !self.real.infinite? && !self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Complex, :rationalize, '() -> Rational'
RDL.pre(:Complex, :rationalize) { self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

RDL.type :Complex, :rationalize, '(%numeric) -> Rational'
RDL.pre(:Complex, :rationalize) { |x| self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(Rational) then (if x.is_a?(Float)||x.is_a?(BigDecimal) then !x.infinite? && !x.nan? else true end) else true end && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

RDL.type :Complex, :real, '() -> %real'

RDL.type :Complex, :real?, '() -> false'

RDL.type :Complex, :rect, '() -> [%real, %real]'
RDL.type :Complex, :rectangular, '() -> [%real, %real]'

RDL.type :Complex, :to_c, '() -> Complex'

RDL.type :Complex, :to_f, '() -> Float'
RDL.pre(:Complex, :to_f) { self.imaginary==0}

RDL.type :Complex, :to_i, '() -> Integer'
RDL.pre(:Complex, :to_i) { self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

RDL.type :Complex, :to_r, '() -> Rational'
RDL.pre(:Complex, :to_r) { self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

RDL.type :Complex, :to_s, '() -> String'

RDL.type :Complex, :zero?, '() -> %bool'

RDL.type :Complex, :coerce, '(%numeric) -> [Complex, Complex]'
