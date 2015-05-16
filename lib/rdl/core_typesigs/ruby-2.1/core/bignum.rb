require 'rdl'
class Bignum < Integer
  extend RDL 


  ## Instance Methods
  typesig(:%, "(Numeric) -> Numeric") 
  typesig(:&, "(Numeric) -> Numeric") 
  typesig(:*, "(Numeric) -> Numeric") 
  typesig(:**, "(Numeric) -> Numeric") 
  typesig(:+, "(Numeric) -> Numeric") 
  typesig(:-, "(Numeric) -> Numeric") 
  typesig(:-@, "() -> Numeric") 

  # Intersection Type # 
  typesig(:/, "(Bignum) -> Fixnum") 
  typesig(:/, "(Complex) -> Complex")
  typesig(:/, "(Fixnum) -> Bignum")
  typesig(:/, "(Float) -> Float")
  typesig(:/, "(Rational) -> Rational")
  # End Intersection # 
  
  typesig(:<, "(Numeric) -> %bool") 
  typesig(:<<, "(Numeric) -> Integer") 
  typesig(:<=, "(Numeric) -> %bool") 

  # Intersection Type # 
  typesig(:<=>, "(Numeric) -> Fixnum") 
  # End Intersection # 
  typesig(:==, "(%any) -> %bool") 
  typesig(:===, "(%any) -> %bool") 
  typesig(:>, "(Numeric) -> %bool") 
  typesig(:>=, "(Numeric) -> %bool") 
  typesig(:>>, "(Numeric) -> Integer") 
  typesig(:[], "(Numeric) -> Fixnum") 
  typesig(:^, "(Numeric) -> Integer") 

  typesig(:abs, "() -> Bignum") 
  typesig(:bit_length, "() -> Integer") 
  typesig(:coerce, "(Integer) -> Array") 
  typesig(:div, "(Numeric) -> Integer") 
  typesig(:divmod, "(Numeric) -> Array") 
  typesig(:eql?, "(%any) -> %bool") 
  typesig(:even?, "() -> %bool") 
  # Intersection Type # 
  typesig(:fdiv, "(Numeric) -> Float") 
  typesig(:fdiv, "(Complex) -> Complex") 
  # End Intersection # 
  typesig(:hash, "() -> Fixnum") 
  typesig(:inspect, "(?Integer) -> String") 
  typesig(:magnitude, "() -> Bignum") 
  typesig(:modulo, "(Numeric) -> Numeric") 
  typesig(:odd?, "() -> %bool") 
  typesig(:remainder, "(Numeric) -> Numeric") 
  typesig(:size, "() -> Integer") 
  typesig(:to_f, "() -> Float") 
  typesig(:to_s, "(?Integer) -> String") 
  typesig(:|, "(Numeric) -> Integer") 
  typesig(:~, "() -> Integer") 
end
