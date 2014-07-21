require 'rdl'

class Set
  extend RDL
  type_params [:t, :each]

# CLASS METHOD: typesig(:[], "(Array<t>) -> Set<t>) # note this t is not the t above!
# CLASS METHOD: typesig(:new, "(enum : ?Enumerable<t>) -> Set<t>") # same note
  rdl_alias :&, :intersection
  typesig(:+, "(enum : Enumerable<t>) -> Set<t>")
  rdl_alias :-, :difference
  rdl_alias :<, :proper_subset?
  rdl_alias :<<, :add
  rdl_alias :<=, :subset?
  rdl_alias :>, :proper_superset?
  rdl_alias :>=, :superset?
  typesig(:^, "(enum : Enumerable<t>) -> Set<t>")
  typesig(:add, "(o : t) -> self")
  typesig(:add?, "(o : t) -> self or nil")
  typesig(:classify, "() { (u) -> t } -> Hash<u, Set<t>>", :vars => [:u])
  typesig(:clear, "() -> self")
  rdl_alias :collect!, :map
  typesig(:delete, "(o : t) -> self")
  typesig(:delete?, "(o : t) -> self or nil")
  typesig(:delete_if, "() { (t) -> %bool } -> self")
  typesig(:difference, "(enum : Enumerable<t>) -> Set<t>")
  typesig(:disjoint?, "(set : Set<t>) -> %bool")
#??  typesig(:divide, "() { BLOCK }")
  typesig(:each, "() { (t) -> %any } -> self")
  typesig(:each, "() -> Enumerator<t>")
  typesig(:empty?, "() -> %bool")
  typesig(:eql?, "(o : XXXX)")
#  typesig(:flatten!, "()") # How do we write a contract for this?
#  typesig(:flatten, "()") # How do we write a contract for this?
#  typesig(:flatten_merge, "(set : XXXX, seen : ?XXXX)") #??
  rdl_alias :include?, :member?
  typesig(:intersect?, "(set : Set<t>) -> %bool")
  typesig(:intersection, "(enum : Enumerable<t>) -> Set<t>")
  typesig(:keep_if, "() { (t) -> %bool) } -> self")
  rdl_alias :length, :size
  typesig(:map!, "() { (t) -> u } -> Set<u>") # !! Fix, actually changes type!
  typesig(:member?, "(o : t) -> %bool")
  typesig(:merge, "(enum : Enumerable<t>) -> self")
  typesig(:proper_subset?, "(set : Set<t>) -> %bool")
  typesig(:proper_superset?, "(set : Set<t>) -> %bool")
  typesig(:reject!, "() { (t) -> %bool } -> self or nil")
  typesig(:replace, "(enum : Enumerable<u>) -> Set<u>") # !! Fix, actually changes type!
  typesig(:select!, "() { (t) -> %bool) } -> self or nil")
  typesig(:size, "() -> Fixnum")
  typesig(:subset?, "(set : Set<t>) -> %bool")
  typesig(:subtract, "(enum : Enumerable<t>) -> self")
  typesig(:superset?, "(set : Set<t>) -> %bool")
  typesig(:to_a, "() -> Array<t>")
  typesig(:to_set, "(klass : ?Class, args : *XXXX) { BLOCK }") # ??
  typesig(:union, "(enum : Enumerable<t>) -> Set<t>")
  rdl_alias :|, :+
end
