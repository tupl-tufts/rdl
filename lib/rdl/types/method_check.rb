module RDL::MethodCheck
  def self.select_and_check_args(method_types, method_name, args, has_block=false)
    possible_types = []
    num_actual_args = args.length

    for m in method_types
      next if num_actual_args < m.min_args
      next if m.max_args != -1 and num_actual_args > m.max_args
      next if (not m.block.nil?) != has_block

      arg_impl_valid, vartype_map = self.check_arg_impl(m, args)  

      if arg_impl_valid
        possible_types.push(m)
      end
    end

    if possible_types.size > 1
      raise Exception, "cannot infer type in intersecton type for method #{method_name}, whose types are #{method_types.inspect}"
    elsif possible_types.size == 0 
      arg_types = args.map {|a| a.rdl_type}

      raise RDL::TypesigException, "In method #{method_name}, annotated types are #{method_types.inspect}, but actual arguments are #{args.inspect} and has_block = #{has_block}, with types #{arg_types.inspect}" 
    else
      chosen_type = possible_types[0]
    end

    vartype_map.empty? ? chosen_type : chosen_type.replace_vartypes(vartype_map)
  end

  def self.check_return(method_type, ret_value)
    ret_value.rdl_type.le method_type.ret
  end

  def self.check_arg_impl(m_type, args)
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

    le_h = {}

    for arg_range in required_indices 
      # while loops are faster...
      start_offset, end_index, type_offset = arg_range
      i = 0
      while start_offset + i  < end_index
        type_index = type_offset + i
        value_index = start_offset + i
        if expected_arg_types[type_index].instance_of?(RDL::Type::MethodType)
          raise Exception, "not implemented"
        else
          unless args[value_index].rdl_type.le(expected_arg_types[type_index], le_h)
            valid = false
            break
          end
        end

        i = i + 1
      end
      break if not valid
    end

    return [false, le_h] if not valid

    # skip the optional shenanigans if we're done
    if arg_layout[:opt] == 0 and arg_layout[:rest] == false
      return [true, le_h]
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
        raise Exception, "not implemented"
      else
        unless args[i].rdl_type.le(expected_arg_types[i].type, le_h)
          valid = false
          break
        end
      end
      i = i + 1
    end

    return [false, le_h] if not valid
    
    if not arg_layout[:rest]
      return [true, le_h]
    end

    rest_index = arg_layout[:required][0] + arg_layout[:opt]
    rest_type = expected_arg_types[rest_index].type
    i = arg_layout[:required][0] + arg_layout[:opt]

    if rest_type.instance_of?(RDL::Type::MethodType)
      raise Exception, "not implemented"
    else
      while i < post_req_start
        unless args[i].rdl_type.le(rest_type, le_h)
          valid = false
          break
        end
        i = i + 1
      end
    end
    return [valid, le_h]
  end
end
