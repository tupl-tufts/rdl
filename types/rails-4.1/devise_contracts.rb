require'rdl'

module ActionDispatch::Routing
  class Mapper
    extend RDL

    # TODO: paths need to be modified if nested within namespace
    # TODO: other valid options for devise_for
    spec :devise_for do
      post_cond do |ret, *args|
        controller = args[0].to_s.pluralize.camelize + "Controller"
        controller = eval(controller)

        if args[-1].class == Hash and args[-1].keys.include?(:path_prefix)
          path_prefix = "/#{args[-1][:path_prefix]}"
        else
          path_prefix = ""
        end

        routes = Rails.application.routes.routes.to_a

        cls = args[0].to_s.singularize
        model_cls = eval(cls.camelize)
        session_methods = ["new_#{cls}_session", "#{cls}_session", "destroy_#{cls}_session"]
        session_routes = ["sign_in", "sign_out"]

        if model_cls.devise_modules.include?(:recoverable)
          password_methods = ["new_#{cls}_password", "edit_#{cls}_password", "#{cls}_password"]
          password_routes = ["password/new", "password/edit", "password"]
        else
          password_methods = []
          password_routes = []
        end

        if model_cls.devise_modules.include?(:confirmable)
          confirm_methods = ["new_#{cls}_confirmation", "#{cls}_confirmation"]
          confirm_routes = ["confirmation/new", "confirmation"]
        else
          confirm_methods = []
          confirm_routes = []
        end

        all_methods = session_methods + password_methods + confirm_methods
        url_methods = all_methods.map {|m| (m + "_url").to_sym}
        path_methods = all_methods.map {|m| (m + "_path").to_sym}

        all_routes = session_routes + password_routes + confirm_routes
        
        url_methods_defined = url_methods.all? {|m|
          controller.instance_methods.include?(m)
        }

        path_methods_defined = path_methods.all? {|m|
          controller.instance_methods.include?(m)
        }

        all_routes.map! {|r| "#{path_prefix}/#{args[0]}/#{r}"}

        routes_added = all_routes.all? {|r1|
          routes.any? {|r|
            defaults = r.app.instance_variable_get(:@defaults)
            path = r.path.spec.to_s.split('(')[0]
            r1 == path
          }
        }

        url_methods.each {|m|
          # typesig(controller, m, "() -> String")
        }

        path_methods.each {|m|
          # typesig(controller, m, "() -> String")
        }

        # TODO: look into how other methods are defined from :helper_method
        helper_methods = [:"current_#{cls}"]
        
        helper_methods_defined = helper_methods.all? {|m|
          # typesig(ApplicationController, m, "() -> #{model_cls}")
          ApplicationController.instance_methods.include?(m)
        }

        url_methods_defined and path_methods_defined and routes_added and helper_methods_defined
      end
    end
  end
end
