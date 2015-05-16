require 'rdl'
class Dir
  extend RDL 

  ## Class Methods
  # typesig(:open)
  # typesig(:foreach)
  # typesig(:entries)
  # typesig(:chdir)
  # typesig(:getwd)
  # typesig(:pwd)
  # typesig(:chroot)
  # typesig(:mkdir)
  # typesig(:rmdir)
  # typesig(:delete)
  # typesig(:unlink)
  # typesig(:home)
  # typesig(:glob)
  # typesig(:[])
  # typesig(:exist?)
  # typesig(:exists?)

  ## Instance Methods
  typesig(:close, "() -> NilClass") 
  typesig(:each, "() -> Enumerator") 
  typesig(:inspect, "() -> String") 
  typesig(:path, "() -> String") 
  typesig(:pos, "() -> Integer") 
  typesig(:pos=, "(Integer) -> Integer") 
  typesig(:read, "() -> String") 
  typesig(:rewind, "() -> Dir") 
  typesig(:seek, "(Integer) -> Dir") 
  typesig(:tell, "() -> Fixnum") 
  typesig(:to_path, "() -> String") 
end
