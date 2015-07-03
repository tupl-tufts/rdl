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

    def member?(obj, inst: nil)
      formals, variance = $__rdl_type_params[base.name]
      raise "No type parameters defined for #{base.name}" unless formals # do check here to avoid hiding errors if generic type written with wrong number of parameters but never checked against instantiated instances
      return false unless base.member?(obj, inst: inst)
      return true unless obj.instantiated? # if obj is not instantiated, only its base class needs to match
      # If obj is instantiated, check that its type is a subtype of self's type
      params = params.map { |t| t.instantiate(inst) } # instantiate parameters according to currently bound type vars
      raise "Generic type #{base.to_s} expects #{formals.size} arguments, got #{params.size} " unless formals.size == @params.size
      obj_type = GenericType.new(@base, *(obj.instance_variable.get('@rdl__inst')))
      return (obj_type <= GenericType.new(@base, *params))
    end

    def instantiate(inst)
      GenericType.new(base, *params.map { |t| t.instantiate(inst) })
    end
    
    def hash
      h = (61 + @base.hash) * @params.hash
    end
  end
end
