require_relative 'type'

module RDL::Type
  # A specialized GenericType for tuples, i.e., fixed-sized arrays
  class TupleType < Type
    attr_reader :params

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(*params)
      t = @@cache[params]
      return t if t
      t = TupleType.__new__(params)
      return (@@cache[params] = t) # assignment evaluates to t
    end

    def initialize(params)
      @params = params
      super()
    end

    def to_s
      "[#{@params.map { |t| t.to_s }.join(', ')}]"
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (other.instance_of? TupleType) && (other.params == @params)
    end

    def <=(other)
      raise "Unimplemented"
      formals, variance, check = $__rdl_type_params[base.name]
      # do check here to avoid hiding errors if generic type written
      # with wrong number of parameters but never checked against
      # instantiated instances
      raise TypeError, "No type parameters defined for #{base.name}" unless formals
      return true if other.instance_of? TopType
#      return (@base <= other) if other.instance_of?(NominalType) # raw subtyping not allowed
      if other.instance_of? GenericType
        return false unless @base == other.base
        return variance.zip(params, other.params).all? { |v, self_t, other_t|
          case v
          when :+
            self_t <= other_t
          when :-
            other_t <= self_t
          when :~
            self_t == other_t
          else
            raise RuntimeError, "Unexpected variance #{v}" # shouldn't happen
          end
        }
      end
      return false
    end
    
    def member?(obj, *args)
      t = RDL::Util.rdl_type obj
      return t <= self if t
      return false unless obj.instance_of?(Array) && obj.size == params.size
      return params.zip(obj).all? { |formal, actual| formal.member?(actual, *args) }
    end

    def instantiate(inst)
      TupleType.new(*params.map { |t| t.instantiate(inst) })
    end
    
    def hash
      h = 73 * @params.hash
    end
  end
end
