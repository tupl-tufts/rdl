RDL.nowrap :Exception

RDL.type :Exception, :==, '(%any) -> %bool'
RDL.type :Exception, :backtrace, '() -> Array<String>'
RDL.type :Exception, :backtrace_locations, '() -> Array<Thread::Backtrace::Location>'
RDL.type :Exception, :cause, '() -> nil' # TODO exception is proper postcondition
RDL.type :Exception, :exception, '(?String) -> Exception' # or error
# RDL.type :Exception, :initialize, '() -> '
RDL.type :Exception, :inspect, '() -> String'
RDL.type :Exception, :message, '() -> String'
# RDL.type :Exception, :method_missing, '() -> '
# RDL.type :Exception, :respond_to?, '() -> '
# RDL.type :Exception, :respond_to_missing?, '() -> '
RDL.type :Exception, :set_backtrace, '(String or Array<String>) -> Array<String>'
RDL.type :Exception, :to_s, '() -> String'
