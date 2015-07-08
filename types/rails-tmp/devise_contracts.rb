require'rdl'

module MapperHelper
  class << self
    attr_accessor :namespace_stack
  end

  def self.devise_for_info_valid?(model, type, action, routes, path_prefix)
    ctrl_cls = model.to_s.pluralize.camelize + "Controller"
    ctrl_cls = eval(ctrl_cls) 

    info = get_devise_for_info(model, type, action, path_prefix)
    path_helper_method = info[:path_helper][0]
    url_helper_method = info[:url_helper][0]
    path_helper_method_type = info[:path_helper][0]
    url_helper_method_type = info[:url_helper][0]
    path = info[:path]
    verb = info[:verb]
    ctrl = info[:controller]

    # TODO: this part should be in post_task, but need a better way to 
    # take care of shared code?

    # typesig(ctrl_cls, path_helper_method, path_helper_method_type)
    # typesig(ctrl_cls, url_helper_method, url_helper_method_type)

    route_added = routes.any? {|r|
      defaults = r.defaults
      route_path = r.path.spec.to_s.split('(')[0]

      route_path == path and verb.include?(r.verb) and
      defaults[:action] == action.to_s and defaults[:controller] == ctrl
    }

    ctrl_cls.instance_methods.include?(path_helper_method) and
    ctrl_cls.instance_methods.include?(url_helper_method) and
    route_added
  end

  def self.get_devise_for_info(model, type, action, path_prefix="")
    # TODO: the arg types may be (*Hash), where each Hash is a user_session?
    #       where is this defined?

    model_s = model.to_s.singularize
    model_s_c = model_s.camelize    

    ns = MapperHelper.namespace_stack
    namespace_str = ns.empty? ? "" : ns.join("_") + "_"
    namespace_path_str = ns.empty? ? "" : ns.join("/") + "/"
    ctrl_prefix = namespace_path_str == "" ? "devise/" : namespace_path_str

    case type
    when :session
      case action
      when :new
        h = :"new_#{namespace_str}#{model_s}_session"
        v = [/^GET$/]
        p = "#{path_prefix}/#{model}/sign_in"
        pht = "(?Hash) -> String"
      when :create
        h = :"#{namespace_str}#{model_s}_session"
        v = [/^POST$/]
        p = "#{path_prefix}/#{model}/sign_in"
        pht = "(?Hash) -> String"
      when :destroy
        h = :"destroy_#{namespace_str}#{model_s}_session"
        v = [/^DELETE$/]
        p = "#{path_prefix}/#{model}/sign_out"
        # TODO: Is there a better way to specify arg is a user session?
        pht = "(?Hash) -> String"
      else 
        raise Exception, "invalid action for #{type.inspect}"
      end

      controller = "#{ctrl_prefix}sessions"
    when :password
      case action
      when :new
        h = :"new_#{namespace_str}#{model_s}_password"
        v = [/^GET$/]
        p = "#{path_prefix}/#{model}/password/new"
        pht = "(?Hash) -> String"
      when :edit
        h = :"edit_#{namespace_str}#{model_s}_password"
        v = [/^GET$/]
        p = "#{path_prefix}/#{model}/password/edit"
        pht = "(?Hash) -> String"
      when :update
        h = :"#{namespace_str}#{model_s}_password"
        v = [/^PUT$/]
        p = "#{path_prefix}/#{model}/password"
        pht = "(?Hash) -> String"
      when :create
        h = :"#{namespace_str}#{model_s}_password"
        v = [/^POST$/]
        p = "#{path_prefix}/#{model}/password"
        pht = "(?Hash) -> String"
      else 
        raise Exception, "invalid action for #{type.inspect}"
      end

      controller = "#{ctrl_prefix}passwords"
    when :confirmation
      case action
      when :new
        h = :"new_#{namespace_str}#{model_s}_confirmation"
        v = [/^GET$/]
        p = "#{path_prefix}/#{model}/confirmation/new"
        pht = "(?Hash) -> String"
      when :show
        h = :"#{namespace_str}#{model_s}_confirmation"
        v = [/^GET$/]
        p = "#{path_prefix}/#{model}/confirmation"
        pht = "(?Hash) -> String"
      when :create
        h = :"#{namespace_str}#{model_s}_confirmation"
        v = [/^POST$/]
        p = "#{path_prefix}/#{model}/confirmation"
        pht = "(?Hash) -> String"
      else 
        raise Exception, "invalid action for #{type.inspect}"
      end

      controller = "#{ctrl_prefix}confirmations"
    else
      raise Exception, "invalid action"
    end

    ph = :"#{h}_path"
    uh = :"#{h}_url"
    uht = pht

    {:verb => v, :path => p, :path_helper => [ph, pht], :url_helper => [uh, uht], :controller => controller}
  end
end

module ActionDispatch::Routing
  class Mapper
    extend RDL

    spec :namespace do
      pre_task do |arg|
        MapperHelper.namespace_stack = [] if not MapperHelper.namespace_stack
        MapperHelper.namespace_stack.push(arg)
      end

      post_task do |ret, *arg|
        MapperHelper.namespace_stack.pop
      end
    end

    # TODO: other valid options for devise_for
    spec :devise_for do
      post_cond do |ret, *args|
        model = args[0].to_s
        model_s = model.singularize
        model_cls = eval(model_s.camelize)

        if args[-1].class == Hash and args[-1].keys.include?(:path_prefix)
          path_prefix = "/#{args[-1][:path_prefix]}"
        else
          path_prefix = ""
        end

        routes = Rails.application.routes.routes.to_a

        # default is session
        actions = [:new, :create, :destroy]
        
        session_info_valid = actions.all? {|action|
          MapperHelper.devise_for_info_valid?(model, :session, action, routes, path_prefix)
        }

        if model_cls.devise_modules.include?(:recoverable)
          actions = [:new, :edit, :update, :create]
          
          password_info_valid = actions.all? {|action|
            MapperHelper.devise_for_info_valid?(model, :password, action, routes, path_prefix)
          }
        else
          password_info_valid = true
        end

        if model_cls.devise_modules.include?(:confirmable)
          actions = [:new, :show, :create]
          
          confirmation_info_valid = actions.all? {|action|
            MapperHelper.devise_for_info_valid?(model, :confirmation, action, routes, path_prefix)
          }
        else
          confirmation_info_valid = true
        end

        ns = MapperHelper.namespace_stack
        namespace_str = ns.empty? ? "" : ns.join("_") + "_"

        helper_methods = {}
        helper_methods[:"current_#{namespace_str}#{model_s}"] = "() -> #{model_cls}"
        helper_methods[:"#{namespace_str}#{model_s}_signed_in?"] = "() -> %bool"
        helper_methods[:"authenticate_#{namespace_str}#{model_s}!"] = "() -> #{model_cls}"
        
        helper_info_valid = helper_methods.keys.all? {|m|
          ApplicationController.instance_methods.include?(m)
        }

        # this should be in post_task? but how to take care of shared code
        helper_methods.each {|method, type|
          #add_typesig(ApplicationController, method, type)
        }

        session_info_valid and password_info_valid and confirmation_info_valid and helper_info_valid
      end
    end
  end
end

