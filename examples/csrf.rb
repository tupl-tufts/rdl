module CSRFHelper
  def self.include2?(h, ks)
    h and h.keys.include?(ks[0]) and h[ks[0]].include?(ks[1])
  end

  def self.special_include?(obj, name)
    (obj.class == Array and obj.include?(name)) or (obj.class == Symbol and obj == name)
  end
end

module ActionController
  module Rendering
    extend RDL

    spec :process_action do
      pre_cond do
        rpc = RDL.state[:rtc_pff_called]
        rpm = RDL.state[:rtc_pff_meta]
        rpc or (not rpc and
           CSRFHelper.include2?(rpm, [self.class, :except]) and
           CSRFHelper.special_include?(rpm[self.class][:except], self.action_name.to_sym))
      end

      post_task do
        RDL.state[:rtc_pff_called] = false
      end
    end
  end

  module RequestForgeryProtection
    extend RDL 

    module ClassMethods
      extend RDL

      spec :protect_from_forgery do
        pre_task do |options|
          RDL.state[:rtc_pff_meta] = {} if not RDL.state[:rtc_pff_meta]
          RDL.state[:rtc_pff_meta][self] = options
        end
      end
    end
    
    spec :verify_authenticity_token do
      pre_task do
        RDL.state[:rtc_pff_called] = true
      end
    end
  end
end

