require_relative 'type'

module RDL::Type
  class DependentArgType < Type
    attr_reader :name
    attr_reader :type
    attr_reader :predicate

    def initialize(name, type, predicate)
      @name = name
      @type = type
      @predicate = predicate
      raise RuntimeError, "Attempt to create annotated type with non-type" unless type.is_a? Type
      raise RuntimeError, "Attempt to create doubly annotated type" if (type.is_a? AnnotatedArgType) || (type.is_a? DependentArgType)
      super()
    end

    def to_s
      return "#{@type.to_s} #{@name} {{#{@predicate}}}"
    end

    def ==(other) # :nodoc:
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? DependentArgType) && (other.name == @name) && (other.type == @type)
    end

    alias eql? ==

    # match on the base type, ignoring refinement
    def match(other)
      return @type.match(other)
    end

    def hash # :nodoc:
      return (57 + @name.hash) * @type.hash
    end

    # ignore refinement in comparison for now
    def <=(other)
      return @type <= other
    end

    def leq_inst(other, inst=nil, ileft=true)
      return @type.leq_inst(other, inst, ileft)
    end

    def member?(obj, *args)
      return @type.member?(obj, *args)
    end

    def instantiate(inst)
      return DependentArgType.new(@name, @type.instantiate(inst), @predicate)
    end
  end
end
