require_relative './type'

module RDL::Type
  class StructuralType < Type
    attr_reader :methods

    # Create a new StructuralType.
    #
    # [+methods+] Map from method names as symbols to their types.
    def initialize(methods)
      @methods = methods
      super
    end

    def to_s  # :nodoc:
      "[ " + @methods.to_a.map { |k,v| "#{k}: #{v}" }.join(", ") + " ]"
    end

    def ==(other)  # :nodoc:
      return other.instance_of? StructuralType && other.methods == @methods
    end

    def hash  # :nodoc:
      @methods.hash
    end
  end
end
