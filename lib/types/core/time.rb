RDL.nowrap :Time

RDL.type :Time, 'self.at', '(Numeric, ?Numeric) -> ``RDL::Type::NominalType.new(trec.val)``'
RDL.type :Time, 'self.at', '(Time) -> Time'
RDL.type :Time, 'self.at', '(Numeric seconds_with_frac) -> Time'
RDL.type :Time, 'self.at', '(Numeric seconds, Numeric microseconds_with_frac) -> Time'
RDL.type :Time, 'self.gm', '(Integer year, ?(Integer or String) month, ?Integer day, ?Integer hour, ?Integer min, ?Numeric sec, ?Numeric usec_with_frac) -> Time'
RDL.type :Time, 'self.local', '(Integer year, ?(Integer or String) month, ?Integer day, ?Integer hour, ?Integer min, ?Numeric sec, ?Numeric usec_with_frac) -> Time'
RDL.rdl_alias :Time, 'self.mktime', 'self.local'
RDL.type :Time, :initialize, '(?Integer year, ?(Integer or String) month, ?Integer day, ?Integer hour, ?Integer min, ?Numeric sec, ?Numeric usec_with_frac) -> self'
RDL.type :Time, 'self.now', '() -> Time'
RDL.type :Time, 'self.utc', '(Integer year, ?(Integer or String) month, ?Integer day, ?Integer hour, ?Integer min, ?Numeric sec, ?Numeric usec_with_frac) -> Time'

RDL.type :Time, :+, '(Numeric) -> Time'
RDL.type :Time, :-, '(Time) -> Float'
RDL.type :Time, :-, '(Numeric) -> Time'
RDL.type :Time, :<=>, '(Time or DateTime) -> -1 or 0 or 1 or nil'
RDL.type :Time, :asctime, '() -> String'
RDL.type :Time, :ctime, '() -> String'
RDL.type :Time, :day, '() -> Integer'
RDL.type :Time, :dst?, '() -> %bool'
RDL.type :Time, :eql?, '(%any) -> %bool'
RDL.type :Time, :friday?, '() -> %bool'
RDL.type :Time, :getgm, '() -> Time'
RDL.type :Time, :getlocal, '(?Integer utc_offset) -> Time'
RDL.type :Time, :getutc, '() -> Time'
RDL.type :Time, :gmt?, '() -> %bool'
RDL.type :Time, :gmt_offset, '() -> Integer'
RDL.type :Time, :gmtime, '() -> self'
RDL.rdl_alias :Time, :gmtoff, :gmt_offset
RDL.type :Time, :hash, '() -> Integer'
RDL.type :Time, :hour, '() -> Integer'
RDL.type :Time, :inspect, '() -> String'
RDL.type :Time, :isdst, '() -> %bool'
RDL.type :Time, :localtime, '(?(String or Integer)) -> self'
RDL.type :Time, :mday, '() -> Integer'
RDL.type :Time, :min, '() -> Integer'
RDL.type :Time, :mon, '() -> Integer'
RDL.type :Time, :monday?, '() -> %bool'
RDL.rdl_alias :Time, :month, :mon
RDL.type :Time, :nsec, '() -> Integer'
RDL.type :Time, :round, '(Integer) -> Time'
RDL.type :Time, :saturday?, '() -> %bool'
RDL.type :Time, :sec, '() -> Integer'
RDL.type :Time, :strftime, '(String) -> String'
RDL.type :Time, :subsec, '() -> Integer or Rational'
RDL.type :Time, :succ, '() -> Time'
RDL.type :Time, :sunday?, '() -> %bool'
RDL.type :Time, :thursday?, '() -> %bool'
RDL.type :Time, :to_a, '() -> [Integer, Integer, Integer, Integer, Integer, Integer, Integer, Integer, %bool, String]'
RDL.type :Time, :to_f, '() -> Float'
RDL.type :Time, :to_i, '() -> Integer'
RDL.type :Time, :to_r, '() -> Rational'
RDL.type :Time, :to_s, '() -> String'
RDL.type :Time, :tuesday?, '() -> %bool'
RDL.type :Time, :tv_nsec, '() -> Numeric'
RDL.type :Time, :tv_sec, '() -> Numeric'
RDL.type :Time, :tv_usec, '() -> Numeric'
RDL.type :Time, :usec, '() -> Numeric'
RDL.type :Time, :utc, '() -> self'
RDL.type :Time, :utc?, '() -> %bool'
RDL.type :Time, :utc_offset, '() -> Integer'
RDL.type :Time, :wday, '() -> Integer'
RDL.type :Time, :wednesday?, '() -> %bool'
RDL.type :Time, :yday, '() -> Integer'
RDL.type :Time, :year, '() -> Integer'
RDL.type :Time, :zone, '() -> String'
