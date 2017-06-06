RDL.nowrap :Proc

RDL.type :Proc, :arity, '() -> Integer'
RDL.type :Proc, :binding, '() -> Binding'
RDL.type :Proc, :curry, '(?Integer arity) -> Proc'
RDL.type :Proc, :hash, '() -> Integer'
RDL.rdl_alias :Proc, :inspect, :to_s
RDL.type :Proc, :lambda, '() -> %bool'
RDL.type :Proc, :parameters, '() -> Array<[Symbol, Symbol]>'
RDL.type :Proc, :source_location, '() -> [String, Integer]'
RDL.type :Proc, :to_proc, '() -> self'
RDL.type :Proc, :to_s, '() -> String'
