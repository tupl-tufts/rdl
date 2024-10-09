RDL.nowrap :'ActionController::Instrumentation'
#RDL.type :'ActionController::Instrumentation', :render, '(String or Symbol) -> Array<String>'
#RDL.type :'ActionController::Instrumentation', :render, '(?String or Symbol, {content_type: ?String, json: ?(String or Array<String> or ApplicationRecord or Array<ApplicationRecord> or Symbol), layout: ?%bool or String, action: ?String or Symbol, location: ?String, nothing: ?%bool, file: ?String, text: ?[to_s: () -> String], status: ?Symbol, content_type: ?String, formats: ?Symbol or Array<Symbol>, locals: ?Hash<Symbol, x>}) -> Array<String>'

# %any version of `render`
#before: 
#RDL.type :'ActionController::Instrumentation', :render, '(?String or Symbol, {content_type: ?String, json: ?%any, xml: ?%any, layout: ?%bool or String, action: ?String or Symbol, location: ?String, nothing: ?%bool, file: ?String, text: ?[to_s: () -> String], status: ?(Symbol or Numeric), content_type: ?String, formats: ?Symbol or Array<Symbol>, locals: ?Hash<Symbol, x>, include: ?%any}) -> Array<String>'
#with JSON comp type:
RDL.type :'ActionController::Instrumentation', :render, '(?String or Symbol, {content_type: ?String, json: ?%any, body: ?String, layout: ?%bool or String, action: ?String or Symbol, location: ?String, nothing: ?%bool, file: ?String, text: ?[to_s: () -> String], status: ?(Symbol or Integer), content_type: ?String, formats: ?Symbol or Array<Symbol>, locals: ?Hash<Symbol, x>, include: ?%any}) -> ``DBType.render_output(targs)``', suspend_comp: true, fallback_output: RDL::Globals.types[:string]
#RDL.type :'ActionController::Instrumentation', :redirect_to, '(?(String or Symbol or ActiveRecord::Base), {controller: ?String, action: ?String, notice: ?String, alert: ?String}) -> String'
RDL.type :'ActionController::Instrumentation', :redirect_to, '(%any, ?%any) -> ``DBType.redirect_to_output(targs)``', suspend_comp: true, fallback_output: RDL::Globals.types[:string]

#RDL.type :'ActionController::Instrumentation', :redirect_to, '({controller: ?String, action: String, notice: ?String, alert: ?String}) -> String' ## When no first argument is provided, `action` must be present in options.
#RDL.type :'ActionController::Instrumentation', :redirect_to, '(String or Symbol or ActiveRecord::Base, ?{controller: ?String, action: ?String, notice: ?String, alert: ?String}) -> String'
