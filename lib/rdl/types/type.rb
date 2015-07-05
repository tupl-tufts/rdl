module RDL::Type
  # Abstract base class for all types. This class
  # should never be instantiated directly.

  class TypeError < StandardError; end

  class Type

    @@contract_cache = {}

    def check_member_or_leq(obj, msg = "")
      if obj.instance_variable_defined? '@__rdl_type'
        t = obj.get_instance_variable '@__rdl_type'
        raise TypeError, "#{msg}Expecting #{to_s}, got object #{obj.inspect} of type #{t.to_s}" unless t <= self
      else
        raise TypeError, "#{msg}Expecting #{to_s}, got object #{obj.inspect}" unless member? obj
      end
    end
    
    def to_contract
      c = @@contract_cache[self]
      return c if c

      c = RDL::Contract::FlatContract.new(to_s) { |obj|
        check_member_or_leq(obj)
        true
      }
      return (@@contract_cache[self] = c)  # assignment evaluates to c
    end

  end
end
