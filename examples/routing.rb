module Kernel
  def qualified_const_get(str)
    path = str.to_s.split('::')
    from_root = path[0].empty?
    if from_root
      from_root = []
      path = path[1..-1]
    else
      start_ns = ((Class === self)||(Module === self)) ? self : self.class
      from_root = start_ns.to_s.split('::')
    end
    until from_root.empty?
      begin
        return (from_root+path).inject(Object) { |ns,name| ns.const_get(name) }
      rescue NameError
        from_root.delete_at(-1)
      end
    end
    path.inject(Object) { |ns,name| ns.const_get(name) }
  end
end

module RoutingHelper
  def self.get_class(ns, name)
    qualified_name = use_namespace ns, name
    p "Getting class #{qualified_name}"
    qualified_const_get qualified_name
  end

  def self.class_exists?(ns, name)
    c = get_class ns, name
    c.is_a? Class
  rescue NameError
    false
  end

  def self.use_namespace(ns, name)
    unless not ns or ns.empty?
      ns.join("::") << "::" << name
    else
      name
    end
  end

  def self.extend_namespace(ns, name)
    if ns
    then ns.push(name)
    else [name]
    end
  end

  def self.retract_namespace(ns, name)
    raise Exception, "Expected namespace, got #{ns}" unless ns
    last = ns.pop
    raise Exception, "Last item #{last} didn't match #{name}" unless last == name
    ns
  end
end

class ActionDispatch::Routing::RouteSet
  extend RDL

  logging_spec = RDL.create_spec do |name|
    pre_task do |*args|
      p "Entering #{name} on #{self}"
    end
    
    post_task do |*args|
      p "Exiting #{name} on #{self}"
    end
  end
  
  spec :draw do
    include_spec logging_spec, "draw"
    dsl do
      def check_resources(name, options)
        name = options[:controller] if options[:controller]
        RoutingHelper.class_exists? @dsl_namespace, "#{name.camelize}Controller"
      end

      spec :get do
        include_spec logging_spec, "get"
      end
      spec :post do
        include_spec logging_spec, "post"
      end
      spec :namespace do
        pre_task do |name|
          @dsl_namespace = RoutingHelper.extend_namespace(@dsl_namespace,name.to_s.camelize)
        end
        post_task do |ret, name|
          @dsl_namespace = RoutingHelper.retract_namespace(@dsl_namespace,name.to_s.camelize)
        end
      end
      spec :resources do
        pre_cond do |*args, options|
          args.all? do |a|
            check_resources a.to_s, options
          end
        end
        # post_cond do |ret, *args|
        #   args.all? do |a|
        #     if a.is_a? String or a.is_a? Symbol
        #     then 
        #       # how to get the Application?
        #       app.method_defined? "#{a.downcase}_path"
        #     else true
        #     end
        #   end
        # end
        include_spec logging_spec, "resources"
      end
      spec :resource do
        pre_cond do |*args, options|
          args.all? do |a|
            a = a.to_s.pluralize
            check_resources a, options
          end
        end
        include_spec logging_spec, "resource"
      end
      spec :collection do
        include_spec logging_spec, "collection"
      end
      spec :member do
        include_spec logging_spec, "member"
      end
    end
  end
end
