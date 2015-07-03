require_relative 'type'

module RDL::Type
  # A type that is parameterized on one or more other types. The base type
  # must be a NominalType, while the parameters should be strings or symbols
  class GenericType < Type
    attr_reader :base
    attr_reader :params

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(base, *params)
      t = @@cache[[base, params]]
      return t if t
      t = GenericType.__new__(base, params)
      return (@@cache[[base, params]] = t) # assignment evaluates to t
    end

    def initialize(base, params)
      raise "base must be NominalType" unless base.instance_of? NominalType

      @base = base
      @params = params
      super()
    end

    def to_s
      "#{@base}<#{@params.map { |t| t.to_s }.join(', ')}>"
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (other.instance_of? GenericType) && (other.base == @base) && (other.params == @params)
    end

    def <=(other)
      formals, variance = $__rdl_type_params[base.name]
      # do check here to avoid hiding errors if generic type written
      # with wrong number of parameters but never checked against
      # instantiated instances
      raise TypeError, "No type parameters defined for #{base.name}" unless formals
      return true if other.instance_of? TopType
      return (@base <= other) if other.instance_of?(NominalType) # raw type
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
    
    def member?(obj)
      formals = $__rdl_type_params[base.name][0]
      raise "No type parameters defined for #{base.name}" unless formals
      return false unless base.member?(obj)
      raise RuntimeError, "member?(obj) called with instantiated obj. Use <= instead." if obj.instantiated?
      return true
    end

    def instantiate(inst)
      GenericType.new(base, *params.map { |t| t.instantiate(inst) })
    end
    
    def hash
      h = (61 + @base.hash) * @params.hash
    end
  end
end
