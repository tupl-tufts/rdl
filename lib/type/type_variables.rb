require_relative './type'

module RDL::Type
  class TypeVariable < Type
    attr_reader :solving
    attr_reader :instantiated
    attr_reader :name
    attr_reader :parent

    def initialize(param_name, parent, initial_type = nil)
      @instantiated = false
      @solving = false
      @constraints = initial_type ? [initial_type] :  []
      @name = param_name
      @parent = parent
      super()
    end

    alias solving? solving
    alias instantiated? instantiated
    
    def replace_parameters(_t_vars)
      self
    end
    
    def has_variables
      return @type.has_variables if instantiated?
      return false
    end
    
    def map
      yield self
    end

    def each
      yield self
    end

    def get_type
      @type
    end

    def _to_actual_type
      if @instantiated
        @type
      elsif @solving
        @instantiated = true
        @solving = false
        @type = NilType.instance
      else
        raise "attempt to coerce and unsolved type variable to a real type. this is an error"
      end
    end
    
    def add_constraint(type)
      @constraints.push(type)
    end
    
    def start_solve
      @solving = true
    end
    
    def solve
      @instantiated = true
      @solving = false

      if @constraints.empty?
        raise "Error, could not infer the types #{id}"
      else
        @type = UnionType.new(*@constraints)
      end
    end

    def solvable?
      return false if @instatianted
      return false unless @solving
      not @constraints.empty?
    end

    def is_tuple
      return @type.is_tuple if instantiated?
      false
    end

    def to_s
      if @instantiated
        @type.to_s
      elsif @solving
        "[#{name} = #{@constraints}]"
      else
        name
      end
    end

    def is_tuple
      return @type.is_tuple if instantiated?
      false
    end

    def <=(other)
      if @instantiated
        return @type <= other
      end

      if self.instance_of?(TypeVariable) and other.instance_of?(TypeVariable) and other.parent.object_id  == self.parent.object_id
        return true
      end
      #TODO(jtoman): refine this later, what to do during solving, etc                                                                                     
      false
    end
  end
end
