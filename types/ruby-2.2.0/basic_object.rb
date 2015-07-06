class BasicObject
  nowrap
  type :==, '(other : %any) -> %bool'
  type :equal?, '(other : %any) -> %bool'
  type :!, '() -> %bool'
  type :!=, '(other: %any) -> %bool'
  type :instance_eval, '(String, filename: ?String, lineno: ?Fixnum) -> %any'
  type :instance_eval, '() { () -> %any } -> %any'
  type :instance_exec, '(args: *%any) { (*%any) -> %any } -> %any'
  type :__send__, '(Symbol, *%any) -> obj : %any'
  rdl_alias :__id__, :object_id
  type :object_id, '() -> Fixnum'
end
