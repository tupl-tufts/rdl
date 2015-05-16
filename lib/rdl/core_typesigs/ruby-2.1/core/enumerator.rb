require 'rdl'
class Enumerator
  extend RDL 


  ## Instance Methods
  #Intersection
  typesig(:each, "(*%any) -> Enumerator") 
  typesig(:each, "(*%any) { (%any) -> %any } -> %any")
  #End Intersection
  typesig(:each_with_index, "() -> Enumerator") 
  typesig(:each_with_index, "() {(*%any, Fixnum) -> %any } -> %any")
  typesig(:each_with_object, "(%any) -> Enumerator") 
  typesig(:each_with_object, "(t) { (*%any, t) -> %any } -> %any", :vars => [:t]) 
  typesig(:feed, "(%any) -> NilClass") 
  typesig(:inspect, "() -> String") 
  typesig(:next, "() -> %any") 
  typesig(:next_values, "() -> Array") 
  typesig(:peek, "() -> %any") 
  typesig(:peek_values, "() -> Array") 
  typesig(:rewind, "() -> Enumerator") 
  typesig(:size, "() -> Integer or Float") 
  typesig(:with_index, "(?Integer) -> Enumerator") 
  typesig(:with_index, "(?Integer) {(*%any, Fixnum) -> %any} -> %any") 
  typesig(:with_object, "(%any) -> Enumerator") 
  typesig(:with_object, "(t) { (*%any, t) -> %any } -> t", :vars => [:t]) 
end
