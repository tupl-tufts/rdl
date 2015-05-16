require 'rdl'
require 'Complex'

class Complex < Numeric
  extend RDL 

  ## Class Methods
  #typesig(:rectangular)
  #typesig(:rect)
  #typesig(:polar)
  #typesig(:generic?)

  ## Instance Methods
  typesig(:*, "(Numeric) -> Complex") 
  typesig(:**, "(Numeric) -> Complex") 
  typesig(:+, "(Numeric) -> Complex") 
  typesig(:-, "(Numeric) -> Complex") 
  typesig(:-@, "() -> Complex") 
  typesig(:/, "(Numeric) -> Complex") 
  typesig(:==, "(%any) -> %bool") 
  typesig(:abs, "() -> Float or Integer or Rational") 
  typesig(:abs2, "() -> Float or Integer or Rational") 
  typesig(:angle, "() -> Float") 
  typesig(:arg, "() -> Float") 
  typesig(:coerce, "(Numeric) -> Array") 
  typesig(:conj, "() -> Complex") 
  typesig(:conjugate, "() -> Complex") 
  typesig(:denominator, "() -> Integer") 
  typesig(:eql?, "(%any) -> %bool") 
  typesig(:fdiv, "(Numeric) -> Complex") 
  typesig(:hash, "() -> Fixnum") 
  typesig(:imag, "() -> Float or Integer or Rational") 
  typesig(:image, "() -> Float or Integer or Rational") 
  typesig(:imaginary, "() -> Float or Integer or Rational") 
  typesig(:inspect, "() -> String") 
  typesig(:magnitude, "() -> Float or Integer or Rational") 
  typesig(:numerator, "() -> Numeric") 
  typesig(:phase, "() -> Float") 
  typesig(:polar, "() -> Array") 
  typesig(:quo, "(Numeric) -> Complex") 
  typesig(:rationalize, "(Array) -> Rational") 
  typesig(:real, "() -> Float or Integer or Rational") 
  typesig(:real?, "() -> %bool") 
  typesig(:rect, "() -> Array") 
  typesig(:rectangular, "() -> Array") 
  typesig(:to_c, "() -> Complex") 
  typesig(:to_f, "() -> Float") 
  typesig(:to_i, "() -> Integer") 
  typesig(:to_r, "() -> Rational") 
  typesig(:to_s, "() -> String") 
end
