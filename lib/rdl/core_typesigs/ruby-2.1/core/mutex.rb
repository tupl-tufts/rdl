require 'rdl'
class Mutex
  extend RDL 


  ## Instance Methods
  typesig(:lock, "() -> Mutex") 
  typesig(:locked?, "() -> %bool") 
  typesig(:owned?, "() -> %bool") 
  typesig(:sleep, "(?Numeric) -> Numeric") 
  typesig(:synchronize, "() {(%any) -> t} -> t", :vars => [:t]) 
  typesig(:try_lock, "() -> %bool") 
  typesig(:unlock, "() -> Mutex") 
end
