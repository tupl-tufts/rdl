module ActionView::Helpers::UrlHelper
  type :link_to, '(String, String or ActiveRecord::Base, ?Hash<Symbol, %any>) -> ActiveSupport::SafeBuffer'
  type :link_to, '(String, ?Hash<Symbol, %any>, ?Hash<Symbol, %any>) -> ActiveSupport::SafeBuffer'
  type :link_to, '(?Hash<Symbol, %any>, ?Hash<Symbol, %any>) {() -> String} -> ActiveSupport::SafeBuffer'
  type :link_to, '(?String, ?Hash<Symbol, %any>) {() -> String} -> ActiveSupport::SafeBuffer'
end
