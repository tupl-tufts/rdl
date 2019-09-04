module RDL::Typecheck

  def self.resolve_constraints
    puts "Starting constraint resolution..."
    RDL::Globals.constrained_types.each { |klass, name|
      typ = RDL::Globals.info.get(klass, name, :type)
      ## If typ is an Array, then it's an array of method types
      ## but for inference, we only use a single method type.
      ## Otherwise, it's a single VarType for an instance/class var.
      var_types = typ.is_a?(Array) ? typ[0].args + [typ[0].ret] : [typ]

      var_types.each { |var_type|
          var_type.lbounds.each { |lower_t, ast|
            var_type.add_and_propagate_lower_bound(lower_t, ast)
          }
          var_type.ubounds.each { |upper_t, ast|
            var_type.add_and_propagate_upper_bound(upper_t, ast)
          }
      }
=begin      
      if typ.is_a?(Array)
        ## it's an array for method types (to handle intersections)
        meth_type = typ[0] ## should only be one type though since we're inferring it
        raise "Expected MethodType, got #{meth_type}." unless meth_type.is_a?(RDL::Type::MethodType)
        (meth_type.args + [meth_type.ret]).each { |var_type|
          var_type.lbounds.each { |lower_t, ast|
            var_type.add_and_propagate_lower_bound(lower_t, ast)
          }
          var_type.ubounds.each { |upper_t, ast|
            var_type.add_and_propagate_upper_bound(upper_t, ast)
          }
        }
      else
        ## variable type in this case
        var_type = typ
        raise "Expected VarType, got #{var_type}." unless var_type.is_a?(RDL::Type::VarType)
        var_type.lbounds.each { |lower_t, ast|
          var_type.add_and_propagate_lower_bound(lower_t, ast)
        }
        var_type.ubounds.each { |upper_t, ast|
          var_type.add_and_propagate_upper_bound(upper_t, ast)
        }        
      end
=end
    }

    if RDL::Config.instance.practical_infer
      puts "practical inference!!!"
      RDL::Globals.constrained_types.each { |klass, name|
        typ = RDL::Globals.info.get(klass, name, :type)
        var_types = typ.is_a?(Array) ? typ[0].args + [typ[0].ret] : [typ]
        var_types.each { |var_type|
          puts "Applying struct_to_nominal to #{var_type}."
          struct_to_nominal(var_type)
        }
      }
    end
    
    puts "Done with constraint resolution."
  end

  def self.struct_to_nominal(var_type)
    return unless var_type.category == :arg ## this rule only applies to args
    return unless var_type.ubounds.all? { |t, loc| t.is_a?(RDL::Type::StructuralType) || t.is_a?(RDL::Type::VarType) } ## all upper bounds must be struct types or var types
    struct_types = var_type.ubounds.select { |t, loc| t.is_a?(RDL::Type::StructuralType) }
    struct_types.map! { |t, loc| t }
    return if struct_types.empty?

    meth_names = struct_types.map { |st| st.methods.keys }.flatten
    matching_classes = ObjectSpace.each_object(Class).select { |c| (meth_names - c.instance_methods).empty? } ## will only be empty if meth_names is a subset of c.instance_methods

    ## TODO: special handling for arrays/hashes/generics?
    ## TODO: special handling for Rails models? see Bree's `active_record_match?` method

    raise "No matching classes found for structural types #{struct_types}." if matching_classes.empty?

    nom_sing_types = matching_classes.map { |c| if c.singleton_class? then RDL::Type::SingletonType.new(RDL::Util.singleton_class_to_class(c)) else RDL::Type::NominalType.new(c) end }
    union = RDL::Type::UnionType.new(*nom_sing_types).canonical
    struct_types.each { |st| var_type.ubounds.delete_if { |s, loc| s.equal?(st) } } ## remove struct types from upper bounds
    var_type.ubounds << [union, "Not providing a location."]
  end

  def self.extract_solution
    puts "Starting solution extraction..."
    RDL::Globals.constrained_types.each { |klass, name|
      typ = RDL::Globals.info.get(klass, name, :type)
      if typ.is_a?(Array)
        meth_type = typ[0]
        raise "Expected MethodType, got #{meth_type}." unless meth_type.is_a?(RDL::Type::MethodType)

        ## ARG SOLUTIONS
        meth_type.args.each { |var_type|
          non_vartype_ubounds = var_type.ubounds.map { |t, ast| t}.reject { |t| t.is_a?(RDL::Type::VarType) }
          sol = RDL::Type::IntersectionType.new(*non_vartype_ubounds)
          puts "Extracted solution for #{var_type} is #{sol}"
          ## TODO: Eventually want to store this solution somewhere.
        }

        ## RET SOLUTION
        non_vartype_lbounds = meth_type.ret.lbounds.map { |t, ast| t}.reject { |t| t.is_a?(RDL::Type::VarType) }
        sol = RDL::Type::UnionType.new(*non_vartype_lbounds).canonical
        puts "Extracted solution for #{meth_type.ret} is #{sol}"
      else
        ## Instance/Class variables: TODO
        ## There is no clear answer as to what to do in this case.
        ## Just need to pick something in between bounds (inclusive).
        ## For now, plan is to just use lower bound when it's not empty/%bot,
        ## otherwise use upper bound.
        ## Can improve later if desired.
        var_type = typ
        raise "Expected VarType, got #{var_type}." unless var_type.is_a?(RDL::Type::VarType)
        if var_type.lbounds.empty? || (var_type.lbounds.size == 1 && var_type.lbounds[0][0] == RDL::Globals.types[:bot])
          ## use upper bounds in this case.
          non_vartype_ubounds = var_type.ubounds.map { |t, ast| t}.reject { |t| t.is_a?(RDL::Type::VarType) }
          sol = RDL::Type::IntersectionType.new(*non_vartype_ubounds)
          puts "Extracted solution for #{var_type} is #{sol}"
        else
          ## use lower bounds
          non_vartype_lbounds = meth_type.ret.lbounds.map { |t, ast| t}.reject { |t| t.is_a?(RDL::Type::VarType) }
          sol = RDL::Type::UnionType.new(*non_vartype_lbounds).canonical
          puts "Extracted solution for #{meth_type.ret} is #{sol}"
        end
      end
    }
  end

  
end
