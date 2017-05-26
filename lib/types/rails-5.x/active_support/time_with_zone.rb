class ActiveSupport::TimeWithZone
  type :beginning_of_day, '() -> ActiveSupport::TimeWithZone'
  type :end_of_day, '() -> ActiveSupport::TimeWithZone'
  type :beginning_of_week, '() -> ActiveSupport::TimeWithZone'
  type :end_of_week, '() -> ActiveSupport::TimeWithZone'
  type :to_date, '() -> Date'
  type :strftime, '(String) -> String'
  type :+, '(ActiveSupport::Duration) -> ActiveSupport::TimeWithZone'
  type :-, '(ActiveSupport::Duration) -> ActiveSupport::TimeWithZone'
  type :<, '(ActiveSupport::TimeWithZone or Time) -> %bool'
  type :>, '(ActiveSupport::TimeWithZone or Time) -> %bool'
  type :<=, '(ActiveSupport::TimeWithZone or Time) -> %bool'
  type :>=, '(ActiveSupport::TimeWithZone or Time) -> %bool'
end
