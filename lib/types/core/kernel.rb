rdl_nowrap :Kernel

# type :Kernel, 'self.Array', '([to_ary: () -> Array<t>]) -> Array<t>'
# type :Kernel, 'self.Array', '([to_a: () -> Array<t>]) -> Array<t>'
type :Kernel, 'self.Complex', '(Numeric x, Numeric y) -> Complex'
type :Kernel, 'self.Complex', '(String x) -> Complex'
type :Kernel, 'self.Float', '(Numeric x) -> Float'
# type :Kernel, 'self.Float', '(x : [to_f : () -> Float]) -> Float'
# type :Kernel, 'self.Hash', '(x : [to_hash : () -> Hash<k,v>]) -> Hash<k,v>'
type :Kernel, 'self.Hash', '(nil x) -> Hash<k,v>'
# type :Kernel, 'self.Hash, '(x : []) -> Hash<k,v>'
type :Kernel, 'self.Integer', '(Numeric or String arg, ?Integer base) -> Integer'
# type :Kernel, 'self.Integer', '(arg : [to_int : () -> Integer], base : ?Integer) -> Integer'
# type :Kernel, 'self.Integer', '(arg : [to_i : () -> Integer], base : ?Integer) -> Integer'
type :Kernel, 'self.Rational', '(Numeric x, Numeric y) -> Rational'
type :Kernel, 'self.Rational', '(String x) -> Rational'
# type :Kernel, 'self.String', '(arg : [to_s : () -> String]) -> String'
type :Kernel, 'self.__callee__', '() -> Symbol or nil'
type :Kernel, 'self.__dir__', '() -> String or nil'
type :Kernel, 'self.__method__', '() -> Symbol or nil'
type :Kernel, 'self.`', '(String) -> String'
type :Kernel, 'self.abort', '(?String msg) -> %bot'
type :Kernel, 'self.at_exit', '() { () -> %any} -> Proc' # TODO: Fix proc
type :Kernel, 'self.autoload', '(String or Symbol module, String filename) -> nil'
type :Kernel, 'self.autoload?', '(Symbol or String name) -> String or nil'
type :Kernel, 'self.binding', '() -> Binding'
type :Kernel, 'self.block_given?', '() -> %bool'
type :Kernel, 'self.caller', '(?Integer start, ?Integer length) -> Array<String> or nil'
type :Kernel, 'self.caller', '(Range) -> Array<String> or nil'
type :Kernel, 'self.caller_locations', '(?Integer start, ?Integer length) -> Array<String> or nil'
type :Kernel, 'self.caller_locations', '(Range) -> Array<String> or nil'
# type :Kernel, 'self.catch' # TODO
type :Kernel, 'self.eval', '(String, ?Binding, ?String filename, ?Integer lineno) -> %any'
# type :Kernel, 'self.exec' #TODO
type :Kernel, 'self.exit', '() -> %bot'
type :Kernel, 'self.exit', '(Integer or %bool status) -> %bot'
type :Kernel, 'self.exit!', '(Integer or %bool status) -> %bot'
type :Kernel, 'self.fail', '() -> %bot'
type :Kernel, 'self.fail', '(String) -> %bot'
type :Kernel, 'self.fail', '(Class, Array<String>) -> %bot'
type :Kernel, 'self.fail', '(Class, String, Array<String>) -> %bot'
# type :Kernel, 'self.fail', '(String or [exception : () -> String], ?String, ?Array<String>) -> %any'
# type :Kernel, 'self.fork' #TODO
type :Kernel, 'self.format', '(String format, *%any args) -> String'
type :Kernel, 'self.gets', '(?String, ?Integer) -> String'
type :Kernel, 'self.global_variables', '() -> Array<Symbol>'
type :Kernel, 'self.iterator?', '() -> %bool'
# type :Kernel, 'self.lambda' # TODO
type :Kernel, 'self.load', '(String filename, ?%bool) -> %bool'
type :Kernel, 'self.local_variables', '() -> Array<Symbol>'
# type :Kernel, 'self.loop' #TODO
type :Kernel, 'self.open', '(String path, ?(String or Integer) mode, ?String perm) -> IO or nil'
# type :Kernel, 'self.open', '(String path, mode : ?String, perm: ?String) {(IO) -> %any)} -> %any' # TODO: returns block value
# type :Kernel, 'self.open', '(String path, mode : ?Integer, perm: ?String) {(IO) -> %any)} -> %any' # TODO: returns block value
# type :Kernel, 'self.p', '(*[inspect : () -> String]) -> nil'
# type :Kernel, 'self.print', '(*[to_s : () -> String] -> nil'
type :Kernel, 'self.printf', '(?IO, ?String, *%any) -> nil'
type :Kernel, :proc, '() {(*%any) -> %any} -> Proc' # TODO more precise
type :Kernel, 'self.putc', '(Integer) -> Integer'
type :Kernel, 'self.puts', '(*[to_s : () -> String]) -> nil'
type :Kernel, 'self.raise', '() -> %bot'
# type :Kernel, 'self.raise', '(String or [exception : () -> String], ?String, ?Array<String>) -> %any'
# TODO: above same as fail?
type :Kernel, 'self.rand', '(Integer or Range max) -> Numeric'
type :Kernel, 'self.readline', '(?String, ?Integer) -> String'
type :Kernel, 'self.readlines', '(?String, ?Integer) -> Array<String>'
type :Kernel, 'self.require', '(String name) -> %bool'
type :Kernel, 'self.require_relative', '(String name) -> %bool'
type :Kernel, 'self.select',
          '(Array<IO> read, ?Array<IO> write, ?Array<IO> error, ?Integer timeout) -> Array<String>' # TODO: return type?
# type :Kernel, 'self.set_trace_func' #TODO
type :Kernel, 'self.sleep', '(Numeric duration) -> Integer'
# type :Kernel, 'self.spawn' #TODO
rdl_alias :Kernel, :sprintf, :format # TODO: are they aliases?
type :Kernel, 'self.srand', '(Numeric number) -> Numeric'
type :Kernel, 'self.syscall', '(Integer num, *%any args) -> %any' # TODO : ?
# type :Kernel, 'self.system' # TODO
type :Kernel, 'self.test', '(String cmd, String file1, ?String file2) -> %bool or Time' # TODO: better, dependent type?
# type :Kernel, 'self.throw' # TODO
# type :Kernel, 'self.trace_var' # TODO
# type :Kernel, 'self.trap' # TODO
# type :Kernel, 'self.untrace_var' # TODO
type :Kernel, 'self.warn', '(*String msg) -> nil'
type :Kernel, :clone, '() -> self'
type :Kernel, :raise, '() -> %bot'
type :Kernel, :raise, '(String) -> %bot'
type :Kernel, :raise, '(Class, String, Array<String>) -> %bot'
type :Kernel, :send, '(String or Symbol, *%any) -> %any'
type :Kernel, :send, '(String or Symbol, *%any) { (*%any) -> %any } -> %any'
