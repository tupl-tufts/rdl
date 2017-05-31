rdl_nowrap :Range

class Range
  # Range is immutable, so covariant
  type_params([:t], nil, variance: [:+]) { |t| t.member?(self.begin) && t.member?(self.end) } # TODO: And instantiated if t instantiated
end

# TODO: Parse error
#type :Range, :Range, 'self.new', '(begin: [<=> : (u, u) -> Integer], end: [<=>, (u, u) -> Integer], exclude_end: ?%bool) -> Range<u>'
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
type :Range, :first, '(Integer n) -> Array<t>'
type :Range, :hash, '() -> Integer'
type :Range, :include?, '(%any obj) -> %bool'
type :Range, :inspect, '() -> String'
type :Range, :last, '() -> t'
type :Range, :last, '(Integer n) -> Array<t>'
type :Range, :max, '() -> t'
type :Range, :max, '() { (t, t) -> Integer } -> t'
type :Range, :max, '(Integer n) -> Array<t>'
type :Range, :max, '(Integer n) { (t, t) -> Integer } -> Array<t>'
rdl_alias :Range, :member?, :include
type :Range, :min, '() -> t'
type :Range, :min, '() { (t, t) -> Integer } -> t'
type :Range, :min, '(Integer n) -> Array<t>'
type :Range, :min, '(Integer n) { (t, t) -> Integer } -> Array<t>'
type :Range, :size, '() -> Integer or nil'
type :Range, :step, '(?Integer n) { (t) -> %any } -> self'
type :Range, :step, '(?Integer n) -> Enumerator<t>'
type :Range, :to_s, '() -> String'
