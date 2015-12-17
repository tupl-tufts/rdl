class Class
  rdl_nowrap

  type :allocate, '() -> %any' # Instance of class self
  type :inherited, '(Class) -> %any'
  #type 'initialize', '() -> '
  #type 'new', '(*%any) -> %any' #Causes two other test cases to fail
  type :superclass, '() -> Class or nil'

  #  type :class_eval, '() {() -> %any} -> %any'
  #  type :method_defined?, '(String or Symbol) -> %bool'
  #  type :define_method, '(String or Symbol) {(*%any) -> %any} -> Proc'
  type :instance_methods, '(?%bool) -> Array<Symbol>'
  type :class, '() -> Class'
  type :superclass, '() -> Class'
  type :name, '() -> String'
end
