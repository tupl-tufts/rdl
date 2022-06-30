RDL.nowrap :'ActionController::Instrumentation'
RDL.type :'ActionController::Instrumentation', :render, '(String or Symbol) -> Array<String>'
#RDL.type :'ActionController::Instrumentation', :render, '(?String or Symbol, {content_type: ?String, json: ?(String or Array<String> or ApplicationRecord or Array<ApplicationRecord> or Symbol), layout: ?%bool or String, action: ?String or Symbol, location: ?String, nothing: ?%bool, file: ?String, text: ?[to_s: () -> String], status: ?Symbol, content_type: ?String, formats: ?Symbol or Array<Symbol>, locals: ?Hash<Symbol, x>}) -> Array<String>'

# %any version of `render`
RDL.type :'ActionController::Instrumentation', :render, '(?String or Symbol, {content_type: ?String, json: ?%any, layout: ?%bool or String, action: ?String or Symbol, location: ?String, nothing: ?%bool, file: ?String, text: ?[to_s: () -> String], status: ?Symbol, content_type: ?String, formats: ?Symbol or Array<Symbol>, locals: ?Hash<Symbol, x>, include: ?%any}) -> Array<String>'
RDL.type :'ActionController::Instrumentation', :redirect_to, '(?(String or Symbol or ActiveRecord::Base), {controller: ?String, action: ?String, notice: ?String, alert: ?String}) -> String'

#RDL.type :'ActionController::Instrumentation', :redirect_to, '({controller: ?String, action: String, notice: ?String, alert: ?String}) -> String' ## When no first argument is provided, `action` must be present in options.
#RDL.type :'ActionController::Instrumentation', :redirect_to, '(String or Symbol or ActiveRecord::Base, ?{controller: ?String, action: ?String, notice: ?String, alert: ?String}) -> String'
