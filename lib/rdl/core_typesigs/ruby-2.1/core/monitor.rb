require 'rdl'
require 'Monitor'

class Monitor
  extend RDL 


  ## Instance Methods
  typesig(:enter, "() -> Integer") 
  typesig(:exit, "() -> Integer") 
  typesig(:try_enter, "() -> %bool") 
end
