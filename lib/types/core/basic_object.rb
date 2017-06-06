RDL.nowrap :BasicObject

RDL.type :BasicObject, :==, '(%any other) -> %bool'
RDL.type :BasicObject, :equal?, '(%any other) -> %bool'
RDL.type :BasicObject, :!, '() -> %bool'
RDL.type :BasicObject, :!=, '(%any other) -> %bool'
RDL.type :BasicObject, :instance_eval, '(String, ?String filename, ?Integer lineno) -> %any'
RDL.type :BasicObject, :instance_eval, '() { () -> %any } -> %any'
RDL.type :BasicObject, :instance_exec, '(*%any args) { (*%any) -> %any } -> %any'
RDL.type :BasicObject, :__send__, '(Symbol, *%any) -> %any obj'
RDL.rdl_alias :BasicObject, :__id__, :object_id
RDL.type :BasicObject, :object_id, '() -> Integer'
