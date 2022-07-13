require_relative 'nominal'

module RDL::Type
  # A type that represents serialized JSON. It is a subtype of string, but
  # the typed structure of the JSON.
  class JSONType < NominalType

    #attr_reader :schema # FiniteHashType

    def self.new(schema_s)
      super "String"

      # TODO: call super constructor of NominalType
      #raise "test"
      raise "Tried to construct a JSONType with an invalid schema! #{schema_s}" unless schema_s.instance_of? FiniteHashType
      @schema = schema_s
    end

    def to_s
      "JSON<#{@schema.to_s}>"
    end

  end
end

