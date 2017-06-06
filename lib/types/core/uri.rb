RDL.nowrap :URI

RDL.type :URI, :decode_www_form, '(String, ?Encoding, ?String separator, %bool use_charset, %bool isindex) -> Array<[String,String]>'
RDL.type :URI, :decode_www_form_component, '(String, ?Encoding) -> Array<[String,String]>'
# RDL.type :URI, :encode_www_form, '(Array<Array<String>>, ?) -> String' #Doublesplat
# RDL.type :URI, :encode_www_form_component, '(String, ?) -> String'
RDL.type :URI, :extract, '(String, ?Array) { (*%any) -> %any} -> Array<String>'
RDL.type :URI, :join, '(*String) -> URI::HTTP'
RDL.type :URI, :parse, '(String) -> URI::HTTP'
RDL.type :URI, :regexp, '(?Array schemes) -> Array<String>' #Assume schemes are strings
RDL.type :URI, :scheme_list, '() -> Hash<String,Class>'
RDL.type :URI, :split, '(String) -> Array<String or nil>'

RDL.type :URI, :escape, '(String, *Regexp) -> String'
RDL.type :URI, :escape, '(String, *String) -> String'
RDL.type :URI, :unescape, '(*String) -> String'
RDL.rdl_alias :URI, :encode, :escape
RDL.rdl_alias :URI, :decode, :unescape
