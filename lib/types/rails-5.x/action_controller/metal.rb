class ActionController::Metal
  type :params, '() -> ActiveSupport::HashWithIndifferentAccess<String or Symbol, v>'
  type :request, "() -> ActionDispatch::Request"
end
