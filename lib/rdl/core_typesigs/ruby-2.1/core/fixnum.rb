require 'rdl'
class Fixnum < Integer
  extend RDL 
  
  RDL.turn_off
  ## Instance Methods
  # Intersection Type # 
  typesig(:%, "(Integer) -> Integer") 
  typesig(:%, "(Float) -> Float")
  typesig(:%, "(Rational) -> Rational")
  # End Intersection # 
  typesig(:&, "(Integer) -> Integer") 
  # Intersection Type # 
  typesig(:*, "(Integer) -> Integer") 
  typesig(:*, "(Complex) -> Complex")
  typesig(:*, "(Float) -> Float")
  typesig(:*, "(Rational) -> Rational")
  # End Intersection # 
  typesig(:**, "(Numeric) -> Numeric") 
  # Intersection Type # 
  typesig(:+, "(Integer) -> Integer") 
  typesig(:+, "(Complex) -> Complex")
  typesig(:+, "(Float) -> Float")
  typesig(:+, "(Rational) -> Rational")
  # End Intersection # 
  # Intersection Type # 
  typesig(:-, "(Integer) -> Integer") 
  typesig(:-, "(Complex) -> Complex")
  typesig(:-, "(Float) -> Float")
  typesig(:-, "(Rational) -> Rational")
  # End Intersection # 
  typesig(:-@, "() -> Integer") 
  # Intersection Type # 
  typesig(:/, "(Integer) -> Integer") 
  typesig(:/, "(Complex) -> Complex")
  typesig(:/, "(Float) -> Float")
  typesig(:/, "(Rational) -> Rational")
  # End Intersection # 
  typesig(:<, "(Integer or Float or Rational) -> %bool") 
  typesig(:<<, "(Fixnum) -> Integer") 
  typesig(:<=, "(Integer or Float or Rational) -> %bool") 
  typesig(:<=>, "(Numeric) -> Fixnum") 
  typesig(:==, "(%any) -> %bool") 
  typesig(:===, "(%any) -> %bool") 
  typesig(:>, "(Float or Integer or Rational) -> %bool") 
  typesig(:>=, "(Integer or Float or Rational) -> %bool") 
  typesig(:>>, "(Integer) -> Integer") 
  typesig(:[], "(Integer) -> Fixnum") 
  typesig(:^, "(Integer) -> Integer") 
  typesig(:abs, "() -> Integer") 
  typesig(:bit_length, "() -> Integer") 
  typesig(:div, "(Numeric) -> Fixnum") 
  typesig(:divmod, "(Numeric) -> Array") 
  typesig(:even?, "() -> %bool") 
  # Intersection Type # 
  typesig(:fdiv, "(Numeric) -> Float") 
  typesig(:fdiv, "(Complex) -> Complex")
  # End Intersection # 
  typesig(:inspect, "(?Fixnum) -> String") 
  typesig(:magnitude, "() -> Integer") 
  # Intersection Type # 
  typesig(:modulo, "(Integer) -> Integer") 
  typesig(:modulo, "(Float) -> Float")
  typesig(:modulo, "(Rational) -> Rational")
  # End Intersection # 
  typesig(:odd?, "() -> %bool") 
  typesig(:size, "() -> Fixnum") 
  typesig(:succ, "() -> Integer") 
  typesig(:to_f, "() -> Float") 
  typesig(:to_s, "(?Fixnum) -> String") 
  typesig(:zero?, "() -> %bool") 
  typesig(:|, "(Integer) -> Integer") 
  typesig(:~, "() -> Integer") 

  RDL.turn_on
end
