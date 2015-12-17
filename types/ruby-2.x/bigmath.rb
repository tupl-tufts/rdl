module BigMath
  rdl_nowrap

  type 'self.exp', '(Fixnum, Fixnum) -> BigDecimal'
  type 'self.log', '(Fixnum, Fixnum) -> BigDecimal'
  type :E, '(Fixnum) -> BigDecimal'
  type :PI, '(Fixnum) -> BigDecimal'
  type :atan, '(Fixnum, Fixnum) -> BigDecimal'
  type :cos, '(Fixnum, Fixnum) -> BigDecimal'
  type :sin, '(Fixnum, Fixnum) -> BigDecimal'
  type :sqrt, '(Fixnum, Fixnum) -> BigDecimal'
end
