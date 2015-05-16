require 'rdl'
class Fiber
  extend RDL 

  ## Class Methods
  #typesig(:yield)

  ## Instance Methods
  typesig(:alive?, "() -> %bool") 
  typesig(:resume, "(*%any) -> %any") 
  typesig(:transfer, "(*%any) -> %any") 

end
