class RDL::Heuristic

  @rules = {}

  @meth_cache = {}

  @twin_cache = Hash.new { |h, k| h[k] = {} }
  @bert_cache = Hash.new { |h, k| h[k] = {} }

  def self.add(name, &blk)
    raise RuntimeError, "Expected heuristic name to be Symbol, given #{name}." unless name.is_a? Symbol
    raise RuntimeError, "Expected block to be provided for heuristic." if blk.nil?
    @rules[name] = blk
  end

  def self.matching_classes(meth_names)
    meth_names.delete(:initialize)
    meth_names.delete(:new)

    return @meth_cache[meth_names] if @meth_cache.key? meth_names
    RDL::Logging.log :heuristics, :debug, "Checking matching classes for #{meth_names}"

    matching_classes = ObjectSpace.each_object(Module).select { |c|
      class_methods = c.instance_methods | RDL::Globals.info.get_methods_from_class(c.to_s)
      (meth_names - class_methods).empty? } ## will only be empty if meth_names is a subset of c.instance_methods

    @meth_cache[meth_names] = matching_classes
    matching_classes
  end

  def self.struct_to_nominal(var_type)
    return unless (var_type.category == :arg) || (var_type.category == :var) ## this rule only applies to args and (instance/class/global) variables
    #return unless var_type.ubounds.all? { |t, loc| t.is_a?(RDL::Type::StructuralType) || t.is_a?(RDL::Type::VarType) } ## all upper bounds must be struct types or var types
    return unless var_type.ubounds.any? { |t, loc| t.is_a?(RDL::Type::StructuralType) } ## upper bounds must include struct type(s)
    struct_types = var_type.ubounds.select { |t, loc| t.is_a?(RDL::Type::StructuralType) }
    struct_types.map! { |t, loc| t }
    return if struct_types.empty?
    meth_names = struct_types.map { |st| st.methods.keys }.flatten.uniq
    matching_classes = matching_classes(meth_names)
    matching_classes.reject! { |c| c.to_s.start_with?("#<Class") || /[^:]*::[a-z]/.match?(c.to_s) || c.to_s.include?("ARGF") } ## weird few constants where :: is followed by a lowecase letter... it's not a class and I can't find anything written about it.
    ## TODO: special handling for arrays/hashes/generics?
    ## TODO: special handling for Rails models? see Bree's `active_record_match?` method
    #raise "No matching classes found for structural types with methods #{meth_names}." if matching_classes.empty?
    RDL::Logging.log :heuristics,
                     :debug,
                     "Struct_to_nominal heuristsic for %s in method %s:%s yields %d matching classes with methods: %s" %
                         [var_type.name, var_type.cls, var_type.meth, matching_classes.size, meth_names*","]
    return if matching_classes.size > 10 ## in this case, just keep the struct types
    nom_sing_types = matching_classes.map { |c| if c.singleton_class? then RDL::Type::SingletonType.new(RDL::Util.singleton_class_to_class(c)) else RDL::Type::NominalType.new(c) end }
    union = RDL::Type::UnionType.new(*nom_sing_types).canonical
    #struct_types.each { |st| var_type.ubounds.delete_if { |s, loc| s.equal?(st) } } ## remove struct types from upper bounds


    return union
    ## used to add and propagate here. Now that this is a heuristic, this should be done after running the rule.
    #var_type.add_and_propagate_upper_bound(union, nil)
  end



  def self.twin_network_guess(var_type)
    return unless (var_type.category == :arg) || (var_type.category == :var) || (var_type.category == :ret)  ## this rule only applies to args and (instance/class/global) variables
    name1 = var_type.base_name#var_type.category == :ret ? var_type.meth.to_s : var_type.name.to_s
    #sols = []
    sols = {}

    
    uri = URI "http://127.0.0.1:5000/"

    RDL::Typecheck.type_names_map.each { |t, names|

      sum = 0
      count = 0
      names.each { |name|
        count += 1
        if @twin_cache[name1][name]
          sum += @twin_cache[name1][name]
        else
          params = { words: [name1, name], method: "twin" }
          uri.query = URI.encode_www_form(params)
          res = Net::HTTP.get_response(uri)
          raise "Failed to make request to twin network server. Received response #{res.body}." unless res.msg == "OK"
          sum += res.body.to_f
          @twin_cache[name1][name] = res.body.to_f
        end
      }
      sim_score = sum / count

=begin      
## Below was query approach before implementing caching.
      params = { words: [name1] + names }
      uri.query = URI.encode_www_form(params)
      #puts "SENDING QUERY OF SIZE #{names.size + 1}: #{names}"
      res = Net::HTTP.get_response(uri)
      #puts "RECEIVED: #{res}"
      puts "Failed to make request to twin network server. Received response #{res.body}." unless res.msg == "OK"

      sim_score = res.body.to_f
=end
      if sim_score > 0.8
        #puts "Twin network found #{name1} and list #{names} have average similarity score of #{sim_score}.".green
        #puts "Adding #{t} as a potential solution."
      #sols << t
        sols[sim_score] = t
      else
        #puts "Twin network found insufficient average similarity score of #{sim_score} between #{name1} and #{names}.".red
      end
    }
   #puts "Done querying all of type_names_map".green

    ## return list of types that are sorted from highest similarity score to lowest
    return sols.sort.map { |sim_score, t| t }.reverse 

    ## TODO: Is creating UnionType the right way to go?
    #return RDL::Type::UnionType.new(*sols).canonical
    
=begin  
     params = { in1: name1, in2: name2 }
     uri.query = URI.encode_www_form(params)

     res = Net::HTTP.get_response(uri)
     if res.msg != "OK"
       puts "Failed to make request to twin network server. Received response #{res.body}."
       return nil
     end

     sim_score = res.body.to_f
     if sim_score > 0.8
       puts "Twin network found #{name1} and #{name2} have similarity score of #{sim_score}."
       puts "Attempting to apply Integer as solution."
       ## TODO: once we replace "count" above, also have to replace Integer as solution.
       return RDL::Globals.types[:integer]
     else
       puts "Twin network found insufficient similarity score of #{sim_score} between #{name1} and #{name2}."
       return nil
     end
=end
  
  end


  def self.twin_network_constraints(pairs_enum)
    uri = URI "http://127.0.0.1:5000/"
    sols = {}
    pairs_enum.each { |var1, var2|
      name1 = var1.base_name
      name2 = var2.base_name

      if @twin_cache[name1][name2]
        sols[[var1, var2]] = @twin_cache[name1][name2]
      else
        params = { words: [name1, name2], method: "twin" }
        uri.query = URI.encode_www_form(params)
        res = Net::HTTP.get_response(uri)
        raise "Failed to make request to twin network server. Received response #{res.body}." unless res.msg == "OK"
        sols[[var1, var2]] = res.body.to_f
        @twin_cache[name1][name2] = res.body.to_f
      end
    }
    sorted = sols.sort_by { |k, v| v }.reverse
    sorted.each { |vars, score|
      #puts "Score: #{score}. Vars: [#{vars[0]}, #{vars[1]}"
      var1, var2 = vars
      if score > 0.9
        new_cons = {}
        begin
          var1.add_and_propagate_upper_bound(var2, nil, new_cons)
          var1.add_and_propagate_lower_bound(var2, nil, new_cons)
          RDL::Typecheck.set_new_constraints if !new_cons.empty?
        rescue => e
          RDL::Typecheck.undo_constraints(new_cons)
        end
      end
    }

    
  end

  def self.bert_model_guess(var_type)
    uri = URI "http://127.0.0.1:5000/"
    if (var_type.category == :arg)
      sols = {}
      
      begin_loc1, end_loc1 = get_arg_loc(var_type) ## get start location of arg in source code


      RDL::Typecheck.type_vars_map.each { |t, vars|
        sum = 0
        count = 0
        raise "Got here for #{t}" if vars.empty?
        vars.each { |var2|
          next if (var_type == var2) || !(var2.category == :arg)
          count += 1
          if @bert_cache[var_type][var2]
            puts "Hit cache for vars #{var_type} and #{var2}, with score of #{@bert_cache[var_type][var2]}".red
            sum += @bert_cache[var_type][var2]
          else            
            source1 = RDL::Typecheck.get_ast(var_type.cls, var_type.meth).loc.expression.source
            source2 = RDL::Typecheck.get_ast(var2.cls, var2.meth).loc.expression.source
            begin_loc2, end_loc2 = get_arg_loc(var2)
            puts "Querying for vars #{var_type.base_name} and #{var2.base_name}.".red
            puts "Sanity check: #{source1[begin_loc1..end_loc1]} and #{source2[begin_loc2..end_loc2]}"
            params = { sources: [source1, source2], var1_locs: [begin_loc1, end_loc1], var2_locs: [begin_loc2, end_loc2], method: "bert"}
            uri.query = URI.encode_www_form(params)
            res = Net::HTTP.get_response(uri)
            raise "Failed to make request to twin network server. Received response #{res.body}." unless res.msg == "OK"
            sum += res.body.to_f
            @bert_cache[var_type][var2] = res.body.to_f
            @bert_cache[var2][var_type] = res.body.to_f
            puts "Received similarity score of #{res.body.to_f} for vars #{var_type.cls}##{var_type.meth}##{var_type.base_name} and #{var2.cls}##{var2.meth}##{var2.base_name}".red
          end
        }
        sim_score = (count == 0) ? 0 : sum / count
        puts "Received overall sim_score average of #{sim_score} for var #{var_type.cls}##{var_type.meth}##{var_type.base_name} and type #{t}".green if sim_score != 0


        if sim_score > 0.9
          sols[sim_score] = t
        else
          #puts "Twin network found insufficient average similarity score of #{sim_score} between #{name1} and #{names}.".red
        end
      }

      ## return list of types that are sorted from highest similarity score to lowest
      return sols.sort.map { |sim_score, t| t }.reverse 

       
    else
      puts "not yet implemented"
    end
  end

  def self.get_arg_loc(var_type)
    ast = RDL::Typecheck.get_ast(var_type.cls, var_type.meth)
    begin_pos = ast.loc.expression.begin_pos

    if ast.type == :def
      meth_name, args, body = *ast
    elsif ast.type == :defs
      _, meth_name, args, body = *ast
    else
      raise RuntimeError, "Unexpected ast type #{ast.type}"
    end

    args.children.each { |c|
      if (c.children[0].to_s == var_type.base_name)
        ## Found the arg corresponding to var_type
        return [c.loc.expression.begin_pos - begin_pos, c.loc.expression.end_pos - begin_pos - 1] ## translate it so that 0 is first position
      end
    }

  end

end


class << RDL::Heuristic
  attr_reader :rules
end

class String
  def is_rails_model?
    return false unless defined? Rails
    ActiveRecord::Base.descendants.map { |d| d.to_s }.include? self
  end

  def to_type
    camelized = self.camelize
    RDL::Type::NominalType.new(RDL::Util.to_class(camelized))
  end

  def is_pluralized_model?
    return false unless defined? Rails
    return false unless pluralize == self
    singularize.camelize.is_rails_model?
  end

  def model_set_type
    RDL::Globals.parser.scan_str "#T Array<#{singularize.camelize}> or ActiveRecord_Relation<#{singularize.camelize}>"
  end

end
if $use_heuristics
  if defined? Rails
    RDL::Heuristic.add(:is_model) { |var| if var.base_name.camelize.is_rails_model? then var.base_name.to_type end }
    RDL::Heuristic.add(:is_pluralized_model) { |var| if var.base_name.is_pluralized_model? then var.base_name.model_set_type end }
  end

  RDL::Heuristic.add(:struct_to_nominal) { |var| t1 = Time.now; g = RDL::Heuristic.struct_to_nominal(var); $stn = $stn + (Time.now - t1); g }
  RDL::Heuristic.add(:int_names) { |var| if var.base_name.end_with?("id") || (var.base_name.end_with? "num") || (var.base_name.end_with? "count") then RDL::Globals.types[:integer] end }
  RDL::Heuristic.add(:int_array_name) { |var| if var.base_name.end_with?("ids") || (var.base_name.end_with? "nums") || (var.base_name.end_with? "counts") then RDL::Globals.parser.scan_str "#T Array<Integer>" end }
  RDL::Heuristic.add(:predicate_method) { |var| if var.base_name.end_with?("?") then RDL::Globals.types[:bool] end }
  RDL::Heuristic.add(:string_name) { |var| if var.base_name.end_with?("name") then RDL::Globals.types[:string] end }
  RDL::Heuristic.add(:hash_access) { |var|
    old_var = var
    var = var.type if old_var.is_a?(RDL::Type::OptionalType)
    types = []
    var.ubounds.reject { |t, ast| t.is_a?(RDL::Type::VarType) }.each { |t, ast|
      if t.is_a?(RDL::Type::IntersectionType)
        types = types + t.types
      else
        types << t
      end
    }
    if !types.empty? && types.all? { |t| t.is_a?(RDL::Type::StructuralType) && t.methods.all? { |meth, typ| ((meth == :[]) || (meth == :[]=)) && typ.args[0].is_a?(RDL::Type::SingletonType) && typ.args[0].val.is_a?(Symbol)  } }
      hash_typ = {}
      types.each { |struct|
        struct.methods.each { |meth, typ|
          if meth == :[]
            value_type = typ.ret#typ.ret.is_a?(RDL::Type::VarType) ? RDL::Typecheck.extract_var_sol(typ.ret, :arg).canonical : typ.ret.canonical
          elsif meth == :[]=
            value_type = typ.args[1]#typ.args[1].is_a?(RDL::Type::VarType) ? RDL::Typecheck.extract_var_sol(typ.args[1], :arg).canonical : typ.args[1].canonical
          else
            raise "Method should be one of :[] or :[]=, got #{meth}."
          end
          if value_type.is_a?(RDL::Type::UnionType)
            RDL::Type::UnionType.new(*value_type.types.map { |t| RDL::Typecheck.extract_var_sol(t, :arg) }).drop_vars.canonical
          elsif value_type.is_a?(RDL::Type::IntersectionType)
            RDL::Type::IntersectionType.new(*value_type.types.map { |t| RDL::Typecheck.extract_var_sol(t, :arg) }).drop_vars.canonical
          else
            value_type = RDL::Typecheck.extract_var_sol(value_type, :arg)
          end
          #value_type = value_type.drop_vars!.canonical if (value_type.is_a?(RDL::Type::UnionType) || value_type.is_a?(RDL::Type::IntersectionType)) && (!value_type.types.all? { |t| t.is_a?(RDL::Type::VarType) })
          hash_typ[typ.args[0].val] = RDL::Type::UnionType.new(value_type, hash_typ[typ.args[0].val]).canonical#RDL::Type::OptionalType.new(value_type) ## TODO:
        }
      }
      #var.ubounds.delete_if { |t| t.is_a?(RDL::Type::StructuralType) } #= [] ## might have to change this later, in particular to take advantage of comp types when performing solution extraction
      fht = RDL::Type::FiniteHashType.new(hash_typ, nil)
      if old_var.is_a?(RDL::Type::OptionalType)
        RDL::Type::OptionalType.new(fht)
      else
        fht
      end
    end
  }
end

### For rules involving :include?, :==, :!=, etc. we would need to track the exact receiver/args used in the method call, and somehow store these in the bounds created for a var type.

if $use_twin_network
  RDL::Heuristic.add(:twin_network) { |var| RDL::Heuristic.bert_model_guess(var) }
end
