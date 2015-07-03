module RDL::Type
  # Abstract base class for all types. This class
  # should never be instantiated directly.

  class TypeError < StandardError; end

  class Type

    @@contract_cache = {}

    def to_contract
      c = @@contract_cache[self]
      return c if c

      c = RDL::Contract::FlatContract.new(to_s) { |x|
        unless Type.type_of(x) <= self
          raise TypeError, "Expecting type #{to_s}, got #{x.inspect}"
        end
        true
      }
      return (@@contract_cache[self] = c)  # assignment evaluates to c
    end

    def self.type_of(obj)
      return RDL::Type::NilType.new if obj.nil? # also handled in NominalType.new
      base = RDL::Type::NominalType.new(obj.class) # the constructor is cached
      inst = (obj.respond_to? :get_instance_variable) && (obj.get_instance_variable('@__rdl_inst'))
      if inst
        return RDL::Type::GenericType.new(base, inst) # this constructor is also cached
      else
        return base
      end
    end
  end
end
