lass ActiveRecord::Relation
  rdl_nowrap
  type_params [:t], :all?

  type :[], '(Fixnum) -> t'
  type :empty?, '() -> %bool'
  type :first, '() -> t'
  type :length, '() -> Fixnum'
  type :sort, '() {(t, t) -> Fixnum} -> Array<t>'
  type :each, '() -> Enumerator<t>'
  type :each, '() { (t) -> %any } -> Array<t>'
end
