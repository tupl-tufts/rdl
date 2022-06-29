RDL.nowrap :Symbol

RDL.type :Symbol, 'self.all_symbols', '() -> Array<Symbol>'
RDL.type :Symbol, :<=>, '(Symbol other) -> Integer or nil'
RDL.type :Symbol, :==, '(Object) -> %bool'
RDL.type :Symbol, :=~, '(Object) -> Integer or nil'
RDL.type :Symbol, :[], '(Integer idx) -> String'
RDL.type :Symbol, :[], '(Integer b, Integer n) -> String'
RDL.type :Symbol, :[], '(Range<Integer>) -> String'
RDL.type :Symbol, :capitalize, '() -> Symbol'
RDL.type :Symbol, :casecmp, '(Symbol other) -> Integer or nil'
RDL.type :Symbol, :downcase, '() -> Symbol'
RDL.type :Symbol, :empty?, '() -> %bool'
RDL.type :Symbol, :encoding, '() -> Encoding'
RDL.type :Symbol, :id2name, '() -> String'
RDL.type :Symbol, :inspect, '() -> String'
RDL.type :Symbol, :intern, '() -> self'
RDL.type :Symbol, :length, '() -> Integer'
RDL.type :Symbol, :match, '(%any obj) -> Integer or nil'
RDL.type :Symbol, :succ, '() -> Symbol'
RDL.rdl_alias :Symbol, :size, :length
RDL.rdl_alias :Symbol, :slice, :[]
RDL.type :Symbol, :swapcase, '() -> Symbol'
RDL.type :Symbol, :to_proc, '() -> Proc' # TODO proc
RDL.type :Symbol, :to_s, "() -> String"
RDL.type :Symbol, :to_sym, "() -> self"
RDL.type :Symbol, :upcase, '() -> Symbol'
