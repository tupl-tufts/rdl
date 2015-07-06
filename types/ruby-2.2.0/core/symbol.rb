class Symbol
  type 'self.all_symbols', '() -> Array<Symbol>'
  type :<=>, '(other: Symbol) -> Fixnum or nil'
  type :==, '(obj: %any) -> %bool'
  type :=~, '(obj: %any) -> Fixnum or nil'
  type :[], '(idx: Fixnum) -> String'
  type :[], '(b: Fixnum, n: Fixnum) -> String'
  type :capitalize, '() -> Symbol'
  type :casecmp, '(other: Symbol) -> Fixnum or nil'
  type :downcase, '() -> Symbol'
  type :empty?, '() -> %bool'
  type :encoding, '() -> Encoding'
  type :id2name, '() -> String'
  type :inspect, '() -> String'
  type :intern, '() -> self'
  type :length, '() -> Fixnum'
  type :match, '(obj: %any) -> Fixnum or nil'
  type :succ, '() -> Symbol'
  rdl_alias :size, :length
  rdl_alias :slice, :[]
  type :swapcase, '() -> Symbol'
  type :to_proc, '() -> Proc' # TODO proc
  rdl_alias :to_s, :id2name
  rdl_alias :to_sym, :intern
  type :upcase, '() -> Symbol'
end