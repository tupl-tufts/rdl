module Kernel
  extend RDL

  typesig('self.Array', '([to_ary : () -> Array<t>]) -> Array<t>', :vars => [:t])
  typesig('self.Array', '([to_a : () -> Array<t>]) -> Array<t>', :vars => [:t])
  typesig('self.Complex', '(x : Numeric, y : Numeric) -> Complex')
  typesig('self.Complex', '(x : String) -> Complex')
  typesig('self.Float', '(x : Numeric) -> Float')
  typesig('self.Float', '(x : [to_f : () -> Float]) -> Float')
  typesig('self.Hash, '(x : [to_hash : () -> Hash<k,v>]) -> Hash<k,v>', :vars => [:k, :v])
  typesig('self.Hash, '(x : nil) -> Hash<k,v>', :vars => [:k, :v])
#  typesig('self.Hash, '(x : []) -> Hash<k,v>', :vars => [:k, :v]) # TODO
  typesig('self.Integer', '(arg : Numeric, base : ?Fixnum) -> Integer)')
  typesig('self.Integer', '(arg : String, base : ?Fixnum) -> Integer)')
  typesig('self.Integer', '(arg : [to_int : () -> Integer], base : ?Fixnum) -> Integer)')
  typesig('self.Integer', '(arg : [to_i : () -> Integer], base : ?Fixnum) -> Integer)')
  typesig('self.Rational', '(x : Numeric, y : Numeric) -> Rational')
  typesig('self.Rational', '(x : String) -> Rational')
  typesig('self.String', '(arg : [to_s : () -> String]) -> String')
  typesig('self.__callee__', '() -> Symbol or nil')
  typesig('self.__dir__', '() -> String or nil')
  typesig('self.__method__', '() -> Symbol or nil')
  typesig('self.`', '(String) -> String')
  typesig('self.abort', '(msg : ?String) -> %any))
  typesig('self.at_exit', '() { () -> %any} -> Proc') # TODO: Fix proc
  typesig('self.autoload', '(modue : String or Symbol, filename : String) -> nil')
  typesig('self.autoload?', '(name : Symbol or String) -> String or nil')
  typesig('self.binding', '() -> Binding')
  typesig('self.block_given?', '() -> %bool')
  typesig('self.caller', '(start : ?Fixnum, length : ?Fixnum) -> Array<String> or nil')
  typesig('self.caller', '(Range) -> Array<String> or nil')
  typesig('self.caller_locations', '(start : ?Fixnum, length : ?Fixnum) -> Array<String> or nil')
  typesig('self.caller_locations', '(Range) -> Array<String> or nil')
#  typesig('self.catch') # TODO
  typesig('self.eval', '(String, ?Binding, filename : ?String, lineno : ?Fixnum) -> %any')
#  typesig('self.exec') #TODO
  typesig('self.exit', '(status : Fixnum or %bool) -> %any')
  typesig('self.exit!', '(status : Fixnum or %bool) -> %any')
  typesig('self.fail', '() -> %any')
  typesig('self.fail', '(String or [exception : () -> String], ?String, ?Array<String>) -> %any')
#  typesig('self.fork') #TODO
  typesig('self.format', '(format : String, args : *%any) -> String')
  typesig('self.gets', '(?String, ?Fixnum) -> String')
  typesig('self.global_variables', '() -> Array<Symbol>')
  typesig('self.iterator?', '() -> %bool')
#  typesig('self.lambda') # TODO
  typesig('self.load', '(filename : String, ?%bool) -> %true')
  typesig('self.local_variables', '() -> Array<Symbol>')
#  typesig('self.loop') #TODO
  typesig('self.open', '(path : String, mode : ?(String or Fixnum), perm : ?String) -> IO or nil')
  typesig('self.open', '(path : String, mode : ?(String or Fixnum), perm : ?String) { (IO) -> %any) } -> %any') # TODO: returns block value
  typesig('self.p', '(*[inspect : () -> String]) -> nil')
  typesig('self.print', '(*[to_s : () -> String] -> nil')
  typesig('self.printf', '(?IO, String, *%any) -> nil')
#  typesig('self.proc') # TODO
  typesig('self.putc', '(Fixnum) -> Fixnum')
  typesig('self.puts', '(*[to_s : () -> String] -> nil')
  typesig('self.raise', '() -> %any')
  typesig('self.raise', '(String or [exception : () -> String], ?String, ?Array<String>) -> %any')
# TODO: above same as fail?
  typesig('self.rand', '(max : Fixnum or Range) -> Numeric')
  typesig('self.readline', '(?String, ?Fixnum) -> String')
  typesig('self.readlines', '(?String, ?Fixnum) -> Array<String>')
  typesig('self.require', '(name : String) -> %bool')
  typesig('self.require_relative', '(name : String) -> %bool')
  typesig('self.select',
          '(read : Array<IO>, write : ?Array<IO>, error : ?Array<IO>, timeout : ?Fixnum) -> Array<String>') # TODO: return type?
#  typesig('self.set_trace_func') #TODO
  typesig('self.sleep', '(duration : Numeric) -> Fixnum')
#  typesig('self.spawn') #TODO
  rdl_alias :sprintf, :format # TODO: are they aliases?
  typesig('self.srand', '(number : Numeric) -> Numeric')
  typesig('self.syscall', '(num : Fixnum, args : *%any) -> %any') # TODO : ?
#  typesig('self.system') # TODO
  typesig('self.test', '(cmd : String, file1 : String, file2 : ?String) -> %bool or Time') # TODO: better, dependent type?
#  typesig('self.throw') # TODO
#  typesig('self.trace_var') # TODO
#  typesig('self.trap') # TODO
#  typesig('self.untrace_var') # TODO
  typesig('self.warn', '(msg : *String) -> nil')
end
