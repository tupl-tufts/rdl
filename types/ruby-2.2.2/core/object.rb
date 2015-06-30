class Object
  nowrap
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

  type :!~, '(other : %any) -> %bool'
  type :<=>, '(other : %any) -> Fixnum or nil'
  type :===, '(other : %any) -> %bool'
  type :=~, '(other : %any) -> nil'
  type :class, '() -> Class'
  type :clone, '() -> self'
#  type :define_singleton_method, '(XXXX : *XXXX)') # TODO
  type :display, '(port : IO) -> nil'
  type :dup, '() -> an_object : self'
  type :enum_for, '(method : ?Symbol, args : *%any) -> Enumerator<%any>'
  type :enum_for, '(method : ?Symbol, args : *%any) { (args : %any) -> %any } -> Enumerator<%any>'
  type :eql?, '(other : %any) -> %bool'
#  type :extend, '(XXXX : *XXXX)') # TODO
  type :freeze, '() -> self'
  type :frozen?, '() -> %bool'
  type :hash, '() -> Fixnum'
  type :inspect, '() -> String'
  type :instance_of?, '(Class) -> %bool'
  type :instance_variable_defined?, '(Symbol or String) -> %bool'
  type :instance_variable_get, '(Symbol or String) -> %any'
  type :instance_variable_set, '(Symbol or String, %any) -> %any' # returns 2nd argument
  type :instance_variables, '() -> Array<Symbol>'
  type :is_a?, '(Class) -> %bool'
  type :kind_of?, '(Class) -> %bool'
  type :method, '(Symbol) -> Method'
  type :methods, '(regular : ?%bool) -> Array<Symbol>'
  type :nil?, '() -> %bool'
  type :private_methods, '(all : ?%bool) -> Array<Symbol>'
  type :protected_methods, '(all : ?%bool) -> Array<Symbol>'
  type :public_method, '(Symbol) -> Method'
  type :public_methods, '(all : ?%bool) -> Array<Symbol>'
  type :public_send, '(Symbol or String, args : *%any) -> %any'
  type :remove_instance_variable, '(Symbol) -> %any'
  type :respond_to?, '(Symbol or String, include_all : ?%bool) -> %bool'
  type :send, '(Symbol or String, args : *%any) -> %any'
  type :singleton_class, '() -> Class'
  type :singleton_method, '(Symbol) -> Method'
  type :singleton_methods, '(all : ?%bool) -> Array<Symbol>'
  type :taint, '() -> self'
  type :tainted?, '() -> %bool'
#  type :tap, '()') # TODO
  type :to_enum, '(method : ?Symbol, args : *%any) -> Enumerator<%any>'
  type :to_enum, '(method : ?Symbol, args : *%any) {(args : %any) -> %any} -> Enumerator<%any>'
# TODO: above alias for enum_for?
  type :to_s, '() -> String'
  type :trust, '() -> self'
  type :untaint, '() -> self'
  type :untrust, '() -> self'
  type :untrusted?, '() -> %bool'
end
