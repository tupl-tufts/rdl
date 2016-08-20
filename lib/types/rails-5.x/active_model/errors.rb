class ActiveModel::Errors
  type :clear, '() -> %any'
  type :delete, '(%symstr) -> %any'
  type :[], '(%symstr) -> Array<String>'
  type :each, '() { (%symstr, String) -> %any } -> %any'
  type :size, '() -> %integer'
  rdl_alias :count, :size
  type :values, '() -> Array<String>'
  type :keys, '() -> Array<Symbol>'
  type :empty?, '() -> %bool'
  rdl_alias :blank?, :empty?
  type :hash, '(?%bool full_messages) -> Hash<Symbol, String>'
  type :add, '(%symstr, %symstr, Hash<Symbol, %any>) -> %any'
  type :add, '(%symstr, { () -> String }, Hash<Symbol, %any>) -> %any' # TODO: combine with prev with union once supported
end
