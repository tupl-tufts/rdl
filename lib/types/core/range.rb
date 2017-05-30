rdl_nowrap :Range

class Range
  # Range is immutable, so covariant
  type_params([:t], nil, variance: [:+]) { |t| t.member?(self.begin) && t.member?(self.end) } # TODO: And instantiated if t instantiated
end

# TODO: Parse error
#type :Range, :Range, 'self.new', '(begin: [<=> : (u, u) -> Fixnum], end: [<=>, (u, u) -> Fixnum], exclude_end: ?%bool) -> Range<u>'
type :Range, :==, '(%any obj) -> %bool'
type :Range, :===, '(%any obj) -> %bool'
type :Range, :begin, '() -> t'
type :Range, :bsearch, '() { (t) -> %bool } -> u or nil'
type :Range, :cover?, '(%any obj) -> %bool'
type :Range, :each, '() { (t) -> %any } -> self'
type :Range, :each, '() -> Enumerator<t>'
type :Range, :end, '() -> t'
rdl_alias :Range, :eql?, :==
type :Range, :exclude_end?, '() -> %bool'
type :Range, :first, '() -> t'
type :Range, :first, '(Fixnum n) -> Array<t>'
type :Range, :hash, '() -> Fixnum'
type :Range, :include?, '(%any obj) -> %bool'
type :Range, :inspect, '() -> String'
type :Range, :last, '() -> t'
type :Range, :last, '(Fixnum n) -> Array<t>'
type :Range, :max, '() -> t'
type :Range, :max, '() { (t, t) -> Fixnum } -> t'
type :Range, :max, '(Fixnum n) -> Array<t>'
type :Range, :max, '(Fixnum n) { (t, t) -> Fixnum } -> Array<t>'
rdl_alias :Range, :member?, :include
type :Range, :min, '() -> t'
type :Range, :min, '() { (t, t) -> Fixnum } -> t'
type :Range, :min, '(Fixnum n) -> Array<t>'
type :Range, :min, '(Fixnum n) { (t, t) -> Fixnum } -> Array<t>'
type :Range, :size, '() -> Fixnum or nil'
type :Range, :step, '(?Fixnum n) { (t) -> %any } -> self'
type :Range, :step, '(?Fixnum n) -> Enumerator<t>'
type :Range, :to_s, '() -> String'
