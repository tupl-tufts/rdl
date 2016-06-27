class Complex < Numeric
  rdl_nowrap

  type :*, '(%integer) -> Complex'
  type :*, '(Float) -> Complex'
  pre(:*) { |x| if x.infinite?||x.nan? then !self.imaginary.is_a?(BigDecimal)&&!self.real.is_a?(BigDecimal) else true end}
  type :*, '(Rational) -> Complex'
  type :*, '(BigDecimal) -> Complex'
  pre(:*) {if x.real.is_a?(Float) then !x.real.infinite? && !x.real.nan? elsif x.imaginary.is_a?(Float) then !x.imaginary.infinite? && !x.imaginary.nan? else true end}
  type :*, '(Complex) -> Complex'
  pre(:*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

  type :**, '(%integer) -> Complex'
  type :**, '(Float) -> Complex'
  type :**, '(Rational) -> Complex'
  type :**, '(BigDecimal x {{ !x.infinite? && !x.nan? && x>=0 }}) -> Complex'
  type :**, '(Complex) -> Complex'
  pre(:**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

  type :+, '(%integer) -> Complex'
  type :+, '(Float) -> Complex'
  pre(:+) { |x| if x.infinite?||x.nan? then !self.real.is_a?(BigDecimal) else true end}
  type :+, '(Rational) -> Complex'
  type :+, '(BigDecimal) -> Complex'
  pre(:+) {if x.real.is_a?(Float) then !x.real.infinite? && !x.real.nan? else true end}
  type :+, '(Complex) -> Complex'
  pre(:+) { |x| if (x.real.is_a?(BigDecimal) && self.real.is_a?(Float)) then !(self.real.infinite?||self.real.nan?) elsif x.real.is_a?(Float)&&self.real.is_a?(BigDecimal) then !(x.real.infinite?||x.real.nan?) elsif (x.imaginary.is_a?(BigDecimal) && self.imaginary.is_a?(Float)) then !(self.imaginary.infinite?||self.imaginary.nan?) elsif x.imaginary.is_a?(Float)&&self.imaginary.is_a?(BigDecimal) then !(x.imaginary.infinite?||x.imaginary.nan?) else true end}

  type :-, '(%integer) -> Complex'
  type :-, '(Float) -> Complex'
  pre(:-) { |x| if x.infinite?||x.nan? then !self.real.is_a?(BigDecimal) else true end}
  type :-, '(Rational) -> Complex'
  type :-, '(BigDecimal) -> Complex'
  pre(:-) {if x.real.is_a?(Float) then !x.real.infinite? && !x.real.nan? else true end}
  type :-, '(Complex) -> Complex'
  pre(:-) { |x| if (x.real.is_a?(BigDecimal) && self.real.is_a?(Float)) then !(self.real.infinite?||self.real.nan?) elsif x.real.is_a?(Float)&&self.real.is_a?(BigDecimal) then !(x.real.infinite?||x.real.nan?) elsif (x.imaginary.is_a?(BigDecimal) && self.imaginary.is_a?(Float)) then !(self.imaginary.infinite?||self.imaginary.nan?) elsif x.imaginary.is_a?(Float)&&self.imaginary.is_a?(BigDecimal) then !(x.imaginary.infinite?||x.imaginary.nan?) else true end}

  type :-, '() -> Complex'

  type :/, '(%integer x {{ x!=0 }}) -> Complex'
  type :/, '(Float x {{ x!=0 }}) -> Complex'
  pre(:/) { |x| if x.infinte?||x.nan? then !self.real.is_a?(BigDecimal) && !self.imaginary.is_a?(BigDecimal) else true end}
  type :/, '(Rational x {{ x!=0 }}) -> Complex'
  type :/, '(BigDecimal x {{ x!=0 }}) -> Complex'
  pre(:/) { |x| if self.real.is_a?(Float) then !self.real.infinite? && !self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end}
  type :/, '(Complex x {{ x!=0 }}) -> Complex'
  pre(:/) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal) || self.real.is_a?(BigDecimal) || self.imaginary .is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && if self.real.is_a?(Float) then !self.real.infinite? && !self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type:==, '(Object) -> %bool'

  type :abs, '() -> %numeric r {{ r>=0 }}'

  type :abs2, '() -> %numeric r {{ r>=0 }}'

  type :angle, '() -> Float'

  type :arg, '() -> Float'

  type :conj, '() -> Complex'
  type :conjugate, '() -> Complex'

  type :denominator, '() -> %integer'

  type :equal?, '(Object) -> %bool'
  type :eql?, '(Object) -> %bool'

  type :fdiv, '(%numeric) -> Complex'
  pre(:fdiv) { |x| if (self.real.is_a?(Float) && (self.real.infinite? || self.real.nan?))||(self.imaginary.is_a?(Float) && (self.imaginary.infinite? || self.imaginary.nan?)) then !x.is_a?(BigDecimal) && (if x.is_a?(Complex) then !x.real.is_a?(BigDecimal) && !x.imaginary.is_a?(BigDecimal) else true end) else true end}

  type :hash, '() -> %integer'

  type :imag, '() -> %real'
  type :imaginary, '() -> %real'

  type :inspect, '() -> String'

  type :magnitude, '() -> %real'

  type :numerator, '() -> Complex'

  type :phase, '() -> Float'

  type :polar, '() -> [%real, %real]'


  type :quo, '(%integer x {{ x!=0 }}) -> Complex'
  type :quo, '(Float x {{ x!=0 }}) -> Complex'
  pre(:quo) { |x| if self.real.is_a?(BigDecimal)||self.imaginary.is_a?(BigDecimal) then !x.infinite? && !x.nan? else true end}
  type :quo, '(Rational x {{ x!=0 }}) -> Complex'
  type :quo, '(BigDecimal x {{ x!=0 }}) -> BigDecimal'
  pre(:quo) { |x| if self.real.is_a?(Float) then !self.real.infinite?&&!self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end}
  type :quo, '(Complex x {{ x!=0 }}) -> Complex'
  pre(:quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal) || self.real.is_a?(BigDecimal) || self.imaginary .is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) && if self.real.is_a?(Float) then !self.real.infinite? && !self.real.nan? else true end && if self.imaginary.is_a?(Float) then !self.imaginary.infinite? && !self.imaginary.nan? else true end else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :rationalize, '() -> Rational'
  pre(:rationalize) { self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

  type :rationalize, '(%numeric) -> Rational'
  pre(:rationalize) { |x| self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(Rational) then (if x.is_a?(Float)||x.is_a?(BigDecimal) then !x.infinite? && !x.nan? else true end) else true end && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

  type :real, '() -> %real'

  type :real?, '() -> false'

  type :rect, '() -> [%real, %real]'
  type :rectangular, '() -> [%real, %real]'

  type :to_c, '() -> Complex'

  type :to_f, '() -> Float'
  pre(:to_f) { self.imaginary==0}

  type :to_i, '() -> %integer'
  pre(:to_i) { self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

  type :to_r, '() -> Rational'
  pre(:to_r) { self.imaginary==0 && if self.real.is_a?(Float)||self.real.is_a?(BigDecimal) then !self.real.infinite? && !self.real.nan? else true end}

  type :to_s, '() -> String'

  type :zero?, '() -> %bool'

  type :coerce, '(%numeric) -> [Complex, Complex]'
end
