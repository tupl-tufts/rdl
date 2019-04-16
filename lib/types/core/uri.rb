RDL.nowrap :URI

RDL.type :URI, :'self.decode_www_form', '(String, ?Encoding, ?String separator, %bool use_charset, %bool isindex) -> Array<[String,String]>'
RDL.type :URI, :'self.decode_www_form_component', '(String, ?Encoding) -> Array<[String,String]>'
# RDL.type :URI, :encode_www_form, '(Array<Array<String>>, ?) -> String' #Doublesplat
# RDL.type :URI, :encode_www_form_component, '(String, ?) -> String'
RDL.type :URI, :'self.extract', '(String, ?Array) { (*%any) -> %any} -> Array<String>'
RDL.type :URI, :'self.join', '(*String) -> URI::HTTP'
RDL.type :URI, :'self.parse', '(String) -> URI::HTTP'
RDL.type :URI, :'self.regexp', '(?Array schemes) -> Array<String>' #Assume schemes are strings
RDL.type :URI, :'self.scheme_list', '() -> Hash<String,Class>'
RDL.type :URI, :'self.split', '(String) -> Array<String or nil>'

RDL.type :URI, :'self.escape', '(String, *Regexp) -> String'
RDL.type :URI, :'self.escape', '(String, *String) -> String'
RDL.type :URI, :'self.unescape', '(*String) -> String'
RDL.rdl_alias :URI, :'self.encode', :'self.escape'
RDL.rdl_alias :URI, :'self.decode', :'self.unescape'
