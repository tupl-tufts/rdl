RDL.type_params 'RDL::Type::SingletonType', [:t], :satisfies?

RDL.type 'RDL::Type::SingletonType', :initialize, "(x) -> self<x>", wrap: false
RDL.type 'RDL::Type::SingletonType', :val, "() -> t", wrap: false
