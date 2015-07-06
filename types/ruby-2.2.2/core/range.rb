class Range

  nowrap
  type_params([:t], nil) { |t| t.member?(self.begin) && t.member?(self.end) } # TODO: And instantiated if t instantiated

  # TODO: Parse error
#  type 'self.new', '(begin: [<=> : (u, u) -> Fixnum], end: [<=>, (u, u) -> Fixnum], exclude_end: ?%bool) -> Range<u>'
  type :==, '(obj: %any) -> %bool'
  type :===, '(obj: %any) -> %bool'
  type :begin, '() -> u'
  type :bsearch, '() { (u) -> %bool } -> u or nil'
  type :cover?, '(obj: %any) -> %bool'
  type :each, '() { (u) -> %any } -> self'
  type :each, '() -> Enumerator<u>'
  type :end, '() -> u'
  rdl_alias :eql?, :==
  type :exclude_end?, '() -> %bool'
  type :first, '() -> u'
  type :first, '(n: Fixnum) -> Array<u>'
  type :hash, '() -> Fixnum'
  type :include?, '(obj: %any) -> %bool'
  type :inspect, '() -> String'
  type :last, '() -> u'
  type :last, '(n: Fixnum) -> Array<u>'
  type :max, '() -> u'
  type :max, '() { (u, u) -> Fixnum } -> u'
  type :max, '(n: Fixnum) -> Array<u>'
  type :max, '(n: Fixnum) { (u, u) -> Fixnum } -> Array<u>'
  rdl_alias :member?, :include
  type :min, '() -> u'
  type :min, '() { (u, u) -> Fixnum } -> u'
  type :min, '(n: Fixnum) -> Array<u>'
  type :min, '(n: Fixnum) { (u, u) -> Fixnum } -> Array<u>'
  type :size, '() -> Fixnum or nil'
  type :step, '(n: ?Fixnum) { (u) -> %any } -> self'
  type :step, '(n: ?Fixnum) -> Enumerator<u>'
  type :to_s, '() -> String'
end