rdl_nowrap :BasicObject
  
type :BasicObject, :==, '(%any other) -> %bool'
type :BasicObject, :equal?, '(%any other) -> %bool'
type :BasicObject, :!, '() -> %bool'
type :BasicObject, :!=, '(%any other) -> %bool'
type :BasicObject, :instance_eval, '(String, ?String filename, ?Fixnum lineno) -> %any'
type :BasicObject, :instance_eval, '() { () -> %any } -> %any'
type :BasicObject, :instance_exec, '(*%any args) { (*%any) -> %any } -> %any'
type :BasicObject, :__send__, '(Symbol, *%any) -> %any obj'
rdl_alias :BasicObject, :__id__, :object_id
type :BasicObject, :object_id, '() -> Fixnum'
