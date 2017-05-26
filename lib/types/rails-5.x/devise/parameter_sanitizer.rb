class Devise::ParameterSanitizer
  type :permit, '(Symbol, Hash<Symbol, Array<Symbol>>) -> NilClass'
end
