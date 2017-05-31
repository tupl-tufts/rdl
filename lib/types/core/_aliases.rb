if defined? BigDecimal
  type_alias '%real', 'Integer or Float or Rational or BigDecimal'
  type_alias '%numeric', 'Integer or Float or Rational or BigDecimal or Complex'
else
  type_alias '%real', 'Integer or Float or Rational'
  type_alias '%numeric', 'Integer or Float or Rational'
end
type_alias '%string', '[to_str: () -> String]'
if defined? Pathname
  type_alias '%path', '%string or Pathname'
else
  type_alias '%path', '%string'
end
type_alias '%open_args', '{external_encoding: ?String, internal_encoding: ?String, encoding: ?String, textmode: ?%any, binmode: ?%any, autoclose: ?%any, mode: ?String}'
