require 'csv'

module RDL::Typecheck

  def self.resolve_constraints
    puts "Starting constraint resolution..."
    RDL::Globals.constrained_types.each { |klass, name|
      puts "Resolving constraints from #{klass} and #{name}"
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
        if var_type.var_type? || var_type.optional_var_type? || var_type.vararg_var_type?
          var_type = var_type.type if var_type.optional_var_type? || var_type.vararg_var_type?
          var_type.lbounds.each { |lower_t, ast|
            var_type.add_and_propagate_lower_bound(lower_t, ast)
          }
          var_type.ubounds.each { |upper_t, ast|
            var_type.add_and_propagate_upper_bound(upper_t, ast)
          }
        elsif var_type.fht_var_type?
          var_type.elts.values.each { |v|
            vt = v.optional_var_type? || v.vararg_var_type? ? v.type : v
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
  end

  def self.extract_var_sol(var, category)
    #raise "Expected VarType, got #{var}." unless var.is_a?(RDL::Type::VarType)
    return var.canonical unless var.is_a?(RDL::Type::VarType)
    if category == :arg
      non_vartype_ubounds = var.ubounds.map { |t, ast| t}.reject { |t| t.instance_of?(RDL::Type::VarType) }
      sol = non_vartype_ubounds.size == 1 ? non_vartype_ubounds[0] : RDL::Type::IntersectionType.new(*non_vartype_ubounds).canonical
      sol = sol.drop_vars.canonical if sol.is_a?(RDL::Type::IntersectionType)  ## could be, e.g., nominal type if only one type used to create intersection.
      #return sol
    elsif category == :ret
      non_vartype_lbounds = var.lbounds.map { |t, ast| t}.reject { |t| t.instance_of?(RDL::Type::VarType) }
      sol = RDL::Type::UnionType.new(*non_vartype_lbounds)
      sol = sol.drop_vars.canonical if sol.is_a?(RDL::Type::UnionType)  ## could be, e.g., nominal type if only one type used to create union.
    #return sol
    elsif category == :var
      if var.lbounds.empty? || (var.lbounds.size == 1 && var.lbounds[0][0] == RDL::Globals.types[:bot])
        ## use upper bounds in this case.
        non_vartype_ubounds = var.ubounds.map { |t, ast| t}.reject { |t| t.instance_of?(RDL::Type::VarType) }
        sol = RDL::Type::IntersectionType.new(*non_vartype_ubounds).canonical
        #return sol
      else
        ## use lower bounds
        non_vartype_lbounds = var.lbounds.map { |t, ast| t}.reject { |t| t.instance_of?(RDL::Type::VarType) }
        sol = RDL::Type::UnionType.new(*non_vartype_lbounds)
        sol = sol.drop_vars.canonical if sol.is_a?(RDL::Type::UnionType)  ## could be, e.g., nominal type if only one type used to create union.
        #return sol#RDL::Type::UnionType.new(*non_vartype_lbounds).canonical
      end
    else
      raise "Unexpected VarType category #{category}."
    end
    if  sol.is_a?(RDL::Type::UnionType) || (sol == RDL::Globals.types[:bot]) || (sol == RDL::Globals.types[:top]) || (sol == RDL::Globals.types[:nil]) || sol.is_a?(RDL::Type::StructuralType) || sol.is_a?(RDL::Type::IntersectionType) || (sol == RDL::Globals.types[:object])
      ## Try each rule. Return first non-nil result.
      ## If no non-nil results, return original solution.
      ## TODO: check constraints.
      RDL::Heuristic.rules.each { |name, rule|
        #puts "Trying rule `#{name}` for variable #{var}."
        typ = rule.call(var)
        new_cons = {}
        begin
          if typ
            #puts "Attempting to apply heuristic solution #{typ} to #{var}"
            typ = typ.canonical
            var.add_and_propagate_upper_bound(typ, nil, new_cons)
            var.add_and_propagate_lower_bound(typ, nil, new_cons)
=begin
            new_cons.each { |var, bounds|
              bounds.each { |u_or_l, t, _|
                puts "1. Added #{u_or_l} bound constraint #{t} of kind #{t.class} to variable #{var}"
                puts "It has upper bounds: "
                var.ubounds.each { |t, _| puts t }
              }
            }
=end
            @new_constraints = true if !new_cons.empty?
            return typ
            #sol = typ
          end
        rescue RDL::Typecheck::StaticTypeError => e
          puts "Attempted to apply rule #{name} to var #{var}, but go the following error: "
          puts e
          undo_constraints(new_cons)
          ## no new constraints in this case so we'll leave it as is
        end
      }
    end
    ## out here, none of the heuristics applied.
    ## Try to use `sol` as solution -- there is a chance it will
    begin
      new_cons = {}
      sol = var if sol == RDL::Globals.types[:bot] # just use var itself when result of solution extraction was %bot.
      return sol if sol.is_a?(RDL::Type::VarType) ## don't add var type as solution
      sol = sol.canonical
      var.add_and_propagate_upper_bound(sol, nil, new_cons)
      var.add_and_propagate_lower_bound(sol, nil, new_cons)
=begin
      new_cons.each { |var, bounds|
        bounds.each { |u_or_l, t, _|
          puts "2. Added #{u_or_l} bound constraint #{t} to variable #{var}"
        }
      }
=end
      @new_constraints = true if !new_cons.empty?

      if sol.is_a?(RDL::Type::GenericType)
        new_params = sol.params.map { |p| if p.is_a?(RDL::Type::VarType) && !p.to_infer then p else extract_var_sol(p, category) end }
        sol = RDL::Type::GenericType.new(sol.base, *new_params)
      elsif sol.is_a?(RDL::Type::TupleType)
        new_params = sol.params.map { |t| extract_var_sol(t, category) }
        sol = RDL::Type::TupleType.new(*new_params)
      end
    rescue RDL::Typecheck::StaticTypeError => e
      puts "Attempted to apply solution #{sol} for var #{var} but got the following error: "
      puts e
      undo_constraints(new_cons)
      ## no new constraints in this case so we'll leave it as is
      sol = var
    end

    return sol
  end

  # [+ cons +] is Hash<VarType, [:upper or :lower], Type, AST> of constraints to be undone.
  def self.undo_constraints(cons)
    cons.each_key { |var_type|
      cons[var_type].each { |upper_or_lower, bound_t, ast|
        if upper_or_lower == :upper
          var_type.ubounds.delete([bound_t, ast])
        elsif upper_or_lower == :lower
          var_type.lbounds.delete([bound_t, ast])
        end
      }
    }
  end

  def self.extract_meth_sol(tmeth)
    raise "Expected MethodType, got #{tmeth}." unless tmeth.is_a?(RDL::Type::MethodType)
    ## ARG SOLUTIONS
    arg_sols = tmeth.args.map { |a|
      if a.optional_var_type?
        soln = RDL::Type::OptionalType.new(extract_var_sol(a.type, :arg))
      elsif a.fht_var_type?
        hash_sol = a.elts.transform_values { |v|
          if v.is_a?(RDL::Type::OptionalType)
            RDL::Type::OptionalType.new(extract_var_sol(v.type, :arg))
          else
            extract_var_sol(v, :arg)
          end
        }
        soln = RDL::Type::FiniteHashType.new(hash_sol, nil)
      else
        soln = extract_var_sol(a, :arg)
      end

      a.solution = soln
      soln
    }

    ## BLOCK SOLUTION
    if tmeth.block && !tmeth.block.ubounds.empty?
      non_vartype_ubounds = tmeth.block.ubounds.map { |t, ast| t.canonical }.reject { |t| t.is_a?(RDL::Type::VarType) }
      non_vartype_ubounds.reject! { |t| t.is_a?(RDL::Type::StructuralType) }#&& (t.methods.size == 1) && (t.methods.has_key?(:to_proc) || t.methods.has_key?(:call)) }
      if non_vartype_ubounds.size == 0
        block_sol = tmeth.block
      elsif non_vartype_ubounds.size > 1
        block_sols = []
        inter = RDL::Type::IntersectionType.new(*non_vartype_ubounds).canonical
        typs = inter.is_a?(RDL::Type::IntersectionType) ? inter.types : [inter]
        typs.each { |m|
          raise "Expected block type to be a MethodType, got #{m}." unless m.is_a?(RDL::Type::MethodType)
          block_sols << RDL::Type::MethodType.new(*extract_meth_sol(m))
        }
        block_sol = RDL::Type::IntersectionType.new(*block_sols).canonical
      else
        block_sol = RDL::Type::MethodType.new(*extract_meth_sol(non_vartype_ubounds[0]))
      end

      tmeth.block.solution = block_sol
    else
      block_sol = nil
    end

    ## RET SOLUTION
    if tmeth.ret.to_s == "self"
      ret_sol = tmeth.ret
    else
      ret_sol = tmeth.ret.is_a?(RDL::Type::VarType) ?  extract_var_sol(tmeth.ret, :ret) : tmeth.ret
    end

    tmeth.ret.solution = ret_sol

    return [arg_sols, block_sol, ret_sol]
  end

  def self.extract_solutions
    ## Go through once to come up with solution for all var types.
    #until !@new_constraints
    typ_sols = {}
    loop do
      @new_constraints = false
      typ_sols = {}
      puts "\n\nRunning solution extraction..."
      RDL::Globals.constrained_types.each { |klass, name|
        RDL::Type::VarType.no_print_XXX!
        typ = RDL::Globals.info.get(klass, name, :type)
        if typ.is_a?(Array)
          raise "Expected just one method type for #{klass}#{name}." unless typ.size == 1
          tmeth = typ[0]

          arg_sols, block_sol, ret_sol = extract_meth_sol(tmeth)

          block_string = block_sol ? " { #{block_sol} }" : nil
          puts "Extracted solution for #{klass}\##{name} is (#{arg_sols.join(',')})#{block_string} -> #{ret_sol}"

          RDL::Type::VarType.print_XXX!
          block_string = block_sol ? " { #{block_sol} }" : nil
          typ_sols[[klass.to_s, name.to_sym]] = "(#{arg_sols.join(', ')})#{block_string} -> #{ret_sol}"
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
          puts "Extracted solution for #{klass} variable #{name} is #{var_sol}."

          RDL::Type::VarType.print_XXX!
          typ_sols[[klass.to_s, name.to_sym]] = var_sol.to_s
        end
      }
      break if !@new_constraints
    end

    #return unless $orig_types

    # complete_types = []
    # incomplete_types = []

    CSV.open("infer_data.csv", "wb") { |csv|
      csv << ["Class", "Method", "Inferred Type", "Original Type", "Source Code", "Comments"]
    }

    correct_types = 0
    total_potential = 0
    meth_types = 0
    var_types = 0
    typ_sols.each_pair { |km, typ|
      klass, meth = km
      orig_typ = RDL::Globals.info.get(klass, meth, :orig_type)
      if orig_typ.is_a?(Array)
        raise "expected just one original type for #{klass}##{meth}" unless orig_typ.size == 1
        orig_typ = orig_typ[0]
      end
      if orig_typ.nil?
        #puts "Original type not found for #{klass}##{meth}."
        #puts "Inferred type is: #{typ}"
      elsif orig_typ.to_s == typ
        #puts "Type for #{klass}##{meth} was correctly inferred, as: "
        #puts typ
        if orig_typ.is_a?(RDL::Type::MethodType)
          correct_types += orig_typ.args.size + 1 ## 1 for ret
          total_potential += orig_typ.args.size + 1 ## 1 for ret
          meth_types += 1
          if !orig_typ.block.nil?
            correct_types += orig_typ.block.args.size + 1 ## 1 for ret
            total_potential += orig_typ.block.args.size + 1 ## 1 for ret
          end
        else
          var_types += 1
          correct_types += 1
          total_potential += 1
        end
      else
        puts "Difference encountered for #{klass}##{meth}."
        puts "Inferred: #{typ}"
        puts "Original: #{orig_typ}"
        if orig_typ.is_a?(RDL::Type::MethodType)
          total_potential += orig_typ.args.size + 1 ## 1 for ret
          total_potential += orig_typ.block.args.size + 1 if !orig_typ.block.nil?
          meth_types += 1
        else
          total_potential += 1
          var_types += 1
        end

      end

      if !meth.to_s.include?("@") && !meth.to_s.include?("$")#orig_typ.is_a?(RDL::Type::MethodType)
        CSV.open("infer_data.csv", "a+") { |csv|
          ast = RDL::Typecheck.get_ast(klass, meth)
          code = ast.loc.expression.source
          if RDL::Util.has_singleton_marker(klass)
            comment = RDL::Util.to_class(RDL::Util.remove_singleton_marker(klass)).method(meth).comment
          else
            comment = RDL::Util.to_class(klass).instance_method(meth).comment
          end
          csv << [klass, meth, typ, orig_typ, code, comment]
          #if typ.include?("XXX")
          #  incomplete_types << [klass, meth, typ, orig_typ, code, comment]
          #else
          #  complete_types << [klass, meth, typ, orig_typ, code, comment]
          #end
        }
      end
    }
    #CSV.open("infer_data.csv", "a+") { |csv|
      #complete_types.each { |row| csv << row }
      #csv << ["X", "X", "X", "X", "X", "X"]
      #incomplete_types.each { |row| csv << row }
    #}

    puts "Total correct (that could be automatically inferred): #{correct_types}"
    puts "Total # method types: #{meth_types}"
    puts "Total # variable types: #{var_types}"
    puts "Total # individual types: #{total_potential}"
  end



end
