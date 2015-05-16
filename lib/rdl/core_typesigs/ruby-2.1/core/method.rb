require 'rdl'
class Method
  extend RDL 


  ## Instance Methods
  typesig(:==, "(%any) -> %bool") 
  typesig(:[], "(*%any) -> %any") 
  typesig(:arity, "() -> Fixnum") 
  typesig(:call, "(*%any) -> %any") 
  typesig(:clone, "() -> Method") 
  typesig(:eql?, "(%any) -> %bool") 
  typesig(:hash, "() -> Integer") 
  typesig(:inspect, "() -> String") 
  typesig(:name, "() -> Symbol") 
  typesig(:original_name, "() -> Symbol") 
  typesig(:owner, "() -> Class or Module") 
  typesig(:parameters, "() -> Array") 
  typesig(:receiver, "() -> %any") 
  typesig(:source_location, "() -> Array") 
  typesig(:to_proc, "() -> Proc") 
  typesig(:to_s, "() -> String") 
  typesig(:unbind, "() -> UnboundMethod") 
end
