class BasicObject
  rdl_nowrap
  
  type :==, '(%any other) -> %bool'
  type :equal?, '(%any other) -> %bool'
  type :!, '() -> %bool'
  type :!=, '(%any other) -> %bool'
  type :instance_eval, '(String, ?String filename, ?Fixnum lineno) -> %any'
  type :instance_eval, '() { () -> %any } -> %any'
  type :instance_exec, '(*%any args) { (*%any) -> %any } -> %any'
  type :__send__, '(Symbol, *%any) -> %any obj'
  rdl_alias :__id__, :object_id
  type :object_id, '() -> Fixnum'
end
