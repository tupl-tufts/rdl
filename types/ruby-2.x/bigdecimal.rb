class BigDecimal < Numeric
  rdl_nowrap

  type :%, '(Numeric) -> BigDecimal'
  pre(:%) { |x| x!=0&&(if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end)}

  type :+, '(Integer) -> BigDecimal'
  type :+, '(Float) -> BigDecimal'
  pre(:+) { |x| x!=Float::INFINITY && !(x.nan?)}
  type :+, '(Rational) -> BigDecimal'
  type :+, '(BigDecimal) -> BigDecimal'
  type :+, '(Complex) -> Complex'
  pre(:+) { |x| if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end}

  type :-, '(Integer) -> BigDecimal'
  type :-, '(Float) -> BigDecimal'
  pre(:-) { |x| x!=Float::INFINITY && !(x.nan?)}
  type :-, '(Rational) -> BigDecimal'
  type :-, '(BigDecimal) -> BigDecimal'
  type :-, '(Complex) -> Complex'
  pre(:-) { |x| if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end}

  type :-, '() -> BigDecimal'

  type :*, '(Integer) -> BigDecimal'
  type :*, '(Float) -> BigDecimal'
  pre(:*) { |x| x!=Float::INFINITY && !(x.nan?)}
  type :*, '(Rational) -> BigDecimal'
  type :*, '(BigDecimal) -> BigDecimal'
  type :*, '(Complex) -> Complex'
  pre(:*) { |x| if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end}

  type :**, '(Integer) -> BigDecimal'
  type :**, '(Float) -> BigDecimal'
  pre(:**) { |x| x!=Float::INFINITY && !x.nan? && if(self<0) then x<=-1||x>=0 else true end}
  type :**, '(Rational) -> BigDecimal'
  pre(:**) { |x| if(self<0) then x<=-1||x>=0 else true end}
  type :**, '(BigDecimal) -> BigDecimal'
  pre(:**) { |x| x!=BigDecimal::INFINITY && if(self<0) then x<=-1||x>=0 else true end}

  type :/, '(Integer) -> BigDecimal'
  pre(:/) { |x| x!=0}
  type :/, '(Float) -> BigDecimal'
  pre(:/) { |x| x!=0 && x!=Float::INFINITY && !(x.nan?)}
  type :/, '(Rational) -> BigDecimal'
  pre(:/) { |x| x!=0}
  type :/, '(BigDecimal) -> BigDecimal'
  pre(:/) { |x| x!=0}
  type :/, '(Complex) -> Complex'
  pre(:/) { |x| x!=0 && if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end && if x.imaginary.is_a?(Float) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end && if (x.real.is_a?(Rational)) then !x.imaginary.nan? else true end}

  type :<, '(Integer) -> %bool'
  type :<, '(Float) -> %bool'
  pre(:<) { |x| !x.nan? && x!=Float::INFINITY}
  type :<, '(Rational) -> %bool'
  type :<, '(BigDecimal) -> %bool'

  type :<=, '(Integer) -> %bool'
  type :<=, '(Float) -> %bool'
  pre(:<=) { |x| !x.nan? && x!=Float::INFINITY}
  type :<=, '(Rational) -> %bool'
  type :<=, '(BigDecimal) -> %bool'

  type :>, '(Integer) -> %bool'
  type :>, '(Float) -> %bool'
  pre(:>) { |x| !x.nan? && x!=Float::INFINITY}
  type :>, '(Rational) -> %bool'
  type :>, '(BigDecimal) -> %bool'

  type :>=, '(Integer) -> %bool'
  type :>=, '(Float) -> %bool'
  pre(:>=) { |x| !x.nan? && x!=Float::INFINITY}
  type :>=, '(Rational) -> %bool'
  type :>=, '(BigDecimal) -> %bool'

  type :==, '(Object) -> %bool'
  pre(:==) { |x| if (x.is_a?(Float)) then (!x.nan? && x!=Float::INFINITY) else true end}

  type :===, '(Object) -> %bool'
  pre(:===) { |x| if (x.is_a?(Float)) then (!x.nan? && x!=Float::INFINITY) else true end}

  type :<=>, '(Integer) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(Float) -> Object'
  pre(:<=>) { |x| !x.nan? && x!=Float::INFINITY}
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(Rational) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(BigDecimal) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}

  type :abs, '() -> BigDecimal'
  post(:abs) { |r,x| r >= 0 }

  type :abs2, '() -> BigDecimal'
  post(:abs2) { |r,x| r >= 0 }

  type :angle, '() -> Numeric'
  post(:angle) { |r,x| r == 0 || r == Math::PI}

  type :arg, '() -> Numeric'
  post(:arg) { |r,x| r == 0 || r == Math::PI}

  type :ceil, '() -> Integer'
  pre(:ceil) { !self.ininite? && !self.nan?}

  type :conj, '() -> BigDecimal'
  type :conjugate, '() -> BigDecimal'

  type :denominator, '() -> Integer'
  pre(:denominator) { !self.ininite? && !self.nan?}
  post(:denominator) { |r,x| r>0}

  type :div, '(Fixnum) -> Integer'
  pre(:div) { |x| x!=0 && !self.infinite? && !self.nan?}
  type :div, '(Bignum) -> Integer'
  pre(:div) { |x| x!=0 && !self.infinite? && !self.nan?}
  type :div, '(Float) -> Integer'
  pre(:div) { |x| x!=0 && !x.nan? && x!=Float::INFINITY && !self.infinite? && !self.nan?}
  type :div, '(Rational) -> Integer'
  pre(:div) { |x| x!=0 && !self.infinite? && !self.nan?}
  type :div, '(BigDecimal) -> Integer'
  pre(:div) { |x| x!=0 && !x.nan? && !self.infinite? && !self.nan?}

  type :divmod, '(%real) -> [%real, %real]'
  pre(:divmod) { |x| x!=0 && if x.is_a?(Float) then !x.nan? && x!=Float::INFINITY else true end}

  type :equal?, '(Object) -> %bool'
  type :eql?, '(Object) -> %bool'

  type :fdiv, '(Integer) -> Float'
  type :fdiv, '(Float) -> Float'
  type :fdiv, '(Rational) -> Float'
  type :fdiv, '(BigDecimal) -> BigDecimal'
  type :fdiv, '(Complex) -> Complex'
  pre(:fdiv) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :finite?, '() -> %bool'

  type :floor, '() -> Integer'
  pre(:floor) { !self.infinite? && !self.nan?}

  type :hash, '() -> Integer'

  type :imag, '() -> Fixnum'
  post(:imag) { |r,x| r == 0 }
  type :imaginary, '() -> Fixnum'
  post(:imaginary) { |r,x| r == 0 }

  type :infinite?, '() -> %bool'

  type :to_s, '() -> String'
  type :inspect, '() -> String'

  type :magnitude, '() -> BigDecimal'
  post(:magnitude) { |r,x| r>0}

  type :modulo, '(Numeric) -> BigDecimal'
  pre(:modulo) { |x| x!=0&&(if x.is_a?(Float) then x!=Float::INFINITY && !x.nan? else true end)}

  type :nan?, '() -> %bool'

  type :numerator, '() -> Integer'
  pre(:numerator) { !self.infinite? && !self.nan?}

  type :phase, '() -> Numeric'

  type :quo, '(Integer) -> BigDecimal'
  pre(:quo) { |x| x!=0}
  type :quo, '(Float) -> BigDecimal'
  pre(:quo) { |x| x!=0 && x!=Float::INFINITY && !x.nan?}
  type :quo, '(Rational) -> BigDecimal'
  pre(:quo) { |x| x!=0}
  type :quo, '(BigDecimal) -> BigDecimal'
  pre(:quo) { |x| x!=0}
  type :quo, '(Complex) -> Complex'
  pre(:quo) { |x| x!=0 && if x.real.is_a?(Float) then x.real!=Float::INFINITY && !(x.real.nan?) else true end && if x.imaginary.is_a?(Float) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end && if (x.real.is_a?(Rational)) then !x.imaginary.nan? else true end}

  type :real, '() -> BigDecimal'

  type :real?, '() -> TrueClass'

  type :round, '() -> Integer' 
  pre(:round) { !self.infinite? && !self.nan?}

  type :round, '(Fixnum) -> BigDecimal' #Also, x must be in range [-2**31, 2**31].

  type :to_f, '() -> Float'
  pre(:to_f) { self<=Float::MAX}

  type :to_i, '() -> Integer' 
  pre(:to_i) { !self.infinite? && !self.nan?}
  type :to_int, '() -> Integer'
  pre(:to_int) { !self.infinite? && !self.nan?}

  type :to_r, '() -> Rational'
  pre(:to_r) { !self.infinite? && !self.nan?}

  type :to_c, '() -> Complex'
  post(:to_c) { |r,x| r.imaginary == 0 }

  type :truncate, '() -> Integer'

  type :truncate, '(Fixnum) -> Rational' #Also, x must be in range [-2**31, 2**31].

  type :zero?, '() -> %bool'

  type :precs, '() -> [Integer, Integer]'

  type :split, '() -> [Fixnum, String, Integer, Integer]'

  type :remainder, '(%real) -> BigDecimal'
  pre(:remainder) { |x| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

  type :fix, '() -> BigDecimal'

  type :frac, '() -> BigDecimal'

  type :power, '(Integer) -> BigDecimal'
  type :power, '(Float) -> BigDecimal'
  pre(:power) { |x| x!=Float::INFINITY && !x.nan? && if(self<0) then x<=-1||x>=0 else true end}
  type :power, '(Rational) -> BigDecimal'
  pre(:power) { |x| if(self<0) then x<=-1||x>=0 else true end}
  type :power, '(BigDecimal) -> BigDecimal'
  pre(:power) { |x| x!=BigDecimal::INFINITY && if(self<0) then x<=-1||x>=0 else true end}

  type :nonzero?, '() -> Object'

  type :exponent, '() -> Integer'

  type :sign, '() -> Fixnum'

  type :_dump, '() -> String'

  type :sqrt, '(Fixnum) -> BigDecimal'
  pre(:sqrt) { self>=0}

  type :add, '(%real, Fixnum) -> BigDecimal'
  pre(:add) { |x,y| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}
  
  type :sub, '(%real, Fixnum) -> BigDecimal'
  pre(:sub) { |x,y| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}

  type :mult, '(%real, Fixnum) -> BigDecimal'
  pre(:mult) { |x,y| if x.is_a?(Float) then !x.infinite? && !x.nan? else true end}
  
  type :coerce, '(%real) -> [BigDecimal, BigDecimal]'
  pre(:coerce) { |x| if x.is_a?(Float) then !x.nan? && !x.finite? else true end}
end
