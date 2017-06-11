RDL.nowrap :Set

RDL.type_params :Set, [:t], :all?

RDL.type :Set, 'self.[]', '(*u) -> Set<u>'
RDL.type :Set, :initialize, '(?Enumerable<u> enum) -> self<u>'

RDL.rdl_alias :Set, :&, :intersection
RDL.type :Set, :+, '(Enumerable<t> enum) -> Set<t>'
RDL.rdl_alias :Set, :-, :difference
RDL.rdl_alias :Set, :<, :proper_subset?
RDL.rdl_alias :Set, :<<, :add
RDL.rdl_alias :Set, :<=, :subset?
RDL.rdl_alias :Set, :>, :proper_superset?
RDL.rdl_alias :Set, :>=, :superset?
RDL.type :Set, :^, '(Enumerable<t> enum) -> Set<t>'
RDL.type :Set, :add, '(t o) -> self'
RDL.type :Set, :add?, '(t o) -> self or nil'
RDL.type :Set, :classify, '() { (u) -> t } -> Hash<u, Set<t>>'
RDL.type :Set, :clear, '() -> self'
RDL.rdl_alias :Set, :collect!, :map
RDL.type :Set, :delete, '(t o) -> self'
RDL.type :Set, :delete?, '(t o) -> self or nil'
RDL.type :Set, :delete_if, '() { (t) -> %bool } -> self'
RDL.type :Set, :difference, '(Enumerable<t> enum) -> Set<t>'
RDL.type :Set, :disjoint?, '(Set<t> set) -> %bool'
#??RDL.type :Set, :divide, '() { BLOCK }'
RDL.type :Set, :each, '() { (t) -> %any } -> self'
RDL.type :Set, :each, '() -> Enumerator<t>'
RDL.type :Set, :empty?, '() -> %bool'
RDL.type :Set, :flatten!, '() -> self or nil'
RDL.post(:Set, :flatten!) { |r| (not r) || (r.none? { |x| x.is_a?(Set) }) }
RDL.type :Set, :flatten, '() -> Set'
RDL.post(:Set, :flatten) { |r| r.none? { |x| x.is_a?(Set) } }
# RDL.type :Set, :flatten_merge, '(set : XXXX, seen : ?XXXX)' #??
RDL.rdl_alias :Set, :include?, :member?
RDL.type :Set, :intersect?, '(Set<t> set) -> %bool'
RDL.type :Set, :intersection, '(Enumerable<t> enum) -> Set<t>'
RDL.type :Set, :keep_if, '() { (t) -> %bool } -> self'
RDL.rdl_alias :Set, :length, :size
RDL.type :Set, :map!, '() { (t) -> u } -> Set<u>' # !! Fix, actually changes RDL.type!
RDL.type :Set, :member?, '(t o) -> %bool'
RDL.type :Set, :merge, '(Enumerable<t> enum) -> self'
RDL.type :Set, :proper_subset?, '(Set<t> set) -> %bool'
RDL.type :Set, :proper_superset?, '(Set<t> set) -> %bool'
RDL.type :Set, :reject!, '() { (t) -> %bool } -> self or nil'
RDL.type :Set, :replace, '(Enumerable<u> enum) -> Set<u>' # !! Fix, actually changes RDL.type!
RDL.type :Set, :select!, '() { (t) -> %bool } -> self or nil'
RDL.type :Set, :size, '() -> Integer'
RDL.type :Set, :subset?, '(Set<t> set) -> %bool'
RDL.type :Set, :subtract, '(Enumerable<t> enum) -> self'
RDL.type :Set, :superset?, '(Set<t> set) -> %bool'
RDL.type :Set, :to_a, '() -> Array<t>'
#RDL.type :Set, :to_set, '(klass: ?Class, args : *XXXX) { BLOCK }' # ??
RDL.rdl_alias :Set, :|, :+
RDL.rdl_alias :Set, :union, :+
