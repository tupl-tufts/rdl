module RDL::Type
  # Abstract base class for all types. This class
  # should never be instantiated directly.

  class TypeError < StandardError; end

  class Type

    @@contract_cache = {}

    def to_contract
      c = @@contract_cache[self]
      return c if c

      slf = self # Bind self to slf since contracts are executed in scope of associated method
      c = RDL::Contract::FlatContract.new(to_s) { |obj|
        raise TypeError, "Expecting #{to_s}, got object of class #{RDL::Util.rdl_type_or_class(obj)}" unless slf.member?(obj)
        true
      }
      return (@@contract_cache[self] = c)  # assignment evaluates to c
    end

    def nil_type?
      is_a?(SingletonType) && @val.nil?
    end

    # default behavior, override in appropriate subclasses
    def canonical
      return self
    end

  end
end
