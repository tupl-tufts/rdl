class Symbol
  nowrap

  type 'self.all_symbols', '() -> Array<Symbol>'
  type :<=>, '(Symbol) -> Fixnum or nil'
  type :==, '(%any) -> %bool'
  type :=~, '(%any) -> Fixnum or nil'
  type :[], '(Fixnum) -> String'
  type :[], '(Fixnum, Fixnum) -> String'
  type :capitalize, '() -> Symbol'
  type :casecmp, '(Symbol) -> Fixnum or nil'
  type :downcase, '() -> Symbol'
  type :empty?, '() -> %bool'
  type :encoding, '() -> Encoding'
  type :id2name, '() -> String'
  type :inspect, '() -> String'
  type :intern, '() -> self'
  type :length, '() -> Fixnum'
  type :match, '(%any) -> Fixnum or nil'
  type :succ, '() -> Symbol'
  rdl_alias :size, :length
  rdl_alias :slice, :[]
  type :swapcase, '() -> Symbol'
  type :to_proc, '() -> Proc' # TODO proc
  rdl_alias :to_s, :id2name
  rdl_alias :to_sym, :intern
  type :upcase, '() -> Symbol'
end