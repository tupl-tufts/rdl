class Proc
  rdl_nowrap

  type :arity, '() -> %integer'
  type :binding, '() -> Binding'
  type :curry, '(?%integer arity) -> Proc'
  type :hash, '() -> %integer'
  rdl_alias :inspect, :to_s
  type :lambda, '() -> %bool'
  type :parameters, '() -> Array<[Symbol, Symbol]>'
  type :source_location, '() -> [String, %integer]'
  type :to_proc, '() -> self'
  type :to_s, '() -> String'


end
