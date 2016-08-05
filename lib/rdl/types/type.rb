module RDL::Type
  # Abstract base class for all types. This class
  # should never be instantiated directly.

  class TypeError < StandardError; end

  class Type

    @@contract_cache = {}

    def to_contract
      c = @@contract_cache[self]
      return c if c

      slf = self # Bind self to slf since contracts are executed in scope of associated method
      c = RDL::Contract::FlatContract.new(to_s) { |obj|
        raise TypeError, "Expecting #{to_s}, got object of class #{RDL::Util.rdl_type_or_class(obj)}" unless slf.member?(obj)
        true
      }
      return (@@contract_cache[self] = c)  # assignment evaluates to c
    end

    def nil_type?
      is_a?(SingletonType) && @val.nil?
    end

    # default behavior, override in appropriate subclasses
    def canonical
      return self
    end

    # [+ other +] is a Type
    # [+ inst +] is a Hash<Symbol, Type> representing an instantiation
    # [+ ileft +] is a %bool
    # if inst is nil, returns self <= other
    # if inst is non-nil and ileft, returns inst(self) <= other, possibly mutating inst to make this true
    # if inst is non-nil and !ileft, returns self <= inst(other), again possibly mutating inst
    def self.leq(left, right, inst=nil, ileft=true)
      left = inst[left.name] if inst && ileft && left.is_a?(VarType) && inst[left.name]
      right = inst[right.name] if inst && !ileft && right.is_a?(VarType) && inst[right.name]
      left = left.type if left.is_a? DependentArgType
      right = right.type if right.is_a? DependentArgType
      left = left.canonical
      right = right.canonical

      # top and bottom
      return true if left.is_a? BotType
      return true if right.is_a? TopType

      # type variables
      begin inst.merge!(left.name => right); return true end if inst && ileft && left.is_a?(VarType)
      begin inst.merge!(right.name => left); return true end if inst && !ileft && right.is_a?(VarType)
      if left.is_a?(VarType) && right.is_a?(VarType)
        return left.name == right.name
      end

      # union
      return left.types.all? { |t| leq(t, right, inst, ileft) } if left.is_a?(UnionType)
      if right.instance_of?(UnionType)
        right.types.each { |t|
          # return true at first match, updating inst accordingly to first succeessful match
          new_inst = inst.dup
          if leq(left, t, new_inst, ileft)
            inst.update(new_inst)
            return true
          end
        }
        return false
      end

      # nominal
      return left.klass.ancestors.member?(right.klass) if left.is_a?(NominalType) && right.is_a?(NominalType)
      if left.is_a?(NominalType) && right.is_a?(StructuralType)
        right.methods.each_pair { |m, t|
          return false unless left.klass.method_defined? m
          types = $__rdl_info.get(left.klass, m, :type)
          if types
            return false unless types.all? { |tlm| leq(tlm, t, nil, ileft) }
            # inst above is nil because the method types inside the class and
            # inside the structural type have an implicit quantifier on them. So
            # even if we're allowed to instantiate type variables we can't do that
            # inside those types
          end
        }
        return true
      end

      # singleton
      return left.val == right.val if left.is_a?(SingletonType) && right.is_a?(SingletonType)
      return true if left.is_a?(SingletonType) && left.val.nil? # right cannot be a SingletonType due to above conditional
      return leq(left.nominal, right, inst, ileft) if left.is_a?(SingletonType) && right.is_a?(NominalType)


      return false
    end
  end

  # [+ a +] is an Array<Type> that may contain union types.
  # returns Array<Array<Type>> containing all possible expansions of the union types.
  # For example, slightly abusing notation:
  #
  # expand_product [A, B]           #=> [[A, B]]
  # expand_product [A or B, C]      #=> [[A, C], [B, C]]
  # expand_product [A or B, C or D] #=> [[A, C], [B, C], [A, D], [B, D]]
  def self.expand_product(a)
    return [[]] if a.empty? # logic below only applies if at least one element
    a.map! { |t| t.canonical }
    counts = a.map { |t| if t.is_a? UnionType then t.types.length - 1 else 0 end }
    res = []
    # now iterate through ever combination of indices
    # using combinations is not quite as memory efficient as inlining that code here,
    # but it's a lot easier to think about combinations separate from this code
    combinations(counts).each { |inds|
      tmp = []
      # set tmp to be a with elts in positions in ind selected from unions
      a.each_with_index { |t, i| if t.is_a? UnionType then tmp << t.types[inds[i]] else tmp << t end }
      res << tmp
    }
    return res
#    return [a]
  end

private

  # [+ a +] is Array<Fixnum>
  # returns Array<Array<Fixnum>> containing all combinations of 0..a[i] at index i
  # For example:
  #
  # combinations [0, 0]  #=> [[0, 0]]
  # combinations [1, 0]  #=> [[0, 0], [1, 0]]
  # combinations [1, 1]  #=> [[0, 0], [0, 1][, [1, 0], [1, 1]]]
  #
  # yes, this is used in expand_product above!
  def self.combinations(a)
    cur = a.map { |x| 0 }
    res = []
    while ((cur <=> a) < 1) # Array#<=> uses lexicographic order, so this will repeat until cur == a
      res << cur.dup
      i = cur.length - 1 # start at right since want next in lexicographic order
      while i >= 0
        cur[i] += 1
        break if (cur[i] <= a[i]) # increment did not overflow position, or it overflowed in position 0 so allow inc to break outer loop
        cur[i] = 0 unless i == 0 # increment overflowed; reset to 0 and continue looping, except allow overflow to exit when i == 0
        i -= 1
      end
    end
    return res
  end

end
