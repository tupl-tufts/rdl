RDL.nowrap :Encoding

RDL.type :Encoding, 'self.aliases', '() -> Hash<String, String>'
RDL.type :Encoding, 'self.compatible?', '(%any obj1, %any obj2) -> Encoding or nil'
RDL.type :Encoding, 'self.default_external', '() -> Encoding'
RDL.type :Encoding, 'self.default_external=', '(String) -> String'
RDL.type :Encoding, 'self.default_external=', '(Encoding) -> Encoding'
RDL.type :Encoding, 'self.default_internal', '() -> Encoding'
RDL.type :Encoding, 'self.default_internal=', '(String) -> String or nil'
RDL.type :Encoding, 'self.default_internal=', '(Encoding) -> Encoding or nil'
RDL.type :Encoding, 'self.find', '(String or Encoding) -> Encoding'
RDL.type :Encoding, 'self.list', '() -> Array<Encoding>'
RDL.type :Encoding, 'self.name_list', '() -> Array<String>'

RDL.type :Encoding, :ascii_compatible?, '() -> %bool'
RDL.type :Encoding, :dummy?, '() -> %bool'
RDL.type :Encoding, :inspect, '() -> String'
RDL.type :Encoding, :name, '() -> String'
RDL.type :Encoding, :names, '() -> Array<String>'
RDL.type :Encoding, :replicate, '(String name) -> Encoding'
RDL.rdl_alias :Encoding, :to_s, :name
