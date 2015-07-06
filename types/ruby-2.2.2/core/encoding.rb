class Encoding
  type 'self.aliases', '() -> Hash<String, String>'
  type 'self.compatible?', '(obj1: %any, obj2: %any) -> Encoding or nil'
  type 'self.default_external', '() -> Encoding'
  type 'self.default_external=', '(Encoding) -> Encoding'
  type 'self.default_internal', '() -> Encoding'
  type 'self.default_internal=', '(Encoding) -> Encoding or nil'
  type 'self.find', '(String) -> Encoding'
  type 'self.list', '() -> Array<Encoding>'
  type 'self.name_list', '() -> Array<String>'

  type :ascii_compatible?, '() -> %bool'
  type :dummy?, '() -> %bool'
  type :inspect, '() -> String'
  type :name, '() -> String'
  type :names, '() -> Array<String>'
  type :replicate, '(name: String) -> Encoding'
  rdl_alias :to_s, :name
end