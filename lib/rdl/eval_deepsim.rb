class RDL::Heuristic

  @arg_type_pool = []
  @ret_type_pool = []
  @var_ranked_sols = {}

  def self.get_ranked_sols
    @var_ranked_sols
  end

  def self.make_var_types
    $orig_type_list.each { |klass, meth|
      begin
        meth_type = RDL::Typecheck.make_unknown_method_type(klass, meth)
      rescue => e
        puts "Could not make unknown method type for #{klass}/#{meth}"
        next
      end
      orig_type = RDL::Globals.info.get(klass, meth, :orig_type)
      raise "Could not find original type for #{klass}/#{meth}" unless orig_type
      orig_type = orig_type[0]
      
      next if orig_type.args.size != meth_type.args.size

      meth_type.args.each_with_index { |arg, i|
        arg = arg.type if arg.optional_var_type? || arg.vararg_var_type?
        next if arg.is_a?(RDL::Type::FiniteHashType)
        #puts "Adding arg solution #{orig_type.args[i]} for variable #{arg}"
        arg.solution = orig_type.args[i]
        @arg_type_pool << arg
      }

      next if orig_type.ret == RDL::Globals.types[:bot]
      meth_type.ret.solution = orig_type.ret
      #puts "Adding ret solution #{orig_type.ret} for #{meth_type.ret}"
      @ret_type_pool << meth_type.ret
    }
  end

  def self.gen_rankings(category)
    if category == :arg
      pool = @arg_type_pool
    elsif category == :ret
      pool = @ret_type_pool
    else
      raise "Unexpected category #{category}."
    end

    pool.each { |var1|
      vec_res = vectorize_var(var1)
      next if vec_res.nil?
      to_compare = []
      pool.each { |var2|
        next if var2 == var1
        vec_res = vectorize_var(var2)
        next if vec_res.nil?
        to_compare << var2
      }
      to_compare_ids = to_compare.map { |v| v.object_id }
      params = { action: "get_similarities", id1: var1.object_id, id_comps: to_compare_ids, kind: category }
      res = send_query(params)
      res = JSON.parse(res.body)
      raise "Expected #{to_compare_ids.size} similarity scores, received #{res.size}" unless res.size == to_compare_ids.size
      sols = {}
      res.each_with_index  { |score, i|
        #@bert_cache[var1][var2] = score
        sols[score] = to_compare[i]
      }
      ranked_sols = sols.sort.map { |score, var| var.solution }.reverse.uniq
      @var_ranked_sols[var1] = ranked_sols
    }
  end

  def self.find_first_match(var)
    rankings = @var_ranked_sols[var]
    rank = rankings.index { |sol| (var.solution == sol) || (var.solution.is_a?(RDL::Type::GenericType) && sol.is_a?(RDL::Type::GenericType) && (var.solution.base == sol.base)) }
    rank = rank.nil? ? -1 : 1 + rank
    return rank
  end

  def self.get_rank_accs(category)
    make_var_types
    gen_rankings(category)
    correct_sol_rankings = @var_ranked_sols.keys.map { |var| find_first_match(var) }
    tot = correct_sol_rankings.size
    puts "TOTAL # QUERIES = #{tot}"
    puts "CATEGORY = #{category}"
    puts "rank,num sols at or under rank, accuracy"
    1.upto(10) { |rank|
      count = correct_sol_rankings.count { |r| (r != -1) && (r <= rank) }
      puts "#{rank},#{count},#{count.to_f / tot}"
    }
    
  end
  
  
end
