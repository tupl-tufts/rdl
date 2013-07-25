module BFHelper
  def self.has_instance_method?(obj, method)
    m = method.to_sym
    obj.public_instance_methods.include?(m) or
      obj.private_instance_methods.include?(m) or
      obj.protected_instance_methods.include?(m)
  end
end

module AbstractController::Callbacks::ClassMethods
  extend RDL

  check_method_spec = RDL.create_spec do 
    pre_task do |*filters|
      RDL.state[:filter_methods] = [] if not RDL.state[:before_filter_methods]
      RDL.state[:filter_methods].push([filters, self])
    end    

    pre_cond "method listed both as :except and :only" do |method_name, h|
      only_opt = h[:only]
      except_opt = h[:except]

      if only_opt and except_opt 
        only_opt.all? {|m|
          not except_opt.include?(m)
        }
      else
        true
      end
    end
  end

  spec :before_filter do
    include_spec check_method_spec
  end

  spec :prepend_before_filter do
    include_spec check_method_spec
  end

  spec :skip_before_filter do
    include_spec check_method_spec
  end

  spec :append_before_filter do
    include_spec check_method_spec
  end

  spec :after_filter do
    include_spec check_method_spec
  end

  spec :prepend_after_filter do
    include_spec check_method_spec
  end

  spec :skip_after_filter do
    include_spec check_method_spec
  end

  spec :append_after_filter do
    include_spec check_method_spec
  end

  spec :around_filter do
    include_spec check_method_spec
  end

  spec :prepend_around_filter do
    include_spec check_method_spec
  end

  spec :skip_around_filter do
    include_spec check_method_spec
  end

  spec :append_around_filter do
    include_spec check_method_spec
  end
end

class ActionDispatch::Routing::RouteSet::Dispatcher
  extend RDL
  
  spec :controller_reference do
    post_cond "filter has undefined method" do |controller|
      methods = []
      
      bfm = RDL.state[:filter_methods]
      bfm and bfm.each {|e| methods.push(e) if e[1] == controller }
      
      methods.all? { |e|
        options = e[0]
        m = options[0]
        method_found = BFHelper.has_instance_method?(controller, m)
        if options.size > 1
          only_methods = options[1][:only]
          except_methods = options[1][:except]
          only_except_methods = []

          [only_methods, except_methods].each {|t|
            if t
              t.each {|i|
                only_except_methods.push(i)
              }
            end
          }

          method_found and only_except_methods.all? {|n|
            BFHelper.has_instance_method?(controller, n)
          }
        else method_found
        end
      }
    end
    
  end
end
