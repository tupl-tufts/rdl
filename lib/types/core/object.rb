# Instead of rdl_nowrap, mark individual methods as not being wrapped so
# we can wrap stuff defined by the user at the top level (since those
# methods are added to Object).

# RDL.type :ARGF, ARGF
# RDL.type :ARGV, 'Array<String>'
# RDL.type :DATA, 'File'
# RDL.type :ENV, ENV
# RDL.type :FALSE, '%false'
# RDL.type :NIL, 'nil'
# RDL.type :RUBY_COPYRIGHT, 'String'
# RDL.type :RUBY_DESCRIPTION, 'String'
# RDL.type :RUBY_ENGINE, 'String'
# RDL.type :RUBY_PATCHLEVEL, Integer
# RDL.type :RUBY_PLATFORM, 'String'
# RDL.type :RUBY_RELEASE_DATE, 'String'
# RDL.type :RUBY_REVISION, Integer
# RDL.type :RUBY_VERSION, 'String'
# RDL.type :STDERR, 'IO'
# RDL.type :STDIN, 'IO'
# RDL.type :STDOUT, 'IO'
# RDL.type :TOPLEVEL_BINDING, 'Binding'
# RDL.type :TRUE, '%true'

RDL.type :Object, :!~, '(%any other) -> %bool', wrap: false
RDL.type :Object, :<=>, '(%any other) -> Integer or nil', wrap: false
RDL.type :Object, :===, '(%any other) -> %bool', wrap: false
RDL.type :Object, :=~, '(%any other) -> nil', wrap: false
RDL.type :Object, :class, '() -> Class', wrap: false
RDL.type :Object, :clone, '() -> self', wrap: false
# RDL.type :Object, :define_singleton_method, '(XXXX : *XXXX)') # TODO
RDL.type :Object, :display, '(IO port) -> nil', wrap: false
RDL.type :Object, :dup, '() -> self an_object', wrap: false
RDL.type :Object, :enum_for, '(?Symbol method, *%any args) -> Enumerator<%any>', wrap: false
RDL.type :Object, :enum_for, '(?Symbol method, *%any args) { (*%any args) -> %any } -> Enumerator<%any>', wrap: false
RDL.type :Object, :eql?, '(%any other) -> %bool', wrap: false
# RDL.type :Object, :extend, '(XXXX : *XXXX)') # TODO
RDL.type :Object, :freeze, '() -> self', wrap: false
RDL.type :Object, :frozen?, '() -> %bool', wrap: false
RDL.type :Object, :hash, '() -> Integer', wrap: false
RDL.type :Object, :inspect, '() -> String', wrap: false
RDL.type :Object, :instance_of?, '(Class) -> %bool', wrap: false
RDL.type :Object, :instance_variable_defined?, '(Symbol or String) -> %bool', wrap: false
RDL.type :Object, :instance_variable_get, '(Symbol or String) -> %any', wrap: false
RDL.type :Object, :instance_variable_set, '(Symbol or String, %any) -> %any', wrap: false # returns 2nd argument
RDL.type :Object, :instance_variables, '() -> Array<Symbol>', wrap: false
RDL.type :Object, :is_a?, '(Class or Module) -> %bool', wrap: false
RDL.type :Object, :kind_of?, '(Class) -> %bool', wrap: false
RDL.type :Object, :method, '(Symbol) -> Method', wrap: false
RDL.type :Object, :methods, '(?%bool regular) -> Array<Symbol>', wrap: false
RDL.type :Object, :nil?, '() -> %bool', wrap: false
RDL.type :Object, :private_methods, '(?%bool all) -> Array<Symbol>', wrap: false
RDL.type :Object, :protected_methods, '(?%bool all) -> Array<Symbol>', wrap: false
RDL.type :Object, :public_method, '(Symbol) -> Method', wrap: false
RDL.type :Object, :public_methods, '(?%bool all) -> Array<Symbol>', wrap: false
RDL.type :Object, :public_send, '(Symbol or String, *%any args) -> %any', wrap: false
RDL.type :Object, :remove_instance_variable, '(Symbol) -> %any', wrap: false
# RDL.type :Object, :respond_to?, '(Symbol or String, ?%bool include_all) -> %bool'
RDL.type :Object, :send, '(Symbol or String, *%any args) -> %any', wrap: false # Can't wrap this, used outside wrap switch
RDL.type :Object, :singleton_class, '() -> Class', wrap: false
RDL.type :Object, :singleton_method, '(Symbol) -> Method', wrap: false
RDL.type :Object, :singleton_methods, '(?%bool all) -> Array<Symbol>', wrap: false
RDL.type :Object, :taint, '() -> self', wrap: false
RDL.type :Object, :tainted?, '() -> %bool', wrap: false
# RDL.type :Object, :tap, '()') # TODO
RDL.type :Object, :to_enum, '(?Symbol method, *%any args) -> Enumerator<%any>', wrap: false
RDL.type :Object, :to_enum, '(?Symbol method, *%any args) {(*%any args) -> %any} -> Enumerator<%any>', wrap: false
# TODO: above alias for enum_for?
RDL.type :Object, :to_s, '() -> String', wrap: false
RDL.type :Object, :trust, '() -> self', wrap: false
RDL.type :Object, :untaint, '() -> self', wrap: false
RDL.type :Object, :untrust, '() -> self', wrap: false
RDL.type :Object, :untrusted?, '() -> %bool', wrap: false
