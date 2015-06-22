module Kernel
  type 'self.Array', '([to_ary : () -> Array<t>]) -> Array<t>'
  type 'self.Array', '([to_a : () -> Array<t>]) -> Array<t>'
  type 'self.Complex', '(x : Numeric, y : Numeric) -> Complex'
  type 'self.Complex', '(x : String) -> Complex'
  type 'self.Float', '(x : Numeric) -> Float'
  type 'self.Float', '(x : [to_f : () -> Float]) -> Float'
  type 'self.Hash, '(x : [to_hash : () -> Hash<k,v>]) -> Hash<k,v>'
  type 'self.Hash, '(x : nil) -> Hash<k,v>'
#  type 'self.Hash, '(x : []) -> Hash<k,v>'
  type 'self.Integer', '(arg : Numeric, base : ?Fixnum) -> Integer)'
  type 'self.Integer', '(arg : String, base : ?Fixnum) -> Integer)'
  type 'self.Integer', '(arg : [to_int : () -> Integer], base : ?Fixnum) -> Integer)'
  type 'self.Integer', '(arg : [to_i : () -> Integer], base : ?Fixnum) -> Integer)'
  type 'self.Rational', '(x : Numeric, y : Numeric) -> Rational'
  type 'self.Rational', '(x : String) -> Rational'
  type 'self.String', '(arg : [to_s : () -> String]) -> String'
  type 'self.__callee__', '() -> Symbol or nil'
  type 'self.__dir__', '() -> String or nil'
  type 'self.__method__', '() -> Symbol or nil'
  type 'self.`', '(String) -> String'
  type 'self.abort', '(msg : ?String) -> %any'
  type 'self.at_exit', '() { () -> %any} -> Proc' # TODO: Fix proc
  type 'self.autoload', '(modue : String or Symbol, filename : String) -> nil'
  type 'self.autoload?', '(name : Symbol or String) -> String or nil'
  type 'self.binding', '() -> Binding'
  type 'self.block_given?', '() -> %bool'
  type 'self.caller', '(start : ?Fixnum, length : ?Fixnum) -> Array<String> or nil'
  type 'self.caller', '(Range) -> Array<String> or nil'
  type 'self.caller_locations', '(start : ?Fixnum, length : ?Fixnum) -> Array<String> or nil'
  type 'self.caller_locations', '(Range) -> Array<String> or nil'
#  type 'self.catch' # TODO
  type 'self.eval', '(String, ?Binding, filename : ?String, lineno : ?Fixnum) -> %any'
#  type 'self.exec' #TODO
  type 'self.exit', '(status : Fixnum or %bool) -> %any'
  type 'self.exit!', '(status : Fixnum or %bool) -> %any'
  type 'self.fail', '() -> %any'
  type 'self.fail', '(String or [exception : () -> String], ?String, ?Array<String>) -> %any'
#  type 'self.fork' #TODO
  type 'self.format', '(format : String, args : *%any) -> String'
  type 'self.gets', '(?String, ?Fixnum) -> String'
  type 'self.global_variables', '() -> Array<Symbol>'
  type 'self.iterator?', '() -> %bool'
#  type 'self.lambda' # TODO
  type 'self.load', '(filename : String, ?%bool) -> %true'
  type 'self.local_variables', '() -> Array<Symbol>'
#  type 'self.loop' #TODO
  type 'self.open', '(path : String, mode : ?(String or Fixnum), perm : ?String) -> IO or nil'
  type 'self.open', '(path : String, mode : ?(String or Fixnum), perm : ?String) {(IO) -> %any)} -> %any' # TODO: returns block value
  type 'self.p', '(*[inspect : () -> String]) -> nil'
  type 'self.print', '(*[to_s : () -> String] -> nil'
  type 'self.printf', '(?IO, String, *%any) -> nil'
#  type 'self.proc' # TODO
  type 'self.putc', '(Fixnum) -> Fixnum'
  type 'self.puts', '(*[to_s : () -> String] -> nil'
  type 'self.raise', '() -> %any'
  type 'self.raise', '(String or [exception : () -> String], ?String, ?Array<String>) -> %any'
# TODO: above same as fail?
  type 'self.rand', '(max : Fixnum or Range) -> Numeric'
  type 'self.readline', '(?String, ?Fixnum) -> String'
  type 'self.readlines', '(?String, ?Fixnum) -> Array<String>'
  type 'self.require', '(name : String) -> %bool'
  type 'self.require_relative', '(name : String) -> %bool'
  type 'self.select',
          '(read : Array<IO>, write : ?Array<IO>, error : ?Array<IO>, timeout : ?Fixnum) -> Array<String>' # TODO: return type?
#  type 'self.set_trace_func' #TODO
  type 'self.sleep', '(duration : Numeric) -> Fixnum'
#  type 'self.spawn' #TODO
  rdl_alias :sprintf, :format # TODO: are they aliases?
  type 'self.srand', '(number : Numeric) -> Numeric'
  type 'self.syscall', '(num : Fixnum, args : *%any) -> %any' # TODO : ?
#  type 'self.system' # TODO
  type 'self.test', '(cmd : String, file1 : String, file2 : ?String) -> %bool or Time' # TODO: better, dependent type?
#  type 'self.throw' # TODO
#  type 'self.trace_var' # TODO
#  type 'self.trap' # TODO
#  type 'self.untrace_var' # TODO
  type 'self.warn', '(msg : *String) -> nil'
end
