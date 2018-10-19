module RDL::Type
  # A specialized precise type for Strings
  class PreciseStringType < Type
    attr_accessor :vals
    attr_accessor :interp, :ubounds, :lbounds

    ## @vals will be an array. For non-interpolated strings, it will only have one element, the string itself.
    ## For interpolated strings, it will include strings and RDL types, in order, where the types represent
    ## the types of the interpolated portions, and the strings represent the surrounding string parts.
    def initialize(*vals)
      @interp = false
      vals.each { |v|
        case v
        when String
          ## do nothing
        when Type
          ## interpolated string
          @interp = true
        else
          raise RuntimeError, "Attempt to create precise string type with non-string or non-type value #{v}" unless vals.all? { |v| v.is_a?(Type) || v.is_a?(String) }
        end
      }
      vals = [vals.join] if !@interp && vals.size > 1 ## if all elements of `vals` are strings, join them into one
      
      @vals = vals
      @ubounds = []
      @lbounds = []
      @promoted = false
      @cant_promote = false
      super()
    end

    def canonical
      return RDL::Globals.types[:string] if @promoted
      return self
    end

    def to_s
      return RDL::Globals.types[:string].to_s if @promoted
      printed_vals = @vals.map { |v|
        case v
        when String
          '"'+v+'"'
        when Type
          '#{' + v.to_s + '}'
        end
      }
      return printed_vals.join
    end

    def ==(other)
      return false if other.nil?
      return RDL::Globals.types[:string] == other if @promoted
      other = other.canonical
      return (other.instance_of? PreciseStringType) && (other.vals == @vals)
    end

    def member?(obj, *args)
      return false unless obj.is_a?(String)
      raise "Checking membership of PreciseStringType not currently supported for interpolated strings." unless @vals.all? { |v| v.is_a?(String) }
      return (@vals.join == obj)
    end

    def promote!
      return false if @cant_promote
      @promoted = true
      check_bounds
    end

    def check_bounds
      return (@lbounds.all? { |lbound| lbound <= self }) && (@ubounds.all? { |ubound| self <= ubound } )
    end

    def cant_promote!
      raise RuntimeError, "already promoted!" if @promoted
      @cant_promote = true
    end

    def <=(other, no_constraint=false)
      return Type.leq(self, other, no_constraint: no_constraint)
    end

    def instantiate(inst)
      return RDL::Globals.types[:string] if @promoted
      @vals.map! { |v| if v.is_a?(Type) then v.instantiate(inst) else v end }
      self
    end

    def widen
      @vals.map! { |v| if v.is_a?(Type) then v.widen else v end }
      self
    end

    def copy
      return PreciseStringType.new(*@vals.map { |v| if v.is_a?(String) then v.clone else v.copy end })
    end

    def hash
      99 * @vals.hash
    end

  end
end
