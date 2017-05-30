rdl_nowrap :Proc

type :Proc, :arity, '() -> %integer'
type :Proc, :binding, '() -> Binding'
type :Proc, :curry, '(?%integer arity) -> Proc'
type :Proc, :hash, '() -> %integer'
rdl_alias :Proc, :inspect, :to_s
type :Proc, :lambda, '() -> %bool'
type :Proc, :parameters, '() -> Array<[Symbol, Symbol]>'
type :Proc, :source_location, '() -> [String, %integer]'
type :Proc, :to_proc, '() -> self'
type :Proc, :to_s, '() -> String'
