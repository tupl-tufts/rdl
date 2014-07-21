class Object
  # inherits from BasicObject.

  # includes Kernel - see there for methods.

  # Following Ruby documentation, Kernel's instance methods are listed
  # here, and Kernel's module methods are defined on Kernel.

  extend RDL

  typesig(:ARGF, ARGF)
  typesig(:ARGV, "Array<String>")
  typesig(:DATA, "File")
  typesig(:ENV, ENV)
  typesig(:FALSE, "%false")
  typesig(:NIL, "nil")
  typesig(:RUBY_COPYRIGHT, "String")
  typesig(:RUBY_DESCRIPTION, "String")
  typesig(:RUBY_ENGINE, "String")
  typesig(:RUBY_PATCHLEVEL, Fixnum)
  typesig(:RUBY_PLATFORM, "String")
  typesig(:RUBY_RELEASE_DATE, "String")
  typesig(:RUBY_REVISION, Fixnum)
  typesig(:RUBY_VERSION, "String")
  typesig(:STDERR, "IO");
  typesig(:STDIN, "IO");
  typesig(:STDOUT, "IO");
  typesig(:TOPLEVEL_BINDING, "Binding")
  typesig(:TRUE, "%true")

  typesig(:!~, "(other : %any) -> %bool")
  typesig(:<=>, "(other : %any) -> Fixnum or nil"), post { ret.nil? || ret.abs < 2 }
  typesig(:===, "(other : %any) -> %bool")
  typesig(:=~, "(other : %any) -> nil")
  typesig(:class, "() -> Class")
  typesig(:clone, "() -> self")
#  typesig(:define_singleton_method, "(XXXX : *XXXX)") # TODO
  typesig(:display, "(port : IO)")
  typesig(:dup, "() -> an_object : self")
  typesig(:enum_for, "(method : ?Symbol, args : *%any) -> Enumerator<%any>")
  typesig(:enum_for, "(method : ?Symbol, args : *%any) { (args : %any) -> %any } -> Enumerator<%any>")
  typesig(:eql?, "(other : %any) -> %bool")
#  typesig(:extend, "(XXXX : *XXXX)") # TODO
  typesig(:freeze, "() -> self")
  typesig(:frozen?, "() -> %bool")
  typesig(:hash, "() -> Fixnum")
  typesig(:inspect, "() -> STring")
  typesig(:instance_of?, "(Class) -> %bool")
  typesig(:instance_variable_defined?, "(Symbol or String) -> %bool")
  typesig(:instance_variable_get, "(Symbol or String) -> %any")
  typesig(:instance_variable_set, "(Symbol or String, %any) -> %any") # returns 2nd argument
  typesig(:instance_variables, "() -> Array<Symbol>")
  typesig(:is_a?, "(Class) -> %bool")
  typesig(:kind_of?, "(Class) -> %bool")
  typesig(:method, "(Symbol) -> Method")
  typesig(:methods, "(regular : ?%bool) -> Array<Symbol>")
  typesig(:nil?, "() -> %bool")
  typesig(:private_methods, "(all : ?%bool) -> Array<Symbol>")
  typesig(:protected_methods, "(all : ?%bool) -> Array<Symbol>")
  typesig(:public_method, "(Symbol) -> Method")
  typesig(:public_methods, "(all : ?%bool) -> Array<Symbol>")
  typesig(:public_send, "(Symbol or String, args : *%any) -> %any")
  typesig(:remove_instance_variable, "(Symbol) -> %any")
  typesig(:respond_to?, "(Symbol or String, include_all : ?%bool) -> %bool")
  typesig(:send, "(Symbol or String, args : *%any) -> %any")
  typesig(:singleton_class, "() -> Class")
  typesig(:singleton_method, "(Symbol) -> Method")
  typesig(:singleton_methods, "(all : ?%bool) -> Array<Symbol>")
  typesig(:taint, "() -> self")
  typesig(:tainted?, "() -> %bool")
#  typesig(:tap, "()") # TODO
  typesig(:to_enum, "(method : ?Symbol, args : *%any) -> Enumerator<%any>")
  typesig(:to_enum, "(method : ?Symbol, args : *%any) { (args : %any) -> %any } -> Enumerator<%any>")
# TODO: above alias for enum_for?
  typesig(:to_s, "() -> String")
  typesig(:trust, "() -> self")
  typesig(:untaint, "() -> self")
  typesig(:untrust, "() -> self")
  typesig(:untrusted?, "() -> %bool")
end
