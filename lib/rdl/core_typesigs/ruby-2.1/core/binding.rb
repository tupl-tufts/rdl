require 'rdl'
class Binding
  extend RDL 


  ## Instance Methods
  typesig(:clone, "() -> Binding") 
  typesig(:dup, "() -> Binding") 
  typesig(:eval, "(String, *String) -> %any") 
  typesig(:local_variable_defined?, "(Symbol) -> %bool") 
  typesig(:local_variable_get, "(Symbol) -> %any") 
  typesig(:local_variable_set, "(Symbol, %any) -> %any") 
end
