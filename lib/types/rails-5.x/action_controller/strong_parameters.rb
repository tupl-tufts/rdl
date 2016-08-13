# TODO: This is all a bit of a hack. Right now, ActionControll::Parameters has its [] method set appropriately during the context
# of the next method by params_types. But that doesn't quite match what actually happens in Rails.

class ActionController::Base

  # [+ typ_hash +] is a Hash<Symbol, String>, where the keys are the parameter names and the Strings are the corresponding types
  # adds these parameters to the `params` hash in the immediately following controller method
  def self.params_type(typs)
    # TODO: Ick, this is ugly. Once it's obvious how to generalize this kind of reasoning to other cases, clean this up!
    typs.each_pair { |param, param_type|
      param_type = $__rdl_parser.scan_str "#T #{param_type}"
      meth_type = $__rdl_parser.scan_str "(#{param.inspect}) -> #{param_type}" # given singleton symbol arg, get param's return type
      $__rdl_deferred << [self, :context_types, [ActionController::Parameters, :[], meth_type], class_check: self]
    }
  end
end

module ActionController
  module StrongParameters
    type :params, '() -> ActionController::Parameters'
  end
end
