RDL.nowrap :Range

# Range is immutable, so covariant
RDL.type_params(:Range, [:t], nil, variance: [:+]) { |t| t.member?(self.begin) && t.member?(self.end) } # TODO: And instantiated if t instantiated

# TODO: Parse error
#RDL.type :Range, :Range, 'self.new', '(begin: [<=> : (u, u) -> Integer], end: [<=>, (u, u) -> Integer], exclude_end: ?%bool) -> Range<u>'
RDL.type :Range, :==, '(%any obj) -> %bool'
RDL.type :Range, :===, '(%any obj) -> %bool'
RDL.type :Range, :begin, '() -> t'
RDL.type :Range, :bsearch, '() { (t) -> %bool } -> u or nil'
RDL.type :Range, :cover?, '(%any obj) -> %bool'
RDL.type :Range, :each, '() { (t) -> %any } -> self'
RDL.type :Range, :each, '() -> Enumerator<t>'
RDL.type :Range, :end, '() -> t'
RDL.rdl_alias :Range, :eql?, :==
RDL.type :Range, :exclude_end?, '() -> %bool'
RDL.type :Range, :first, '() -> t'
RDL.type :Range, :first, '(Integer n) -> Array<t>'
RDL.type :Range, :hash, '() -> Integer'
RDL.type :Range, :include?, '(%any obj) -> %bool'
RDL.type :Range, :inspect, '() -> String'
RDL.type :Range, :last, '() -> t'
RDL.type :Range, :last, '(Integer n) -> Array<t>'
RDL.type :Range, :max, '() -> t'
RDL.type :Range, :max, '() { (t, t) -> Integer } -> t'
RDL.type :Range, :max, '(Integer n) -> Array<t>'
RDL.type :Range, :max, '(Integer n) { (t, t) -> Integer } -> Array<t>'
RDL.rdl_alias :Range, :member?, :include
RDL.type :Range, :min, '() -> t'
RDL.type :Range, :min, '() { (t, t) -> Integer } -> t'
RDL.type :Range, :min, '(Integer n) -> Array<t>'
RDL.type :Range, :min, '(Integer n) { (t, t) -> Integer } -> Array<t>'
RDL.type :Range, :size, '() -> Integer or nil'
RDL.type :Range, :step, '(?Integer n) { (t) -> %any } -> self'
RDL.type :Range, :step, '(?Integer n) -> Enumerator<t>'
RDL.type :Range, :to_s, '() -> String'
