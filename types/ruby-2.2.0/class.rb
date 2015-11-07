class Class
   nowrap

   #  type :class_eval, '() {() -> %any} -> %any'
   #  type :method_defined?, '(String or Symbol) -> %bool'
   #  type :define_method, '(String or Symbol) {(*%any) -> %any} -> Proc'
   type :instance_methods, '(?%bool) -> Array<Symbol>'
   type :class, '() -> Class'
   type :superclass, '() -> Class'
   type :name, '() -> String'
end