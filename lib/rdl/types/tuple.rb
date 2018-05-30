module RDL::Type
  # A specialized GenericType for tuples, i.e., fixed-sized arrays
  class TupleType < Type
    attr_reader :params
    attr_reader :array   # either nil or array type if self has been promoted to array
    attr_accessor :ubounds # upper bounds this tuple has been compared with using <=
    attr_accessor :lbounds # lower bounds...

    # no caching because array might be mutated
    def initialize(*params)
      raise RuntimeError, "Attempt to create tuple type with non-type param" unless params.all? { |p| p.is_a? Type }
      @params = params
      @array = nil # emphasize initially this is a tuple, not an array
      @cant_promote = false
      @ubounds = []
      @lbounds = []
      super()
    end

    def canonical
      return @array if @array
      return self
    end

    def to_s
      return @array.to_s if @array
      return "[#{@params.map { |t| t.to_s }.join(', ')}]"
    end

    def ==(other) # :nodoc:
      return false if other.nil?
      return (@array == other) if @array
      other = other.canonical
      return (other.instance_of? TupleType) && (other.params == @params)
    end

    alias eql? ==

    def match(other)
      return @array.match(other) if @array
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return (other.instance_of? TupleType) && (@params.length == other.params.length) && (@params.zip(other.params).all? { |t,o| t.match(o) })
    end

    def promote(t=nil)
      return false if @cant_promote
      param = UnionType.new(*@params, t)
      param = param.widen if RDL::Config.instance.promote_widen
      GenericType.new(RDL::Globals.types[:array], param)
    end

    ### TODO: similar question as in tuple types. Should [1,2,3] be promoted to Array<1 or 2 or 3> or Array<Integer>
    def promote!(t=nil)
      array = promote(t)
      return false if !array
      @array = array
      check_bounds
    end

    def check_bounds(no_promote=false)
      return (@lbounds.all? { |lbound|  lbound.<=(self, no_promote )}) && (@ubounds.all? { |ubound| self.<=(ubound, no_promote) })
    end

    def cant_promote!
      raise RuntimeError, "already promoted!" if @array
      @cant_promote = true
    end

    def <=(other, no_constraint=false)
      return Type.leq(self, other, no_constraint: no_constraint)
    end

    def member?(obj, *args)
      return @array.member?(obj, *args) if @array
      t = RDL::Util.rdl_type obj
      return t <= self if t
      return false unless obj.instance_of?(Array) && obj.size == @params.size
      return @params.zip(obj).all? { |formal, actual| formal.member?(actual, *args) }
    end

    def instantiate(inst)
      return @array.instantiate(inst) if @array
      #return TupleType.new(*@params.map { |t| t.instantiate(inst) })
      @params.map! { |t| t.instantiate(inst) }
      self
    end

    def widen
      return @array.widen if @array
      #return TupleType.new(*@params.map { |t| t.widen })
      @params.map! { |t| t.widen }
      self
    end

    def copy
      return TupleType.new(*@params.map { |t| t.copy })      
    end

    def hash
      # note don't change hash value if @array becomes non-nil
      73 * @params.hash
    end

  end
end
