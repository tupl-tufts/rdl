require 'rdl'
class Regexp
  extend RDL 

  ## Class Methods
  # typesig(:compile)
  # typesig(:quote)
  # typesig(:escape)
  # typesig(:union)
  # typesig(:last_match)
  # typesig(:try_convert)

  ## Instance Methods
  typesig(:==, "(%any) -> %bool") 
  typesig(:===, "(%any) -> %bool") 
  typesig(:=~, "(String or Symbol) -> Integer") 
  typesig(:casefold?, "() -> %bool") 
  typesig(:encoding, "() -> Encoding") 
  typesig(:eql?, "(%any) -> %bool") 
  typesig(:fixed_encoding?, "() -> %bool") 
  typesig(:hash, "() -> Fixnum") 
  typesig(:inspect, "() -> String") 
  typesig(:match, "(String, ?Integer) -> MatchData") 
  typesig(:named_captures, "() -> Hash") 
  typesig(:names, "() -> Array") 
  typesig(:options, "() -> Fixnum") 
  typesig(:source, "() -> String") 
  typesig(:to_s, "() -> String") 
  typesig(:~, "() -> Integer") 
end
