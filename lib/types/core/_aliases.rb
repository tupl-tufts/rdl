module RDL
  PRE_INTMERGE_VERSIONS = ['>= 2.0.0', '< 2.4.0']
end

if defined? Fixnum
  type_alias '%integer', 'Fixnum or Bignum'
else
  type_alias '%integer', 'Integer'
end
if defined? BigDecimal
  type_alias '%real', '%integer or Float or Rational or BigDecimal'
  type_alias '%numeric', '%integer or Float or Rational or BigDecimal or Complex'
else
  type_alias '%real', '%integer or Float or Rational'
  type_alias '%numeric', '%integer or Float or Rational'
end
type_alias '%string', '[to_str: () -> String]'
if defined? Pathname
  type_alias '%path', '%string or Pathname'
else
  type_alias '%path', '%string'
end
type_alias '%open_args', '{external_encoding: ?String, internal_encoding: ?String, encoding: ?String, textmode: ?%any, binmode: ?%any, autoclose: ?%any, mode: ?String}'
