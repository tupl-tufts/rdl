class BigDecimal

  #type 'self._load', '()'
  type 'self.double_fig', '() -> Fixnum'
  type 'self.limit', '(Fixnum) -> Fixnum'
  type 'self.mode', '(Fixnum mode, ?(%bool or Symbol) value) -> Fixnum'
  #type 'self.new', '(Integer or Float or Rational or BigDecimal or String, Fixnum) -> BigDecimal'
  type 'self.save_exception_mode', '() { (*%any) -> %any } -> %any'
  type 'self.save_limit', '() { (*%any) -> %any } -> %any'
  type 'self.save_rounding_mode', '() { (*%any) -> %any } -> %any'
  type 'self.ver', '() -> String'
  
  # TODO
end