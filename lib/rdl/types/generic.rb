require_relative 'type'

module RDL::Type
  # A type that is parameterized on one or more other types. The base type
  # must be a NominalType, while the parameters can be any type.
  class GenericType < Type
    attr_reader :base
    attr_reader :params

    @@cache = {}

    class << self
      alias :__new__ :new
    end

    def self.new(base, *params)
      t = @@cache[[base, params]]
      if not t
        t = GenericType.__new__(base, params)
        @@cache[[base, params]] = t
      end
      return t
    end

    def initialize(base, params)
      raise "base must be NominalType" unless base.instance_of? NominalType

      @base = base
      @params = params
      super()
    end

    def each 
      yield @base
      @params.each {|p| yield p}
    end

    def map
      new_nominal = yield @base
      new_params = []
      params.each {|p| new_params << (yield p)}
      GenericType.new(new_nominal, *new_params)
    end

    def le(other, h={})
      if not self.get_vartypes.empty?
        raise RDL::TypeComparisonException, "self should not contain VarTypes, self = #{self}"
      end

      case other
      when GenericType        
        return false unless @base.le(other.base)
        zipped = @params.zip(other.params)
        zipped.all? {|t, u| t.le(u, h)}
      when NominalType
        if other.name.to_s == "Object"
          true
        else
          false
        end
      when TupleType
        false
      when VarType
        if h.keys.include? other.name
          h[other.name] = UnionType.new(h[other.name], self)
        else
          h[other.name] = self
        end

        true
      else
        super(other, h)
      end
    end

    def to_s
      "#{@base}<#{params.join(', ')}>"
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (other.instance_of? GenericType) && (other.base == @base) && (other.params == @params)
    end

    def hash
      h = (61 + @base.hash) * @params.hash
    end
  end
end
