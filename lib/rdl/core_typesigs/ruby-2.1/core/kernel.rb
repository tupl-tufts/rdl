require_relative '../../../lib/rdl.rb'

module Kernel
    extend RDL
    
    typesig :Array, "([to_ary : () -> Array<t>]) -> Array<t>", :vars => [:t]
    typesig :Array, "([to_a : () -> Array<t>]) -> Array<t>", :vars => [:t]
    typesig :Complex, "(x : Numeric, y : Numeric) -> Complex"
    typesig :Complex, "(x : String) -> Complex"
    typesig :Float, "(x : Numeric) -> Float"
    typesig :Float, "(x : [to_f : () -> Float]) -> Float"
    typesig :Hash, "(x : [to_hash : () -> Hash<k,v>]) -> Hash<k,v>", :vars => [:k, :v]
    typesig :Hash, "(x : nil) -> Hash<k,v>", :vars => [:k, :v]
    #  typesig :Hash, "(x : []) -> Hash<k,v>", :vars => [:k, :v] # TODO
    typesig :Integer, "(arg : Numeric, base : ?Fixnum) -> Integer"
    typesig :Integer, "(arg : String, base : ?Fixnum) -> Integer"
    typesig :Integer, "(arg : [to_int : () -> Integer], base : ?Fixnum) -> Integer"
    typesig :Integer, "(arg : [to_i : () -> Integer], base : ?Fixnum) -> Integer"
    typesig :Rational, "(x : Numeric, y : Numeric) -> Rational"
    typesig :Rational, "(x : String) -> Rational"
    typesig :String, "(arg : [to_s : () -> String]) -> String"
    typesig :__callee__, "() -> Symbol or nil"
    typesig :__dir__, "() -> String or nil"
    typesig :__method__, "() -> Symbol or nil"
    typesig :`, "(String) -> String"
    typesig :abort, "(msg : ?String) -> %any"
    typesig :at_exit, "() { () -> %any} -> Proc" # TODO: Fix proc
    typesig :autoload, "(modue : String or Symbol, filename : String) -> nil"
    typesig :autoload?, "(name : Symbol or String) -> String or nil"
    typesig :binding, "() -> Binding"
    typesig :block_given?, "() -> %bool"
    typesig :caller, "(start : ?Fixnum, length : ?Fixnum) -> Array<String> or nil"
    typesig :caller, "(Range) -> Array<String> or nil"
    typesig :caller_locations, "(start : ?Fixnum, length : ?Fixnum) -> Array<String> or nil"
    typesig :caller_locations, "(Range) -> Array<String> or nil"
    #  typesig :catch) # TODO
    typesig :eval, "(String, ?Binding, filename : ?String, lineno : ?Fixnum) -> %any"
    #  typesig :exec) #TODO
    typesig :exit, "(status : Fixnum or %bool) -> %any"
    typesig :exit!, "(status : Fixnum or %bool) -> %any"
    typesig :fail, "() -> %any"
    typesig :fail, "(String or [exception : () -> String], ?String, ?Array<String>) -> %any"
    #  typesig :fork) #TODO
    typesig :format, "(format : String, args : *%any) -> String"
    typesig :gets, "(?String, ?Fixnum) -> String"
    typesig :global_variables, "() -> Array<Symbol>"
    typesig :iterator?, "() -> %bool"
    #  typesig :lambda" # TODO
    typesig :load, "(filename : String, ?%bool) -> %true"
    typesig :local_variables, "() -> Array<Symbol>"
    #  typesig :loop" #TODO
    typesig :open, "(path : String, mode : ?(String or Fixnum), perm : ?String) -> IO or nil"
    typesig :open, "(path : String, mode : ?(String or Fixnum), perm : ?String) { (IO) -> %any) } -> %any" # TODO: returns block value
    typesig :p, "(*[inspect : () -> String]) -> nil"
    typesig :print, "(*[to_s : () -> String] -> nil"
    typesig :printf, "(?IO, String, *%any) -> nil"
    #  typesig :proc) # TODO
    typesig :putc, "(Fixnum) -> Fixnum"
    typesig :puts, "(*[to_s : () -> String] -> nil"
    typesig :raise, "() -> %any"
    typesig :raise, "(String or [exception : () -> String], ?String, ?Array<String>) -> %any"
    # TODO: above same as fail?
    typesig :rand, "(max : Fixnum or Range) -> Numeric"
    typesig :readline, "(?String, ?Fixnum) -> String"
    typesig :readlines, "(?String, ?Fixnum) -> Array<String>"
    typesig :require, "(name : String) -> %bool"
    typesig :require_relative, "(name : String) -> %bool"
    typesig :select,
    "(read : Array<IO>, write : ?Array<IO>, error : ?Array<IO>, timeout : ?Fixnum) -> Array<String>" # TODO: return type?
    #  typesig :set_trace_func #TODO
    typesig :sleep, "(duration : Numeric) -> Fixnum"
    #  typesig :spawn #TODO
    
    
    #rdl_alias :sprintf, :format # TODO: are they aliases?
    typesig :srand, "(number : Numeric) -> Numeric"
    typesig :syscall, "(num : Fixnum, args : *%any) -> %any" # TODO : ?
    #  typesig :system) # TODO
    typesig :test, "(cmd : String, file1 : String, file2 : ?String) -> %bool or Time" # TODO: better, dependent type?
    #  typesig :throw) # TODO
    #  typesig :trace_var) # TODO
    #  typesig :trap) # TODO
    #  typesig :untrace_var) # TODO
    typesig :warn, "(msg : *String) -> nil"
    
    def warn(msg)
        return nil
    end
    
end
