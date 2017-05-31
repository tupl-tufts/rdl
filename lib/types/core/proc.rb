rdl_nowrap :Proc

type :Proc, :arity, '() -> Integer'
type :Proc, :binding, '() -> Binding'
type :Proc, :curry, '(?Integer arity) -> Proc'
type :Proc, :hash, '() -> Integer'
rdl_alias :Proc, :inspect, :to_s
type :Proc, :lambda, '() -> %bool'
type :Proc, :parameters, '() -> Array<[Symbol, Symbol]>'
type :Proc, :source_location, '() -> [String, Integer]'
type :Proc, :to_proc, '() -> self'
type :Proc, :to_s, '() -> String'
