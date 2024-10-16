RDL.nowrap :Date
RDL.nowrap :DateTime

RDL.type :Date, 'self.now', '() -> DateTime'
RDL.type :Date, :strftime, '(String) -> String'
RDL.type :Date, :to_datetime, '() -> DateTime'
RDL.type :DateTime, :to_datetime, '() -> self'
RDL.type :DateTime, :to_milliseconds, '() -> Integer'
