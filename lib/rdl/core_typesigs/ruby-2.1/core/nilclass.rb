require 'rdl'
class NilClass
  extend RDL 

  RDL.turn_off
  ## Instance Methods
  typesig(:&, "(%any) -> FalseClass") 
  typesig(:^, "(%any) -> %bool") 
  typesig(:inspect, "() -> String") 
  typesig(:nil?, "() -> %bool") 
  typesig(:rationalize, "(?Float) -> Fixnum") 
  typesig(:to_a, "() -> Array") 
  typesig(:to_c, "() -> Complex") 
  typesig(:to_f, "() -> Float") 
  typesig(:to_h, "() -> Hash") 
  typesig(:to_i, "() -> Integer") 
  typesig(:to_r, "() -> Rational") 
  typesig(:to_s, "() -> String") 
  typesig(:|, "(%any) -> %bool") 
  RDL.turn_on
end
