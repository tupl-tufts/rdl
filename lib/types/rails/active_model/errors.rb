RDL.nowrap :'ActiveModel::Errors'
RDL.type :'ActiveModel::Errors', :clear, '() -> %any'
RDL.type :'ActiveModel::Errors', :delete, '(%symstr) -> %any'
RDL.type :'ActiveModel::Errors', :[], '(%symstr) -> Array<String>'
RDL.type :'ActiveModel::Errors', :each, '() { (%symstr, String) -> %any } -> %any'
RDL.type :'ActiveModel::Errors', :full_messages, '() -> Array<String>'
RDL.type :'ActiveModel::Errors', :size, '() -> Integer'
RDL.rdl_alias :'ActiveModel::Errors', :count, :size
RDL.type :'ActiveModel::Errors', :values, '() -> Array<String>'
RDL.type :'ActiveModel::Errors', :keys, '() -> Array<Symbol>'
RDL.type :'ActiveModel::Errors', :empty?, '() -> %bool'
RDL.rdl_alias :'ActiveModel::Errors', :blank?, :empty?
RDL.type :'ActiveModel::Errors', :hash, '(?%bool full_messages) -> Hash<Symbol, String>'
RDL.type :'ActiveModel::Errors', :add, '(%symstr, %symstr, ?Hash<Symbol, %any>) -> Array<String>'
RDL.type :'ActiveModel::Errors', :add, '(%symstr, { () -> String }, Hash<Symbol, %any>) -> Array<String>' # TODO: combine with prev with union once supported
