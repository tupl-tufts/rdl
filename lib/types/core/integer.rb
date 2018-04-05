RDL.nowrap :Integer

def Numeric.sing_or_type(trec, targs, meth, type)
  if trec.is_a?(RDL::Type::SingletonType) && (targs.empty? || targs[0].is_a?(RDL::Type::SingletonType))
    if targs[0]
      v = trec.val.send(meth, targs[0].val)
    else
      v = trec.val.send(meth)
    end
    RDL::Type::SingletonType.new(v)
  else
    RDL::Globals.parser.scan_str "#T #{type}"
  end
end

RDL.type :Integer, :%, '(Integer x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :%, "Integer")``'
RDL.type :Integer, :%, '(Float x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :%, "Float")``'
RDL.type :Integer, :%, '(Rational x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :%, "Rational")``'
RDL.type :Integer, :%, '(BigDecimal x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :%, "BigDecimal")``'

RDL.type :Integer, :&, '(Integer) -> ``sing_or_type(trec, targs, :&, "Integer")``'

RDL.type :Integer, :*, '(Integer) -> ``sing_or_type(trec, targs, :*, "Integer")``'
RDL.type :Integer, :*, '(Float) -> ``sing_or_type(trec, targs, :*, "Float")``'
RDL.type :Integer, :*, '(Rational) -> ``sing_or_type(trec, targs, :*, "Rational")``'
RDL.type :Integer, :*, '(BigDecimal) -> ``sing_or_type(trec, targs, :*, "BigDecimal")``'
RDL.type :Integer, :*, '(Complex) -> ``sing_or_type(trec, targs, :*, "Complex")``'
RDL.pre(:Integer, :*) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end} #can't have a complex with part BigDecimal, other part infinity/NAN

RDL.type :Integer, :**, '(Integer) -> ``sing_or_type(trec, targs, :**, "%numeric")``'
RDL.type :Integer, :**, '(Float) -> ``sing_or_type(trec, targs, :**, "%numeric")``'
RDL.type :Integer, :**, '(Rational) -> ``sing_or_type(trec, targs, :**, "%numeric")``'
RDL.type :Integer, :**, '(BigDecimal) -> ``sing_or_type(trec, targs, :**, "BigDecimal")``'
RDL.pre(:Integer, :**) { |x| x!=BigDecimal::INFINITY && if self<0 then x<=-1||x>=0 else true end}
RDL.post(:Integer, :**) { |r,x| r.real?}
RDL.type :Integer, :**, '(Complex) -> ``sing_or_type(trec, targs, :**, "Complex")``'
RDL.pre(:Integer, :**) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end}

RDL.type :Integer, :+, '(Integer) -> ``sing_or_type(trec, targs, :+, "Integer")``'
RDL.type :Integer, :+, '(Float) -> ``sing_or_type(trec, targs, :+, "Float")``'
RDL.type :Integer, :+, '(Rational) -> ``sing_or_type(trec, targs, :+, "Rational")``'
RDL.type :Integer, :+, '(BigDecimal) -> ``sing_or_type(trec, targs, :+, "BigDecimal")``'
RDL.type :Integer, :+, '(Complex) -> ``sing_or_type(trec, targs, :+, "Complex")``'

RDL.type :Integer, :-, '(Integer) -> ``sing_or_type(trec, targs, :-, "Integer")``'
RDL.type :Integer, :-, '(Float) -> ``sing_or_type(trec, targs, :-, "Float")``'
RDL.type :Integer, :-, '(Rational) -> ``sing_or_type(trec, targs, :-, "Rational")``'
RDL.type :Integer, :-, '(BigDecimal) -> ``sing_or_type(trec, targs, :-, "BigDecimal")``'
RDL.type :Integer, :-, '(Complex) -> ``sing_or_type(trec, targs, :-, "Complex")``'

RDL.type :Integer, :-@, '() -> ``sing_or_type(trec, targs, :-@, "Integer")``'

RDL.type :Integer, :+@, '() -> ``sing_or_type(trec, targs, :-@, "Integer")``'

RDL.type :Integer, :/, '(Integer x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :/, "Integer")``'
RDL.type :Integer, :/, '(Float x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :/, "Float")``'
RDL.type :Integer, :/, '(Rational x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :/, "Rational")``'
RDL.type :Integer, :/, '(BigDecimal x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :/, "BigDecimal")``'
RDL.type :Integer, :/, '(Complex x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :/, "Complex")``'
RDL.pre(:Integer, :/) { |x| x!=0 && if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Integer, :<, '(Integer) -> ``sing_or_type(trec, targs, :<, "%bool")``'
RDL.type :Integer, :<, '(Float) -> ``sing_or_type(trec, targs, :<, "%bool")``'
RDL.type :Integer, :<, '(Rational) -> ``sing_or_type(trec, targs, :<, "%bool")``'
RDL.type :Integer, :<, '(BigDecimal) -> ``sing_or_type(trec, targs, :<, "%bool")``'

RDL.type :Integer, :<<, '(Integer) -> ``sing_or_type(trec, targs, :<<, "Integer")``'

RDL.type :Integer, :<=, '(Integer) -> ``sing_or_type(trec, targs, :<=, "%bool")``'
RDL.type :Integer, :<=, '(Float) -> ``sing_or_type(trec, targs, :<=, "%bool")``'
RDL.type :Integer, :<=, '(Rational) -> ``sing_or_type(trec, targs, :<=, "%bool")``'
RDL.type :Integer, :<=, '(BigDecimal) -> ``sing_or_type(trec, targs, :<=, "%bool")``'

RDL.type :Integer, :<=>, '(Integer) -> ``sing_or_type(trec, targs, :<=>, "Integer")``'
RDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
RDL.type :Integer, :<=>, '(Float) -> ``sing_or_type(trec, targs, :<=>, "Integer")``'
RDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
RDL.type :Integer, :<=>, '(Rational) -> ``sing_or_type(trec, targs, :<=>, "Integer")``'
RDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }
RDL.type :Integer, :<=>, '(BigDecimal) -> ``sing_or_type(trec, targs, :<=>, "Integer")``'
RDL.post(:Integer, :<=>) { |r,x| r == -1 || r == 0 || r == 1 }

RDL.type :Integer, :==, '(Object) -> ``sing_or_type(trec, targs, :==, "%bool")``'

RDL.type :Integer, :===, '(Object) -> ``sing_or_type(trec, targs, :===, "%bool")``'

RDL.type :Integer, :>, '(Integer) -> ``sing_or_type(trec, targs, :>, "%bool")``'
RDL.type :Integer, :>, '(Float) -> ``sing_or_type(trec, targs, :>, "%bool")``'
RDL.type :Integer, :>, '(Rational) -> ``sing_or_type(trec, targs, :>, "%bool")``'
RDL.type :Integer, :>, '(BigDecimal) -> ``sing_or_type(trec, targs, :>, "%bool")``'

RDL.type :Integer, :>=, '(Integer) -> ``sing_or_type(trec, targs, :>=, "%bool")``'
RDL.type :Integer, :>=, '(Float) -> ``sing_or_type(trec, targs, :>=, "%bool")``'
RDL.type :Integer, :>=, '(Rational) -> ``sing_or_type(trec, targs, :>=, "%bool")``'
RDL.type :Integer, :>=, '(BigDecimal) -> ``sing_or_type(trec, targs, :>=, "%bool")``'

RDL.type :Integer, :>>, '(Integer) -> Integer r {{ r >= 0 }}' ## TODO

RDL.type :Integer, :[], '(Integer) -> ``sing_or_type(trec, targs, :[], "Integer")``'
RDL.post(:Integer, :[]) { |r,x| r == 0 || r==1}
RDL.type :Integer, :[], '(Rational) -> ``sing_or_type(trec, targs, :[], "Integer")``'
RDL.post(:Integer, :[]) { |r,x| r == 0 || r==1}
RDL.type :Integer, :[], '(Float) -> ``sing_or_type(trec, targs, :[], "Integer")``'
RDL.pre(:Integer, :[]) { |x| x != Float::INFINITY && !x.nan? }
RDL.post(:Integer, :[]) { |r,x| r == 0 || r==1}
RDL.type :Integer, :[], '(BigDecimal) -> ``sing_or_type(trec, targs, :[], "Integer")``'
RDL.pre(:Integer, :[]) { |x| x != BigDecimal::INFINITY && !x.nan? }
RDL.post(:Integer, :[]) { |r,x| r == 0 || r == 1 }

RDL.type :Integer, :^, '(Integer) -> ``sing_or_type(trec, targs, :^, "Integer")``'

RDL.type :Integer, :|, '(Integer) -> ``sing_or_type(trec, targs, :|, "Integer")``'

RDL.type :Integer, :~, '() -> ``sing_or_type(trec, targs, :~, "Integer")``'

RDL.type :Integer, :abs, '() -> Integer r {{ r>=0 }}' ## TODO

RDL.type :Integer, :bit_length, '() -> Integer r {{ r>=0 }}' ## TODO

RDL.type :Integer, :div, '(Integer x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :div, "Integer")``'
RDL.type :Integer, :div, '(Float x {{ x!=0 && !x.nan? }}) -> ``sing_or_type(trec, targs, :div, "Integer")``'
RDL.type :Integer, :div, '(Rational x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :div, "Integer")``'
RDL.type :Integer, :div, '(BigDecimal x {{ x!=0 && !x.nan? }}) -> ``sing_or_type(trec, targs, :div, "Integer")``'

RDL.type :Integer, :divmod, '(%real x {{ x!=0 }}) -> [%real, %real]'
RDL.pre(:Integer, :divmod) { |x| if x.is_a?(Float) then !x.nan? else true end}

RDL.type :Integer, :fdiv, '(Integer) -> ``sing_or_type(trec, targs, :fdiv, "Float")``'
RDL.type :Integer, :fdiv, '(Float) -> ``sing_or_type(trec, targs, :fdiv, "Float")``'
RDL.type :Integer, :fdiv, '(Rational) -> ``sing_or_type(trec, targs, :fdiv, "Float")``'
RDL.type :Integer, :fdiv, '(BigDecimal) -> ``sing_or_type(trec, targs, :fdiv, "BigDecimal")``'
RDL.type :Integer, :fdiv, '(Complex) -> ``sing_or_type(trec, targs, :fdiv, "Complex")``'
RDL.pre(:Integer, :fdiv) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Integer, :to_s, '() -> String'
RDL.type :Integer, :inspect, '() -> String'

RDL.type :Integer, :magnitude, '() -> Integer r {{ r>=0 }}' ## TODO

RDL.type :Integer, :modulo, '(Integer x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :modulo, "Integer")``'
RDL.type :Integer, :modulo, '(Float x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :modulo, "Float")``'
RDL.type :Integer, :modulo, '(Rational x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :modulo, "Rational")``'
RDL.type :Integer, :modulo, '(BigDecimal x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :modulo, "BigDecimal")``'

RDL.type :Integer, :quo, '(Integer x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :quo, "Integer")``'
RDL.type :Integer, :quo, '(Float x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :quo, "Float")``'
RDL.type :Integer, :quo, '(Rational x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :quo, "Rational")``'
RDL.type :Integer, :quo, '(BigDecimal x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :quo, "BigDecimal")``'
RDL.type :Integer, :quo, '(Complex x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :quo, "Complex")``'
RDL.pre(:Integer, :quo) { |x| if (x.real.is_a?(BigDecimal)||x.imaginary.is_a?(BigDecimal)) then (if x.real.is_a?(Float) then (x.real!=Float::INFINITY && !(x.real.nan?)) elsif(x.imaginary.is_a?(Float)) then x.imaginary!=Float::INFINITY && !(x.imaginary.nan?) else true end) else true end && if (x.real.is_a?(Rational) && x.imaginary.is_a?(Float)) then !x.imaginary.nan? else true end}

RDL.type :Integer, :abs2, '() -> Integer r {{ r>=0 }}' ## TODO
RDL.type :Integer, :angle, '() -> ``sing_or_type(trec, targs, :angle, "%numeric")``'
RDL.post(:Integer, :angle) { |r,x| r == 0 || r == Math::PI}
RDL.type :Integer, :arg, '() -> ``sing_or_type(trec, targs, :arg, "%numeric")``'
RDL.post(:Integer, :arg) { |r,x| r == 0 || r == Math::PI}
RDL.type :Integer, :equal?, '(Object) -> ``sing_or_type(trec, targs, :equal?, "%bool")``'
RDL.type :Integer, :eql?, '(Object) -> ``sing_or_type(trec, targs, :eql?, "%bool")``'
RDL.type :Integer, :hash, '() -> Integer'
RDL.type :Integer, :ceil, '() -> ``sing_or_type(trec, targs, :ceil, "Integer")``'
RDL.type :Integer, :chr, '(Encoding) -> String'
RDL.type :Integer, :coerce, '(%numeric) -> [%real, %real]'
RDL.pre(:Integer, :coerce) { |x| if x.is_a?(Complex) then x.imaginary==0 else true end}
RDL.type :Integer, :conj, '() -> ``sing_or_type(trec, targs, :conj, "Integer")``'
RDL.type :Integer, :conjugate, '() -> ``sing_or_type(trec, targs, :conjugate, "Integer")``'
RDL.type :Integer, :denominator, '() -> ``sing_or_type(trec, targs, :denominator, "Integer")``'
RDL.post(:Integer, :denominator) { |r,x| r == 1 }
RDL.type :Integer, :downto, '(Integer) { (Integer) -> %any } -> Integer'
RDL.type :Integer, :downto, '(Integer limit) -> Enumerator<Integer>'
RDL.type :Integer, :even?, '() -> ``sing_or_type(trec, targs, :even?, "%bool")``'
RDL.type :Integer, :gcd, '(Integer) -> ``sing_or_type(trec, targs, :gcd, "Integer")``'
RDL.type :Integer, :gcdlcm, '(Integer) -> [Integer, Integer]'
RDL.type :Integer, :floor, '() -> ``sing_or_type(trec, targs, :floor, "Integer")``'
RDL.type :Integer, :imag, '() -> Integer r {{ r==0 }}' ## TODO
RDL.type :Integer, :imaginary, '() -> Integer r {{ r==0 }}' ## TODO
RDL.type :Integer, :integer?, '() -> true'
RDL.type :Integer, :lcm, '(Integer) -> ``sing_or_type(trec, targs, :lcm, "Integer")``'
RDL.type :Integer, :next, '() -> ``sing_or_type(trec, targs, :next, "Integer")``'
RDL.type :Integer, :numerator, '() -> ``sing_or_type(trec, targs, :numerator, "Integer")``'
RDL.type :Integer, :odd?, '() -> ``sing_or_type(trec, targs, :odd?, "%bool")``'
RDL.type :Integer, :ord, '() -> ``sing_or_type(trec, targs, :ord, "Integer")``'
RDL.type :Integer, :phase, '() -> ``sing_or_type(trec, targs, :phase, "%numeric")``'
RDL.type :Integer, :pred, '() -> ``sing_or_type(trec, targs, :pred, "Integer")``'
RDL.type :Integer, :rationalize, '() -> Rational' ## TODO
RDL.type :Integer, :rationalize, '(%numeric) -> Rational' ## TODO
RDL.type :Integer, :real, '() -> ``sing_or_type(trec, targs, :real, "Integer")``'
RDL.type :Integer, :real?, '() -> true'
RDL.type :Integer, :remainder, '(Integer x {{ x!=0 }}) -> Integer r {{ r>=0 }}' ## TODO
RDL.type :Integer, :remainder, '(Float x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :remainder, "Float")``'
RDL.type :Integer, :remainder, '(Rational x {{ x!=0 }}) -> Rational r {{ r>=0 }}' ## TODO
RDL.type :Integer, :remainder, '(BigDecimal x {{ x!=0 }}) -> ``sing_or_type(trec, targs, :gcd, "BigDecimal")``'
RDL.type :Integer, :round, '() -> ``sing_or_type(trec, targs, :round, "Integer")``'
RDL.type :Integer, :round, '(%numeric) -> ``sing_or_type(trec, targs, :round, "%numeric")``'
RDL.pre(:Integer, :round) { |x| x!=0 && if x.is_a?(Complex) then x.imaginary==0 && (if x.real.is_a?(Float)||x.real.is_a?(BigDecimal) then !x.real.infinite? && !x.real.nan? else true end) elsif x.is_a?(Float) then x!=Float::INFINITY && !x.nan? elsif x.is_a?(BigDecimal) then x!=BigDecimal::INFINITY && !x.nan? else true end} #Also, x must be in range [-2**31, 2**31].
RDL.type :Integer, :size, '() -> ``sing_or_type(trec, targs, :size, "Integer")``'
RDL.type :Integer, :succ, '() -> ``sing_or_type(trec, targs, :succ, "Integer")``'
RDL.type :Integer, :times, '() { (Integer) -> %any } -> Integer'
RDL.type :Integer, :times, '() -> Enumerator<Integer>'
RDL.type :Integer, :to_c, '() -> Complex r {{ r.imaginary==0 }}'
RDL.type :Integer, :to_f, '() -> ``sing_or_type(trec, targs, :to_f, "Float")``'
RDL.type :Integer, :to_i, '() -> self'
RDL.type :Integer, :to_int, '() -> self'
RDL.type :Integer, :to_r, '() -> Rational' ## TODO
RDL.type :Integer, :truncate, '() -> ``sing_or_type(trec, targs, :truncate, "Integer")``'
RDL.type :Integer, :upto, '(Integer) { (Integer) -> %any } -> Integer'
RDL.type :Integer, :upto, '(Integer) -> Enumerator<Integer>'
RDL.type :Integer, :zero?, '() -> ``sing_or_type(trec, targs, :zero?, "%bool")``'
