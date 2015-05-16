require 'rdl'
require 'Rational'

class Rational < Numeric
  extend RDL 


  ## Instance Methods
  typesig(:*, "(Numeric) -> Rational") 
  typesig(:**, "(Numeric) -> Numeric") 
  typesig(:+, "(Numeric) -> Numeric") 
  typesig(:-, "(Numeric) -> Numeric") 
  typesig(:/, "(Numeric) -> Numeric") 
  typesig(:<=>, "(Numeric) -> Fixnum") 
  typesig(:==, "(%any) -> %bool") 
  typesig(:ceil, "() -> Integer") 
  typesig(:ceil, "(Integer) -> Rational")
  typesig(:coerce, "(Numeric) -> Array") 
  typesig(:denominator, "() -> Integer") 
  typesig(:fdiv, "(Numeric) -> Float") 
  typesig(:floor, "() -> Integer") 
  typesig(:floor, "(Integer) -> Rational")
  typesig(:hash, "() -> Fixnum") 
  typesig(:inspect, "() -> String") 
  typesig(:numerator, "() -> Fixnum") 
  typesig(:quo, "(Numeric) -> Numeric") 
  typesig(:rationalize, "(?Numeric) -> Rational") 
  typesig(:round, "() -> Integer") 
  typesig(:round, "(Integer) -> Rational")
  typesig(:to_f, "() -> Float") 
  typesig(:to_i, "() -> Integer") 
  typesig(:to_r, "() -> Rational") 
  typesig(:to_s, "() -> String") 
  typesig(:truncate, "() -> Integer") 
  typesig(:truncate, "(Integer) -> Rational")
end
