rdl_nowrap :'ActiveRecord::Relation'

class ActiveRecord::Relation
  type_params [:t], :all?
end

type :'ActiveRecord::Relation', :[], '(Fixnum) -> t'
type :'ActiveRecord::Relation', :empty?, '() -> %bool'
type :'ActiveRecord::Relation', :first, '() -> t'
type :'ActiveRecord::Relation', :length, '() -> Fixnum'
type :'ActiveRecord::Relation', :sort, '() {(t, t) -> Fixnum} -> Array<t>'
type :'ActiveRecord::Relation', :each, '() -> Enumerator<t>'
type :'ActiveRecord::Relation', :each, '() { (t) -> %any } -> Array<t>'
