require 'rdl'
class Symbol
  extend RDL 

  RDL.turn_off
  ## Class Methods
  #typesig(:all_symbols)

  ## Instance Methods
  typesig(:<=>, "(Symbol) -> Fixnum") 
  typesig(:==, "(%any) -> %bool") 
  typesig(:===, "(%any) -> %bool") 
  typesig(:=~, "(%any) -> Fixnum") 
  typesig(:[], "(Integer) -> Char") 
  typesig(:[], "(Integer, Integer) -> String")
  typesig(:capitalize, "() -> Symbol") 
  typesig(:casecmp, "(Symbol) -> Fixnum") 
  typesig(:downcase, "() -> Symbol") 
  typesig(:empty?, "() -> %bool") 
  typesig(:encoding, "() -> Encoding") 
  typesig(:id2name, "() -> String") 
  typesig(:inspect, "() -> String") 
  typesig(:intern, "() -> Symbol") 
  typesig(:length, "() -> Integer") 
  typesig(:match, "(%any) -> Fixnum") 
  typesig(:size, "() -> Integer") 
  typesig(:slice, "(Integer) -> Char") 
  typesig(:slice, "(Integer, Integer) -> String")
  typesig(:succ, "() -> Symbol") 
  typesig(:swapcase, "() -> Symbol") 
  typesig(:to_proc, "() -> Proc") 
  typesig(:to_s, "() -> String") 
  typesig(:to_sym, "() -> Symbol") 
  typesig(:upcase, "() -> Symbol") 
  RDL.turn_on
end
