RDL.nowrap :Enumerator

RDL.type_params :Enumerator, [:t], :all?

RDL.type :Enumerator, :initialize, '(?Integer) { (Array<u>) -> %any } -> self<u>'
RDL.type :Enumerator, :initialize, '(?Proc) { (Array<u>) -> %any } -> self<u>' # TODO Proc
# TODO: deprecated form of new
RDL.type :Enumerator, :each, '() { (t) -> %any } -> %any' # is there a better RDL.type?
RDL.type :Enumerator, :each, '() -> self'
# TODO: args
RDL.type :Enumerator, :each_with_index, '() { (t, Integer) -> %any } -> %any' # TODO args
RDL.type :Enumerator, :each_with_index, '() -> Enumerator<[t, Integer]>' # TODO args
RDL.type :Enumerator, :each_with_object, '(u) { (t, u) -> %any } -> %any' # TODO args
RDL.type :Enumerator, :each_with_object, '(u) -> Enumerator<[t, u]>' # TODO args
RDL.type :Enumerator, :feed, '(t) -> nil'
RDL.type :Enumerator, :inspect, '() -> String'
RDL.type :Enumerator, :next, '() -> t'
RDL.type :Enumerator, :next_values, '() -> Array<t>'
RDL.type :Enumerator, :peek, '() -> t'
RDL.type :Enumerator, :peek_values, '() -> Array<t>'
RDL.type :Enumerator, :rewrind, '() -> self'
RDL.type :Enumerator, :size, '() -> Integer or Float or nil'
RDL.rdl_alias :Enumerator, :with_index, :each_with_index
RDL.rdl_alias :Enumerator, :with_object, :each_with_object
