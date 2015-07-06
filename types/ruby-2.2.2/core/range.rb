class Range

  nowrap
  type_params([:t], nil) { |t| t.member?(self.begin) && t.member?(self.end) } # TODO: And instantiated if t instantiated

  # TODO: Parse error
#  type 'self.new', '([<=> : (u, u) -> Fixnum], [<=>, (u, u) -> Fixnum], ?%bool) -> Range<u>'
  type :==, '(%any) -> %bool'
  type :===, '(%any) -> %bool'
  type :begin, '() -> u'
  type :bsearch, '() { (u) -> %bool } -> u or nil'
  type :cover?, '(%any) -> %bool'
  type :each, '() { (u) -> %any } -> self'
  type :each, '() -> Enumerator<u>'
  type :end, '() -> u'
  rdl_alias :eql?, :==
  type :exclude_end?, '() -> %bool'
  type :first, '() -> u'
  type :first, '(Fixnum) -> Array<u>'
  type :hash, '() -> Fixnum'
  type :include?, '(%any) -> %bool'
  type :inspect, '() -> String'
  type :last, '() -> u'
  type :last, '(Fixnum) -> Array<u>'
  type :max, '() -> u'
  type :max, '() { (u, u) -> Fixnum } -> u'
  type :max, '(Fixnum) -> Array<u>'
  type :max, '(Fixnum) { (u, u) -> Fixnum } -> Array<u>'
  rdl_alias :member?, :include
  type :min, '() -> u'
  type :min, '() { (u, u) -> Fixnum } -> u'
  type :min, '(Fixnum) -> Array<u>'
  type :min, '(Fixnum) { (u, u) -> Fixnum } -> Array<u>'
  type :size, '() -> Fixnum or nil'
  type :step, '(?Fixnum) { (u) -> %any } -> self'
  type :step, '(?Fixnum) -> Enumerator<u>'
  type :to_s, '() -> String'
end