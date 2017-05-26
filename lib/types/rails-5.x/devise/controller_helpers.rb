module Devise::Controllers::Helpers
  type :devise_parameter_sanitizer, '() -> Devise::ParameterSanitizer'
  type :current_user, '() -> User'
end
