rdl_nowrap :Enumerable

module Enumerable
  type_params [:t], :all?
end

type :Enumerable, :all?, '() -> %bool'
type :Enumerable, :all?, '() { (t) -> %bool } -> %bool'
type :Enumerable, :any?, '() -> %bool'
type :Enumerable, :any?, '() { (t) -> %bool } -> %bool'
# type :Enumerable, :chunk, '(XXXX : *XXXX)' # TODO
type :Enumerable, :collect, '() { (t) -> u } -> Array<u>'
type :Enumerable, :collect, '() -> Enumerator<t>'
# type :Enumerable, :collect_concat # TODO
type :Enumerable, :count, '() -> Fixnum'
type :Enumerable, :count, '(%any) -> Fixnum'
type :Enumerable, :count, '() { (t) -> %bool } -> Fixnum'
type :Enumerable, :cycle, '(?Fixnum n) { (t) -> %any } -> nil'
type :Enumerable, :cycle, '(?Fixnum n) -> Enumerator<t>'
type :Enumerable, :detect, '(?Proc ifnone) { (t) -> %bool } -> t or nil' # TODO ifnone
type :Enumerable, :detect, '(?Proc ifnone) -> Enumerator<t>'
type :Enumerable, :drop, '(Fixnum n) -> Array<t>'
type :Enumerable, :drop_while, '() { (t) -> %bool } -> Array<t>'
type :Enumerable, :drop_while, '() -> Enumerator<t>'
type :Enumerable, :each_cons, '(Fixnum n) { (Array<t>) -> %any } -> nil'
type :Enumerable, :each_cons, '(Fixnum n) -> Enumerator<t>'
# type :Enumerable, :each_entry, '(XXXX : *XXXX)' # TODO
rdl_alias :Enumerable, :each_slice, :each_cons
type :Enumerable, :each_with_index, '() { (t, Fixnum) -> %any } -> Enumerable<t>' # args! note may not return self
type :Enumerable, :each_with_index, '() -> Enumerable<t>' # args! note may not return self
# type :Enumerable, :each_with_object, '(XXXX : XXXX)' #TODO
type :Enumerable, :entries, '() -> Array<t>' # TODO args?
rdl_alias :Enumerable, :find, :detect
type :Enumerable, :find_all, '() { (t) -> %bool } -> Array<t>'
type :Enumerable, :find_all, '() -> Enumerator<t>'
type :Enumerable, :find_index, '(%any value) -> Fixnum or nil'
type :Enumerable, :find_index, '() { (t) -> %bool } -> Fixnum or nil'
type :Enumerable, :find_index, '() -> Enumerator<t>'
type :Enumerable, :first, '() -> t or nil'
type :Enumerable, :first, '(Fixnum n) -> Array<t> or nil'
#  rdl_alias :Enumerable, :flat_map, :collect_concat
type :Enumerable, :grep, '(%any) -> Array<t>'
type :Enumerable, :grep, '(%any) { (t) -> u } -> Array<u>'
type :Enumerable, :group_by, '() { (t) -> u } -> Hash<u, Array<t>>'
type :Enumerable, :group_by, '() -> Enumerator<t>'
type :Enumerable, :include?, '(%any) -> %bool'
type :Enumerable, :inject, '(any initial, Symbol) -> %any' # can't tell initial, return type; not enough info in Symbol
type :Enumerable, :inject, '(Symbol) -> %any'
type :Enumerable, :inject, '(u initial) { (u, t) -> u } -> u'
type :Enumerable, :inject, '() { (t, t) -> t } -> t' # if initial not given, first element is initial
# type :Enumerable, :lazy # TODO
rdl_alias :Enumerable, :map, :collect
type :Enumerable, :max, '() -> t'
type :Enumerable, :max, '() { (t, t) -> Fixnum } -> t'
type :Enumerable, :max, '(Fixnum) -> Array<t>'
type :Enumerable, :max, '(Fixnum) { (t, t) -> Fixnum } -> Array<t>'
type :Enumerable, :max_by, '() -> Enumerator<t>'
type :Enumerable, :max_by, '() { (t, t) -> Fixnum } -> t'
type :Enumerable, :max_by, '(Fixnum) -> Enumerator<t>'
type :Enumerable, :max_by, '(Fixnum) { (t, t) -> Fixnum } -> Array<t>'
rdl_alias :Enumerable, :member?, :include?
type :Enumerable, :min, '() -> t'
type :Enumerable, :min, '() { (t, t) -> Fixnum } -> t'
type :Enumerable, :min, '(Fixnum) -> Array<t>'
type :Enumerable, :min, '(Fixnum) { (t, t) -> Fixnum } -> Array<t>'
type :Enumerable, :min_by, '() -> Enumerator<t>'
type :Enumerable, :min_by, '() { (t, t) -> Fixnum } -> t'
type :Enumerable, :min_by, '(Fixnum) -> Enumerator<t>'
type :Enumerable, :min_by, '(Fixnum) { (t, t) -> Fixnum } -> Array<t>'
type :Enumerable, :minmax, '() -> [t, t]'
type :Enumerable, :minmax, '() { (t, t) -> Fixnum } -> [t, t]'
type :Enumerable, :minmax_by, '() -> [t, t]'
type :Enumerable, :minmax_by, '() { (t, t) -> Fixnum } -> Enumerator<t>'
type :Enumerable, :none?, '() -> %bool'
type :Enumerable, :none?, '() { (t) -> %bool } -> %bool'
type :Enumerable, :one?, '() -> %bool'
type :Enumerable, :one?, '() { (t) -> %bool } -> %bool'
type :Enumerable, :partition, '() { (t) -> %bool } -> [Array<t>, Array<t>]'
type :Enumerable, :partition, '() -> Enumerator<t>'
rdl_alias :Enumerable, :reduce, :inject
type :Enumerable, :reject, '() { (t) -> %bool } -> Array<t>'
type :Enumerable, :reject, '() -> Enumerator<t>'
type :Enumerable, :reverse_each, '() { (t) -> %any } -> Enumerator<t>' # is that really the return type? TODO args
type :Enumerable, :reverse_each, '() -> Enumerator<t>' # TODO args
rdl_alias :Enumerable, :select, :find_all
# type :Enumerable, :slice_after, '(XXXX : *XXXX)' # TODO
# type :Enumerable, :slice_before, '(XXXX : *XXXX)' # TODO
# type :Enumerable, :slice_when, '()' # TODO
type :Enumerable, :sort, '() -> Array<t>'
type :Enumerable, :sort, '() { (t, t) -> Fixnum } -> Array<t>'
type :Enumerable, :sort_by, '() { (t) -> %any } -> Array<t>'
type :Enumerable, :sort_by, '() -> Enumerator<t>'
type :Enumerable, :take, '(Fixnum n) -> Array<t> or nil'
type :Enumerable, :take_while, '() { (t) -> %bool } -> Array<t>'
type :Enumerable, :take_while, '() -> Enumerator<t>'
rdl_alias :Enumerable, :to_a, :entries
type :Enumerable, :to_h, '() -> Hash<t, t>' # TODO args?
# type :Enumerable, :zip, '(XXXX : *XXXX)' # TODO
