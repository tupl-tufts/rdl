require_relative './type'
require_relative './native'

module RDL::Type
  # A type that is parameterized on one or more other types. The base type
  # must be a NominalType, while the parameters can be any type.
  class GenericType < Type
    attr_reader :base
    attr_reader :params
    attr_accessor :dynamic
    attr_accessor :method_cache

    @@cache = RDL::NativeHash.new

    class << self
      alias :__new__ :new
    end

    def self.new(base, *params)
      # RTC has dynamic as an optional arg
      # For now we are assuming it's the last arg
      if params[-1] == true or params[-1] == false
        dynamic = params.pop
      else
        dynamic = false
      end

      t = @@cache[[base, params, dynamic]]
      if not t
        t = GenericType.__new__(base, params, dynamic)
        t.method_cache = RDL::NativeHash.new
        @@cache[[base, params, dynamic]] = t
      end

      return t
    end

    def initialize(base, params, dynamic = false)
      raise "base must be NominalType" unless base.instance_of? NominalType

      @base = base
      @params = params
      @method_cache = RDL::NativeHash.new
      @dynamic = dynamic
      super()
    end

    def each 
      yield @base
      @params.each {|p| yield p}
    end

    def parameterized?
      true
    end

    def map
      new_nominal = yield @base
      new_params = RDL::NativeArray.new
      params.each {|p| new_params << (yield p)}
      GenericType.new(new_nominal, *new_params, dynamic)
    end

    def get_method(name, which = nil, tvars = nil)
      replacement_map = tvars || RDL::NativeHash.new

      if dynamic
        # no caching here folks                          
        @base.type_parameters.each_with_index {|t_param, type_index|          
          replacement_map[t_param.symbol] ||= TypeVariable.new(t_param.symbol, self, params[type_index])
        }

        to_ret = @base.get_method(name, which).replace_parameters(replacement_map)

        if to_ret.is_a?(IntersectionType)
          to_ret.each {|type|            
            type.type_variables += replacement_map.values
          }
        else
          to_ret.type_variables += replacement_map.values
        end
        to_ret
      else
        if @method_cache[name]
          return @method_cache[name]
        end

        @base.type_parameters.each_with_index {|t_param, type_index|
          replacement_map[t_param.symbol] ||= params[type_index]
        }

        to_ret = @base.get_method(name, which, replacement_map)
        
        has_tvars =
          if to_ret.is_a?(IntersectionType)
            to_ret.types.any? {
            |type|
            not type.type_variables.empty?
          }
          else
            not to_ret.type_variables.empty?
          end
        if not has_tvars
          @method_cache[name] = to_ret
        end

        return to_ret
      end
    end

    def <=(other)
      case other
      when GenericType
        return false unless (@base <= other.base)
        
        zipped = @params.zip(other.params)

        if not @dynamic
          return false unless zipped.all? do |t, u|
            if u.instance_of?(TypeVariable)
              t <= u
            else
              t <= u and u <= t
            end
          end
        else
          return false unless zipped.all? do |t, u|
            t <= u
          end
        end
        true
      when NominalType
        if other.name.to_s == "Object"
          true
        else
          false 
        end
      when TupleType
        false
      else
        super(other)
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
