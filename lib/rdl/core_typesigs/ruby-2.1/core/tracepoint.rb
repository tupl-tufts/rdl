require 'rdl'
class TracePoint
  extend RDL 

  ## Class Methods
  #typesig(:new)
  #typesig(:trace)

  ## Instance Methods
  typesig(:binding, "() -> Binding") 
  typesig(:defined_class, "() -> Class") 
  typesig(:disable, "() -> %bool") 
  typesig(:disable, "() {(%any) -> %any} -> %any") 
  typesig(:enable, "() -> %bool") 
  typesig(:enabled?, "() -> %bool") 
  typesig(:enabled?, "() {(%any) -> %any} -> %any") 
  #typesig(:event, "() -> Event")
  typesig(:inspect, "() -> String") 
  # typesig(:lineno, "()") 
  # typesig(:method_id, "()")
  # typesig(:path, "()")
  # typesig(:raised_exception, "()")
  # typesig(:return_value, "()")
  typesig(:self, "() -> TracePoint")
end
