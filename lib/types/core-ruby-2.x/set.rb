class Set
  rdl_nowrap

  type_params [:t], :all?

  type 'self.[]', '(*u) -> Set<u>'
  type 'self.new', '(?Enumerable<u> enum) -> Set<u>'

  rdl_alias :&, :intersection
  type :+, '(Enumerable<t> enum) -> Set<t>'
  rdl_alias :-, :difference
  rdl_alias :<, :proper_subset?
  rdl_alias :<<, :add
  rdl_alias :<=, :subset?
  rdl_alias :>, :proper_superset?
  rdl_alias :>=, :superset?
  type :^, '(Enumerable<t> enum) -> Set<t>'
  type :add, '(t o) -> self'
  type :add?, '(t o) -> self or nil'
  type :classify, '() { (u) -> t } -> Hash<u, Set<t>>'
  type :clear, '() -> self'
  rdl_alias :collect!, :map
  type :delete, '(t o) -> self'
  type :delete?, '(t o) -> self or nil'
  type :delete_if, '() { (t) -> %bool } -> self'
  type :difference, '(Enumerable<t> enum) -> Set<t>'
  type :disjoint?, '(Set<t> set) -> %bool'
#??  type :divide, '() { BLOCK }'
  type :each, '() { (t) -> %any } -> self'
  type :each, '() -> Enumerator<t>'
  type :empty?, '() -> %bool'
  type :flatten!, '() -> self or nil'
  post(:flatten!) { |r| (not r) || (r.none? { |x| x.is_a?(Set) }) }
  type :flatten, '() -> Set'
  post(:flatten) { |r| r.none? { |x| x.is_a?(Set) } }
  #  type :flatten_merge, '(set : XXXX, seen : ?XXXX)' #??
  rdl_alias :include?, :member?
  type :intersect?, '(Set<t> set) -> %bool'
  type :intersection, '(Enumerable<t> enum) -> Set<t>'
  type :keep_if, '() { (t) -> %bool } -> self'
  rdl_alias :length, :size
  type :map!, '() { (t) -> u } -> Set<u>' # !! Fix, actually changes type!
  type :member?, '(t o) -> %bool'
  type :merge, '(Enumerable<t> enum) -> self'
  type :proper_subset?, '(Set<t> set) -> %bool'
  type :proper_superset?, '(Set<t> set) -> %bool'
  type :reject!, '() { (t) -> %bool } -> self or nil'
  type :replace, '(Enumerable<u> enum) -> Set<u>' # !! Fix, actually changes type!
  type :select!, '() { (t) -> %bool } -> self or nil'
  type :size, '() -> Fixnum'
  type :subset?, '(Set<t> set) -> %bool'
  type :subtract, '(Enumerable<t> enum) -> self'
  type :superset?, '(Set<t> set) -> %bool'
  type :to_a, '() -> Array<t>'
#  type :to_set, '(klass: ?Class, args : *XXXX) { BLOCK }' # ??
  rdl_alias :|, :+
  rdl_alias :union, :+
end
