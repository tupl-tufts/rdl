module RDL::Type
  class ChoiceType < VarType
    ## variational typing!
    attr_accessor :choices, :connecteds

    # [+ choices +] is a Hash<Integer, Type>, where the keys are the distinct numbers of every chocie,
    # and the values are the diferent Type choices.
    # [+ connecteds +] is an Array<Type> of connected ChoiceTypes which are jointly chosen over.
    # All connecteds should have the same choice numbers
    def initialize(choices, connecteds=[])
      raise "Expected at least one choice." if choices.size == 0
      raise "Expected Hash<Integer, Type>, got #{choices}." unless choices.is_a?(Hash) && choices.keys.all? { |k| k.is_a?(Integer) } && choices.values.all { |v| v.is_a?(Type) }
      raise "Expected Array of ChoiceTypes type." unless connecteds.is_a?(Array)&& connecteds.all? { |t| t.is_a?(ChoiceType) }
      @choices = choices
      @connecteds = connecteds
    end

    def add_connecteds(*connecteds)
      connecteds.each { |c|
        raise "Expected ChoiceType, got #{c}." unless c.is_a?(ChoiceType)
        @connecteds << c unless self.equal? c
      }
    end

    def to_s
      "~~ #{connecteds} ~~"
    end

  end
end
