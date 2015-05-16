require 'rdl'
class Proc
  extend RDL 

  ## Class Methods
  #typesig(:new)

  ## Instance Methods
  typesig(:===, "(*%any) -> %any") 
  typesig(:[], "(*%any) -> %any") 
  typesig(:arity, "() -> Fixnum") 
  typesig(:binding, "() -> Binding") 
  typesig(:call, "(*%any) -> %any") 
  typesig(:clone, "() -> Proc") 
  typesig(:curry, "(?Fixnum) -> Proc") 
  typesig(:dup, "() -> Proc") 
  typesig(:hash, "() -> Integer") 
  typesig(:inspect, "() -> String") 
  typesig(:lambda?, "() -> %bool") 
  typesig(:parameters, "() -> Array") 
  typesig(:source_location, "() -> Array") 
  typesig(:to_proc, "() -> Proc") 
  typesig(:to_s, "() -> String") 
  typesig(:yield, "(*%any) -> %any") 
end
