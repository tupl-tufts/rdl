require_relative 'type'

module RDL::Type
  class DependentArgType < Type
    attr_reader :name
    attr_reader :type
    attr_reader :predicate

# Note: Named argument types aren't hashconsed.

    def initialize(name, type, predicate)
      @name = name
      @type = type
      /\{\{(.+)\}\}/ =~ predicate
      @predicate = $1
      raise RuntimeError, "Attempt to create annotated type with non-type" unless type.is_a? Type
      raise RuntimeError, "Attempt to create doubly annotated type" if (type.is_a? AnnotatedArgType)||(type.is_a? DependentArgType)
      super()
    end

    def to_s
      "#{@type.to_s} #{@name} {#{@predicate}}"
    end

    def eql?(other)
      self == other
    end

    def ==(other) # :nodoc:
      return (other.instance_of? DependentArgType) && (other.name == @name) && (other.type == @type)
    end

    # doesn't have a match method - queries shouldn't have annotations in them

    def hash # :nodoc:
      return (57 + @name.hash) * @type.hash
    end

    def member?(obj, *args)
      @type.member?(obj, *args)
    end

    def instantiate(inst)
      return DependentArgType.new(@name, @type.instantiate(inst),@predicate)
    end
  end
end
