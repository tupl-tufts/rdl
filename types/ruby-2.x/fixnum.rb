class Fixnum < Integer
  rdl_nowrap

  type :%, '(Fixnum) -> Fixnum'
  pre(:%) { |x| x!=0}
  type :%, '(Bignum) -> Integer'
  pre(:%) { |x| x!=0}
  type :%, '(Float) -> Float'
  pre(:%) { |x| x!=0}
  type :%, '(Rational) -> Rational'
  pre(:%) { |x| x!=0}
  type :%, '(BigDecimal) -> BigDecimal'
  pre(:%) { |x| x!=0}

  type :&, '(Integer) -> Fixnum'

  type :*, '(Integer) -> Integer'
  type :*, '(Float) -> Float'
  type :*, '(Rational) -> Rational'
  type :*, '(BigDecimal) -> BigDecimal'
  type :*, '(Complex) -> Complex'
  pre(:*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

  type :**, '(Integer) -> Numeric'
  type :**, '(Float) -> Numeric'
  type :**, '(Rational) -> Numeric'
  type :**, '(BigDecimal) -> BigDecimal'
  pre(:**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
  post(:**) { |r,x| r.real?}
  type :**, '(Complex) -> Complex'
  pre(:**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

  type :+, '(Integer) -> Integer'
  type :+, '(Float) -> Float'
  type :+, '(Rational) -> Rational'
  type :+, '(BigDecimal) -> BigDecimal'
  type :+, '(Complex) -> Complex'

  type :-, '(Integer) -> Integer'
  type :-, '(Float) -> Float'
  type :-, '(Rational) -> Rational'
  type :-, '(BigDecimal) -> BigDecimal'
  type :-, '(Complex) -> Complex'

  type :-, '() -> Fixnum'

  type :/, '(Integer) -> Integer'
  pre(:/) { |x| x!=0}
  type :/, '(Float) -> Float'
  pre(:/) { |x| x!=0}
  type :/, '(Rational) -> Rational'
  pre(:/) { |x| x!=0}
  type :/, '(BigDecimal) -> BigDecimal'
  pre(:/) { |x| x!=0}
  type :/, '(Complex) -> Complex'
  pre(:/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end} 

  type :<, '(Integer) -> %bool'
  type :<, '(Float) -> %bool'
  type :<, '(Rational) -> %bool'
  type :<, '(BigDecimal) -> %bool'

  type :<<, '(Fixnum) -> Integer' #must be below a certain amount, not exactly sure what amount

  type :<=, '(Integer) -> %bool'
  type :<=, '(Float) -> %bool'
  type :<=, '(Rational) -> %bool'
  type :<=, '(BigDecimal) -> %bool'

  type :<=>, '(Integer) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(Float) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(Rational) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}
  type :<=>, '(BigDecimal) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1}

  type :==, '(Object) -> %bool'

  type :===, '(Object) -> %bool'

  type :>, '(Integer) -> %bool'
  type :>, '(Float) -> %bool'
  type :>, '(Rational) -> %bool'
  type :>, '(BigDecimal) -> %bool'

  type :>=, '(Integer) -> %bool'
  type :>=, '(Float) -> %bool'
  type :>=, '(Rational) -> %bool'
  type :>=, '(BigDecimal) -> %bool'

  type :>>, '(Integer) -> Integer'
  post(:>>) { |r,x| r >= 0 }

  type :[], '(Integer) -> Fixnum'
  post(:[]) { |r,x| r == 0 || r==1}
  type :[], '(Rational) -> Fixnum'
  post(:[]) { |r,x| r == 0 || r==1}
  type :[], '(Float) -> Fixnum'
  pre(:[]) { |x| x!=Float::INFINITY && !x.nan? }
  post(:[]) { |r,x| r == 0 || r==1}
  type :[], '(BigDecimal) -> Fixnum'
  pre(:[]) { |x| x!=BigDecimal::INFINITY && !x.nan? }
  post(:[]) { |r,x| r == 0 || r==1}

  type :^, '(Integer) -> Integer'

  type :|, '(Integer) -> Integer'

  type :~, '() -> Fixnum'

  type :abs, '() -> Integer'
  post(:abs) { |r,x| r >= 0 }

  type :bit_length, '() -> Fixnum'
  post(:bit_length) { |r,x| r >= 0 }

  type :div, '(Fixnum) -> Integer'
  pre(:div) { |x| x!=0}
  type :div, '(Bignum) -> Fixnum'
  pre(:div) { |x| x!=0}
  type :div, '(Float) -> Integer'
  pre(:div) { |x| x!=0 && !x.nan?}
  type :div, '(Rational) -> Integer'
  pre(:div) { |x| x!=0}
  type :div, '(BigDecimal) -> Integer'
  pre(:div) { |x| x!=0 && !x.nan?}

  type :divmod, '(%real) -> [%real, %real]'
  pre(:divmod) { |x| x!=0 && if x.is_a?(Float) then !x.nan? else true end}

  type :even?, '() -> %bool'

  type :fdiv, '(Integer) -> Float'
  type :fdiv, '(Float) -> Float'
  type :fdiv, '(Rational) -> Float'
  type :fdiv, '(BigDecimal) -> BigDecimal'
  type :fdiv, '(Complex) -> Complex'
  pre(:fdiv) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :to_s, '() -> String'
  type :inspect, '() -> String'

  type :magnitude, '() -> Integer'
  post(:magnitude) { |r,x| r >= 0 }

  type :modulo, '(Fixnum) -> Fixnum'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(Bignum) -> Integer'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(Float) -> Float'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(Rational) -> Rational'
  pre(:modulo) { |x| x!=0}
  type :modulo, '(BigDecimal) -> BigDecimal'
  pre(:modulo) { |x| x!=0}

  type :next, '() -> Integer'

  type :odd?, '() -> %bool'

  type :size, '() -> Fixnum'

  type :succ, '() -> Integer'

  type :to_f, '() -> Float'

  type :zero?, '() -> %bool'

  type :ceil, '() -> Integer'

  type :denominator, '() -> Fixnum'
  post(:denominator) { |r,x| r == 1 }

  type :floor, '() -> Integer' 
  type :numerator, '() -> Fixnum'

  type :quo, '(Integer) -> Rational'
  pre(:quo) { |x| x!=0}
  type :quo, '(Float) -> Float'
  pre(:quo) { |x| x!=0}
  type :quo, '(Rational) -> Rational'
  pre(:quo) { |x| x!=0}
  type :quo, '(BigDecimal) -> BigDecimal'
  pre(:quo) { |x| x!=0}
  type :quo, '(Complex) -> Complex'
  pre(:quo) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

  type :rationalize, '() -> Rational'

  type :rationalize, '(Numeric) -> Rational'

  type :round, '() -> Integer'

  type :round, '(Numeric) -> Numeric'
  pre(:round) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].

  type :to_i, '() -> Fixnum'

  type :to_r, '() -> Rational'

  type :truncate, '() -> Integer'

  type :angle, '() -> Numeric'
  post(:angle) { |r,x| r == 0 || r == Math::PI}

  type :arg, '() -> Numeric'
  post(:arg) { |r,x| r == 0 || r == Math::PI}

  type :equal?, '(Object) -> %bool'
  type :eql?, '(Object) -> %bool'

  type :hash, '() -> Integer'

  type :phase, '() -> Numeric'

  type :abs2, '() -> Integer'
  post(:abs2) { |r,x| r >= 0 }

  type :conj, '() -> Fixnum'
  type :conjugate, '() -> Fixnum'

  type :imag, '() -> Fixnum'
  post(:imag) { |r,x| r == 0 }
  type :imaginary, '() -> Fixnum'
  post(:imaginary) { |r,x| r == 0 }

  type :real, '() -> Fixnum'

  type :real?, '() -> TrueClass'

  type :to_c, '() -> Complex'
  post(:to_c) { |r,x| r.imaginary == 0 }

  type :remainder, '(Fixnum) -> Fixnum' 
  pre(:remainder) { |x| x!=0}
  post(:remainder) { |r,x| r>0}
  type :remainder, '(Bignum) -> Fixnum'
  pre(:remainder) { |x| x!=0}
  post(:remainder) { |r,x| r>0}
  type :remainder, '(Float) -> Float'
  pre(:remainder) { |x| x!=0}
  type :remainder, '(Rational) -> Rational'
  pre(:remainder) { |x| x!=0}
  post(:remainder) { |r,x| r>0}
  type :remainder, '(BigDecimal) -> BigDecimal'
  pre(:remainder) { |x| x!=0}

  type :coerce, '(Numeric) -> [%real, %real]'
  pre(:coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
end
