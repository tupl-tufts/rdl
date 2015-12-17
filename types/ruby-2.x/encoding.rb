class Encoding
  rdl_nowrap

  type 'self.aliases', '() -> Hash<String, String>'
  type 'self.compatible?', '(%any obj1, %any obj2) -> Encoding or nil'
  type 'self.default_external', '() -> Encoding'
  type 'self.default_external=', '(String) -> String'
  type 'self.default_external=', '(Encoding) -> Encoding'
  type 'self.default_internal', '() -> Encoding'
  type 'self.default_internal=', '(String) -> String or nil'
  type 'self.default_internal=', '(Encoding) -> Encoding or nil'
  type 'self.find', '(String or Encoding) -> Encoding'
  type 'self.list', '() -> Array<Encoding>'
  type 'self.name_list', '() -> Array<String>'

  type :ascii_compatible?, '() -> %bool'
  type :dummy?, '() -> %bool'
  type :inspect, '() -> String'
  type :name, '() -> String'
  type :names, '() -> Array<String>'
  type :replicate, '(String name) -> Encoding'
  rdl_alias :to_s, :name
end
