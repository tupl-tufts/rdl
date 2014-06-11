require_relative './native'
#require 'rtc/runtime/native'
#require 'rtc/options'

module RDL::MethodCheck
  def self.check_type(value, type, check_variables = true)
    #if value.is_proxy_object?
    #  value.rtc_type <= type
    #elsif type.is_tuple
    if type.is_tuple
      return false unless value.is_a?(Array) and value.size == type.ordered_params.size

      i = 0
      len = value.size
      ordered_params = type.ordered_params

      while i < len
        return false unless self.check_type(value[i], ordered_params[i], check_variables)
        i += 1
      end

      return true
=begin
    elsif type.is_a?(Rtc::Types::HashType)
      return false unless value.is_a?(Hash)
      type.required.each {
        |k,t|
        return false unless value.has_key?(k)
        return false unless self.check_type(value[k], t, check_variables)
      }
      type.optional.each {
        |k,t|
        if value.has_key?(k)
          return false unless self.check_type(value[k], t, check_variables)
        end
      }
      return true
=end
    #elsif $RTC_STRICT or (not value.rtc_is_complex?)
    elsif not value.rtc_is_complex?
      return value.rdl_type <= type
    else
      if type.has_variables and check_variables
        return value.rdl_type <= type
      end
      case type
      when RDL::Type::GenericType
        #return type.nominal.klass == value.class
        #return type.base == value.class
        t = eval(type.base.name.to_s)
        return t == value.class
      when RDL::Type::UnionType
        if type.has_variables
          solution_found = false
          for t in type.types
            if self.check_type(value, t, check_variables)
              raise Exception, "Ambiguous union detected" if solution_found
              solution_found
            end
          end
          solution_found
        else
          type.types.any? {|t|             
            self.check_type(value, t, check_variables)
          }
        end
      when RDL::Type::TopType
        return true
      else
        return false
      end
    end
  end
  
  def self.select_and_check_args(method_types, method_name, args, has_block, class_obj)
    method_types.each { |mt|
      mt.type_variables.each { |tv| tv.start_solve if not tv.instantiated? and not tv.solving? }
    }

    possible_types = RDL::NativeArray.new
    num_actual_args = args.length

    for m in method_types
      next if num_actual_args < m.min_args
      next if m.max_args != -1 and num_actual_args > m.max_args
      next if (not m.block.nil?) != has_block

      annotate_now = m.type_variables.empty?
      annot_vector = RDL::NativeArray.new(args.length)

      if self.check_arg_impl(m, args, annotate_now, annot_vector)
        possible_types.push([m, annotate_now ? annot_vector : false])
      end
    end
    
    if possible_types.size > 1
      raise Exception, "cannot infer type in intersecton type for method #{method_name}, whose types are #{method_types.inspect}"
    elsif possible_types.size == 0 
      arg_types = args.map {|a|
        a.rdl_type
      }
      
      raise TypesigException, "In method #{method_name}, annotated types are #{method_types.inspect}, but actual arguments are #{args.inspect}, with types #{arg_types.inspect}" +
        " for class #{class_obj}"
    else
      chosen_type, annotations = possible_types[0]
    end

    if not annotations
      unsolved_variables = update_variables(chosen_type.type_variables)
      annotations = annotate_args(chosen_type, args)
    else
      unsolved_variables = []
    end

    return chosen_type, annotations, unsolved_variables
  end

  def self.check_return(m_type, return_value, unsolved_variables)
    unsolved_variables = update_variables(unsolved_variables)
    return false unless self.check_type(return_value, m_type.ret)
    update_variables(unsolved_variables)
    true
  end

  def self.check_args(m_type, args, unsolved_variables)
    if unsolved_variables.empty?
      annot_vector = RDL::NativeArray.new(args.length)
      return self.check_arg_impl(m_type, args, true, annot_vector) ? 
      [annot_vector,[]] : false
    else
      return false unless self.check_arg_impl(m_type, args, false)
      unsolved_variables = update_variables(unsolved_variables)
      annotations = annotate_args(m_type, args)
      return annotations, unsolved_variables
    end
  end

  def self.update_variables(t_vars)
    return unless t_vars
    unsolved_type_variables = RDL::NativeArray.new
    t_vars.each {
      |tvar|
      if tvar.solvable?
        tvar.solve
      elsif tvar.instantiated
        next
      else
        unsolved_type_variables << tvar
      end
    }
    return unsolved_type_variables
  end

  # comment this too. it needs it badly
  def self.annotate_args(method_type, args)
    annot_vector = RDL::NativeArray.new(args.length)
    arg_types = method_type.args
    # cached, not so bad
    param_layout = method_type.parameter_layout
    num_args = args.length
    i = 0
    #unwrap_positions = method_type.unwrap
    unwrap_positions = []

    while i < param_layout[:required][0]
      if unwrap_positions.include?(i)
        annot_vector[i] = args[i]
      else
        annot_vector[i] = args[i]#.rtc_annotate(arg_types[i].to_actual_type)
      end
      i = i + 1
    end
    i = num_args - param_layout[:required][1]
    while i < num_args
      if unwrap_positions.include?(i)
        annot_vector[i] = args[i]
      else
        annot_vector[i] = args[i].rtc_annotate(arg_types[i].to_actual_type)
      end
      i = i + 1
    end
    i = param_layout[:required][0]
    while i < (param_layout[:required][0] + param_layout[:opt]) and
        i < (num_args - param_layout[:required][1])
      if unwrap_positions.include?(i)
        annot_vector[i] = args[i]
      else
        annot_vector[i] = args[i].rtc_annotate(arg_types[i].type.to_actual_type)
      end
      i = i + 1
    end
    i = param_layout[:required][0] + param_layout[:opt]
    rest_index = i
    no_annotate_rest = unwrap_positions.include?(rest_index)
    while i < num_args - param_layout[:required][1]
      if no_annotate_rest
        annot_vector[i] = args[i]
      else
        annot_vector[i] = args[i].rtc_annotate(arg_types[rest_index].type.to_actual_type)
      end
      i = i + 1
    end
    return annot_vector
  end
  
  # returns false on type error or a true value.
  # TOOD(jtoman): comment this. it needs it *badly*
  def self.check_arg_impl(m_type, args,annotate_now, annot_vector = nil)
    expected_arg_types = m_type.args
    arg_layout = m_type.parameter_layout
    i = 0
    valid = true
    num_actual_args = args.length
    required_indices = [
                        # start offset, end index, type offset
                        [0,arg_layout[:required][0], 0],
                        [num_actual_args - arg_layout[:required][1], num_actual_args, 
                         arg_layout[:required][0] + arg_layout[:opt] + (arg_layout[:rest]?1 : 0)
                        ]
                       ]

    # TODO: Fix unwrap_positions
    #unwrap_positions = m_type.unwrap
    unwrap_positions = []

    for arg_range in required_indices 
      # while loops are faster...
      start_offset, end_index, type_offset = arg_range
      i = 0
      while start_offset + i  < end_index
        type_index = type_offset + i
        value_index = start_offset + i
        if expected_arg_types[type_index].instance_of?(RDL::Type::MethodType)
          annot_vector[value_index] = Rtc::BlockProxy.new(args[value_index], 
                                                          expected_arg_types[type_index].to_actual_type, 
                                                          method_name, class_obj, []) if annotate_now
        else
          unless self.check_type(args[value_index], expected_arg_types[type_index])
            valid = false
            break
          end

          if annotate_now
            if unwrap_positions.include?(type_index)
              annot_vector[value_index] = args[value_index]
            else
              annot_vector[value_index] = args[value_index]#.rtc_annotate(expected_arg_types[type_index].to_actual_type)
            end
          end
        end

        i = i + 1
      end
      break if not valid
    end

    return false if not valid

    # skip the optional shenanigans if we're done
    if arg_layout[:opt] == 0 and arg_layout[:rest] == false
      return true
    end
    
    # start index of the final required arguments
    post_req_start = num_actual_args - arg_layout[:required][1]
    non_req_args_count = post_req_start - arg_layout[:required][0]
    if non_req_args_count > arg_layout[:opt]
      final_opt_index = arg_layout[:required][0] + arg_layout[:opt]
    else
      final_opt_index = post_req_start
    end
    i = arg_layout[:required][0]
    while i < final_opt_index
      if expected_arg_types[i].type.instance_of?(RDL::Type::MethodType)
        annot_vector[i] = Rtc::BlockProxy.new(args[i], expected_arg_types[i].type.to_actual_type, method_name, class_obj, []) if annotate_now
      else
        unless self.check_type(args[i], expected_arg_types[i].type)
          valid = false
          break
        end
        if annotate_now
          if unwrap_positions.include?(i)
            annot_vector[i] = arg[i]
          else
            annot_vector[i] = args[i].rtc_annotate(expected_arg_types[i].type.to_actual_type)
          end
        end
      end
      i = i + 1
    end

    return false if not valid
    
    if not arg_layout[:rest]
      return true
    end
    rest_index = arg_layout[:required][0] + arg_layout[:opt]
    rest_type = expected_arg_types[rest_index].type
    i = arg_layout[:required][0] + arg_layout[:opt]
    if rest_type.instance_of?(Rtc::Types::ProceduralType)
      if annotate_now
        while i < post_req_start
          annot_vector[i] = Rtc::BlockProxy.new(args[i], rest_type.to_actual_type, method_name, class_obj, [])
        end
      end
    else
      while i < post_req_start
        unless self.check_type(args[i], rest_type)
          valid = false
          break
        end
        if annotate_now
          if unwrap_positions.include?(rest_index)
            annot_vector[i] = args[i]
          else
            annot_vector[i] = args[i].rtc_annotate(rest_type)
          end
        end
        i = i + 1
      end
    end
    return valid
  end
end
