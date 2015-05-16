require 'rdl'
class MatchData
  extend RDL 


  ## Instance Methods
  typesig(:==, "(%any) -> %bool") 
  typesig(:[], "(Integer) -> String") 
  typesig(:[], "(Integer, Integer) -> Array") 
  typesig(:[], "(Range) -> Array") 
  typesig(:[], "(String) -> String") 
  typesig(:begin, "(Numeric) -> Fixnum") 
  typesig(:captures, "() -> Array") 
  typesig(:end, "(Numeric) -> Integer") 
  typesig(:eql?, "(%any) -> %bool") 
  typesig(:hash, "() -> Integer") 
  typesig(:inspect, "() -> String") 
  typesig(:length, "() -> Integer") 
  typesig(:names, "() -> Array") 
  typesig(:offset, "(Numeric) -> Array") 
  typesig(:post_match, "() -> String") 
  typesig(:pre_match, "() -> String") 
  typesig(:regexp, "() -> Regexp") 
  typesig(:size, "() -> Integer") 
  typesig(:string, "() -> String") 
  typesig(:to_a, "() -> Array") 
  typesig(:to_s, "() -> String") 
  typesig(:values_at, "(*Integer) -> Array") 
end
