class Range
  type_params([:t], nil) { |t| t.member?(self.begin) && t.member?(self.end) } # TODO: And instantiated if t instantiated

  # TODO: Parse error
#  type 'self.new', '(begin: [<=> : (u, u) -> Fixnum], end: [<=>, (u, u) -> Fixnum], exclude_end: ?%bool) -> Range<u>'
  type :==, '(%any obj) -> %bool'
  type :===, '(%any obj) -> %bool'
  type :begin, '() -> u'
  type :bsearch, '() { (u) -> %bool } -> u or nil'
  type :cover?, '(%any obj) -> %bool'
  type :each, '() { (u) -> %any } -> self'
  type :each, '() -> Enumerator<u>'
  type :end, '() -> u'
  rdl_alias :eql?, :==
  type :exclude_end?, '() -> %bool'
  type :first, '() -> u'
  type :first, '(Fixnum n) -> Array<u>'
  type :hash, '() -> Fixnum'
  type :include?, '(%any obj) -> %bool'
  type :inspect, '() -> String'
  type :last, '() -> u'
  type :last, '(Fixnum n) -> Array<u>'
  type :max, '() -> u'
  type :max, '() { (u, u) -> Fixnum } -> u'
  type :max, '(Fixnum n) -> Array<u>'
  type :max, '(Fixnum n) { (u, u) -> Fixnum } -> Array<u>'
  rdl_alias :member?, :include
  type :min, '() -> u'
  type :min, '() { (u, u) -> Fixnum } -> u'
  type :min, '(Fixnum n) -> Array<u>'
  type :min, '(Fixnum n) { (u, u) -> Fixnum } -> Array<u>'
  type :size, '() -> Fixnum or nil'
  type :step, '(?Fixnum n) { (u) -> %any } -> self'
  type :step, '(?Fixnum n) -> Enumerator<u>'
  type :to_s, '() -> String'
end