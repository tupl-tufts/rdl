module URI
  rdl_nowrap

  type :decode_www_form, '(String, ?Encoding, ?String separator, %bool use_charset, %bool isindex) -> Array<[String,String]>'
  type :decode_www_form_component, '(String, ?Encoding) -> Array<[String,String]>'
  # type 'encode_www_form', '(Array<Array<String>>, ?) -> String' #Doublesplat
  # type 'encode_www_form_component', '(String, ?) -> String'
  type :extract, '(String, ?Array) { (*%any) -> %any} -> Array<String>'
  type :join, '(*String) -> URI::HTTP'
  type :parse, '(String) -> URI::HTTP'
  type :regexp, '(?Array schemes) -> Array<String>' #Assume schemes are strings
  type :scheme_list, '() -> Hash<String,Class>'
  type :split, '(String) -> Array<String or nil>'

  type :escape, '(String, *Regexp) -> String'
  type :escape, '(String, *String) -> String'
  type :unescape, '(*String) -> String'
  rdl_alias :encode, :escape
  rdl_alias :decode, :unescape
end
