rdl_nowrap :Exception

type :Exception, :==, '(%any) -> %bool'
type :Exception, :backtrace, '() -> Array<String>'
type :Exception, :backtrace_locations, '() -> Array<Thread::Backtrace::Location>'
type :Exception, :cause, '() -> nil' # TODO exception is proper postcondition
type :Exception, :exception, '(?String) -> Exception' # or error
# type :Exception, :initialize, '() -> '
type :Exception, :inspect, '() -> String'
type :Exception, :message, '() -> String'
# type :Exception, :method_missing, '() -> '
# type :Exception, :respond_to?, '() -> '
# type :Exception, :respond_to_missing?, '() -> '
type :Exception, :set_backtrace, '(String or Array<String>) -> Array<String>'
type :Exception, :to_s, '() -> String'
