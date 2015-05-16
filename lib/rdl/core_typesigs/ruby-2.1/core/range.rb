require 'rdl'
class Range
  extend RDL 


  ## Instance Methods
  typesig(:==, "(%any) -> %bool") 
  typesig(:===, "(%any) -> %bool") 
  typesig(:begin, "() -> %any") 
  typesig(:bsearch, "() -> Enumerator") 
  typesig(:bsearch, "() {(%any) -> %any} -> %any") 
  typesig(:cover?, "(%any) -> %bool") 
  typesig(:each, "() -> Enumerator") 
  typesig(:each, "() {(Integer) -> %any} -> Range") 
  typesig(:end, "() -> Integer") 
  typesig(:eql?, "(%any) -> %bool") 
  typesig(:exclude_end?, "() -> %bool") 
  typesig(:first, "() -> %any") 
  typesig(:first, "(Integer) -> Array")
  typesig(:hash, "() -> Fixnum") 
  typesig(:include?, "(%any) -> %bool") 
  typesig(:inspect, "() -> String") 
  typesig(:last, "() -> %any") 
  typesig(:last, "(Integer) -> Array")
  typesig(:max, "(?Integer) -> %any") 
  typesig(:max, "(?Integer) {(t,t) -> Fixnum} -> %any", :vars => [:t])
  typesig(:member?, "(%any) -> %bool") 
  typesig(:min, "(?Integer) -> %any") 
  typesig(:min, "(?Integer) {(t,t) -> Fixnum} -> %any", :vars => [:t])
  typesig(:size, "() -> Numeric") 
  typesig(:step, "(?Integer) -> Enumerator") 
  typesig(:step, "(?Integer) {(%any) -> %any} -> Range")
  typesig(:to_s, "() -> String") 
end
