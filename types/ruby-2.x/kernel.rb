module Kernel
  rdl_nowrap

  #  type 'self.Array', '([to_ary: () -> Array<t>]) -> Array<t>'
#  type 'self.Array', '([to_a: () -> Array<t>]) -> Array<t>'
  type 'self.Complex', '(Numeric x, Numeric y) -> Complex'
  type 'self.Complex', '(String x) -> Complex'
  type 'self.Float', '(Numeric x) -> Float'
#  type 'self.Float', '(x : [to_f : () -> Float]) -> Float'
#  type 'self.Hash', '(x : [to_hash : () -> Hash<k,v>]) -> Hash<k,v>'
  type 'self.Hash', '(nil x) -> Hash<k,v>'
#  type 'self.Hash, '(x : []) -> Hash<k,v>'
  type 'self.Integer', '(Numeric or String arg, ?Fixnum base) -> Integer'
#  type 'self.Integer', '(arg : [to_int : () -> Integer], base : ?Fixnum) -> Integer'
#  type 'self.Integer', '(arg : [to_i : () -> Integer], base : ?Fixnum) -> Integer'
  type 'self.Rational', '(Numeric x, Numeric y) -> Rational'
  type 'self.Rational', '(String x) -> Rational'
#  type 'self.String', '(arg : [to_s : () -> String]) -> String'
  type 'self.__callee__', '() -> Symbol or nil'
  type 'self.__dir__', '() -> String or nil'
  type 'self.__method__', '() -> Symbol or nil'
  type 'self.`', '(String) -> String'
  type 'self.abort', '(?String msg) -> %bot'
  type 'self.at_exit', '() { () -> %any} -> Proc' # TODO: Fix proc
  type 'self.autoload', '(String or Symbol module, String filename) -> nil'
  type 'self.autoload?', '(Symbol or String name) -> String or nil'
  type 'self.binding', '() -> Binding'
  type 'self.block_given?', '() -> %bool'
  type 'self.caller', '(?Fixnum start, ?Fixnum length) -> Array<String> or nil'
  type 'self.caller', '(Range) -> Array<String> or nil'
  type 'self.caller_locations', '(?Fixnum start, ?Fixnum length) -> Array<String> or nil'
  type 'self.caller_locations', '(Range) -> Array<String> or nil'
#  type 'self.catch' # TODO
  type 'self.eval', '(String, ?Binding, ?String filename, ?Fixnum lineno) -> %any'
#  type 'self.exec' #TODO
  type 'self.exit', '(Fixnum or %bool status) -> %bot'
  type 'self.exit!', '(Fixnum or %bool status) -> %bot'
  type 'self.fail', '() -> %bot'
  type 'self.fail', '(String) -> %bot'
  type 'self.fail', '(Class, Array<String>) -> %bot'
  type 'self.fail', '(Class, String, Array<String>) -> %bot'
  #  type 'self.fail', '(String or [exception : () -> String], ?String, ?Array<String>) -> %any'
#  type 'self.fork' #TODO
  type 'self.format', '(String format, *%any args) -> String'
  type 'self.gets', '(?String, ?Fixnum) -> String'
  type 'self.global_variables', '() -> Array<Symbol>'
  type 'self.iterator?', '() -> %bool'
#  type 'self.lambda' # TODO
  type 'self.load', '(String filename, ?%bool) -> %bool'
  type 'self.local_variables', '() -> Array<Symbol>'
#  type 'self.loop' #TODO
  type 'self.open', '(String path, ?(String or Fixnum) mode, ?String perm) -> IO or nil'
#  type 'self.open', '(String path, mode : ?String, perm: ?String) {(IO) -> %any)} -> %any' # TODO: returns block value
#  type 'self.open', '(String path, mode : ?Fixnum, perm: ?String) {(IO) -> %any)} -> %any' # TODO: returns block value
#  type 'self.p', '(*[inspect : () -> String]) -> nil'
#  type 'self.print', '(*[to_s : () -> String] -> nil'
  type 'self.printf', '(?IO, ?String, *%any) -> nil'
  type(:proc, "() {(*%any) -> %any} -> Proc") # TODO more precise
  type 'self.putc', '(Fixnum) -> Fixnum'
  type 'self.puts', '(*[to_s : () -> String]) -> nil'
  type 'self.raise', '() -> %bot'
#  type 'self.raise', '(String or [exception : () -> String], ?String, ?Array<String>) -> %any'
# TODO: above same as fail?
  type 'self.rand', '(Fixnum or Range max) -> Numeric'
  type 'self.readline', '(?String, ?Fixnum) -> String'
  type 'self.readlines', '(?String, ?Fixnum) -> Array<String>'
  type 'self.require', '(String name) -> %bool'
  type 'self.require_relative', '(String name) -> %bool'
  type 'self.select',
          '(Array<IO> read, ?Array<IO> write, ?Array<IO> error, ?Fixnum timeout) -> Array<String>' # TODO: return type?
#  type 'self.set_trace_func' #TODO
  type 'self.sleep', '(Numeric duration) -> Fixnum'
#  type 'self.spawn' #TODO
  rdl_alias :sprintf, :format # TODO: are they aliases?
  type 'self.srand', '(Numeric number) -> Numeric'
  type 'self.syscall', '(Fixnum num, *%any args) -> %any' # TODO : ?
#  type 'self.system' # TODO
  type 'self.test', '(String cmd, String file1, ?String file2) -> %bool or Time' # TODO: better, dependent type?
#  type 'self.throw' # TODO
#  type 'self.trace_var' # TODO
#  type 'self.trap' # TODO
#  type 'self.untrace_var' # TODO
  type 'self.warn', '(*String msg) -> nil'
  type :clone, '() -> self'
  type :raise, '() -> %bot'
  type :raise, '(String) -> %bot'
  type :raise, '(Class, String, Array<String>) -> %bot'
  type :send, '(String or Symbol, *%any) -> %any'
  type :send, '(String or Symbol, *%any) { (*%any) -> %any } -> %any'
end
