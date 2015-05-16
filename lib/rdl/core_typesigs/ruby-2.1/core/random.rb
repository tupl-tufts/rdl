require 'rdl'
class Random
  extend RDL 

  ## Class Methods
  #typesig(:srand)
  #typesig(:rand)
  #typesig(:new_seed)

  ## Instance Methods
  typesig(:==, "(%any) -> %bool") 
  typesig(:bytes, "(Numeric) -> String") 
  typesig(:rand, "() -> Float") 
  typesig(:rand, "(?Integer) -> Numeric")
  typesig(:seed, "() -> Integer") 
end
