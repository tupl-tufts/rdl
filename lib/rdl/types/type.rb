module RDL::Type
  # Abstract base class for all types. This class
  # should never be instantiated directly.

  class TypeError < StandardError; end

  class Type
    @@contract_cache = {}

    def solution
      @solution
    end

    def solution=(soln)
      @solution = soln
      RDL::Logging.log :typecheck, :warning, "Solution written to #{self.class}"
    end

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

    def var_type?
      is_a?(VarType)
    end

    def optional_var_type?
      is_a?(OptionalType) && @type.var_type?
    end

    def vararg_var_type?
      is_a?(VarargType) && @type.var_type?
    end

    def fht_var_type?
      is_a?(FiniteHashType) && @elts.keys.all? { |k| k.is_a?(Symbol) } && @elts.values.all? { |v| v.optional_var_type? || v.var_type? }
    end

    def kind_of_var_input?
      var_type? || optional_var_type? || fht_var_type? || vararg_var_type?
    end

    # default behavior, override in appropriate subclasses
    def canonical; return self; end
    def optional?; return false; end
    def vararg?; return false; end

    # [+ other +] is a Type
    # [+ inst +] is a Hash<Symbol, Type> representing an instantiation
    # [+ ileft +] is a %bool
    # [+ deferred_constraints +] is an Array<[Type, Type]>. When provided, instead of applying
    # constraints to VarTypes, we simply defer them by putting them in this array.
    # [+ no_constraint +] is a %bool indicating whether or not we should add to tuple/FHT constraints
    # [+ ast +] is a parser expression, used for printing error messages when VarType constraints are violated.
    # [+ propagate +] is a %bool indicating whether or not VarType constraints should be propagated.
    # [+ new_cons +] is a set of all new contraints generated on VarTypes, which may be rolled back if they are
    # from heuristic guesses.
    # [+ removed_choices +] is a Hash<ChoiceType, Hash<Integer, Type>> mapping ChoiceTypes to choices removed
    # from that ChoiceType. These removals may be rolled back in certain cases.
    # if inst is nil, returns self <= other
    # if inst is non-nil and ileft, returns inst(self) <= other, possibly mutating inst to make this true
    # if inst is non-nil and !ileft, returns self <= inst(other), again possibly mutating inst
    def self.leq(left, right, inst=nil, ileft=true, deferred_constraints=nil, no_constraint: false, ast: nil, propagate: false, new_cons: {}, removed_choices: {})
      #propagate = false
      left = inst[left.name] if inst && ileft && left.is_a?(VarType) && !left.to_infer && inst[left.name]
      right = inst[right.name] if inst && !ileft && right.is_a?(VarType) && !right.to_infer && inst[right.name]
      left = left.type if left.is_a?(DependentArgType) || left.is_a?(AnnotatedArgType)
      right = right.type if right.is_a?(DependentArgType) || right.is_a?(AnnotatedArgType)
      left = left.type if left.is_a? NonNullType # ignore nullness!
      right = right.type if right.is_a? NonNullType
      left = left.canonical
      right = right.canonical
      return true if left.equal?(right)

      # top and bottom
      return true if left.is_a? BotType
      return true if right.is_a? TopType

      # dynamic
      return true if left.is_a? DynamicType
      return true if right.is_a? DynamicType

      # type variables
      begin inst.merge!(left.name => right); return true end if inst && ileft && left.is_a?(VarType) && !left.to_infer
      begin inst.merge!(right.name => left); return true end if inst && !ileft && right.is_a?(VarType) && !right.to_infer
      if left.is_a?(VarType) && !left.to_infer && right.is_a?(VarType) && !right.to_infer
        return left.name == right.name
      elsif left.is_a?(VarType) && left.to_infer && right.is_a?(VarType) && right.to_infer
        if deferred_constraints.nil?
          left.add_ubound(right, ast, new_cons, propagate: propagate) unless (left.ubounds.any? { |t, loc| t == right || t.hash == right.hash } || left.equal?(right)) ## Added this last one for ChoiceTypes, because the ChoiceType can change but the hash does not.
          right.add_lbound(left, ast, new_cons, propagate: propagate) unless (right.lbounds.any? { |t, loc| t == left || t.hash == left.hash } || right.equal?(left))
        else
          deferred_constraints << [left, right]
        end
        return true
      elsif left.is_a?(VarType) && left.to_infer
        if deferred_constraints.nil?
          left.add_ubound(right, ast, new_cons, propagate: propagate) unless (left.ubounds.any? { |t, loc| t == right || t.hash == right.hash } || left.equal?(right))
        else
          deferred_constraints << [left, right]
        end
        return true
      elsif right.is_a?(VarType) && right.to_infer

        RDL::Logging.log :typecheck, :trace, "#{right}.is_a VarType"
        RDL::Logging.log :typecheck, :trace, "\t#{left} <= #{right}"
        if deferred_constraints.nil?
          RDL::Logging.log :typecheck, :trace, 'no deferred_constraints'
          right.add_lbound(left, ast, new_cons, propagate: propagate) unless (right.lbounds.any? { |t, loc| t == left || t.hash == left.hash } || right.equal?(left))
        else
          RDL::Logging.log :typecheck, :trace, 'deferred_constraints:'
          deferred_constraints << [left, right]
          deferred_constraints.each { |k, v| if v.is_a?(Array) then v.each { |v| RDL::Logging.log(:typecheck, :trace, "#{k} <= #{v[1] || v}") } else RDL::Logging.log(:typecheck, :trace, "#{k} <= #{v}") end }
        end
        return true
      end

      ## choice types
      if left.is_a?(ChoiceType) && right.is_a?(ChoiceType)
        ## ChoiceTypes can't contain VarTypes to be inferred within them, so no need to worry about constraints here.
        if left.connecteds.include?(right)
          ## if left and right are connected, left <= right whenever each individual left choice is <= the corresponding right choice
          left.choices.each { |choice, t|
            return false unless right.choices.has_key? choice
            return false unless t <= right.choices[choice]
          }
          return true
        else
          ## if left and right are not connected, each left choice must be <= all right choices
          raise "Not currently supported." if (left.choices.values + right.choices.values).any? { |t| t.is_a?(VarType) }
          lsafe_choices = []
          rsafe_choices = []
          left.choices.each { |lchoice, lt|
            right.choices.each { |rchoice, rt|
              if lt <= rt
                lsafe_choices << lchoice unless lsafe_choices.include? lchoice
                rsafe_choices << rchoice unless rsafe_choices.include? rchoice
              end
            }
          }
          if lsafe_choices.empty?
            return false
          else
            ## There are some safe choices. Remove the unsafe ones and return true
            left.choices.each { |num, _| left.remove!(num) unless lsafe_choices.include?(num) }
            right.choices.each { |num, _| right.remove!(num) unless rsafe_choices.include?(num) }
            return true
          end
        end
      elsif left.is_a?(ChoiceType) || right.is_a?(ChoiceType)
        if left.is_a?(ChoiceType)
          main_ct = left
          lct = true
        else
          main_ct = right
          lct = false
        end
        to_remove = []
        ub_var_choices = Hash.new { |h, k| h[k] = {} } # Hash<VarType, Hash<Integer, Type>>. The keys are tactual arguments that are VarTypes. The values are choice hashes, to be turned into ChoiceTypes that will be upper bounds on the keys.
        lb_var_choices = Hash.new { |h, k| h[k] = {} } # same as above, but values are lower bounds on keys.
        main_ct.choices.each { |num, t|
          new_dcs = []
          check = lct ? Type.leq(t, right, inst, ileft, new_dcs, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices) : Type.leq(left, t, inst, ileft, new_dcs, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
          if check
            new_dcs.each { |t1, t2|
              ub_var_choices[t1][num] = RDL::Type::UnionType.new(ub_var_choices[t1][num], t2).canonical if t1.is_a?(VarType)
              lb_var_choices[t2][num] = RDL::Type::UnionType.new(lb_var_choices[t2][num], t1).canonical if t2.is_a?(VarType)
            }
          else
            to_remove << num
          end
        }

        if to_remove.size == main_ct.choices.size
          return false
        else
          to_remove.each { |num| main_ct.remove!(num) }
          if !((lb_var_choices.empty?) && (ub_var_choices.empty?))
            all_cts = []
            ub_var_choices.each { |vartype, choice_hash|
              if choice_hash.values.uniq.size == 1
                RDL::Type::Type.leq(vartype, choice_hash.values[0], nil, false, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
              else
                t = RDL::Type::ChoiceType.new(choice_hash)
                RDL::Type::Type.leq(vartype, t, nil, false, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
                all_cts << t
              end
            }

            lb_var_choices.each { |vartype, choice_hash|
              RDL::Logging.log :typecheck, :trace, vartype.to_s
              if choice_hash.values.uniq.size == 1
                RDL::Type::Type.leq(choice_hash.values[0], vartype, nil, false, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
              else
                t = RDL::Type::ChoiceType.new(choice_hash)
                RDL::Type::Type.leq(t, vartype, nil, false, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
                all_cts << t
              end
            }
            (all_cts + [main_ct]).each { |ct| ct.add_connecteds(*(all_cts+ [main_ct])) }
          end
        end
        return true
      end

      # union
      return left.types.all? { |t| leq(t, right, inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices) } if left.is_a?(UnionType)
      if right.instance_of?(UnionType)
        right.types.each { |t|
          # return true at first match, updating inst accordingly to first succeessful match
          new_inst = inst.dup unless inst.nil?
          #new_rc = {}
          if leq(left, t, new_inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)#new_rc)
            inst.update(new_inst) unless inst.nil?
            return true
          else
            ## if a particular arm doesn't apply, undo the
            #removed_choices.each { |
          end
        }
        return false
      end

      # intersection
      return right.types.all? { |t| leq(left, t, inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices) } if right.instance_of?(IntersectionType)
      return left.types.any? { |t| leq(t, right, inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices) } if left.is_a?(IntersectionType)


      # nominal
      return left.klass.ancestors.member?(right.klass) if left.is_a?(NominalType) && right.is_a?(NominalType)
      if (left.is_a?(NominalType) || left.is_a?(TupleType) || left.is_a?(FiniteHashType) || left.is_a?(TopType) || left.is_a?(PreciseStringType) || (left.is_a?(SingletonType) && !left.val.nil?)) && right.is_a?(StructuralType)

        case left
        when TupleType
          lklass = Array
          base_inst = { self: left}#, t: left.promote.params[0] }
          t_bind = left.promote.params[0].to_s == "t" ? RDL::Globals.types[:bot] : left.promote.params[0]
          base_inst[:t] = t_bind
        when FiniteHashType
          lklass = Hash
          base_inst = { self: left }
          # hack
          k_bind = left.promote.params[0].to_s == "k" ? RDL::Globals.types[:bot] : left.promote.params[0]
          v_bind = left.promote.params[1].to_s == "v" ? RDL::Globals.types[:bot] : left.promote.params[1]
          base_inst[:k] = k_bind
          base_inst[:v] = v_bind
        when PreciseStringType
          lklass = String
          base_inst = { self: left }
        when TopType
          lklass = Object
          base_inst = { self: RDL::Globals.types[:object] }
        when SingletonType
          base_inst = { self: left }
          if left.val.class == Class
            lklass = left.val
            klass_lookup = "[s]"+lklass.to_s
          else
            lklass = left.val.class
          end
        else
          if (left == RDL::Globals.types[:array]) || (left == RDL::Type::NominalType.new(Range))
            lklass = left.klass
            left = RDL::Type::GenericType.new(left, RDL::Globals.types[:bot])
            base_inst = { self: left, t: RDL::Globals.types[:bot] }
          elsif (left == RDL::Globals.types[:hash])
            left = RDL::Type::GenericType.new(RDL::Globals.types[:hash], RDL::Globals.types[:bot], RDL::Globals.types[:bot])
            lklass = Hash
            base_inst = { self: left, k: RDL::Globals.types[:bot], v: RDL::Globals.types[:bot] }
          else
            lklass = left.klass
            base_inst = { self: left }
          end
        end
        klass_lookup = lklass.to_s unless klass_lookup

        right.methods.each_pair { |m, t|
          return false unless lklass.method_defined?(m) || RDL::Typecheck.lookup({}, klass_lookup, m, nil, make_unknown: false)#RDL::Globals.info.get(lklass, m, :type) ## Added the second condition because Rails lazily defines some methods.
          types = RDL::Typecheck.lookup({}, lklass.to_s, m, nil, make_unknown: false)#RDL::Globals.info.get(lklass, m, :type)
          if RDL::Config.instance.use_comp_types
            types = RDL::Typecheck.filter_comp_types(types, true)
          else
            types = RDL::Typecheck.filter_comp_types(types, false)
          end

          ret = types.nil? #false
          if types
            choice_num = 0
            ub_var_choices = Hash.new { |h, k| h[k] = {} } # Hash<VarType, Hash<Integer, Type>>. The keys are tactual arguments that are VarTypes. The values are choice hashes, to be turned into ChoiceTypes that will be upper bounds on the keys.
            lb_var_choices = Hash.new { |h, k| h[k] = {} } # Hash<VarType, Hash<Integer, Type>>. The keys are tactual arguments that are VarTypes. The values are choice hashes, to be turned into ChoiceTypes that will be lower bounds on the keys.
            types.each { |tlm|
              choice_num += 1
              blk_typ = tlm.block.is_a?(RDL::Type::MethodType) ? tlm.block.args + [tlm.block.ret] : [tlm.block]
              if (tlm.args + blk_typ + [tlm.ret]).any? { |t| t.is_a? ComputedType }
                ## In this case, need to actually evaluate the ComputedType.
                ## Going to do this using the receiver `left` and the args from `t`
                ## If subtyping holds for this, then we know `left` does indeed have a method of the relevant type.
                tlm = RDL::Typecheck.compute_types(tlm, lklass, left, t.args)
              end
              new_dcs = []
              if leq(tlm.instantiate(base_inst), t, nil, ileft, new_dcs, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
                ret = true
                if types.size > 1 && !new_dcs.empty? ## method has intersection type, and vartype constraints were created
                  new_dcs.each { |t1, t2|
                    ub_var_choices[t1][choice_num] = RDL::Type::UnionType.new(ub_var_choices[t1][choice_num], t2).canonical if t1.is_a?(VarType)
                    lb_var_choices[t2][choice_num] = RDL::Type::UnionType.new(lb_var_choices[t2][choice_num], t1).canonical if t2.is_a?(VarType)
                  }
                else
                  new_dcs.each { |t1, t2| RDL::Type::Type.leq(t1, t2, nil, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices) }
                end
              end
            }

            if !((lb_var_choices.empty?) && (ub_var_choices.empty?))
              all_cts = []
              ub_var_choices.each { |vartype, choice_hash|
                if choice_hash.values.uniq.size == 1
                  RDL::Type::Type.leq(vartype, choice_hash.values[0], nil, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
                else
                  t = RDL::Type::ChoiceType.new(choice_hash)
                  RDL::Type::Type.leq(vartype, t, nil, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
                  all_cts << t
                end
              }

              lb_var_choices.each { |vartype, choice_hash|
                if choice_hash.values.uniq.size == 1
                  RDL::Type::Type.leq(choice_hash.values[0], vartype, nil, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
                else
                  t = RDL::Type::ChoiceType.new(choice_hash)
                  RDL::Type::Type.leq(t, vartype, nil, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
                  all_cts << t
                end
              }
              all_cts.each { |ct| ct.add_connecteds(*all_cts) }
            end
          end
          return ret if !ret ## false if at least one type didn't match for this method
        }
        return true
      end


      # singleton
      return left.val == right.val if left.is_a?(SingletonType) && right.is_a?(SingletonType)
      return true if left.is_a?(SingletonType) && left.val.nil? # right cannot be a SingletonType due to above conditional
      return leq(left.nominal, right, inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices) if left.is_a?(SingletonType) # fall through case---use nominal type for reasoning

      # generic
      if left.is_a?(GenericType) && right.is_a?(GenericType)
        formals, variance, _ = RDL::Globals.type_params[left.base.name]
        # do check here to avoid hiding errors if generic type written
        # with wrong number of parameters but never checked against
        # instantiated instances
        raise TypeError, "No type parameters defined for #{left.base.name}" unless formals
        return false unless (left.base == right.base ||
                             (left.base.klass.ancestors.member?(right.base.klass) &&
                              left.params.length == right.params.length))
        return variance.zip(left.params, right.params).all? { |v, tl, tr|
          case v
          when :+
            leq(tl, tr, inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
          when :-
            leq(tr, tl, inst, !ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
          when :~
            leq(tl, tr, inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices) && leq(tr, tl, inst, !ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
          else
            raise RuntimeError, "Unexpected variance #{v}" # shouldn't happen
          end
        }
      end
      if left.is_a?(GenericType) && right.is_a?(StructuralType)
        # similar to logic above for leq(NominalType, StructuralType, ...)
        formals, variance, _ = RDL::Globals.type_params[left.base.name]
        raise TypeError, "No type parameters defined for #{left.base.name}" unless formals
        base_inst = Hash[*formals.zip(left.params).flatten] # instantiation for methods in base's class
        klass = left.base.klass
        right.methods.each_pair { |meth, t|
          if (klass.to_s == "ActiveRecord_Relation") && !klass.method_defined?(meth) && defined? DBType
            types = RDL::Typecheck.lookup({}, klass.to_s, meth, {}, make_unknown: false)
            if !types
              base_types = RDL::Typecheck.lookup({}, "[s]"+DBType.rec_to_nominal(left).name, meth, {}, make_unknown: false)
              return false unless base_types
              types = base_types.map { |t| RDL::Type::MethodType.new(t.args, t.block, left) }
            end
            return false unless types
          else
            return false unless klass.method_defined?(meth) || RDL::Typecheck.lookup({}, klass.to_s, meth, nil, make_unknown: false)#RDL::Globals.info.get(klass, meth, :type) ## Added the second condition because Rails lazily defines some methods.
            types = RDL::Typecheck.lookup({}, klass.to_s, meth, {}, make_unknown: false)#RDL::Globals.info.get(klass, meth, :type)
          end

          if RDL::Config.instance.use_comp_types
            types = RDL::Typecheck.filter_comp_types(types, true)
          else
            types = RDL::Typecheck.filter_comp_types(types, false)
          end

          ret = types.nil?
          if types
            choice_num = 0
            ub_var_choices = Hash.new { |h, k| h[k] = {} } # Hash<VarType, Hash<Integer, Type>>. The keys are tactual arguments that are VarTypes. The values are choice hashes, to be turned into ChoiceTypes that will be upper bounds on the keys.
            lb_var_choices = Hash.new { |h, k| h[k] = {} } # Hash<VarType, Hash<Integer, Type>>. The keys are tactual arguments that are VarTypes. The values are choice hashes, to be turned into ChoiceTypes that will be lower bounds on the keys.
            types.each { |tlm|
              choice_num += 1
              blk_typ = tlm.block.is_a?(RDL::Type::MethodType) ? tlm.block.args + [tlm.block.ret] : [tlm.block]
              tlm = RDL::Typecheck.compute_types(tlm, klass, left, t.args) if (tlm.args + blk_typ + [tlm.ret]).any? { |t| t.is_a? ComputedType }
              new_dcs = []
              if leq(tlm.instantiate(base_inst.merge({ self: left})), t, nil, ileft, new_dcs, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
                ret = true
                if types.size > 1 && !new_dcs.empty? ## method has intersection type, and vartype constraints were
                  new_dcs.each { |t1, t2|
                    ub_var_choices[t1][choice_num] = RDL::Type::UnionType.new(ub_var_choices[t1][choice_num], t2).canonical if t1.is_a?(VarType)
                    lb_var_choices[t2][choice_num] = RDL::Type::UnionType.new(lb_var_choices[t2][choice_num], t1).canonical if t2.is_a?(VarType)
                  }
                else
                  new_dcs.each { |t1, t2| RDL::Type::Type.leq(t1, t2, nil, false, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices) }
                end
              end
            }
            if !((lb_var_choices.empty?) && (ub_var_choices.empty?))
              all_cts = []
              ub_var_choices.each { |vartype, choice_hash|
                if choice_hash.values.uniq.size == 1
                  RDL::Type::Type.leq(vartype, choice_hash.values[0], nil, false, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
                else
                  t = RDL::Type::ChoiceType.new(choice_hash)
                  RDL::Type::Type.leq(vartype, t, nil, false, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
                  all_cts << t
                end
              }

              lb_var_choices.each { |vartype, choice_hash|
                if choice_hash.values.uniq.size == 1
                  RDL::Type::Type.leq(choice_hash.values[0], vartype, nil, false, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
                else
                  t = RDL::Type::ChoiceType.new(choice_hash)
                  RDL::Type::Type.leq(t, vartype, nil, false, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
                  all_cts << t
                end
              }
              all_cts.each { |ct| ct.add_connecteds(*all_cts) }
            end
          end
          return ret if !ret ## false if at least one type didn't match for this method
        }
        return true
      end


      # Note we do not allow raw subtyping leq(GenericType, NominalType, ...)

      # method
      if left.is_a?(MethodType) && right.is_a?(MethodType)
        inst = {} if not inst
        if left.args.last.is_a?(VarargType)
          #return false unless right.args.size >= left.args.size
          if right.args.size >= left.args.size
            new_args = right.args[(left.args.size - 1) ..-1]
            if left.args.size == 1
              left = RDL::Type::MethodType.new(new_args, left.block, left.ret)
            else
              left = RDL::Type::MethodType.new(left.args[0..(left.args.size-2)]+new_args, left.block, left.ret)
            end
          elsif right.args.size == left.args.size
            left = RDL::Type::MethodType.new(left.args[0..left.args.size-2] + [left.args[-1].type], left.block, left.ret)
          else
            left = RDL::Type::MethodType.new(left.args[0..left.args.size-2], left.block, left.ret)
          end
        end

        last_arg = left.args.last
        if last_arg.is_a?(OptionalType) || (last_arg.is_a?(AnnotatedArgType) && last_arg.type.is_a?(OptionalType))
          left = RDL::Type::MethodType.new(
            left.args.map { |t|
              if t.is_a?(OptionalType) then t.type
              elsif t.is_a?(AnnotatedArgType) && t.type.is_a?(OptionalType) then t.type.type
              else t end },
            left.block, left.ret)
          if left.args.size == right.args.size + 1
          ## A method with an optional type in the last position can be used in place
          ## of a method without the optional type. So drop it and then check subtyping.
            left = RDL::Type::MethodType.new(left.args.slice(0, left.args.size-1), left.block, left.ret)
          end
        end
        return false unless left.args.size == right.args.size
        return false unless left.args.zip(right.args).all? { |tl, tr|
          leq(
            tr.instantiate(inst),
            tl.instantiate(inst),
            inst,
            !ileft,
            deferred_constraints,
            no_constraint: no_constraint,
            ast: ast,
            propagate: propagate,
            new_cons: new_cons,
            removed_choices: removed_choices
          )
        } # contravariance
        #return false unless left.args.zip(right.args).all? { |tl, tr| leq(tr.instantiate(inst), tl.instantiate(inst), inst, false, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons) } # contravariance

        if left.block && right.block
          return false unless leq(right.block.instantiate(inst), left.block.instantiate(inst), inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices) # contravariance
        elsif (left.block && !left.block.is_a?(VarType) && !right.block) || (right.block && !right.block.is_a?(VarType) && !left.block)
          return false # one has a block and the other doesn't
        end
        return leq(left.ret.instantiate(inst), right.ret.instantiate(inst), inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices) # covariance

      end
      return true if left.is_a?(MethodType) && right.is_a?(NominalType) && right.name == 'Proc'

      if left.is_a?(MethodType) && right.is_a?(StructuralType)
        return true if (right.methods.size == 1) && right.methods.has_key?(:to_proc)
        right.methods.each_pair { |m, t|
          if m == :call
            return false unless left.args.size == t.args.size
          end
        }
        return true
      end

      # structural
      if left.is_a?(StructuralType) && right.is_a?(StructuralType)
        # allow width subtyping - methods of right have to be in left, but not vice-versa
        return right.methods.all? { |m, t|
          # in recursive call set inst to nil since those method types have implicit quantifier
          left.methods.has_key?(m) && leq(left.methods[m], t, nil, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
        }
      end
      # Note we do not allow a structural type to be a subtype of a nominal type or generic type,
      # even though in theory that would be possible.

      # tuple
      if left.is_a?(TupleType) && right.is_a?(TupleType)
        # Tuples are immutable, so covariant subtyping allowed
        return false unless left.params.length == right.params.length
        return false unless left.params.zip(right.params).all? { |lt, rt| leq(lt, rt, inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices) }
        # subyping check passed
        left.ubounds << right unless no_constraint
        right.lbounds << left unless no_constraint
        return true
      end
      if left.is_a?(TupleType) && right.is_a?(GenericType) && right.base == RDL::Globals.types[:array]
        # TODO !ileft and right carries a free variable
        return false unless left.promote!
        return leq(left, right, inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices) # recheck for promoted type
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
            return false unless leq(tl, tr, inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
            right_elts.delete k
          else
            return false unless right.rest && leq(tl, right.rest, inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
          end
        }
        right_elts.each_pair { |k, t|
          return false unless t.is_a? OptionalType
        }
        unless left.rest.nil?
          # If left has optional stuff, right needs to accept it
          return false unless !(right.rest.nil?) && leq(left.rest, right.rest, inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices)
        end
        left.ubounds << right unless no_constraint
        right.lbounds << left unless no_constraint
        return true
      end
      if left.is_a?(FiniteHashType) && right.is_a?(GenericType) && right.base == RDL::Globals.types[:hash]
        # TODO !ileft and right carries a free variable
        return false unless left.promote!
        return leq(left, right, inst, ileft, deferred_constraints, no_constraint: no_constraint, ast: ast, propagate: propagate, new_cons: new_cons, removed_choices: removed_choices) # recheck for promoted type
      end

      ## precise string

      if left.is_a?(PreciseStringType)
        if right.is_a?(PreciseStringType)
          return false if left.vals.size != right.vals.size
          left.vals.each_with_index { |v, i|
            if v.is_a?(String) && right.vals[i].is_a?(String)
              return false unless v == right.vals[i]
            elsif v.is_a?(Type) && right.vals[i].is_a?(Type)
              return false unless v <= right.vals[i]
            else
              return false
            end
          }
          left.ubounds << right unless no_constraint
          right.lbounds << left unless no_constraint
          return true
        elsif right == RDL::Globals.types[:string]
          return false unless left.promote!
          return true
        elsif right.is_a?(NominalType) && String.ancestors.include?(RDL::Util.to_class(right.name))
          ## necessary because of checking agains union types: we don't want to promote! unless it will work
          left.promote!
          return true
        end
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

  # [+ a +] is Array<Integer>
  # returns Array<Array<Integer>> containing all combinations of 0..a[i] at index i
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
