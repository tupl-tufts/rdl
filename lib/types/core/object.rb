# Instead of rdl_nowrap, mark individual methods as not being wrapped so
# we can wrap stuff defined by the user at the top level (since those
# methods are added to Object).

# type :ARGF, ARGF
# type :ARGV, 'Array<String>'
# type :DATA, 'File'
# type :ENV, ENV
# type :FALSE, '%false'
# type :NIL, 'nil'
# type :RUBY_COPYRIGHT, 'String'
# type :RUBY_DESCRIPTION, 'String'
# type :RUBY_ENGINE, 'String'
# type :RUBY_PATCHLEVEL, Integer
# type :RUBY_PLATFORM, 'String'
# type :RUBY_RELEASE_DATE, 'String'
# type :RUBY_REVISION, Integer
# type :RUBY_VERSION, 'String'
# type :STDERR, 'IO'
# type :STDIN, 'IO'
# type :STDOUT, 'IO'
# type :TOPLEVEL_BINDING, 'Binding'
# type :TRUE, '%true'

type :Object, :!~, '(%any other) -> %bool', wrap: false
type :Object, :<=>, '(%any other) -> Integer or nil', wrap: false
type :Object, :===, '(%any other) -> %bool', wrap: false
type :Object, :=~, '(%any other) -> nil', wrap: false
type :Object, :class, '() -> Class', wrap: false
type :Object, :clone, '() -> self', wrap: false
# type :Object, :define_singleton_method, '(XXXX : *XXXX)') # TODO
type :Object, :display, '(IO port) -> nil', wrap: false
type :Object, :dup, '() -> self an_object', wrap: false
type :Object, :enum_for, '(?Symbol method, *%any args) -> Enumerator<%any>', wrap: false
type :Object, :enum_for, '(?Symbol method, *%any args) { (*%any args) -> %any } -> Enumerator<%any>', wrap: false
type :Object, :eql?, '(%any other) -> %bool', wrap: false
# type :Object, :extend, '(XXXX : *XXXX)') # TODO
type :Object, :freeze, '() -> self', wrap: false
type :Object, :frozen?, '() -> %bool', wrap: false
type :Object, :hash, '() -> Integer', wrap: false
type :Object, :inspect, '() -> String', wrap: false
type :Object, :instance_of?, '(Class) -> %bool', wrap: false
type :Object, :instance_variable_defined?, '(Symbol or String) -> %bool', wrap: false
type :Object, :instance_variable_get, '(Symbol or String) -> %any', wrap: false
type :Object, :instance_variable_set, '(Symbol or String, %any) -> %any', wrap: false # returns 2nd argument
type :Object, :instance_variables, '() -> Array<Symbol>', wrap: false
type :Object, :is_a?, '(Class or Module) -> %bool', wrap: false
type :Object, :kind_of?, '(Class) -> %bool', wrap: false
type :Object, :method, '(Symbol) -> Method', wrap: false
type :Object, :methods, '(?%bool regular) -> Array<Symbol>', wrap: false
type :Object, :nil?, '() -> %bool', wrap: false
type :Object, :private_methods, '(?%bool all) -> Array<Symbol>', wrap: false
type :Object, :protected_methods, '(?%bool all) -> Array<Symbol>', wrap: false
type :Object, :public_method, '(Symbol) -> Method', wrap: false
type :Object, :public_methods, '(?%bool all) -> Array<Symbol>', wrap: false
type :Object, :public_send, '(Symbol or String, *%any args) -> %any', wrap: false
type :Object, :remove_instance_variable, '(Symbol) -> %any', wrap: false
# type :Object, :respond_to?, '(Symbol or String, ?%bool include_all) -> %bool'
type :Object, :send, '(Symbol or String, *%any args) -> %any', wrap: false # Can't wrap this, used outside wrap switch
type :Object, :singleton_class, '() -> Class', wrap: false
type :Object, :singleton_method, '(Symbol) -> Method', wrap: false
type :Object, :singleton_methods, '(?%bool all) -> Array<Symbol>', wrap: false
type :Object, :taint, '() -> self', wrap: false
type :Object, :tainted?, '() -> %bool', wrap: false
# type :Object, :tap, '()') # TODO
type :Object, :to_enum, '(?Symbol method, *%any args) -> Enumerator<%any>', wrap: false
type :Object, :to_enum, '(?Symbol method, *%any args) {(*%any args) -> %any} -> Enumerator<%any>', wrap: false
# TODO: above alias for enum_for?
type :Object, :to_s, '() -> String', wrap: false
type :Object, :trust, '() -> self', wrap: false
type :Object, :untaint, '() -> self', wrap: false
type :Object, :untrust, '() -> self', wrap: false
type :Object, :untrusted?, '() -> %bool', wrap: false
