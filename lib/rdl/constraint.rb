module RDL::Typecheck

  def self.resolve_constraints
    puts "Starting constraint resolution..."
    RDL::Globals.constrained_types.each { |klass, name|
      typ = RDL::Globals.info.get(klass, name, :type)
      ## If typ is an Array, then it's an array of method types
      ## but for inference, we only use a single method type.
      ## Otherwise, it's a single VarType for an instance/class var.
      if typ.is_a?(Array)
        var_types = name == :initialize ? typ[0].args + [typ[0].block] : typ[0].args + [typ[0].block, typ[0].ret]
      else
        var_types = [typ]
      end
      
      var_types.each { |var_type|
        if var_type.var_type? || var_type.optional_var_type?        
          var_type = var_type.type if var_type.is_a?(RDL::Type::OptionalType)
          var_type.lbounds.each { |lower_t, ast|
            var_type.add_and_propagate_lower_bound(lower_t, ast)
          }
          var_type.ubounds.each { |upper_t, ast|
            var_type.add_and_propagate_upper_bound(upper_t, ast)
          }
        elsif var_type.fht_var_type?
          var_type.elts.values.each { |v|
            vt = v.is_a?(RDL::Type::OptionalType) ? v.type : v
            vt.lbounds.each { |lower_t, ast|
              vt.add_and_propagate_lower_bound(lower_t, ast)
            }
            vt.ubounds.each { |upper_t, ast|
              vt.add_and_propagate_upper_bound(upper_t, ast)
            }            
          }
        else
          raise "Got unexpected type #{var_type}."
        end
      }
    }

    if RDL::Config.instance.practical_infer
      puts "practical inference!!!"
      RDL::Globals.constrained_types.each { |klass, name|
        typ = RDL::Globals.info.get(klass, name, :type)
        if typ.is_a?(Array)
          var_types = name == :initialize ? typ[0].args + [typ[0].block] : typ[0].args + [typ[0].block, typ[0].ret]
        else
          var_types = [typ]
        end
        
        var_types.each { |var_type|
          if var_type.fht_var_type?
            var_type.elts.values.each { |v|
              vt = v.is_a?(RDL::Type::OptionalType) ? v.type : v
              puts "Applying struct_to_nominal to #{vt}."
              struct_to_nominal(vt)
            }
          else
            var_type = var_type.type if var_type.is_a?(RDL::Type::OptionalType)
            puts "Applying struct_to_nominal to #{var_type}."
            struct_to_nominal(var_type)
          end
        }
      }
    end
    
    puts "Done with constraint resolution."
  end

  def self.struct_to_nominal(var_type)
    return unless (var_type.category == :arg) || (var_type.category == :var)#(var_type.category == :ivar) || (var_type.category == :cvar) || (var_type.category == :gvar) ## this rule only applies to args and (instance/class/global) variables
    #return unless var_type.ubounds.all? { |t, loc| t.is_a?(RDL::Type::StructuralType) || t.is_a?(RDL::Type::VarType) } ## all upper bounds must be struct types or var types
    return unless var_type.ubounds.any? { |t, loc| t.is_a?(RDL::Type::StructuralType) } ## upper bounds must include struct type(s)
    struct_types = var_type.ubounds.select { |t, loc| t.is_a?(RDL::Type::StructuralType) }
    struct_types.map! { |t, loc| t }
    return if struct_types.empty?
    meth_names = struct_types.map { |st| st.methods.keys }.flatten
    matching_classes = ObjectSpace.each_object(Class).select { |c|
      class_methods = c.instance_methods | RDL::Globals.info.get_methods_from_class(c.to_s)
      (meth_names - class_methods).empty? } ## will only be empty if meth_names is a subset of c.instance_methods
    ## Because every object inherits from Object/BasicObject,
    ## we end up with some really weird issues regarding the eigenclasses
    ## of objects if we try to include all possible matching classes.
    ## We can just narrow things down here right off the bat.
    if matching_classes.include?(BasicObject)
      matching_classes = [BasicObject]
    elsif matching_classes.include?(Object)
      matching_classes = [Object]
    end

    ## TODO: special handling for arrays/hashes/generics?
    ## TODO: special handling for Rails models? see Bree's `active_record_match?` method

    raise "No matching classes found for structural types #{struct_types}." if matching_classes.empty?
    return if matching_classes.size > 10 ## in this case, just keep the struct types
    nom_sing_types = matching_classes.map { |c| if c.singleton_class? then RDL::Type::SingletonType.new(RDL::Util.singleton_class_to_class(c)) else RDL::Type::NominalType.new(c) end }
    union = RDL::Type::UnionType.new(*nom_sing_types).canonical
    struct_types.each { |st| var_type.ubounds.delete_if { |s, loc| s.equal?(st) } } ## remove struct types from upper bounds
    #var_type.ubounds << [union, "Not providing a location."]
    var_type.add_and_propagate_upper_bound(union, nil)
  end

  def self.extract_var_sol(var, category)
    #raise "Expected VarType, got #{var}." unless var.is_a?(RDL::Type::VarType)
    return var.canonical unless var.is_a?(RDL::Type::VarType)
    if category == :arg
      non_vartype_ubounds = var.ubounds.map { |t, ast| t}.reject { |t| t.is_a?(RDL::Type::VarType) }
      sol = non_vartype_ubounds.size == 1 ? non_vartype_ubounds[0] : RDL::Type::IntersectionType.new(*non_vartype_ubounds).canonical
      #return sol
    elsif category == :ret
      non_vartype_lbounds = var.lbounds.map { |t, ast| t}.reject { |t| t.is_a?(RDL::Type::VarType) }
      sol = RDL::Type::UnionType.new(*non_vartype_lbounds)
      sol = sol.drop_vars!.canonical if sol.is_a?(RDL::Type::UnionType) ## could be, e.g., nominal type if only one type used to create union.
      #return sol
    elsif category == :var
      if var.lbounds.empty? || (var.lbounds.size == 1 && var.lbounds[0][0] == RDL::Globals.types[:bot])
        ## use upper bounds in this case.
        non_vartype_ubounds = var.ubounds.map { |t, ast| t}.reject { |t| t.is_a?(RDL::Type::VarType) }
        sol = RDL::Type::IntersectionType.new(*non_vartype_ubounds).canonical
        #return sol
      else
        ## use lower bounds
        non_vartype_lbounds = var.lbounds.map { |t, ast| t}.reject { |t| t.is_a?(RDL::Type::VarType) }
        sol = RDL::Type::UnionType.new(*non_vartype_lbounds)
        sol = sol.drop_vars!.canonical if sol.is_a?(RDL::Type::UnionType) ## could be, e.g., nominal type if only one type used to create union.
        #return sol#RDL::Type::UnionType.new(*non_vartype_lbounds).canonical
      end
    else
      raise "Unexpected VarType category #{category}."
    end
    
    if sol.is_a?(RDL::Type::UnionType) || (sol == RDL::Globals.types[:bot]) || sol.is_a?(RDL::Type::StructuralType)
      ## Try each rule. Return first non-nil result.
      ## If no non-nil results, return original solution.
      ## TODO: check constraints.
      RDL::Heuristic.rules.each { |name, rule|
        #puts "Trying rule `#{name}` for variable #{var}."
        typ = rule.call(var)
        return typ if typ
      }
      return sol
    else
      return sol
    end
  end

  def self.extract_meth_sol(tmeth)
    raise "Expected MethodType, got #{tmeth}." unless tmeth.is_a?(RDL::Type::MethodType)
    ## ARG SOLUTIONS
    arg_sols = tmeth.args.map { |a|
      if a.optional_var_type?
        RDL::Type::OptionalType.new(extract_var_sol(a.type, :arg))
      elsif a.fht_var_type?
        hash_sol = a.elts.transform_values { |v|
          if v.is_a?(RDL::Type::OptionalType)
            RDL::Type::OptionalType.new(extract_var_sol(v.type, :arg))
          else
            extract_var_sol(v, :arg)
          end
        }
        RDL::Type::FiniteHashType.new(hash_sol, nil)
      else
        extract_var_sol(a, :arg)
      end
    }

    ## BLOCK SOLUTION
    if tmeth.block && !tmeth.block.ubounds.empty?
      non_vartype_ubounds = tmeth.block.ubounds.map { |t, ast| t.canonical }.reject { |t| t.is_a?(RDL::Type::VarType) }          
      block_sol = non_vartype_ubounds.size > 1 ? RDL::Type::IntersectionType.new(*non_vartype_ubounds).canonical : non_vartype_bounds[0] ## doing this once and calling canonical to remove any supertypes that would be eliminated anyway
      block_sols = []
      block_sol.types.each { |m|
        raise "Expected block type to be a MethodType, got #{m}." unless m.is_a?(RDL::Type::MethodType)
        block_sols << RDL::Type::MethodType.new(*extract_meth_sol(m))
      }
      block_sol = RDL::Type::IntersectionType.new(*block_sols).canonical
    else
      block_sol = nil
    end

    ## RET SOLUTION
    ret_sol = tmeth.ret.is_a?(RDL::Type::VarType) ?  extract_var_sol(tmeth.ret, :ret) : tmeth.ret

    return [arg_sols, block_sol, ret_sol]
  end
  
  def self.extract_solutions
    puts "Starting solution extraction..."
    ## Go through once to come up with solution for all var types.
    RDL::Globals.constrained_types.each { |klass, name|
      typ = RDL::Globals.info.get(klass, name, :type)
      if typ.is_a?(Array)
        raise "Expected just one method type for #{klass}#{name}." unless typ.size == 1
        tmeth = typ[0]

        arg_sols, block_sol, ret_sol = extract_meth_sol(tmeth)
        block_string = block_sol ? " { #{block_sol} }" : nil
        puts "Extracted solution for #{klass}\##{name} is (#{arg_sols.join(',')})#{block_string} -> #{ret_sol}"

      elsif name.to_s == "splat_param"
      else
        ## Instance/Class (also some times splat parameter) variables:
        ## There is no clear answer as to what to do in this case.
        ## Just need to pick something in between bounds (inclusive).
        ## For now, plan is to just use lower bound when it's not empty/%bot,
        ## otherwise use upper bound.
        ## Can improve later if desired.
        var_sol = extract_var_sol(typ, :var)
        #typ.solution = var_sol
        
        puts "Extracted solution for #{typ} is #{var_sol}."
      end
    }
  end
end
