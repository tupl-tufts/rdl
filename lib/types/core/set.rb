rdl_nowrap :Set

class Set
  type_params [:t], :all?
end

type :Set, 'self.[]', '(*u) -> Set<u>'
type :Set, 'self.new', '(?Enumerable<u> enum) -> Set<u>'

rdl_alias :Set, :&, :intersection
type :Set, :+, '(Enumerable<t> enum) -> Set<t>'
rdl_alias :Set, :-, :difference
rdl_alias :Set, :<, :proper_subset?
rdl_alias :Set, :<<, :add
rdl_alias :Set, :<=, :subset?
rdl_alias :Set, :>, :proper_superset?
rdl_alias :Set, :>=, :superset?
type :Set, :^, '(Enumerable<t> enum) -> Set<t>'
type :Set, :add, '(t o) -> self'
type :Set, :add?, '(t o) -> self or nil'
type :Set, :classify, '() { (u) -> t } -> Hash<u, Set<t>>'
type :Set, :clear, '() -> self'
rdl_alias :Set, :collect!, :map
type :Set, :delete, '(t o) -> self'
type :Set, :delete?, '(t o) -> self or nil'
type :Set, :delete_if, '() { (t) -> %bool } -> self'
type :Set, :difference, '(Enumerable<t> enum) -> Set<t>'
type :Set, :disjoint?, '(Set<t> set) -> %bool'
#??type :Set, :divide, '() { BLOCK }'
type :Set, :each, '() { (t) -> %any } -> self'
type :Set, :each, '() -> Enumerator<t>'
type :Set, :empty?, '() -> %bool'
type :Set, :flatten!, '() -> self or nil'
post(:Set, :flatten!) { |r| (not r) || (r.none? { |x| x.is_a?(Set) }) }
type :Set, :flatten, '() -> Set'
post(:Set, :flatten) { |r| r.none? { |x| x.is_a?(Set) } }
# type :Set, :flatten_merge, '(set : XXXX, seen : ?XXXX)' #??
rdl_alias :Set, :include?, :member?
type :Set, :intersect?, '(Set<t> set) -> %bool'
type :Set, :intersection, '(Enumerable<t> enum) -> Set<t>'
type :Set, :keep_if, '() { (t) -> %bool } -> self'
rdl_alias :Set, :length, :size
type :Set, :map!, '() { (t) -> u } -> Set<u>' # !! Fix, actually changes type!
type :Set, :member?, '(t o) -> %bool'
type :Set, :merge, '(Enumerable<t> enum) -> self'
type :Set, :proper_subset?, '(Set<t> set) -> %bool'
type :Set, :proper_superset?, '(Set<t> set) -> %bool'
type :Set, :reject!, '() { (t) -> %bool } -> self or nil'
type :Set, :replace, '(Enumerable<u> enum) -> Set<u>' # !! Fix, actually changes type!
type :Set, :select!, '() { (t) -> %bool } -> self or nil'
type :Set, :size, '() -> Integer'
type :Set, :subset?, '(Set<t> set) -> %bool'
type :Set, :subtract, '(Enumerable<t> enum) -> self'
type :Set, :superset?, '(Set<t> set) -> %bool'
type :Set, :to_a, '() -> Array<t>'
#type :Set, :to_set, '(klass: ?Class, args : *XXXX) { BLOCK }' # ??
rdl_alias :Set, :|, :+
rdl_alias :Set, :union, :+
