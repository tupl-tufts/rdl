class Object
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
  # type :RUBY_PATCHLEVEL, Fixnum
  # type :RUBY_PLATFORM, 'String'
  # type :RUBY_RELEASE_DATE, 'String'
  # type :RUBY_REVISION, Fixnum
  # type :RUBY_VERSION, 'String'
  # type :STDERR, 'IO'
  # type :STDIN, 'IO'
  # type :STDOUT, 'IO'
  # type :TOPLEVEL_BINDING, 'Binding'
  # type :TRUE, '%true'

  type :!~, '(%any other) -> %bool', wrap: false
  type :<=>, '(%any other) -> Fixnum or nil', wrap: false
  type :===, '(%any other) -> %bool', wrap: false
  type :=~, '(%any other) -> nil', wrap: false
  type :class, '() -> Class', wrap: false
  type :clone, '() -> self', wrap: false
#  type :define_singleton_method, '(XXXX : *XXXX)') # TODO
  type :display, '(IO port) -> nil', wrap: false
  type :dup, '() -> self an_object', wrap: false
  type :enum_for, '(?Symbol method, *%any args) -> Enumerator<%any>', wrap: false
  type :enum_for, '(?Symbol method, *%any args) { (*%any args) -> %any } -> Enumerator<%any>', wrap: false
  type :eql?, '(%any other) -> %bool', wrap: false
#  type :extend, '(XXXX : *XXXX)') # TODO
  type :freeze, '() -> self', wrap: false
  type :frozen?, '() -> %bool', wrap: false
  type :hash, '() -> Fixnum', wrap: false
  type :inspect, '() -> String', wrap: false
  type :instance_of?, '(Class) -> %bool', wrap: false
  type :instance_variable_defined?, '(Symbol or String) -> %bool', wrap: false
  type :instance_variable_get, '(Symbol or String) -> %any', wrap: false
  type :instance_variable_set, '(Symbol or String, %any) -> %any', wrap: false # returns 2nd argument
  type :instance_variables, '() -> Array<Symbol>', wrap: false
  type :is_a?, '(Class or Module) -> %bool', wrap: false
  type :kind_of?, '(Class) -> %bool', wrap: false
  type :method, '(Symbol) -> Method', wrap: false
  type :methods, '(?%bool regular) -> Array<Symbol>', wrap: false
  type :nil?, '() -> %bool', wrap: false
  type :private_methods, '(?%bool all) -> Array<Symbol>', wrap: false
  type :protected_methods, '(?%bool all) -> Array<Symbol>', wrap: false
  type :public_method, '(Symbol) -> Method', wrap: false
  type :public_methods, '(?%bool all) -> Array<Symbol>', wrap: false
  type :public_send, '(Symbol or String, *%any args) -> %any', wrap: false
  type :remove_instance_variable, '(Symbol) -> %any', wrap: false
#  type :respond_to?, '(Symbol or String, ?%bool include_all) -> %bool'
  type :send, '(Symbol or String, *%any args) -> %any', wrap: false # Can't wrap this, used outside wrap switch
  type :singleton_class, '() -> Class', wrap: false
  type :singleton_method, '(Symbol) -> Method', wrap: false
  type :singleton_methods, '(?%bool all) -> Array<Symbol>', wrap: false
  type :taint, '() -> self', wrap: false
  type :tainted?, '() -> %bool', wrap: false
#  type :tap, '()') # TODO
  type :to_enum, '(?Symbol method, *%any args) -> Enumerator<%any>', wrap: false
  type :to_enum, '(?Symbol method, *%any args) {(*%any args) -> %any} -> Enumerator<%any>', wrap: false
# TODO: above alias for enum_for?
  type :to_s, '() -> String', wrap: false
  type :trust, '() -> self', wrap: false
  type :untaint, '() -> self', wrap: false
  type :untrust, '() -> self', wrap: false
  type :untrusted?, '() -> %bool', wrap: false
end
