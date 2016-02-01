class Numeric
  rdl_nowrap

  type :%, '(Numeric) -> Numeric'
  pre(:%) { |x| x!=0}
  type :+, '(Numeric) -> Numeric'
  type :-, '() -> Numeric'
  type :<=>, '(Numeric) -> Object'
  post(:<=>) { |x| x == -1 || x==0 || x==1 || x==nil}
  type :abs, '() -> Numeric'
  post(:abs) { |x| x >= 0 }
  type :abs2, '() -> Numeric'
  post(:abs2) { |x| x >= 0 }
  type :angle, '() -> Numeric'
  type :arg, '() -> Numeric'
  type :ceil, '() -> Integer'
  type :coerce, '(Numeric) -> [Numeric, Numeric]'
  type :conj, '() -> Numeric'
  type :conjugate, '() -> Numeric'
  type :denominator, '() -> Integer'
  post(:denominator) { |x| x >= 0 }
  type :div, '(Numeric) -> Integer'
  pre(:div) { |x| x!=0}
  type :divmod, '(Numeric) -> [Numeric, Numeric]'
  pre(:divmod) { |x| x!=0 }
  type :eql?, '(Numeric) -> %bool'
  type :fdiv, '(Numeric) -> Numeric'
  type :floor, '() -> Integer'
  type :i, '() -> Complex'
  type :imag, '() -> Numeric'
  type :imaginary, '() -> Numeric'
  type :integer?, '() -> %bool'
  type :magnitude, '() -> Numeric'
  type :modulo, '(Numeric) -> %real'
  pre(:modulo) { |x| x!=0 }
  type :nonzero?, '() -> self or nil'
  type :numerator, '() -> Integer'
  type :phase, '() -> Numeric'
  type :polar, '() -> [Numeric, Numeric]'
  type :quo, '(Numeric) -> Numeric'
  type :real, '() -> Numeric'
  type :real?, '() -> Numeric'
  type :rect, '() -> [Numeric, Numeric]'
  type :rectangular, '() -> [Numeric, Numeric]'
  type :remainder, '(Numeric) -> %real'
  type :round, '(Numeric) -> Numeric'
  type :singleton_method_added, '(Symbol) -> TypeError'
  type :step, '(Numeric) { (Numeric) -> %any } -> Numeric'
  type :step, '(Numeric) -> Enumerator<Numeric>'
  type :step, '(Numeric, Numeric) { (Numeric) -> %any } -> Numeric'
  type :step, '(Numeric, Numeric) -> Enumerator<Numeric>'
  type :to_c, '() -> Complex'
  type :to_int, '() -> Integer'
  type :truncate, '() -> Integer'
  type :zero?, '() -> %bool'
end
