class Range
  rdl_nowrap

  # Range is immutable, so covariant
  type_params([:t], nil, variance: [:+]) { |t| t.member?(self.begin) && t.member?(self.end) } # TODO: And instantiated if t instantiated

  # TODO: Parse error
#  type 'self.new', '(begin: [<=> : (u, u) -> Fixnum], end: [<=>, (u, u) -> Fixnum], exclude_end: ?%bool) -> Range<u>'
  type :==, '(%any obj) -> %bool'
  type :===, '(%any obj) -> %bool'
  type :begin, '() -> t'
  type :bsearch, '() { (t) -> %bool } -> u or nil'
  type :cover?, '(%any obj) -> %bool'
  type :each, '() { (t) -> %any } -> self'
  type :each, '() -> Enumerator<t>'
  type :end, '() -> t'
  rdl_alias :eql?, :==
  type :exclude_end?, '() -> %bool'
  type :first, '() -> t'
  type :first, '(Fixnum n) -> Array<t>'
  type :hash, '() -> Fixnum'
  type :include?, '(%any obj) -> %bool'
  type :inspect, '() -> String'
  type :last, '() -> t'
  type :last, '(Fixnum n) -> Array<t>'
  type :max, '() -> t'
  type :max, '() { (t, t) -> Fixnum } -> t'
  type :max, '(Fixnum n) -> Array<t>'
  type :max, '(Fixnum n) { (t, t) -> Fixnum } -> Array<t>'
  rdl_alias :member?, :include
  type :min, '() -> t'
  type :min, '() { (t, t) -> Fixnum } -> t'
  type :min, '(Fixnum n) -> Array<t>'
  type :min, '(Fixnum n) { (t, t) -> Fixnum } -> Array<t>'
  type :size, '() -> Fixnum or nil'
  type :step, '(?Fixnum n) { (t) -> %any } -> self'
  type :step, '(?Fixnum n) -> Enumerator<t>'
  type :to_s, '() -> String'
end
