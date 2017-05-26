class ActionController::Base
  type 'self.helpers', '() -> ActionView::Base'
  type(:logger, "() -> ActiveSupport::TaggedLogging")
end
