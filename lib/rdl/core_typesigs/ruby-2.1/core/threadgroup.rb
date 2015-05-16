require 'rdl'
class ThreadGroup
  extend RDL 


  ## Instance Methods
  typesig(:add, "(Thread) -> ThreadGroup") 
  typesig(:enclose, "() -> ThreadGroup") 
  typesig(:enclosed?, "() -> %bool") 
  typesig(:list, "() -> Array") 
end
