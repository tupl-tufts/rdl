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
    def canonical; return self; end
    def optional?; return false; end
    def vararg?; return false; end

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
      left = left.type if left.is_a? NonNullType # ignore nullness!
      right = right.type if right.is_a? NonNullType
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
          new_inst = inst.dup unless inst.nil?
          if leq(left, t, new_inst, ileft)
            inst.update(new_inst) unless inst.nil?
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
      return leq(left.nominal, right, inst, ileft) if left.is_a?(SingletonType) # fall through case---use nominal type for reasoning

      # generic
      if left.is_a?(GenericType) && right.is_a?(GenericType)
        formals, variance, _ = $__rdl_type_params[left.base.name]
        # do check here to avoid hiding errors if generic type written
        # with wrong number of parameters but never checked against
        # instantiated instances
        raise TypeError, "No type parameters defined for #{base.name}" unless formals
        return false unless left.base == right.base
        return variance.zip(left.params, right.params).all? { |v, tl, tr|
          case v
          when :+
            leq(tl, tr, inst, ileft)
          when :-
            leq(tr, tl, inst, !ileft)
          when :~
            leq(tl, tr, inst, ileft) && leq(tr, tl, inst, !ileft)
          else
            raise RuntimeError, "Unexpected variance #{v}" # shouldn't happen
          end
        }
      end
      if left.is_a?(GenericType) && right.is_a?(StructuralType)
        # similar to logic above for leq(NominalType, StructuralType, ...)
        formals, variance, _ = $__rdl_type_params[left.base.name]
        raise TypeError, "No type parameters defined for #{base.name}" unless formals
        base_inst = Hash[*formals.zip(left.params).flatten] # instantiation for methods in base's class
        klass = left.base.klass
        right.methods.each_pair { |meth, t|
          return false unless klass.method_defined? meth
          types = $__rdl_info.get(klass, meth, :type)
          if types
            return false unless types.all? { |tlm| leq(tlm.instantiate(base_inst), t, nil, ileft) }
          end
        }
        return true
      end
      # Note we do not allow raw subtyping leq(GenericType, NominalType, ...)

      # method
      if left.is_a?(MethodType) && right.is_a?(MethodType)
        return false unless left.args.size == right.args.size
        return false unless left.args.zip(right.args).all? { |tl, tr| leq(tr, tl, inst, !ileft) } # contravariance
        return false unless leq(left.ret, right.ret, inst, ileft) # covariance
        if left.block && right.block
          return leq(right.block, left.block, inst, !ileft) # contravariance
        elsif left.block.nil? && right.block.nil?
          return true
        else
          return false # one has a block and the other doesn't
        end
      end
      return true if left.is_a?(MethodType) && right.is_a?(NominalType) && right.name == 'Proc'

      # structural
      if left.is_a?(StructuralType) && right.is_a?(StructuralType)
        # allow width subtyping - methods of right have to be in left, but not vice-versa
        return right.methods.all? { |m, t|
          # in recursive call set inst to nil since those method types have implicit quantifier
          left.methods.has_key?(m) && leq(left.methods[m], t, nil, ileft)
        }
      end
      # Note we do not allow a structural type to be a subtype of a nominal type or generic type,
      # even though in theory that would be possible.

      # tuple
      if left.is_a?(TupleType) && right.is_a?(TupleType)
        # Tuples are immutable, so covariant subtyping allowed
        return false unless left.params.length == right.params.length
        return false unless left.params.zip(right.params).all? { |lt, rt| leq(lt, rt, inst, ileft) }
        # subyping check passed
        left.ubounds << right
        right.lbounds << left
        return true
      end
      if left.is_a?(TupleType) && right.is_a?(GenericType) && right.base == $__rdl_array_type
        # TODO !ileft and right carries a free variable
        return false unless left.promote!
        return leq(left, right, inst, ileft) # recheck for promoted type
      end

      # finite hash
      if left.is_a?(FiniteHashType) && right.is_a?(FiniteHashType)
        # Like Tuples, FiniteHashes are immutable, so covariant subtyping allowed
        # But note, no width subtyping allowed, to match #member?
        right_elts = right.elts.clone # shallow copy
        left.elts.each_pair { |k, tl|
          if right_elts.has_key? k
            tr = right_elts[k]
            return false if tl.is_a?(OptionalType) && !tr.is_a?(OptionalType) # optional left, required right not allowed, since left may not have key
            tl = tl.type if tl.is_a? OptionalType
            tr = tr.type if tr.is_a? OptionalType
            return false unless leq(tl, tr, inst, ileft)
            right_elts.delete k
          else
            return false unless right.rest && leq(tl, right.rest, inst, ileft)
          end
        }
        right_elts.each_pair { |k, t|
          return false unless t.is_a? OptionalType
        }
        unless left.rest.nil?
          # If left has optional stuff, right needs to accept it
          return false unless !(right.rest.nil?) && leq(left.rest, right.rest, inst, ileft)
        end
        left.ubounds << right
        right.lbounds << left
        return true
      end
      if left.is_a?(FiniteHashType) && right.is_a?(GenericType) && right.base == $__rdl_hash_type
        # TODO !ileft and right carries a free variable
        return false unless left.promote!
        return leq(left, right, inst, ileft) # recheck for promoted type
      end

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
