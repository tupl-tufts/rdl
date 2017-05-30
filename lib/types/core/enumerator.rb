class Enumerator
  rdl_nowrap

  type_params [:t], :all?

  type 'self.new', '(?Fixnum) { (Array<u>) -> %any } -> Enumerator<u>'
  type 'self.new', '(?Proc) { (Array<u>) -> %any } -> Enumerator<u>' # TODO Proc
  # TODO: deprecated form of new
  type :each, '() { (t) -> %any } -> %any' # is there a better type?
  type :each, '() -> self'
  # TODO: args
  type :each_with_index, '() { (t, Fixnum) -> %any } -> %any' # TODO args
  type :each_with_index, '() -> Enumerator<[t, Fixnum]>' # TODO args
  type :each_with_object, '(u) { (t, u) -> %any } -> %any' # TODO args
  type :each_with_object, '(u) -> Enumerator<[t, u]>' # TODO args
  type :feed, '(t) -> nil'
  type :inspect, '() -> String'
  type :next, '() -> t'
  type :next_values, '() -> Array<t>'
  type :peek, '() -> t'
  type :peek_values, '() -> Array<t>'
  type :rewrind, '() -> self'
  type :size, '() -> Fixnum or Float or nil'
  rdl_alias :with_index, :each_with_index
  rdl_alias :with_object, :each_with_object
end
