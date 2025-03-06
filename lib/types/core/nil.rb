RDL.nowrap :NilClass

RDL.type :NilClass, :&, '(%any obj) -> false'
RDL.type :NilClass, :'^', '(%any obj) -> %bool'
RDL.type :NilClass, :|, '(%any obj) -> %bool'
RDL.type :NilClass, :is_a?, '(NilClass) -> true'
RDL.type :NilClass, :is_a?, '(%any) -> false'
RDL.type :NilClass, :present?, '() -> false'
RDL.type :NilClass, :rationalize, '() -> Rational'
RDL.type :NilClass, :to_a, '() -> []'
RDL.type :NilClass, :to_c, '() -> Complex'
RDL.type :NilClass, :to_f, '() -> 0.0'
RDL.type :NilClass, :to_h, '() -> {}'
RDL.type :NilClass, :to_r, '() -> Rational'
RDL.type :NilClass, :try, '(%any, *%any) -> nil' # from ActiveSupport::CoreExtensions::Object::Try
RDL.type :NilClass, :[], '(%any) -> nil'
