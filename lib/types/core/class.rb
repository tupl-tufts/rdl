rdl_nowrap :Class

type :Class, :allocate, '() -> %any' # Instance of class self
type :Class, :inherited, '(Class) -> %any'
#type :Class, 'initialize', '() -> '
#type :Class, 'new', '(*%any) -> %any' #Causes two other test cases to fail
type :Class, :superclass, '() -> Class or nil'

#type :Class, :class_eval, '() {() -> %any} -> %any'
#type :Class, :method_defined?, '(String or Symbol) -> %bool'
#type :Class, :define_method, '(String or Symbol) {(*%any) -> %any} -> Proc'
type :Class, :instance_methods, '(?%bool) -> Array<Symbol>'
type :Class, :class, '() -> Class'
type :Class, :superclass, '() -> Class'
type :Class, :name, '() -> String'
