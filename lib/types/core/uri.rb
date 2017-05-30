rdl_nowrap :URI

type :URI, :decode_www_form, '(String, ?Encoding, ?String separator, %bool use_charset, %bool isindex) -> Array<[String,String]>'
type :URI, :decode_www_form_component, '(String, ?Encoding) -> Array<[String,String]>'
# type :URI, :encode_www_form, '(Array<Array<String>>, ?) -> String' #Doublesplat
# type :URI, :encode_www_form_component, '(String, ?) -> String'
type :URI, :extract, '(String, ?Array) { (*%any) -> %any} -> Array<String>'
type :URI, :join, '(*String) -> URI::HTTP'
type :URI, :parse, '(String) -> URI::HTTP'
type :URI, :regexp, '(?Array schemes) -> Array<String>' #Assume schemes are strings
type :URI, :scheme_list, '() -> Hash<String,Class>'
type :URI, :split, '(String) -> Array<String or nil>'

type :URI, :escape, '(String, *Regexp) -> String'
type :URI, :escape, '(String, *String) -> String'
type :URI, :unescape, '(*String) -> String'
rdl_alias :URI, :encode, :escape
rdl_alias :URI, :decode, :unescape
