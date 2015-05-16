require 'rdl'
class Encoding
  extend RDL 

  ## Class Methods
  # typesig(:list)
  # typesig(:name_list)
  # typesig(:aliases)
  # typesig(:find)
  # typesig(:compatible?)
  # typesig(:_load)
  # typesig(:default_external)
  # typesig(:default_external=)
  # typesig(:default_internal)
  # typesig(:default_internal=)
  # typesig(:locale_charmap)

  ## Instance Methods
  
  typesig(:ascii_compatible?, "() -> %bool") 
  typesig(:dummy?, "() -> %bool") 
  typesig(:inspect, "() -> String") 
  typesig(:name, "() -> String") 
  typesig(:names, "() -> Array") 
  typesig(:replicate, "(String) -> Encoding") 
  typesig(:to_s, "() -> String") 
end
