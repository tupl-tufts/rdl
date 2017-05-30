rdl_nowrap :Enumerator

class Enumerator
  type_params [:t], :all?
end

type :Enumerator, 'self.new', '(?Fixnum) { (Array<u>) -> %any } -> Enumerator<u>'
type :Enumerator, 'self.new', '(?Proc) { (Array<u>) -> %any } -> Enumerator<u>' # TODO Proc
# TODO: deprecated form of new
type :Enumerator, :each, '() { (t) -> %any } -> %any' # is there a better type?
type :Enumerator, :each, '() -> self'
# TODO: args
type :Enumerator, :each_with_index, '() { (t, Fixnum) -> %any } -> %any' # TODO args
type :Enumerator, :each_with_index, '() -> Enumerator<[t, Fixnum]>' # TODO args
type :Enumerator, :each_with_object, '(u) { (t, u) -> %any } -> %any' # TODO args
type :Enumerator, :each_with_object, '(u) -> Enumerator<[t, u]>' # TODO args
type :Enumerator, :feed, '(t) -> nil'
type :Enumerator, :inspect, '() -> String'
type :Enumerator, :next, '() -> t'
type :Enumerator, :next_values, '() -> Array<t>'
type :Enumerator, :peek, '() -> t'
type :Enumerator, :peek_values, '() -> Array<t>'
type :Enumerator, :rewrind, '() -> self'
type :Enumerator, :size, '() -> Fixnum or Float or nil'
rdl_alias :Enumerator, :with_index, :each_with_index
rdl_alias :Enumerator, :with_object, :each_with_object
