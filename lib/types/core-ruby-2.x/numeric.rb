class Numeric
  rdl_nowrap

  type :%, '(%numeric) -> %numeric'
  pre(:%) { |x| x!=0}
  type :+, '(%numeric) -> %numeric'
  type :-, '() -> %numeric'
  type :<=>, '(%numeric) -> Object'
  post(:<=>) { |r,x| r == -1 || r==0 || r==1 || r==nil}
  type :abs, '() -> %numeric'
  post(:abs) { |r,x| r >= 0 }
  type :abs2, '() -> %numeric'
  post(:abs2) { |r,x| r >= 0 }
  type :angle, '() -> %numeric'
  type :arg, '() -> %numeric'
  type :ceil, '() -> %integer'
  type :coerce, '(%numeric) -> [%numeric, %numeric]'
  type :conj, '() -> %numeric'
  type :conjugate, '() -> %numeric'
  type :denominator, '() -> %integer'
  post(:denominator) { |r,x| r >= 0 }
  type :div, '(%numeric) -> %integer'
  pre(:div) { |x| x!=0}
  type :divmod, '(%numeric) -> [%numeric, %numeric]'
  pre(:divmod) { |x| x!=0 }
  type :eql?, '(%numeric) -> %bool'
  type :fdiv, '(%numeric) -> %numeric'
  type :floor, '() -> %integer'
  type :i, '() -> Complex'
  type :imag, '() -> %numeric'
  type :imaginary, '() -> %numeric'
  type :integer?, '() -> %bool'
  type :magnitude, '() -> %numeric'
  type :modulo, '(%numeric) -> %real'
  pre(:modulo) { |x| x!=0 }
  type :nonzero?, '() -> self or nil'
  type :numerator, '() -> %integer'
  type :phase, '() -> %numeric'
  type :polar, '() -> [%numeric, %numeric]'
  type :quo, '(%numeric) -> %numeric'
  type :real, '() -> %numeric'
  type :real?, '() -> %numeric'
  type :rect, '() -> [%numeric, %numeric]'
  type :rectangular, '() -> [%numeric, %numeric]'
  type :remainder, '(%numeric) -> %real'
  type :round, '(%numeric) -> %numeric'
  type :singleton_method_added, '(Symbol) -> TypeError'
  type :step, '(%numeric) { (%numeric) -> %any } -> %numeric'
  type :step, '(%numeric) -> Enumerator<%numeric>'
  type :step, '(%numeric, %numeric) { (%numeric) -> %any } -> %numeric'
  type :step, '(%numeric, %numeric) -> Enumerator<%numeric>'
  type :to_c, '() -> Complex'
  type :to_int, '() -> %integer'
  type :truncate, '() -> %integer'
  type :zero?, '() -> %bool'
end
