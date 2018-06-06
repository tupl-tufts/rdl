RDL.type_params 'RDL::Type::SingletonType', [:t], :satisfies?

RDL.type 'RDL::Type::SingletonType', :initialize, "(x) -> self<x>", wrap: false
RDL.type 'RDL::Type::SingletonType', :val, "() -> t", wrap: false
RDL.type 'RDL::Type::SingletonType', :nominal, "() -> RDL::Type::NominalType", wrap: false

RDL.type 'RDL::Type::NominalType', :initialize, "(Class or String) -> self", wrap: false
RDL.type 'RDL::Type::NominalType', :klass, "() -> Class", wrap: false

RDL.type 'RDL::Type::GenericType', :initialize, "(RDL::Type::Type, *RDL::Type::Type) -> self", wrap: false
RDL.type 'RDL::Type::GenericType', :params, "() -> Array<RDL::Type::Type>", wrap: false
RDL.type 'RDL::Type::GenericType', :base, "() -> RDL::Type::NominalType", wrap: false

RDL.type 'RDL::Type::UnionType', :initialize, "(*RDL::Type::Type) -> self", wrap: false
RDL.type 'RDL::Type::UnionType', :canonical, "() -> RDL::Type::Type", wrap: false
RDL.type 'RDL::Type::UnionType', :types, "() -> Array<RDL::Type::Type>", wrap: false

RDL.type 'RDL::Type::TupleType', :initialize, "(*RDL::Type::Type) -> self", wrap: false
RDL.type 'RDL::Type::TupleType', :params, "() -> Array<RDL::Type::Type>", wrap: false
RDL.type 'RDL::Type::TupleType', :promote, "(?RDL::Type::Type) -> RDL::Type::GenericType", wrap: false
RDL.type 'RDL::Type::TupleType', :promote!, "(?RDL::Type::Type) -> %bool", wrap: false
RDL.type 'RDL::Type::TupleType', :check_bounds, "(?%bool) -> %bool", wrap: false

RDL.type 'RDL::Type::FiniteHashType', :elts, "() -> Hash<%any, RDL::Type::Type>", wrap: false
RDL.type 'RDL::Type::FiniteHashType', :promote, "(?%any, ?RDL::Type::Type) -> RDL::Type::GenericType", wrap: false
RDL.type 'RDL::Type::FiniteHashType', :promote!, "(?%any, ?RDL::Type::Type) -> %bool", wrap: false
RDL.type 'RDL::Type::FiniteHashType', :initialize, "(Hash<%any, RDL::Type::Type> or {}, ?RDL::Type::Type) -> self", wrap: false
RDL.type 'RDL::Type::FiniteHashType', :check_bounds, "(?%bool) -> %bool", wrap: false

RDL.type 'RDL::Type::VarargType', :initialize, '(RDL::Type::Type) -> self', wrap: false

RDL.type 'RDL::Type::VarType', :initialize, "(String) -> self", wrap: false

RDL.type 'RDL::Globals', 'self.parser', "() -> RDL::Type::Parser", wrap: false
RDL.type 'RDL::Globals', 'self.types', "() -> Hash<Symbol, RDL::Type::Type>", wrap: false
RDL.type 'RDL::Type::Parser', :scan_str, "(String) -> RDL::Type::Type", wrap: false
RDL.type 'RDL::Config', 'self.instance', "() -> RDL::Config", wrap: false
RDL.type 'RDL::Config', 'weak_update_promote', "() -> %bool", wrap: false
