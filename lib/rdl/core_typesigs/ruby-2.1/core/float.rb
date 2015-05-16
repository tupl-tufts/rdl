require 'rdl'
class Float < Numeric
  extend RDL 


  ## Instance Methods
  typesig(:%, "(Numeric) -> Float") 
  # Intersection Type # 
  typesig(:*, "(Numeric) -> Float") 
  typesig(:*, "(Complex) -> Complex")
  # End Intersection # 
  # Intersection Type # 
  typesig(:**, "(Numeric) -> Float") 
  typesig(:**, "(Complex) -> Complex") 
  # End Intersection # 
  # Intersection Type # 
  typesig(:+, "(Numeric) -> Float") 
  typesig(:+, "(Complex) -> Complex") 
  # End Intersection # 
  # Intersection Type # 
  typesig(:-, "(Numeric) -> Float") 
  typesig(:-, "(Complex) -> Complex")
  # End Intersection # 
  typesig(:-@, "() -> Float") 
  # Intersection Type # 
  typesig(:/, "(Numeric) -> Float") 
  typesig(:/, "(Complex) -> Complex")
  # End Intersection # 
  typesig(:<, "(Integer or Float or Rational) -> %bool") 
  typesig(:<=, "(Integer or Float or Rational) -> %bool") 
  typesig(:<=>, "(%any) -> Fixnum") 
  typesig(:==, "(%any) -> %bool") 
  typesig(:===, "(%any) -> %bool") 
  typesig(:>, "(Integer or Float or Rational) -> %bool") 
  typesig(:>=, "(Integer or Float or Rational) -> %bool") 
  typesig(:abs, "() -> Float") 
  typesig(:angle, "() -> Fixnum or Float") 
  typesig(:arg, "() -> Fixnum or Float") 
  typesig(:ceil, "() -> Integer") 
  typesig(:coerce, "(Numeric) -> Array") 
  typesig(:denominator, "() -> Integer") 
  typesig(:divmod, "(Numeric) -> Array") 
  typesig(:eql?, "(%any) -> %bool") 
  # Intersection Type #  
  typesig(:fdiv, "(Numeric) -> Float") 
  typesig(:fdiv, "(Complex) -> Complex")
  # End Intersection # 
  typesig(:finite?, "() -> %bool") 
  typesig(:floor, "() -> Integer") 
  typesig(:hash, "() -> Integer") 
  typesig(:infinite?, "() -> Fixnum") 
  typesig(:inspect, "() -> String") 
  typesig(:magnitude, "() -> Float") 
  typesig(:modulo, "(Numeric) -> Float") 
  typesig(:nan?, "() -> %bool") 
  typesig(:numerator, "() -> Integer") 
  typesig(:phase, "() -> Fixnum or Float") 
  # Intersection Type # 
  typesig(:quo, "(Numeric) -> Float") 
  typesig(:quo, "(Complex) -> Complex")
  # End Intersection # 
  typesig(:rationalize, "(?Float) -> Rational") 
  typesig(:round, "(Integer) -> Integer or Float") 
  typesig(:to_f, "() -> Float") 
  typesig(:to_i, "() -> Integer") 
  typesig(:to_int, "() -> Integer") 
  typesig(:to_r, "() -> Rational") 
  typesig(:to_s, "() -> String") 
  typesig(:truncate, "() -> Integer") 
  typesig(:zero?, "() -> %bool") 
end
