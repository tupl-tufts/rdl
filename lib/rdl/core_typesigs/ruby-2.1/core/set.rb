require 'rdl'
require 'set'

class Set
  extend RDL
  
  ## Public Class Methods
  typesig(:[], "(Array<t>) -> Set<t>", :vars => [:t])
#  typesig(:new, "(?Enumerable<t>) -> Set<t>", :vars => [:t])

  ## Public Instance Methods
  typesig(:+, "(Enumberable<t>) -> Set<t>", :vars => [:t])
  typesig(:-, "(Enumberable<t>) -> Set<t>", :vars => [:t])
  typesig(:<, "(Set) -> %bool")
  typesig(:<<, "(Object) -> Set")
  typesig(:<=, "(Set) -> %bool")
  typesig(:==, "(Object) -> %bool")
  typesig(:>, "(Set) -> %bool")
  typesig(:>=, "(Set) -> %bool")
  typesig(:^, "(Enumerable) -> Set")

  typesig(:add, "(Object) -> Set")
  typesig(:add?, "(Object) -> Set or nil")
  typesig(:classify, "() { (u) -> t } -> Hash<u, Set<t>>", :vars => [:u, :t])
  typesig(:clear, "() -> Set")
#  typesig(:collect!, " ") #???
  typesig(:delete, "(Object) -> Set")
  typesig(:delete?, "(Object) -> Set or nil")
  typesig(:delete_if, "() { (t) -> %bool } -> Set<t>", :vars => [:t])
  typesig(:difference, "(Enumberable<t>) -> Set<t>", :vars => [:t])
  typesig(:disjoint?, "(Set) -> %bool")
  typesig(:divide, "() {(t,?t) -> %any} -> Set<Set<t>>", :vars =>[:t])
  typesig(:each, "() {(t) -> %any} -> Set or Enumerator", :vars => [:t])
  typesig(:empty?, "() -> %bool")
  typesig(:flatten, "() -> Set")
  typesig(:flatten!, "() -> Set or nil")
  typesig(:include, "(Object) -> %bool")
  #typesig(:initialize_copy) Not sure what this does
  typesig(:inspect, "() -> String")
  typesig(:intersect?, "(Set) -> %bool")
  typesig(:delete_if, "() { (t) -> %bool } -> Set<t>", :vars => [:t])
  typesig(:length, "() -> Integer")
  typesig(:merge, "(Enumerable) -> Set")
  typesig(:proper_subset?, "(Set) -> %bool")
  typesig(:proper_superset?, "(Set) -> %bool")
  typesig(:reject!, "() { (t) -> %bool } -> Set<t> or nil", :vars => [:t])
  typesig(:replace, "(Enumerable) -> Set")
  typesig(:size, "() -> Integer")
  typesig(:subset?, "(Set) -> %bool")
  typesig(:subtract, "(Enumerable) -> Set")
  typesig(:superset?, "(Set) -> %bool")
  typesig(:to_a, "() -> Array")
  typesig(:union, "(Enumerable) -> Set")
  typesig(:|, "(Enumerable) -> Set")


  
end

