if defined? BigDecimal
  RDL.type_alias '%real', 'Integer or Float or Rational or BigDecimal'
  RDL.type_alias '%numeric', 'Integer or Float or Rational or BigDecimal or Complex'
else
  RDL.type_alias '%real', 'Integer or Float or Rational'
  RDL.type_alias '%numeric', 'Integer or Float or Rational'
end
RDL.type_alias '%string', '[to_str: () -> String]'
if defined? Pathname
  RDL.type_alias '%path', '%string or Pathname'
else
  RDL.type_alias '%path', '%string'
end
RDL.type_alias '%open_args', '{external_encoding: ?String, internal_encoding: ?String, encoding: ?String, textmode: ?%any, binmode: ?%any, autoclose: ?%any, mode: ?String}'
