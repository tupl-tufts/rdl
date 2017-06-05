rdl_nowrap :'ActiveModel::Errors'
type :'ActiveModel::Errors', :clear, '() -> %any'
type :'ActiveModel::Errors', :delete, '(%symstr) -> %any'
type :'ActiveModel::Errors', :[], '(%symstr) -> Array<String>'
type :'ActiveModel::Errors', :each, '() { (%symstr, String) -> %any } -> %any'
type :'ActiveModel::Errors', :size, '() -> Integer'
rdl_alias :'ActiveModel::Errors', :count, :size
type :'ActiveModel::Errors', :values, '() -> Array<String>'
type :'ActiveModel::Errors', :keys, '() -> Array<Symbol>'
type :'ActiveModel::Errors', :empty?, '() -> %bool'
rdl_alias :'ActiveModel::Errors', :blank?, :empty?
type :'ActiveModel::Errors', :hash, '(?%bool full_messages) -> Hash<Symbol, String>'
type :'ActiveModel::Errors', :add, '(%symstr, %symstr, Hash<Symbol, %any>) -> %any'
type :'ActiveModel::Errors', :add, '(%symstr, { () -> String }, Hash<Symbol, %any>) -> %any' # TODO: combine with prev with union once supported
