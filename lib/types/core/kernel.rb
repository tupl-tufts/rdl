RDL.nowrap :Kernel

# RDL.type :Kernel, 'self.Array', '([to_ary: () -> Array<t>]) -> Array<t>'
# RDL.type :Kernel, 'self.Array', '([to_a: () -> Array<t>]) -> Array<t>'
RDL.type :Kernel, 'self.Complex', '(Numeric x, Numeric y) -> Complex'
RDL.type :Kernel, 'self.Complex', '(String x) -> Complex'
RDL.type :Kernel, 'self.Float', '(Numeric x) -> Float'
# RDL.type :Kernel, 'self.Float', '(x : [to_f : () -> Float]) -> Float'
# RDL.type :Kernel, 'self.Hash', '(x : [to_hash : () -> Hash<k,v>]) -> Hash<k,v>'
RDL.type :Kernel, 'self.Hash', '(nil x) -> Hash<k,v>'
# RDL.type :Kernel, 'self.Hash, '(x : []) -> Hash<k,v>'
RDL.type :Kernel, 'self.Integer', '(Numeric or String arg, ?Integer base) -> Integer'
# RDL.type :Kernel, 'self.Integer', '(arg : [to_int : () -> Integer], base : ?Integer) -> Integer'
# RDL.type :Kernel, 'self.Integer', '(arg : [to_i : () -> Integer], base : ?Integer) -> Integer'
RDL.type :Kernel, 'self.Rational', '(Numeric x, Numeric y) -> Rational'
RDL.type :Kernel, 'self.Rational', '(String x) -> Rational'
# RDL.type :Kernel, 'self.String', '(arg : [to_s : () -> String]) -> String'
RDL.type :Kernel, 'self.__callee__', '() -> Symbol or nil'
RDL.type :Kernel, 'self.__dir__', '() -> String or nil'
RDL.type :Kernel, 'self.__method__', '() -> Symbol or nil'
RDL.type :Kernel, 'self.`', '(String) -> String'
RDL.type :Kernel, 'self.abort', '(?String msg) -> %bot'
RDL.type :Kernel, 'self.at_exit', '() { () -> %any} -> Proc' # TODO: Fix proc
RDL.type :Kernel, 'self.autoload', '(String or Symbol module, String filename) -> nil'
RDL.type :Kernel, 'self.autoload?', '(Symbol or String name) -> String or nil'
RDL.type :Kernel, 'self.binding', '() -> Binding'
RDL.type :Kernel, 'self.block_given?', '() -> %bool'
RDL.type :Kernel, 'self.caller', '(?Integer start, ?Integer length) -> Array<String> or nil'
RDL.type :Kernel, 'self.caller', '(Range) -> Array<String> or nil'
RDL.type :Kernel, 'self.caller_locations', '(?Integer start, ?Integer length) -> Array<String> or nil'
RDL.type :Kernel, 'self.caller_locations', '(Range) -> Array<String> or nil'
# RDL.type :Kernel, 'self.catch' # TODO
RDL.type :Kernel, 'self.eval', '(String, ?Binding, ?String filename, ?Integer lineno) -> %any'
# RDL.type :Kernel, 'self.exec' #TODO
RDL.type :Kernel, 'self.exit', '() -> %bot'
RDL.type :Kernel, 'self.exit', '(Integer or %bool status) -> %bot'
RDL.type :Kernel, 'self.exit!', '(Integer or %bool status) -> %bot'
RDL.type :Kernel, 'self.fail', '() -> %bot'
RDL.type :Kernel, 'self.fail', '(String) -> %bot'
RDL.type :Kernel, 'self.fail', '(Class, Array<String>) -> %bot'
RDL.type :Kernel, 'self.fail', '(Class, String, Array<String>) -> %bot'
# RDL.type :Kernel, 'self.fail', '(String or [exception : () -> String], ?String, ?Array<String>) -> %any'
# RDL.type :Kernel, 'self.fork' #TODO
RDL.type :Kernel, 'self.format', '(String format, *%any args) -> String'
RDL.type :Kernel, 'self.gets', '(?String, ?Integer) -> String'
RDL.type :Kernel, 'self.global_variables', '() -> Array<Symbol>'
RDL.type :Kernel, 'self.iterator?', '() -> %bool'
# RDL.type :Kernel, 'self.lambda' # TODO
RDL.type :Kernel, 'self.load', '(String filename, ?%bool) -> %bool'
RDL.type :Kernel, 'self.local_variables', '() -> Array<Symbol>'
# RDL.type :Kernel, 'self.loop' #TODO
RDL.type :Kernel, 'self.open', '(String path, ?(String or Integer) mode, ?String perm) -> IO or nil'
# RDL.type :Kernel, 'self.open', '(String path, mode : ?String, perm: ?String) {(IO) -> %any)} -> %any' # TODO: returns block value
# RDL.type :Kernel, 'self.open', '(String path, mode : ?Integer, perm: ?String) {(IO) -> %any)} -> %any' # TODO: returns block value
# RDL.type :Kernel, 'self.p', '(*[inspect : () -> String]) -> nil'
# RDL.type :Kernel, 'self.print', '(*[to_s : () -> String] -> nil'
RDL.type :Kernel, 'self.printf', '(?IO, ?String, *%any) -> nil'
RDL.type :Kernel, :proc, '() {(*%any) -> %any} -> Proc' # TODO more precise
RDL.type :Kernel, 'self.putc', '(Integer) -> Integer'
RDL.type :Kernel, 'self.puts', '(*[to_s : () -> String]) -> nil'
RDL.type :Kernel, 'self.raise', '() -> %bot'
# RDL.type :Kernel, 'self.raise', '(String or [exception : () -> String], ?String, ?Array<String>) -> %any'
# TODO: above same as fail?
RDL.type :Kernel, 'self.rand', '(Integer or Range max) -> Numeric'
RDL.type :Kernel, 'self.readline', '(?String, ?Integer) -> String'
RDL.type :Kernel, 'self.readlines', '(?String, ?Integer) -> Array<String>'
RDL.type :Kernel, 'self.require', '(String name) -> %bool'
RDL.type :Kernel, 'self.require_relative', '(String name) -> %bool'
RDL.type :Kernel, 'self.select',
          '(Array<IO> read, ?Array<IO> write, ?Array<IO> error, ?Integer timeout) -> Array<String>' # TODO: return RDL.type?
# RDL.type :Kernel, 'self.set_trace_func' #TODO
RDL.type :Kernel, 'self.sleep', '(Numeric duration) -> Integer'
# RDL.type :Kernel, 'self.spawn' #TODO
RDL.rdl_alias :Kernel, :sprintf, :format # TODO: are they aliases?
RDL.type :Kernel, 'self.srand', '(Numeric number) -> Numeric'
RDL.type :Kernel, 'self.syscall', '(Integer num, *%any args) -> %any' # TODO : ?
# RDL.type :Kernel, 'self.system' # TODO
RDL.type :Kernel, 'self.test', '(String cmd, String file1, ?String file2) -> %bool or Time' # TODO: better, dependent RDL.type?
# RDL.type :Kernel, 'self.throw' # TODO
# RDL.type :Kernel, 'self.trace_var' # TODO
# RDL.type :Kernel, 'self.trap' # TODO
# RDL.type :Kernel, 'self.untrace_var' # TODO
RDL.type :Kernel, 'self.warn', '(*String msg) -> nil'
RDL.type :Kernel, :clone, '() -> self'
RDL.type :Kernel, :raise, '() -> %bot'
RDL.type :Kernel, :raise, '(String) -> %bot'
RDL.type :Kernel, :raise, '(Class, String, Array<String>) -> %bot'
RDL.type :Kernel, :send, '(String or Symbol, *%any) -> %any'
RDL.type :Kernel, :send, '(String or Symbol, *%any) { (*%any) -> %any } -> %any'
