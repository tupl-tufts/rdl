require_relative 'type'

module RDL::Type
  # A type that is parameterized on one or more other types. The base type
  # must be a NominalType or self, while the parameters should be strings or symbols
  class GenericType < Type
    attr_reader :base
    attr_reader :params

    def initialize(base, *params)
      raise RuntimeError, "Attempt to create generic type with non-type param" unless params.all? { |p| p.is_a? Type }
      raise "base must be NominalType or self, got #{base} of type #{base.class}" unless ((base.instance_of? NominalType) || ((base.instance_of? VarType) && (base.name.to_s == "self")))
      @base = base
      @params = params
      super()
    end

    def to_s
      "#{@base}<#{@params.map { |t| t.to_s }.join(', ')}>"
    end

    def ==(other) # :nodoc:
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? GenericType) && (other.base == @base) && (other.params == @params)
    end

    alias eql? ==

    def match(other)
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return false unless other.instance_of? GenericType
      return @params.length == other.params.length && @params.zip(other.params).all? { |t,o| t.match(o) }
    end

    def <=(other)
      return Type.leq(self, other)
    end

    def member?(obj, *args)
      raise "No type parameters defined for #{base.name}" unless RDL::Globals.type_params[base.name]
#      formals = RDL::Globals.type_params[base.name][0]
      t = RDL::Util.rdl_type obj
      return t <= self if t
      return false unless base.member?(obj, *args)
      return true
    end

    def instantiate(inst)
      GenericType.new(base.instantiate(inst), *params.map { |t| t.instantiate(inst) })
    end

    def widen
      GenericType.new(base.widen, *params.map { |t| t.widen })
    end

    def copy
      GenericType.new(base.copy, *params.map { |t| t.copy })
    end

    def hash
      (61 + @base.hash) * @params.hash
    end

    def to_inst
      return RDL::Globals.type_params[base.name][0].zip(@params).to_h
    end
  end
end
