class Set
  type_params [:t]
  def __rdl_member?(inst)
    t = inst[:t]
    all? { |x| t.member? x }
  end
  
  type 'self.[]', '(*u) -> Set<u>'
  type 'self.new', '(enum: ?Enumerable<u>) -> Set<u>'

  rdl_alias :&, :intersection
  type :+, '(enum: Enumerable<t>) -> Set<t>'
  rdl_alias :-, :difference
  rdl_alias :<, :proper_subset?
  rdl_alias :<<, :add
  rdl_alias :<=, :subset?
  rdl_alias :>, :proper_superset?
  rdl_alias :>=, :superset?
  type :^, '(enum : Enumerable<t>) -> Set<t>'
  type :add, '(o : t) -> self'
  type :add?, '(o : t) -> self or nil'
  type :classify, '() { (u) -> t } -> Hash<u, Set<t>>'
  type :clear, '() -> self'
  rdl_alias :collect!, :map
  type :delete, '(o: t) -> self'
  type :delete?, '(o: t) -> self or nil'
  type :delete_if, '() { (t) -> %bool } -> self'
  type :difference, '(enum: Enumerable<t>) -> Set<t>'
  type :disjoint?, '(set: Set<t>) -> %bool'
#??  type :divide, '() { BLOCK }'
  type :each, '() { (t) -> %any } -> self'
  type :each, '() -> Enumerator<t>'
  type :empty?, '() -> %bool'
#  type :flatten!, '()' # How do we write a contract for this?
#  type :flatten, '()' # How do we write a contract for this?
#  type :flatten_merge, '(set : XXXX, seen : ?XXXX)' #??
  rdl_alias :include?, :member?
  type :intersect?, '(set: Set<t>) -> %bool'
  type :intersection, '(enum: Enumerable<t>) -> Set<t>'
  type :keep_if, '() { (t) -> %bool } -> self'
  rdl_alias :length, :size
  type :map!, '() { (t) -> u } -> Set<u>' # !! Fix, actually changes type!
  type :member?, '(o: t) -> %bool'
  type :merge, '(enum: Enumerable<t>) -> self'
  type :proper_subset?, '(set: Set<t>) -> %bool'
  type :proper_superset?, '(set: Set<t>) -> %bool'
  type :reject!, '() { (t) -> %bool } -> self or nil'
  type :replace, '(enum: Enumerable<u>) -> Set<u>' # !! Fix, actually changes type!
  type :select!, '() { (t) -> %bool } -> self or nil'
  type :size, '() -> Fixnum'
  type :subset?, '(set: Set<t>) -> %bool'
  type :subtract, '(enum: Enumerable<t>) -> self'
  type :superset?, '(set: Set<t>) -> %bool'
  type :to_a, '() -> Array<t>'
#  type :to_set, '(klass: ?Class, args : *XXXX) { BLOCK }' # ??
  type :union, '(enum: Enumerable<t>) -> Set<t>'
  rdl_alias :|, :+
end
