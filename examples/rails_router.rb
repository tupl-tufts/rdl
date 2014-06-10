require 'deep_clone'

module RailsHelper
  class << self
    attr_accessor :namespace
  end

  def self.get_resource_info(controller, action)
    controller_s = controller.singularize
    controller_c = controller.camelize

    case action
    when :new
      v = [/^GET$/]
      p = "/#{controller_s}/new"
      prefix = "#{controller_s}"
      pht = "() -> String"
    when :create
      v = [/^POST$/]
      p = "/#{controller_s}"
      prefix = "#{controller_s}"
      pht = "() -> String"
    when :show
      v = [/^GET$/]
      p = "/#{controller_s}"
      prefix = "#{controller_s}"
      pht = "() -> String"
    when :edit
      v = [/^GET$/]
      p = "/#{controller_s}/edit"
      prefix = "edit_#{controller_s}"
      pht = "() -> String"
    when :update
      v = [/^PUT$/, /^PATCH$/]
      p = "/#{controller_s}"
      prefix = "#{controller_s}"
      pht = "() -> String"
    when :destroy
      v = [/^DELETE$/]
      p = "/#{controller_s}"
      prefix = "#{controller_s}"
      pht = "() -> String"
    else
      raise Exception, "invalid action #{action.inspect}"
    end

    ph = "#{prefix}_path".to_sym
    uh = "#{prefix}_url".to_sym
    uht = pht
    {:verb => v, :path => p, :path_helper => [ph, pht], :url_helper => [uh, uht]}
  end

  def self.get_resources_info(controller, action)
    controller_s = controller.singularize
    controller_c = controller.camelize
    n = RailsHelper.namespace.to_s
    nnh = (n == "" ? "" : "#{n}_")

    case action
    when :index
      v = [/^GET$/]
      p = "/#{controller}"
      prefix = "#{nnh}#{controller}"
      pht = "() -> String"
    when :new
      v = [/^GET$/]
      p = "/#{controller}/new"

      if n == ""
        prefix = "#{controller_s}"
      else
        prefix = "new_#{nnh}#{controller_s}"
      end

      pht = "() -> String"
    when :create
      v = [/^POST$/]
      p = "/#{controller}"
      prefix = "#{nnh}#{controller}"
      pht = "() -> String"
    when :show
      v = [/^GET$/]
      p = "/#{controller}/:id"
      prefix = "#{nnh}#{controller_s}"
      pht = "(#{controller_c}) -> String"
    when :edit
      v = [/^GET$/]
      p = "/#{controller}/:id/edit"
      prefix = "edit_#{nnh}#{controller_s}"
      pht = "(#{controller_c}) -> String"
    when :update
      v = [/^PUT$/, /^PATCH$/]
      p = "/#{controller}/:id"
      prefix = "#{nnh}#{controller_s}"
      pht = "(#{controller_c}) -> String"
    when :destroy
      v = [/^DELETE$/]
      p = "/#{controller}/:id"
      prefix = "#{nnh}#{controller_s}"
      pht = "(#{controller_c}) -> String"
    else
      raise Exception, "invalid action #{action.inspect}"
    end

    p = "/#{nnh[0..-2]}#{p}" if nnh != ""

    ph = "#{prefix}_path".to_sym
    uh = "#{prefix}_url".to_sym
    uht = pht
    {:verb => v, :path => p, :path_helper => [ph, pht], :url_helper => [uh, uht]}
  end

  def self.resource_routes_info_valid?(routes, controller, action, options={})
    info = get_resource_info(controller, action)
    r_p = info[:path]
    r_v = info[:verb]

    routes.any? {|r|
      defaults = r.app.instance_variable_get(:@defaults)
      path = r.path.spec.to_s.split('(')[0]

      if defaults
        defaults[:controller] == controller and defaults[:action] == action.to_s and path == r_p and r_v.include?(r.verb)
      else
        false
      end
    }
  end

  def self.resources_routes_info_valid?(routes, controller, action, options={})
    info = get_resources_info(controller, action)
    r_p = info[:path]
    r_v = info[:verb]

    namespace = self.namespace.to_s
    namespace == "" ? c2 = controller : c2 = "#{namespace}/#{controller}"

    routes.any? {|r|
      defaults = r.app.instance_variable_get(:@defaults)
      path = r.path.spec.to_s.split('(')[0]

      if defaults
        defaults[:controller] == c2 and defaults[:action] == action.to_s and path == r_p and r_v.include?(r.verb)
      else
        false
      end
    }
  end

  def self.resource_routes_valid?(routes, resources_args)
    controller = resources_args[0].to_s.pluralize
    controller_obj = controller.pluralize.camelize + "Controller"
    controller_obj = eval(controller_obj)
    options = resources_args[1].nil? ? {} : resources_args[1]
    routes = Rails.application.routes.routes.to_a

    actions = [:new, :create, :show, :edit, :update, :destroy]

    if options.keys.include?(:only)
      actions = options[:only]
    elsif options.keys.include?(:except)
      actions = actions - options[:except]
    end

    r1 = actions.all? {|action|
      resource_routes_info_valid?(routes, controller, action, options)
    }

    r2 = actions.all? {|action|
      info = get_resource_info(controller, action)
      r_ph = info[:path_helper][0]
      r_uh = info[:url_helper][0]

      path_helper_added = controller_obj.instance_methods.include?(r_ph)
      url_helper_added = controller_obj.instance_methods.include?(r_uh)

      path_helper_added and url_helper_added
    }

    r1 and r2
  end

  def self.resources_routes_valid?(routes, resources_args)
    controller = resources_args[0].to_s
    controller_obj = controller.camelize + "Controller"
    controller_obj = eval(controller_obj)
    options = resources_args[1].nil? ? {} : resources_args[1]
    routes = Rails.application.routes.routes.to_a

    actions = [:index, :new, :create, :show, :edit, :update, :destroy]

    if options.keys.include?(:only)
      actions = options[:only]
    elsif options.keys.include?(:except)
      actions = actions - options[:except]
    end

    r1 = actions.all? {|action|
      resources_routes_info_valid?(routes, controller, action, options)
    }

    r2 = actions.all? {|action|
      info = get_resources_info(controller, action)
      r_ph = info[:path_helper][0]
      r_uh = info[:url_helper][0]

      path_helper_added = controller_obj.instance_methods.include?(r_ph)
      url_helper_added = controller_obj.instance_methods.include?(r_uh)

      path_helper_added and url_helper_added
    }

    r1 and r2
  end
end

module ActionDispatch
  module Routing
    class Mapper
      extend RDL

      spec :namespace do
        pre_task do |*args, &blk|
          RailsHelper.namespace = args[0]
        end

        post_task do |ret, *args, &blk|
          RailsHelper.namespace = nil
        end
      end

      spec :get do
        pre_task do |*args, &blk|
        end

        pre_cond do |*args, &blk|
          options = args[1] || {}
          
          if options.keys.include?(:to) 
            if options[:to].class == String
              controller = options[:to].split("#")[0]
              controller = controller.camelize
              action = options[:to].split("#")[1]

              controller_defined = Object.const_defined?(controller)

              # TODO: see if action was added. Need late binding?

              controller_defined
            else
              true
            end
          else
            true
          end
        end
      end

      spec :resource do
        pre_task do |*args, &blk|
        end

        post_task do |ret, *args, &blk|
          return true if args[0] == :session or args[0] == :password or args[0] == :registration or args[0] == :confirmation

          controller = args[0].to_s
          controller_obj = controller.pluralize.camelize + "Controller"
          controller_obj = eval(controller_obj)
          options = args[1] || {}
          routes = Rails.application.routes.routes.to_a
     
          actions = [:new, :create, :show, :edit, :update, :destroy]
          
          if options.keys.include?(:only)
            actions = options[:only]
          elsif options.keys.include?(:except)
            actions = actions - options[:except]
          end

          actions.each {|action|
            info = RailsHelper.get_resource_info(controller, action)
            r_ph = info[:path_helper]
            r_uh = info[:url_helper]

            typesig(controller_obj, r_ph[0], r_ph[1])
            typesig(controller_obj, r_uh[0], r_uh[1])
          }
        end

        post_cond do |ret, *args, &blk|
          return true if args[0] == :session or args[0] == :password or args[0] == :registration or args[0] == :confirmation

          model = args[0].to_s
          routes = Rails.application.routes.routes.to_a
     
          new_routes_valid = RailsHelper.resource_routes_valid?(routes, args)

          new_routes_valid
        end
      end
      
      # TODO: resources arg can also be a list
      spec :resources do
        pre_task do |*args, &blk|
        end

        post_task do |ret, *args, &blk|
          controller = args[0].to_s
          controller_obj = controller.camelize + "Controller"
          controller_obj = eval(controller_obj)
          options = args[1] || {}
          routes = Rails.application.routes.routes.to_a
     
          actions = [:index, :new, :create, :show, :edit, :update, :destroy]
          
          if options.keys.include?(:only)
            actions = options[:only]
          elsif options.keys.include?(:except)
            actions = actions - options[:except]
          end

          actions.each {|action|
            info = RailsHelper.get_resources_info(controller, action)
            r_ph = info[:path_helper]
            r_uh = info[:url_helper]

            typesig(controller_obj, r_ph[0], r_ph[1])
            typesig(controller_obj, r_uh[0], r_uh[1])
          }
        end

        post_cond do |ret, *args, &blk|
          model = args[0].to_s
          routes = Rails.application.routes.routes.to_a
     
          new_routes_valid = RailsHelper.resources_routes_valid?(routes, args)

          new_routes_valid
        end
      end
    end
  end
end
