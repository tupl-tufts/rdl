rdl_nowrap :Regexp

type :Regexp, 'self.escape', '(String or Symbol) -> String'
type :Regexp, 'self.last_match', '() -> MatchData', wrap: false # Can't wrap or messes up MatchData
type :Regexp, 'self.last_match', '(Fixnum) -> String', wrap: false
type :Regexp, 'self.new', '(String, ?%any options, ?String kcode) -> Regexp'
type :Regexp, 'self.new', '(Regexp) -> Regexp'
rdl_alias :Regexp, 'self.compile', 'self.new'
rdl_alias :Regexp, 'self.quote', 'self.escape'
type :Regexp, 'self.try_convert', '(%any obj) -> Regexp or nil'
type :Regexp, 'self.union', '(*(Regexp or String) pats) -> Regexp'
type :Regexp, 'self.union', '(Array<Regexp or String> pats) -> Regexp'
type :Regexp, :==, '(%any other) -> %bool'
type :Regexp, :===, '(%any other) -> %bool', wrap: false # Can't wrap this of it messes with $1, $2, etc as well!
type :Regexp, :=~, '(String str) -> Fixnum or nil', wrap: false # Can't wrap this or it will mess with $1, $2, etc
type :Regexp, :casefold?, '() -> %bool'
type :Regexp, :encoding, '() -> Encoding'
rdl_alias :Regexp, :eql?, :==
type :Regexp, :fixed_encoding?, '() -> %bool'
type :Regexp, :hash, '() -> Fixnum'
type :Regexp, :inspect, '() -> String'
type :Regexp, :match, '(String, ?Fixnum) -> MatchData or nil'
type :Regexp, :named_captures, '() -> Hash<String, Array<Fixnum>>'
type :Regexp, :names, '() -> Array<String>'
type :Regexp, :options, '() -> Fixnum'
type :Regexp, :source, '() -> String'
type :Regexp, :to_s, '() -> String'
type :Regexp, :~, '() -> Fixnum or nil'
