RDL.nowrap :Enumerable

RDL.type_params :Enumerable, [:t], :all?

RDL.type :Enumerable, :all?, '() -> %bool'
RDL.type :Enumerable, :all?, '() { (t) -> %bool } -> %bool'
RDL.type :Enumerable, :any?, '() -> %bool'
RDL.type :Enumerable, :any?, '() { (t) -> %bool } -> %bool'
# RDL.type :Enumerable, :chunk, '(XXXX : *XXXX)' # TODO
RDL.type :Enumerable, :collect, '() { (t) -> u } -> Array<u>'
RDL.type :Enumerable, :collect, '() -> Enumerator<t>'
# RDL.type :Enumerable, :collect_concat # TODO
RDL.type :Enumerable, :count, '() -> Integer'
RDL.type :Enumerable, :count, '(%any) -> Integer'
RDL.type :Enumerable, :count, '() { (t) -> %bool } -> Integer'
RDL.type :Enumerable, :cycle, '(?Integer n) { (t) -> %any } -> nil'
RDL.type :Enumerable, :cycle, '(?Integer n) -> Enumerator<t>'
RDL.type :Enumerable, :detect, '(?Proc ifnone) { (t) -> %bool } -> t or nil' # TODO ifnone
RDL.type :Enumerable, :detect, '(?Proc ifnone) -> Enumerator<t>'
RDL.type :Enumerable, :drop, '(Integer n) -> Array<t>'
RDL.type :Enumerable, :drop_while, '() { (t) -> %bool } -> Array<t>'
RDL.type :Enumerable, :drop_while, '() -> Enumerator<t>'
RDL.type :Enumerable, :each_cons, '(Integer n) { (Array<t>) -> %any } -> nil'
RDL.type :Enumerable, :each_cons, '(Integer n) -> Enumerator<t>'
# RDL.type :Enumerable, :each_entry, '(XXXX : *XXXX)' # TODO
RDL.rdl_alias :Enumerable, :each_slice, :each_cons
RDL.type :Enumerable, :each_with_index, '() { (t, Integer) -> %any } -> Enumerable<t>' # args! note may not return self
RDL.type :Enumerable, :each_with_index, '() -> Enumerable<t>' # args! note may not return self
# RDL.type :Enumerable, :each_with_object, '(XXXX : XXXX)' #TODO
RDL.type :Enumerable, :entries, '() -> Array<t>' # TODO args?
RDL.rdl_alias :Enumerable, :find, :detect
RDL.type :Enumerable, :find_all, '() { (t) -> %bool } -> Array<t>'
RDL.type :Enumerable, :find_all, '() -> Enumerator<t>'
RDL.type :Enumerable, :find_index, '(%any value) -> Integer or nil'
RDL.type :Enumerable, :find_index, '() { (t) -> %bool } -> Integer or nil'
RDL.type :Enumerable, :find_index, '() -> Enumerator<t>'
RDL.type :Enumerable, :first, '() -> t or nil'
RDL.type :Enumerable, :first, '(Integer n) -> Array<t> or nil'
#  RDL.rdl_alias :Enumerable, :flat_map, :collect_concat
RDL.type :Enumerable, :grep, '(%any) -> Array<t>'
RDL.type :Enumerable, :grep, '(%any) { (t) -> u } -> Array<u>'
RDL.type :Enumerable, :group_by, '() { (t) -> u } -> Hash<u, Array<t>>'
RDL.type :Enumerable, :group_by, '() -> Enumerator<t>'
RDL.type :Enumerable, :include?, '(%any) -> %bool'
RDL.type :Enumerable, :inject, '(any initial, Symbol) -> %any' # can't tell initial, return RDL.type; not enough info in Symbol
RDL.type :Enumerable, :inject, '(Symbol) -> %any'
RDL.type :Enumerable, :inject, '(u initial) { (u, t) -> u } -> u'
RDL.type :Enumerable, :inject, '() { (t, t) -> t } -> t' # if initial not given, first element is initial
# RDL.type :Enumerable, :lazy # TODO
RDL.rdl_alias :Enumerable, :map, :collect
RDL.type :Enumerable, :max, '() -> t'
RDL.type :Enumerable, :max, '() { (t, t) -> Integer } -> t'
RDL.type :Enumerable, :max, '(Integer) -> Array<t>'
RDL.type :Enumerable, :max, '(Integer) { (t, t) -> Integer } -> Array<t>'
RDL.type :Enumerable, :max_by, '() -> Enumerator<t>'
RDL.type :Enumerable, :max_by, '() { (t, t) -> Integer } -> t'
RDL.type :Enumerable, :max_by, '(Integer) -> Enumerator<t>'
RDL.type :Enumerable, :max_by, '(Integer) { (t, t) -> Integer } -> Array<t>'
RDL.rdl_alias :Enumerable, :member?, :include?
RDL.type :Enumerable, :min, '() -> t'
RDL.type :Enumerable, :min, '() { (t, t) -> Integer } -> t'
RDL.type :Enumerable, :min, '(Integer) -> Array<t>'
RDL.type :Enumerable, :min, '(Integer) { (t, t) -> Integer } -> Array<t>'
RDL.type :Enumerable, :min_by, '() -> Enumerator<t>'
RDL.type :Enumerable, :min_by, '() { (t, t) -> Integer } -> t'
RDL.type :Enumerable, :min_by, '(Integer) -> Enumerator<t>'
RDL.type :Enumerable, :min_by, '(Integer) { (t, t) -> Integer } -> Array<t>'
RDL.type :Enumerable, :minmax, '() -> [t, t]'
RDL.type :Enumerable, :minmax, '() { (t, t) -> Integer } -> [t, t]'
RDL.type :Enumerable, :minmax_by, '() -> [t, t]'
RDL.type :Enumerable, :minmax_by, '() { (t, t) -> Integer } -> Enumerator<t>'
RDL.type :Enumerable, :none?, '() -> %bool'
RDL.type :Enumerable, :none?, '() { (t) -> %bool } -> %bool'
RDL.type :Enumerable, :one?, '() -> %bool'
RDL.type :Enumerable, :one?, '() { (t) -> %bool } -> %bool'
RDL.type :Enumerable, :partition, '() { (t) -> %bool } -> [Array<t>, Array<t>]'
RDL.type :Enumerable, :partition, '() -> Enumerator<t>'
RDL.rdl_alias :Enumerable, :reduce, :inject
RDL.type :Enumerable, :reject, '() { (t) -> %bool } -> Array<t>'
RDL.type :Enumerable, :reject, '() -> Enumerator<t>'
RDL.type :Enumerable, :reverse_each, '() { (t) -> %any } -> Enumerator<t>' # is that really the return RDL.type? TODO args
RDL.type :Enumerable, :reverse_each, '() -> Enumerator<t>' # TODO args
RDL.rdl_alias :Enumerable, :select, :find_all
# RDL.type :Enumerable, :slice_after, '(XXXX : *XXXX)' # TODO
# RDL.type :Enumerable, :slice_before, '(XXXX : *XXXX)' # TODO
# RDL.type :Enumerable, :slice_when, '()' # TODO
RDL.type :Enumerable, :sort, '() -> Array<t>'
RDL.type :Enumerable, :sort, '() { (t, t) -> Integer } -> Array<t>'
RDL.type :Enumerable, :sort_by, '() { (t) -> %any } -> Array<t>'
RDL.type :Enumerable, :sort_by, '() -> Enumerator<t>'
RDL.type :Enumerable, :take, '(Integer n) -> Array<t> or nil'
RDL.type :Enumerable, :take_while, '() { (t) -> %bool } -> Array<t>'
RDL.type :Enumerable, :take_while, '() -> Enumerator<t>'
RDL.rdl_alias :Enumerable, :to_a, :entries
RDL.type :Enumerable, :to_h, '() -> Hash<t, t>' # TODO args?
# RDL.type :Enumerable, :zip, '(XXXX : *XXXX)' # TODO
