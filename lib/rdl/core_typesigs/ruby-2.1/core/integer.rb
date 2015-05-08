require_relative '../../../../rdl.rb'

class Integer
  extend RDL


  #Public Instance Methods
  typesig(:chr, "(?Encoding) -> String")
  typesig(:denominator, "() -> Integer" ) #{ret == 1}
  typesig(:downto, "(Integer) {(Integer) -> %any } -> Integer")
  typesig(:downto, "(Integer) -> Enumerator")
  typesig(:downto, "(Integer) {(Integer) -> %any} -> %any")
  typesig(:even?, "() -> %bool")  #{ret % 2 == 0}
  typesig(:gcd, "(Integer) -> Integer") #{ret <= self && ret <= prm[0] && self.% ret == 0 && prm[0] % ret == 0}

  typesig(:gcdlcm, "(Integer) -> Array<Integer>")
  typesig(:integer?, "() -> %bool") #{ret == true}
  typesig(:lcm, "(Integer) -> Integer")
  typesig(:next, "() -> Integer") #{ ret == self.+ 1}
  typesig(:numerator, "() -> Integer") #{ret == self}
  typesig(:odd?, "() -> %bool") #{ret.% 2 == 1}
  typesig(:ord, "() -> Integer")
  typesig(:pred, "() -> Integer")

  typesig(:rationalize, "() -> Rational")
  typesig(:round, "(?Integer) -> Integer or Float")
  typesig(:succ, "() -> Integer")
  typesig(:times, "() -> Enumerator")
  typesig(:times, "(Integer) {(Integer) -> %any} -> %any")
  typesig(:to_i, "(Integer) -> Integer") #{ret == self}
  typesig(:to_r, " () -> Rational")
  typesig(:upto, "(Integer) -> Enumerator")
  typesig(:upto, "(Integer) {(Integer) -> %any} -> %any")

end
