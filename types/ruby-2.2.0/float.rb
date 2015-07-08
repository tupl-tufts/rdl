class Float
  type :%, '(other: Float) -> Float'
  type :*, '(other: Float) -> Float'
  type :**, '(other: Float) -> Float'
  type :+, '(other: Float) -> Float'
  type :-, '(other: Float) -> Float'
  type :-, '() -> Float'
  type :/, '(other: Numeric) -> Float'
  type :<, '(Numeric) -> %bool'
  pre(:<) { |x| x.real? }
  type :<=, '(Numeric) -> %bool'
  pre(:<=) { |x| x.real? }
  type :<=>, '(Numeric) -> -1 or 0 or 1 or nil'
  pre(:<=>) { |x| x.real? }
  type :==, '(%any) -> %bool'
  type :>, '(Numeric) -> %bool'
  pre(:>) { |x| x.real? }
  type :>=, '(Numeric) -> %bool'
  pre(:>=) { |x| x.real? }
  type :abs, '() -> Float'
  type :angle, '() -> 0 or ${Math::PI}'
  type :arg, '() -> 0 or ${Math::PI}'
  type :ceil, '() -> Integer'
  type :coerce, '(Numeric) -> [Float, Float]'
  type :denominator, '() -> Integer'
  post(:denominator) { |r, _| r > 0 }
  type :divmod, '(Numeric) -> [Numeric, Numeric]'
  type :equl?, '(%any) -> %bool'
  type :fdiv, '(Numeric) -> Float'
  type :finite?, '() -> %bool'
  type :floor, '() -> Integer'
  type :hash, '() -> Integer'
  type :infinite?, '() -> -1 or 1 or nil'
  rdl_alias :inspect, :to_s
  type :magnitude, '() -> Float'
  rdl_alias :modulo, :%
  type :nan?, '() -> %bool'
  type :next_float, '() -> Float'
  type :numerator, '() -> Integer'
  type :phase, '() -> 0 or ${Math::PI}'
  type :prev_float, '() -> Float'
  rdl_alias :quo, :/
  type :rationalize, '(eps: Float) -> Rational'
  type :round, '(ndigits: ?Fixnum) -> Integer or FLoat'
  type :to_f, '() -> self'
  type :to_i, '() -> Integer'
  rdl_alias :to_int, :to_i
  type :to_r, '() -> Rational'
  type :to_s, '() -> String'
  type :truncate, '() -> Integer'
  type :zero?, '() -> %bool'
end