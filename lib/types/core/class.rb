RDL.nowrap :Class

RDL.type :Class, :allocate, '() -> ``RDL::Type::NominalType.new(trec.val)``' # Instance of class self
RDL.type :Class, :inherited, '(Class) -> %any'
#RDL.type :Class, 'initialize', '() -> '
#RDL.type :Class, 'new', '(*%any) -> %any' #Causes two other test cases to fail
RDL.type :Class, :superclass, '() -> Class or nil'

#RDL.type :Class, :class_eval, '() {() -> %any} -> %any'
#RDL.type :Class, :method_defined?, '(String or Symbol) -> %bool'
#RDL.type :Class, :define_method, '(String or Symbol) {(*%any) -> %any} -> Proc'
RDL.type :Class, :instance_methods, '(?%bool) -> Array<Symbol>'
RDL.type :Class, :class, '() -> Class'
RDL.type :Class, :superclass, '() -> Class'
RDL.type :Class, :name, '() -> String'
RDL.type :Class, :==, '(%any) -> %bool'
RDL.type :Class, :===, '(%any) -> %bool'
