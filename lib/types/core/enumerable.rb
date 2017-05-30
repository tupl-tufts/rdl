module Enumerable
  rdl_nowrap

  type_params [:t], :all?

  type :all?, '() -> %bool'
  type :all?, '() { (t) -> %bool } -> %bool'
  type :any?, '() -> %bool'
  type :any?, '() { (t) -> %bool } -> %bool'
  #  type :chunk, '(XXXX : *XXXX)' # TODO
  type :collect, '() { (t) -> u } -> Array<u>'
  type :collect, '() -> Enumerator<t>'
#  type :collect_concat # TODO
  type :count, '() -> Fixnum'
  type :count, '(%any) -> Fixnum'
  type :count, '() { (t) -> %bool } -> Fixnum'
  type :cycle, '(?Fixnum n) { (t) -> %any } -> nil'
  type :cycle, '(?Fixnum n) -> Enumerator<t>'
  type :detect, '(?Proc ifnone) { (t) -> %bool } -> t or nil' # TODO ifnone
  type :detect, '(?Proc ifnone) -> Enumerator<t>'
  type :drop, '(Fixnum n) -> Array<t>'
  type :drop_while, '() { (t) -> %bool } -> Array<t>'
  type :drop_while, '() -> Enumerator<t>'
  type :each_cons, '(Fixnum n) { (Array<t>) -> %any } -> nil'
  type :each_cons, '(Fixnum n) -> Enumerator<t>'
#  type :each_entry, '(XXXX : *XXXX)' # TODO
  rdl_alias :each_slice, :each_cons
  type :each_with_index, '() { (t, Fixnum) -> %any } -> Enumerable<t>' # args! note may not return self
  type :each_with_index, '() -> Enumerable<t>' # args! note may not return self
#  type :each_with_object, '(XXXX : XXXX)' #TODO
  type :entries, '() -> Array<t>' # TODO args?
  rdl_alias :find, :detect
  type :find_all, '() { (t) -> %bool } -> Array<t>'
  type :find_all, '() -> Enumerator<t>'
  type :find_index, '(%any value) -> Fixnum or nil'
  type :find_index, '() { (t) -> %bool } -> Fixnum or nil'
  type :find_index, '() -> Enumerator<t>'
  type :first, '() -> t or nil'
  type :first, '(Fixnum n) -> Array<t> or nil'
#  rdl_alias :flat_map, :collect_concat
  type :grep, '(%any) -> Array<t>'
  type :grep, '(%any) { (t) -> u } -> Array<u>'
  type :group_by, '() { (t) -> u } -> Hash<u, Array<t>>'
  type :group_by, '() -> Enumerator<t>'
  type :include?, '(%any) -> %bool'
  type :inject, '(any initial, Symbol) -> %any' # can't tell initial, return type; not enough info in Symbol
  type :inject, '(Symbol) -> %any'
  type :inject, '(u initial) { (u, t) -> u } -> u'
  type :inject, '() { (t, t) -> t } -> t' # if initial not given, first element is initial
#  type :lazy # TODO
  rdl_alias :map, :collect
  type :max, '() -> t'
  type :max, '() { (t, t) -> Fixnum } -> t'
  type :max, '(Fixnum) -> Array<t>'
  type :max, '(Fixnum) { (t, t) -> Fixnum } -> Array<t>'
  type :max_by, '() -> Enumerator<t>'
  type :max_by, '() { (t, t) -> Fixnum } -> t'
  type :max_by, '(Fixnum) -> Enumerator<t>'
  type :max_by, '(Fixnum) { (t, t) -> Fixnum } -> Array<t>'
  rdl_alias :member?, :include?
  type :min, '() -> t'
  type :min, '() { (t, t) -> Fixnum } -> t'
  type :min, '(Fixnum) -> Array<t>'
  type :min, '(Fixnum) { (t, t) -> Fixnum } -> Array<t>'
  type :min_by, '() -> Enumerator<t>'
  type :min_by, '() { (t, t) -> Fixnum } -> t'
  type :min_by, '(Fixnum) -> Enumerator<t>'
  type :min_by, '(Fixnum) { (t, t) -> Fixnum } -> Array<t>'
  type :minmax, '() -> [t, t]'
  type :minmax, '() { (t, t) -> Fixnum } -> [t, t]'
  type :minmax_by, '() -> [t, t]'
  type :minmax_by, '() { (t, t) -> Fixnum } -> Enumerator<t>'
  type :none?, '() -> %bool'
  type :none?, '() { (t) -> %bool } -> %bool'
  type :one?, '() -> %bool'
  type :one?, '() { (t) -> %bool } -> %bool'
  type :partition, '() { (t) -> %bool } -> [Array<t>, Array<t>]'
  type :partition, '() -> Enumerator<t>'
  rdl_alias :reduce, :inject
  type :reject, '() { (t) -> %bool } -> Array<t>'
  type :reject, '() -> Enumerator<t>'
  type :reverse_each, '() { (t) -> %any } -> Enumerator<t>' # is that really the return type? TODO args
  type :reverse_each, '() -> Enumerator<t>' # TODO args
  rdl_alias :select, :find_all
#  type :slice_after, '(XXXX : *XXXX)' # TODO
#  type :slice_before, '(XXXX : *XXXX)' # TODO
#  type :slice_when, '()' # TODO
  type :sort, '() -> Array<t>'
  type :sort, '() { (t, t) -> Fixnum } -> Array<t>'
  type :sort_by, '() { (t) -> %any } -> Array<t>'
  type :sort_by, '() -> Enumerator<t>'
  type :take, '(Fixnum n) -> Array<t> or nil'
  type :take_while, '() { (t) -> %bool } -> Array<t>'
  type :take_while, '() -> Enumerator<t>'
  rdl_alias :to_a, :entries
  type :to_h, '() -> Hash<t, t>' # TODO args?
#  type :zip, '(XXXX : *XXXX)' # TODO
end
