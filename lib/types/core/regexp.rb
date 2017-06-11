RDL.nowrap :Regexp

RDL.type :Regexp, 'self.escape', '(String or Symbol) -> String'
RDL.type :Regexp, 'self.last_match', '() -> MatchData', wrap: false # Can't wrap or messes up MatchData
RDL.type :Regexp, 'self.last_match', '(Integer) -> String', wrap: false
RDL.type :Regexp, :initialize, '(String, ?%any options, ?String kcode) -> self'
RDL.type :Regexp, :initialize, '(Regexp) -> self'
RDL.rdl_alias :Regexp, 'self.compile', 'self.new'
RDL.rdl_alias :Regexp, 'self.quote', 'self.escape'
RDL.type :Regexp, 'self.try_convert', '(%any obj) -> Regexp or nil'
RDL.type :Regexp, 'self.union', '(*(Regexp or String) pats) -> Regexp'
RDL.type :Regexp, 'self.union', '(Array<Regexp or String> pats) -> Regexp'
RDL.type :Regexp, :==, '(%any other) -> %bool'
RDL.type :Regexp, :===, '(%any other) -> %bool', wrap: false # Can't wrap this of it messes with $1, $2, etc as well!
RDL.type :Regexp, :=~, '(String str) -> Integer or nil', wrap: false # Can't wrap this or it will mess with $1, $2, etc
RDL.type :Regexp, :casefold?, '() -> %bool'
RDL.type :Regexp, :encoding, '() -> Encoding'
RDL.rdl_alias :Regexp, :eql?, :==
RDL.type :Regexp, :fixed_encoding?, '() -> %bool'
RDL.type :Regexp, :hash, '() -> Integer'
RDL.type :Regexp, :inspect, '() -> String'
RDL.type :Regexp, :match, '(String, ?Integer) -> MatchData or nil'
RDL.type :Regexp, :named_captures, '() -> Hash<String, Array<Integer>>'
RDL.type :Regexp, :names, '() -> Array<String>'
RDL.type :Regexp, :options, '() -> Integer'
RDL.type :Regexp, :source, '() -> String'
RDL.type :Regexp, :to_s, '() -> String'
RDL.type :Regexp, :~, '() -> Integer or nil'
