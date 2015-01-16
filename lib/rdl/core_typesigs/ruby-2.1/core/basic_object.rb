require_relative '../../../lib/rdl.rb'

class BasicObject
    extend RDL
    
    typesig(:==, "(other : %any) -> %bool")
    typesig(:equal?, "(other : %any) -> %bool")
    typesig(:!, "() -> %bool")
    typesig(:!=, "(other: %any) -> %bool")
    typesig(:instance_eval, "(String, filename : ?String, lineno : ?Fixnum) -> %any)")
    typesig(:instance_eval, "() { () -> %any } -> %any")
    typesig(:instance_exec, "(args: *%any) { (*%any) -> %any } -> %any")
    typesig(:__send__, "(Symbol, *%any) -> obj : %any")
    rdl_alias :__id__, :object_id
    typesig(:object_id, "() -> Fixnum")
end
