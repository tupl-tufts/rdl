class NilClass
  rdl_nowrap
  type :&, '(%any obj) -> false'
  type :'^', '(%any obj) -> %bool'
  type :|, '(%any obj) -> %bool'
  type :rationalize, '() -> Rational'
  type :to_a, '() -> []'
  type :to_c, '() -> Complex'
  type :to_f, '() -> 0.0'
  type :to_h, '() -> {}'
  type :to_r, '() -> Rational'
end
