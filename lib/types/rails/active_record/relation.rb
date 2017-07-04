RDL.nowrap :'ActiveRecord::Relation'

RDL.type_params :'ActiveRecord::Relation', [:t], :all?

RDL.type :'ActiveRecord::Relation', :[], '(Integer) -> t'
RDL.type :'ActiveRecord::Relation', :empty?, '() -> %bool'
RDL.type :'ActiveRecord::Relation', :first, '() -> t'
RDL.type :'ActiveRecord::Relation', :length, '() -> Integer'
RDL.type :'ActiveRecord::Relation', :sort, '() {(t, t) -> Integer} -> Array<t>'
RDL.type :'ActiveRecord::Relation', :each, '() -> Enumerator<t>'
RDL.type :'ActiveRecord::Relation', :each, '() { (t) -> %any } -> Array<t>'
