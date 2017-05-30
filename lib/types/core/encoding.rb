rdl_nowrap :Encoding

type :Encoding, 'self.aliases', '() -> Hash<String, String>'
type :Encoding, 'self.compatible?', '(%any obj1, %any obj2) -> Encoding or nil'
type :Encoding, 'self.default_external', '() -> Encoding'
type :Encoding, 'self.default_external=', '(String) -> String'
type :Encoding, 'self.default_external=', '(Encoding) -> Encoding'
type :Encoding, 'self.default_internal', '() -> Encoding'
type :Encoding, 'self.default_internal=', '(String) -> String or nil'
type :Encoding, 'self.default_internal=', '(Encoding) -> Encoding or nil'
type :Encoding, 'self.find', '(String or Encoding) -> Encoding'
type :Encoding, 'self.list', '() -> Array<Encoding>'
type :Encoding, 'self.name_list', '() -> Array<String>'

type :Encoding, :ascii_compatible?, '() -> %bool'
type :Encoding, :dummy?, '() -> %bool'
type :Encoding, :inspect, '() -> String'
type :Encoding, :name, '() -> String'
type :Encoding, :names, '() -> Array<String>'
type :Encoding, :replicate, '(String name) -> Encoding'
rdl_alias :Encoding, :to_s, :name
