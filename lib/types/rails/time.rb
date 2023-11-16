RDL.type :Time, 'self.zone', '() -> ActiveSupport::TimeZone'
RDL.type :Time, :+, '(ActiveSupport::Duration) -> Time'
RDL.type :Time, :-, '(ActiveSupport::Duration) -> Time'
