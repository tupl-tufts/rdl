module ActionController::Instrumentation
  type(:render, "(String or Symbol) -> Array<String>")
  type(:render, "(?String or Symbol, {content_type: ?String, layout: ?%bool or String, action: ?String or Symbol, location: ?String, nothing: ?%bool, text: ?[to_s: () -> String], status: ?Symbol, content_type: ?String, formats: ?Symbol or Array<Symbol>, locals: ?Hash<Symbol, %any>}) -> Array<String>")
  type(:redirect_to, '(:back) -> String')
  type(:redirect_to, '({controller: ?String, action: ?String, notice: ?String, alert: ?String}) -> String')
  type(:redirect_to, '(String or Symbol or ActiveRecord::Base, ?{controller: ?String, action: ?String, notice: ?String, alert: ?String}) -> String')
end
