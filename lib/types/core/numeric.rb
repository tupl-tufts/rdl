RDL.nowrap :Numeric

RDL.type :Numeric, :%, '(%numeric) -> %numeric'
RDL.pre(:Numeric, :%) { |x| x!=0}
RDL.type :Numeric, :-@, '() -> %numeric'
RDL.type :Numeric, :+@, '() -> %numeric'
RDL.type :Numeric, :<=>, '(%numeric) -> Object'
RDL.post(:Numeric, :<=>) { |r,x| r == -1 || r==0 || r==1 || r==nil}
RDL.type :Numeric, :abs, '() -> %numeric'
RDL.post(:Numeric, :abs) { |r,x| r >= 0 }
RDL.type :Numeric, :abs2, '() -> %numeric'
RDL.post(:Numeric, :abs2) { |r,x| r >= 0 }
RDL.type :Numeric, :angle, '() -> %numeric'
RDL.type :Numeric, :arg, '() -> %numeric'
RDL.type :Numeric, :ceil, '() -> Integer'
RDL.type :Numeric, :coerce, '(%numeric) -> [%numeric, %numeric]'
RDL.type :Numeric, :conj, '() -> %numeric'
RDL.type :Numeric, :conjugate, '() -> %numeric'
RDL.type :Numeric, :denominator, '() -> Integer'
RDL.post(:Numeric, :denominator) { |r,x| r >= 0 }
RDL.type :Numeric, :div, '(%numeric) -> Integer'
RDL.pre(:Numeric, :div) { |x| x!=0}
RDL.type :Numeric, :divmod, '(%numeric) -> [%numeric, %numeric]'
RDL.pre(:Numeric, :divmod) { |x| x!=0 }
RDL.type :Numeric, :eql?, '(%numeric) -> %bool'
RDL.type :Numeric, :fdiv, '(%numeric) -> %numeric'
RDL.type :Numeric, :floor, '() -> Integer'
RDL.type :Numeric, :i, '() -> Complex'
RDL.type :Numeric, :imag, '() -> %numeric'
RDL.type :Numeric, :imaginary, '() -> %numeric'
RDL.type :Numeric, :integer?, '() -> %bool'
RDL.type :Numeric, :magnitude, '() -> %numeric'
RDL.type :Numeric, :modulo, '(%numeric) -> %real'
RDL.pre(:Numeric, :modulo) { |x| x!=0 }
RDL.type :Numeric, :nonzero?, '() -> self or nil'
RDL.type :Numeric, :numerator, '() -> Integer'
RDL.type :Numeric, :phase, '() -> %numeric'
RDL.type :Numeric, :polar, '() -> [%numeric, %numeric]'
RDL.type :Numeric, :quo, '(%numeric) -> %numeric'
RDL.type :Numeric, :real, '() -> %numeric'
RDL.type :Numeric, :real?, '() -> %numeric'
RDL.type :Numeric, :rect, '() -> [%numeric, %numeric]'
RDL.type :Numeric, :rectangular, '() -> [%numeric, %numeric]'
RDL.type :Numeric, :remainder, '(%numeric) -> %real'
RDL.type :Numeric, :round, '(%numeric) -> %numeric'
RDL.type :Numeric, :singleton_method_added, '(Symbol) -> TypeError'
RDL.type :Numeric, :step, '(%numeric) { (?%numeric) -> %any } -> %numeric'
RDL.type :Numeric, :step, '(%numeric) -> Enumerator<%numeric>'
RDL.type :Numeric, :step, '(%numeric, %numeric) { (?%numeric) -> %any } -> %numeric'
RDL.type :Numeric, :step, '(%numeric, %numeric) -> Enumerator<%numeric>'
RDL.type :Numeric, :to_c, '() -> Complex'
RDL.type :Numeric, :to_int, '() -> Integer'
RDL.type :Numeric, :truncate, '() -> Integer'
RDL.type :Numeric, :zero?, '() -> %bool'
