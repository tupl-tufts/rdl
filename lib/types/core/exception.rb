class Exception
  rdl_nowrap

  type :==, '(%any) -> %bool'
  type :backtrace, '() -> Array<String>'
  type :backtrace_locations, '() -> Array<Thread::Backtrace::Location>'
  type :cause, '() -> nil' # TODO exception is proper postcondition
  type :exception, '(?String) -> Exception' # or error
  # type 'initialize', '() -> '
  type :inspect, '() -> String'
  type :message, '() -> String'
  # type 'method_missing', '() -> '
  # type 'respond_to?', '() -> '
  # type 'respond_to_missing?', '() -> '
  type :set_backtrace, '(String or Array<String>) -> Array<String>'
  type :to_s, '() -> String'
end
