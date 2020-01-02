module RDL::Type
  class ChoiceType < Type

    class << self
      alias :__new__ :new
    end
    
    ## variational typing!
    attr_accessor :choices, :connecteds
    attr_accessor :ubounds # upper bounds this ChoiceType has been compared with using <=
    attr_accessor :lbounds # lower bounds...
    attr_reader :activated # a Type when one arm of this ChoiceTypes is activated, nil otherwise

    # [+ choices +] is a Hash<Integer, Type>, where the keys are the distinct numbers of every chocie,
    # and the values are the diferent Type choices.
    # [+ connecteds +] is an Array<Type> of connected ChoiceTypes which are jointly chosen over.
    # All connecteds should have the same choice numbers
    def initialize(choices, connecteds=[])
      raise "Expected at least one choice." if choices.size == 0
      raise "Expected Hash<Integer, Type>, got #{choices}." unless choices.is_a?(Hash) && choices.keys.all? { |k| k.is_a?(Integer) } && choices.values.all? { |v| v.is_a?(Type) }
      raise "Expected Array of ChoiceTypes, got #{connecteds}." unless connecteds.is_a?(Array)&& connecteds.all? { |t| t.is_a?(ChoiceType) }
      @choices = choices
      @connecteds = connecteds
      @ubounds = []
      @lbounds = []
      @activated = nil
      @hash = 101 + @choices.hash
    end

    def add_connecteds(*connecteds)
      connecteds.each { |c|
        raise "Expected ChoiceType, got #{c}." unless c.is_a?(ChoiceType)
        @connecteds << c unless self.equal? c
      }
    end

    def <=(other)
      return Type.leq(self, other)
    end
    
    def to_s
      typs = []
      @choices.each { |choice, typ|
        typs << (choice.to_s + " => " + typ.to_s)
      }
      "<< " + typs.join(", ") + " >>"
    end

    def ==(other) # :nodoc:
      return false if other.nil?
      return (other.instance_of? ChoiceType) && (other.choices == @choices) ## include connecteds here?
    end

    alias eql? ==
    
    def remove!(choice, removed_hash: {})
      raise "Expected integer, got #{choice}." unless choice.is_a? Integer
      removed = @choices.delete(choice)
      removed_hash[self] ||= {}
      removed_hash[self][choice] = removed
      raise "Bounds violation after removing choice #{choice} type #{removed} from ChoiceType #{self}" unless check_bounds
      @connecteds.each { |t| t.remove!(choice, removed_hash: removed_hash) if t.choices.has_key?(choice) }
    end

    def check_bounds
      return (@lbounds.all? { |lbound| lbound <= self }) && (@ubounds.all? { |ubound| self <= ubound })
    end

    def canonical
      return @activated if @activated
      @choices = @choices.transform_values { |v| v.canonical }
      return @choices.values[0] if (@choices.values.uniq.size == 1)
      self
    end

    def activate(choice)
      raise "No choice #{choice} for this ChoiceType." unless @choices.has_key?(choice)
      @activated = @choices[choice]
    end

    def deactivate
      @activated = nil
    end

    def activate_all_connected(choice)
      activate(choice)
      @connecteds.each { |c| c.activate(choice) }
    end

    def deactivate_all_connected
      @activated = nil
      @connecteds.each { |c| c.deactivate }
    end

    def instantiate(inst)
      # Following the lead of Tuples and FHTs, this instantiate method will actually mutate self.
      @choices.each { |choice, t|
        @choices[choice] = t.instantiate(inst)
      }
      self
    end

    def add_choices(choices)
      raise "Expected Hash<Integer, Type>, got #{choices}" unless choices.is_a?(Hash) && choices.keys.all? { |k| k.is_a?(Integer) } && choices.values.all? { |t| t.is_a?(Type) }
      choices.each { |num, t|
        raise "Tried to add choice { #{num} => #{t} } to #{self}, but choice ##{num} already exists." if @choices.has_key?(num)
        @choices[num] = t
      }
    end

    def copy
      new_choices = {}
      @choices.each { |num, t| new_choices[num] = t.copy }
      new_connecteds = @connecteds.map { |c| RDL::Type::ChoiceType.new(c.choices.transform_values { |t| t.copy }) }
      new_self = ChoiceType.new(new_choices, new_connecteds)
      new_connecteds.each { |c| c.add_connecteds(*([new_self] + new_connecteds)) }
      new_self
    end

    def hash
      @hash
    end

  end  
end
