rdl_nowrap :Symbol

type :Symbol, 'self.all_symbols', '() -> Array<Symbol>'
type :Symbol, :<=>, '(Symbol other) -> Fixnum or nil'
type :Symbol, :==, '(%any obj) -> %bool'
type :Symbol, :=~, '(%any obj) -> Fixnum or nil'
type :Symbol, :[], '(Fixnum idx) -> String'
type :Symbol, :[], '(Fixnum b, Fixnum n) -> String'
type :Symbol, :[], '(Range<Fixnum>) -> String'
type :Symbol, :capitalize, '() -> Symbol'
type :Symbol, :casecmp, '(Symbol other) -> Fixnum or nil'
type :Symbol, :downcase, '() -> Symbol'
type :Symbol, :empty?, '() -> %bool'
type :Symbol, :encoding, '() -> Encoding'
type :Symbol, :id2name, '() -> String'
type :Symbol, :inspect, '() -> String'
type :Symbol, :intern, '() -> self'
type :Symbol, :length, '() -> Fixnum'
type :Symbol, :match, '(%any obj) -> Fixnum or nil'
type :Symbol, :succ, '() -> Symbol'
rdl_alias :Symbol, :size, :length
rdl_alias :Symbol, :slice, :[]
type :Symbol, :swapcase, '() -> Symbol'
type :Symbol, :to_proc, '() -> Proc' # TODO proc
rdl_alias :Symbol, :to_s, :id2name
rdl_alias :Symbol, :to_sym, :intern
type :Symbol, :upcase, '() -> Symbol'
