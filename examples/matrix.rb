require 'matrix'
require 'rdl'

$error_threshold = 0.000001

class Matrix
  class << self
    extend RDL

    spec :identity do
      pre_task do |arg|
        $matrix_identity_arg = arg
      end

      arg 0, (RDL.flat {|a| a > 0})

      ret (RDL.flat {|r|
             num_rows = r.instance_variable_get(:@rows).size
             num_cols = r.instance_variable_get(:@column_size)
             arg = $matrix_identity_arg
             c = true
             
             for i in 0..num_rows-1
               for j in 0..num_cols-1
                 if i == j
                   c = c & (r[i,j] == 1)
                 else
                   c = c & (r[i,j] == 0)
                 end
               end
             end

             (num_cols == arg) & (num_rows == arg) & c
           })
    end

    spec :[] do
      pre_task do |*args|
        $matrix_create_args = args
      end

      pre_cond do |*args|
        arg_sizes = args.map {|x| x.size}
        (arg_sizes.uniq.size == 1) | (arg_sizes.uniq.size == 0)
      end

      ret (RDL.flat {|r|
             args = $matrix_create_args
             ret_rows = r.instance_variable_get(:@rows)

             args == ret_rows
           })
    end

    spec :build do
      pre_task do |*args|
        $matrix_build_args = args
      end

      pre_cond do |*args|
        arg_sizes = args.map {|x| x.size}
        (arg_sizes.uniq.size == 1) | (arg_sizes.uniq.size == 0)
      end

      arg 0, RDL.flat {|a| a >= 0}
      rest 1, RDL.flat {|a| a >= 0}

      ret (RDL.flat {|r|
             row_size_arg = $matrix_build_args[0]
             
             if $matrix_build_args.size == 1
               # 2nd arg is a default arg == 1st_arg
               column_size_arg = row_size_arg  
             else
               column_size_arg = $matrix_build_args[1]
             end

             ret_row_count = r.instance_variable_get(:@rows).size
             ret_col_count = r.instance_variable_get(:@column_size)
             
             (row_size_arg == ret_row_count) & (column_size_arg == ret_col_count)
           })
    end

    spec :column_vector do
      pre_task do |arg|
        $matrix_column_vector_arg = arg
      end

      ret (RDL.flat {|r|
             arg = $matrix_column_vector_arg
             
             ret_rows = r.instance_variable_get(:@rows)
             ret_row_count = ret_rows.size
             ret_col_count = r.instance_variable_get(:@column_size)

             c = true

             for i in 0..ret_row_count-1
               c = c & (ret_rows[i] == [arg[i]])
             end

             (ret_row_count == arg.size) & (ret_col_count == 1) & c
           })
    end

    spec :columns do
      pre_task do |arg|
        $matrix_columns_arg = arg
      end

      ret (RDL.flat {|r|
             arg = $matrix_columns_arg
             transpose_ret_rows = r.transpose.instance_variable_get(:@rows)

             transpose_ret_rows == arg
           })
    end

    spec :diagonal do
      pre_task do |*args|
        $matrix_diagonal_args = args
      end

      ret (RDL.flat {|r|
             args = $matrix_diagonal_args
             ret_row_count = r.instance_variable_get(:@rows).size
             ret_col_count = r.instance_variable_get(:@column_size)

             c = true

             for i in 0..ret_row_count-1
               for j in 0..ret_col_count-1
                 if i == j
                   c = c & (r[i,j] == args[i])
                 else
                   c = c & (r[i,j] == 0)
                 end
               end
             end

             (ret_row_count == ret_col_count) & (ret_row_count == args.size) & c
           })
    end

    spec :empty do
      pre_task do |*args|
        $matrix_empty_args = args
      end

      pre_cond do |*args|
        if args.size == 0
          row_size = 0
          col_size = 0
        elsif args.size == 1
          row_size = args[0]
          col_size = 0
        else
          row_size = args[0]
          col_size = args[1]
        end        

        (row_size >= 0) & (col_size >= 0) & ((row_size == 0) | (col_size == 0))
      end

      ret (RDL.flat {|r|
             args = $matrix_empty_args
             
             if args.size == 0
               row_size = 0
               col_size = 0
             elsif args.size == 1
               row_size = args[0]
               col_size = 0
             else
               row_size = args[0]
               col_size = args[1]
             end

             ret_rows = r.instance_variable_get(:@rows)
             ret_row_count = ret_rows.size
             ret_col_count = r.instance_variable_get(:@column_size)

             c = ret_rows.all? {|x| x == []}

             (ret_row_count == row_size) & (ret_col_count == col_size) & c
           })
    end

    spec :row_vector do
      pre_task do |arg|
        $matrix_row_vector_arg = arg
      end

      ret (RDL.flat {|r|
             arg = $matrix_row_vector_arg
             
             ret_rows = r.instance_variable_get(:@rows)
             ret_row_count = ret_rows.size
             ret_col_count = r.instance_variable_get(:@column_size)

             (ret_rows == [arg]) & (ret_row_count == 1) & (ret_col_count == arg.size)
           })
    end

    spec :rows do
      pre_task do |*args|
        $matrix_rows_args = args
      end

      pre_cond do |*args|
        arg_sizes = args[0].map {|x| x.size}
        (arg_sizes.uniq.size == 1) | (arg_sizes.uniq.size == 0)
      end

      ret (RDL.flat {|r|
             arg_row = $matrix_rows_args[0]

             # There is a second optional arg.
             # the optional argument copy is false, use the given arrays as the 
             # internal structure of the matrix without copying
             # the post condition involving dup is not listed here

             ret_rows = r.instance_variable_get(:@rows)
             ret_rows == arg_row
           })
    end

    spec :scalar do
      pre_task do |*args|
        $matrix_scalar_args = args
      end

      arg 0, RDL.flat {|a| a > 0}

      ret (RDL.flat {|r|
             arg_n = $matrix_scalar_args[0]
             arg_value = $matrix_scalar_args[1]

             ret_row_size = r.instance_variable_get(:@rows).size
             ret_col_size = r.instance_variable_get(:@column_size)

             c = true

             for i in 0..ret_row_size-1
               for j in 0..ret_col_size-1
                 if i == j
                   c = c & (r[i,j] == arg_value)
                 else
                   c = c & (r[i,j] == 0)
                 end
               end
             end

             (ret_row_size == ret_col_size) & (ret_col_size == arg_n) & c
           })
    end

    spec :zero do
      pre_task do |arg|
        $matrix_zero_arg = arg
      end

      arg 0, RDL.flat {|a| a > 0}

      ret (RDL.flat {|r|
             arg = $matrix_zero_arg

             ret_row_size = r.instance_variable_get(:@rows).size
             ret_col_size = r.instance_variable_get(:@column_size)

             c = true

             for i in 0..ret_row_size-1
               for j in 0..ret_col_size-1
                 c = c & (r[i,j] == 0)
               end
             end

             (ret_row_size == ret_col_size) & (ret_col_size == arg) & c
           })
    end
  end
end

class Matrix
  extend RDL

  spec :* do
    pre_task do |arg|
      $matrix_mult_arg = arg
      $matrix_mult_self = self
    end

    # an RTC pre_condition would require all elements to be numbers
    
    ret (RDL.flat {|r|
           arg = $matrix_mult_arg
           slf = $matrix_mult_self

           ret_row_size = r.instance_variable_get(:@rows).size
           ret_col_size = r.instance_variable_get(:@column_size)
           
           slf_row_size = slf.instance_variable_get(:@rows).size
           arg_col_size = arg.instance_variable_get(:@column_size)

           (ret_row_size == slf_row_size) & (ret_col_size == arg_col_size)
         })
  end

  spec :** do
    pre_task do |arg|
      $matrix_exp_arg = arg
      $matrix_exp_self = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_exp_self

           ret_row_size = r.instance_variable_get(:@rows).size
           ret_col_size = r.instance_variable_get(:@column_size)
           
           slf_row_size = slf.instance_variable_get(:@rows).size

           (ret_row_size == ret_col_size) & (slf_row_size == ret_col_size)
         })
  end

  spec :- do
    pre_task do |arg|
      $matrix_minus_arg = arg
      $matrix_minus_slf = self
    end
    
    ret (RDL.flat {|r|
           arg = $matrix_minus_arg
           slf = $matrix_minus_slf

           arg_row_size = arg.instance_variable_get(:@rows).size
           arg_col_size = arg.instance_variable_get(:@column_size)

           ret_row_size = r.instance_variable_get(:@rows).size
           ret_col_size = r.instance_variable_get(:@column_size)

           c = true

           for i in 0..ret_row_size-1
             for j in 0..ret_col_size-1
               c = c & (r[i,j] == slf[i,j] - arg[i,j])
             end
           end
           
           (ret_row_size == arg_row_size) & (ret_col_size == arg_col_size) & c
         })
  end

  spec :+ do
    pre_task do |arg|
      $matrix_add_arg = arg
      $matrix_add_slf = self
    end
    
    ret (RDL.flat {|r|
           arg = $matrix_add_arg
           slf = $matrix_add_slf

           arg_row_size = arg.instance_variable_get(:@rows).size
           arg_col_size = arg.instance_variable_get(:@column_size)

           ret_row_size = r.instance_variable_get(:@rows).size
           ret_col_size = r.instance_variable_get(:@column_size)

           c = true

           for i in 0..ret_row_size-1
             for j in 0..ret_col_size-1
               c = c & (r[i,j] == slf[i,j] + arg[i,j])
             end
           end
           
           (ret_row_size == arg_row_size) & (ret_col_size == arg_col_size) & c
         })
  end

  spec :/ do
    pre_task do |arg|
      $matrix_div_arg = arg
      $matrix_div_slf = self
    end
    
    ret (RDL.flat {|r|
           arg = $matrix_div_arg
           slf = $matrix_div_slf

           arg_row_size = arg.instance_variable_get(:@rows).size
           arg_col_size = arg.instance_variable_get(:@column_size)

           ret_row_size = r.instance_variable_get(:@rows).size
           ret_col_size = r.instance_variable_get(:@column_size)
           
           ret_approx = slf * arg.inverse
           diff = r - ret_approx
           diff_row_size = diff.instance_variable_get(:@rows).size
           diff_col_size = diff.instance_variable_get(:@column_size)

           c = true

           for i in 0..diff_row_size-1
             for j in 0...diff_col_size-1
               c = c & (diff[i,j].abs < $error_threshold)
             end
           end

           (ret_row_size == arg_row_size) & (ret_col_size == arg_col_size) & c
         })
  end

  spec :== do
    pre_task do |arg|
      $matrix_eq_arg = arg
      $matrix_eq_slf = self
    end
    
    ret (RDL.flat {|r|
           arg = $matrix_eq_arg
           slf = $matrix_eq_slf

           arg_row_size = arg.instance_variable_get(:@rows).size
           arg_col_size = arg.instance_variable_get(:@column_size)

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)

           matrices_eq = true

           if not (arg_row_size == slf_row_size and arg_col_size == slf_col_size)
             matrices_eq = false
           else
             for i in 0..arg_row_size-1
               for j in 0..arg_col_size-1
                 matrices_eq = matrices_eq & (arg[i,j] == slf[i,j])
               end
             end
           end

           ((r == true) & matrices_eq) | ((r == false) & (not matrices_eq))
         })
  end

  spec :[] do
    pre_task do |*args|
      $matrix_index_args = args
      $matrix_index_slf = self
    end
    
    ret (RDL.flat {|r|
           args = $matrix_index_args
           slf = $matrix_index_slf

           arg_i = args[0]
           arg_j = args[1]

           slf_rows = slf.instance_variable_get(:@rows)
           slf_row_size = slf_rows.size
           slf_col_size = slf.instance_variable_get(:@column_size)

           args_out_of_range = (arg_i < 0) | (arg_i >= slf_row_size) | (arg_j < 0) | (arg_j >= slf_col_size)
           
           slf_includes_arg = slf_rows.any? {|x| x.any? {|x2| x2 == r} }

           ((r == nil) & args_out_of_range) | slf_includes_arg
         })
  end

  spec :clone do
    # skipped
  end

  spec :coerce do
    # skipped
  end

  spec :collect do
    pre_task do |*args|
      $matrix_collect_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_collect_slf

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)

           ret_row_size = r.instance_variable_get(:@rows).size
           ret_col_size = r.instance_variable_get(:@column_size)

           (slf_row_size == ret_row_size) & (slf_col_size == ret_col_size)
         })
  end

  spec :column do
    pre_task do |arg, &blk|
      $matrix_column_arg = arg
      $matrix_column_blk = blk
      $matrix_column_slf = self
    end

    ret (RDL.flat {|r|
           arg = $matrix_column_arg
           blk = $matrix_column_blk
           slf = $matrix_column_slf

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)

           c = true

           for i in 0..slf_row_size-1 
             c = c & (r[i] == slf[i, arg]) if r != nil
           end

           arg_out_of_range = arg >= slf_col_size || arg < -slf_col_size

           ((not blk) & ((r == nil) & arg_out_of_range) | c) | blk
         })
  end

  spec :column_vectors do
    pre_task do |*args|
      $matrix_column_vectors_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_column_vectors_slf

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)

           c = true

           for i in 0..r.size-1
             c = c & (slf.column(i) == r[i])
           end

           (r.size == slf_col_size) & c
         })
  end

  spec :conjugate do
    pre_task do |*args|
      $matrix_conjugate_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_conjugate_slf

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)

           r_row_size = r.instance_variable_get(:@rows).size
           r_col_size = r.instance_variable_get(:@column_size)

           (r_row_size == slf_row_size) & (r_col_size == slf_col_size)
         })
  end

  spec :determinant do
    pre_task do |*args|
      $matrix_determinant_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_determinant_slf

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)

           # could do something like m.determinant == m.transpose.determinant
           # but seems like there are some recursive call problems with RDL
           
           true
         })
  end

  spec :each do
    # skipped, it can do something with the block argument
  end

  spec :each_with_index do
    # skipped, it can do something with the block argument
  end

  spec :elements_to_f do
    pre_task do |*args|
      $matrix_elements_to_f_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_elements_to_f_slf

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)  

           ret_row_size = r.instance_variable_get(:@rows).size
           ret_col_size = r.instance_variable_get(:@column_size)  

           c = true

           for i in 0..slf_row_size-1
             for j in 0..slf_col_size-1
               diff = (slf[i,j] - r[i,j]).abs
               c = c & (diff < $error_threshold)
             end
           end

           (slf_row_size == ret_row_size) & (slf_col_size == ret_col_size) & c
         })
  end

  spec :elements_to_i do
    pre_task do |*args|
      $matrix_elements_to_f_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_elements_to_f_slf

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)  

           ret_row_size = r.instance_variable_get(:@rows).size
           ret_col_size = r.instance_variable_get(:@column_size)  

           c = true

           for i in 0..slf_row_size-1
             for j in 0..slf_col_size-1
               diff = (slf[i,j] - r[i,j]).abs
               c = c & (diff < $error_threshold)
             end
           end

           (slf_row_size == ret_row_size) & (slf_col_size == ret_col_size) & c
         })
  end

  spec :elements_to_r do
    pre_task do |*args|
      $matrix_elements_to_f_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_elements_to_f_slf

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)  

           ret_row_size = r.instance_variable_get(:@rows).size
           ret_col_size = r.instance_variable_get(:@column_size)  

           c = true

           for i in 0..slf_row_size-1
             for j in 0..slf_col_size-1
               diff = (slf[i,j] - r[i,j]).abs
               c = c & (diff < $error_threshold)
             end
           end

           (slf_row_size == ret_row_size) & (slf_col_size == ret_col_size) & c
         })
  end

  spec :empty? do
    pre_task do |*args|
      $matrix_empty_q_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_empty_q_slf

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)  

           # this post condition is pretty much the method definition

           ((r == true) & ((slf_row_size == 0) & (slf_col_size == 0))) | ((r == false) & (not ((slf_row_size == 0) & (slf_col_size == 0))))
         })
  end

  spec :hash do
    # no post cond?
    # could do something like a bunch of returns are different from difference matrices
    
    ret (RDL.flat {|r|
           true
         })
  end

  spec :imaginary do
    pre_task do |*args|
      $matrix_imaginary_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_imaginary_slf

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)

           r_row_size = r.instance_variable_get(:@rows).size
           r_col_size = r.instance_variable_get(:@column_size)

           (r_row_size == slf_row_size) & (r_col_size == slf_col_size)
         })
  end

  spec :inspect do
     # depends on the inspect of each individual element's inspect
  end

  spec :inverse do
    pre_task do |*args|
      $matrix_inverse_slf = self
    end

    pre_cond do |*args|
      slf_row_size = self.instance_variable_get(:@rows).size
      slf_col_size = self.instance_variable_get(:@column_size)  
      
      slf_row_size == slf_col_size
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_inverse_slf
           
           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)  
  
           # could do something like A * A.inverse = I
           # but seems like RDL does not support such a recursive call
 
           true
         })
  end

  spec :minor do
    pre_task do |*args|
      $matrix_minor_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_minor_slf
           
           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)  

           ret_row_size = r.instance_variable_get(:@rows).size
           ret_col_size = r.instance_variable_get(:@column_size)  
  
           slf_elements = slf.column_vectors.map {|x| x.instance_variable_get(:@elements)}
           slf_elements = slf_elements.flatten(1)

           ret_elements = r.column_vectors.map {|x| x.instance_variable_get(:@elements)}
           ret_elements = ret_elements.flatten(1)

           c = ret_elements.all? {|x| slf_elements.include?(x)}

           (ret_row_size <= slf_row_size) & (ret_col_size <= slf_col_size) & c
         })
  end
  
  spec :rank do
    pre_task do |*args|
      $matrix_rank_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_rank_slf
           slf_row_size = slf.instance_variable_get(:@rows).size
           (r >= 0) & (r <= slf_row_size)
         })
  end

  spec :real do
    pre_task do |*args|
      $matrix_real_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_real_slf

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)

           r_row_size = r.instance_variable_get(:@rows).size
           r_col_size = r.instance_variable_get(:@column_size)

           (r_row_size == slf_row_size) & (r_col_size == slf_col_size)
         })    
  end

  spec :real? do
    pre_task do |*args|
      $matrix_real_q_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_real_q_slf
           all_are_real = slf.all? {|x| x.real?}

           (r == true & all_are_real) | (r == false & (not all_are_real))
         })
  end

  spec :row do
    pre_task do |arg, &blk|
      $matrix_row_arg = arg
      $matrix_row_blk = blk
      $matrix_row_slf = self
    end
    
    ret (RDL.flat {|r|
           arg = $matrix_row_arg
           blk = $matrix_row_blk
           slf = $matrix_row_slf

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)

           c = true

           for i in 0..slf_col_size-1 
             c = c & (r[i] == slf[arg, i]) if r != nil
           end

           arg_out_of_range = arg >= slf_row_size || arg < -slf_row_size

           ((not blk) & ((r == nil) & arg_out_of_range) | c) | blk
         })
  end

  spec :regular? do
    pre_task do |*args|
      $matrix_regular_q_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_regular_q_slf

           ((r == true) & (not (slf.singular?))) | ((r == false) & (slf.singular?))
         })
  end

  spec :row_size do
    ret (RDL.flat {|r|
           r >= 0
         })
  end

  spec :row_vectors do
    pre_task do |*args|
      $matrix_row_vectors_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_row_vectors_slf

           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)

           c = true

           for i in 0..r.size-1
             c = c & (slf.row(i) == r[i])
           end

           (r.size == slf_row_size) & c
         })
  end

  spec :singular? do
    pre_task do |*args|
      $matrix_singular_q_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_singular_q_slf
           
           ((r == true) & (slf.determinant == 0)) | ((r == false) & (slf.determinant != 0)) 
         })
  end

  spec :square? do
    pre_task do |*args|
      $matrix_square_q_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_square_q_slf
           
           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)  

           ((r == true) & (slf_row_size == slf_col_size)) | ((r == false) & (slf_row_size != slf_col_size)) 
         })
  end

  spec :to_a do
    pre_task do |*args|
      $matrix_trace_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_trace_slf
           
           slf_rows = slf.instance_variable_get(:@rows)
           slf_row_size = slf_rows.size
           slf_col_size = slf.instance_variable_get(:@column_size)  

           r == slf_rows           
         })
  end

  spec :to_s do
    # depends on individual element's to_s 
  end

  spec :trace do
    pre_task do |*args|
      $matrix_trace_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_trace_slf
           
           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)  

           r2 = 0

           for i in 0..slf_row_size-1
             for j in 0..slf_col_size-1
               r2 += slf[i,j] if i == j
             end
           end

           r == r2
         })
  end

  spec :transpose do
    pre_task do |*args|
      $matrix_transpose_slf = self
    end
    
    ret (RDL.flat {|r|
           slf = $matrix_transpose_slf
           
           slf_row_size = slf.instance_variable_get(:@rows).size
           slf_col_size = slf.instance_variable_get(:@column_size)  

           ret_row_size = r.instance_variable_get(:@rows).size
           ret_col_size = r.instance_variable_get(:@column_size)  

           c = true

           for i in 0..slf_row_size-1
             for j in 0..slf_col_size-1
               c = c & (slf[i,j] == r[j, i])
             end
           end

           (slf_row_size == ret_col_size) & (slf_col_size == ret_row_size) & c
         })
  end

end

# Test cases

Matrix.identity(2)
#Matrix.identity(-1)

Matrix[ [25, 93], [-1, 66] ]

Matrix.build(2, 4) {|row, col| col - row }
Matrix.build(3) { rand }

Matrix.column_vector([4,5,6])

Matrix.columns([[25, 93], [-1, 66]])

Matrix.diagonal(9, 5, -3)

Matrix.empty()
Matrix.empty(0)
Matrix.empty(1)
Matrix.empty(2, 0)
Matrix.empty(0, 3)

Matrix.row_vector([4,5,6])

Matrix.rows([[25, 93], [-1, 66]])

Matrix.scalar(2, 5)

Matrix.zero(2)

Matrix[[2,4], [6,8]] * Matrix.identity(2)

Matrix[[7,6], [3,9]] ** 2

Matrix.scalar(2,5) + Matrix[[1,0], [-4,7]]

Matrix[[1,5], [4,2]] - Matrix[[9,3], [-4,1]]

Matrix[[7,6], [3,9]] / Matrix[[2,9], [3,1]]

Matrix[[7,6], [3,9]] == Matrix[[2,9], [3,1]]
Matrix[[7,6], [3,9]] == Matrix[[7,6], [3,9]]
Matrix[[7,6], [3,9]] == Matrix[[7,6], [2,4], [3,9]]
Matrix[[7,6], [3,9]] == Matrix[[7,6], [2,3], [3,9]]

Matrix[[7,6], [3,9]][0,1]
Matrix[[7,6], [3,9]][0,8]
Matrix[[7,6], [3,9]][1,8]
Matrix[[7,6], [3,9]][8,8]

Matrix[ [1,2], [3,4] ].collect { |e| e**2 }

Matrix[[1,2], [3,4], [5, 6]].column(0)
Matrix[[1,2], [3,4], [5, 6]].column(1)
Matrix[[1,2], [3,4], [5, 6]].column(2)
Matrix[[1,2], [3,4], [5, 6]].column(3)
Matrix[[1,2], [3,4], [5, 6]].column(-2)
Matrix[[1,2], [3,4], [5, 6]].column(-1)
Matrix[[1,2], [3,4], [5, 6]].column(-100)
Matrix[[1,2], [3,4], [5, 6]].column(200)

Matrix[[3,4], [5, 6]].column_vectors

Matrix[[Complex(1,2), Complex(0,1), 0], [1, 2, 3]].conjugate

Matrix[[7,6], [3,9]].determinant

Matrix[[7,6], [3,9]].elements_to_f

Matrix[[7,6], [3,9]].elements_to_i

Matrix[[7,6], [3,9]].elements_to_r

Matrix[[7,6], [3,9]].empty?
Matrix[].elements_to_r

Matrix[[7,6], [3,9]].hash
Matrix[].hash

Matrix[[Complex(1,2), Complex(0,1), 0], [1, 2, 3]].imaginary

Matrix.diagonal(9, 5, -3).minor(0..1, 0..2)

Matrix[[7,6], [3,9]].rank

Matrix[[Complex(1,2), Complex(0,1), 0], [1, 2, 3]].real

Matrix[[1,2], [3,4], [5, 6]].row(0)
Matrix[[1,2], [3,4], [5, 6]].row(1)
Matrix[[1,2], [3,4], [5, 6]].row(2)
Matrix[[1,2], [3,4], [5, 6]].row(3)
Matrix[[1,2], [3,4], [5, 6]].row(-2)
Matrix[[1,2], [3,4], [5, 6]].row(-1)
Matrix[[1,2], [3,4], [5, 6]].row(-100)
Matrix[[1,2], [3,4], [5, 6]].row(200)

Matrix[[7,6], [3,9]].regular?
Matrix[[1,0], [0,1]].regular?

Matrix[[1,2], [3,4], [5, 6]].row_size

Matrix[[3,4], [5, 6]].row_vectors

Matrix[[7,6], [3,9]].singular?
Matrix[[1,0], [0,1]].singular?

Matrix[[7,6], [3,9]].square?
Matrix[[7,6], [3,9], [1,2]].square?

Matrix[[7,6], [3,9]].to_a

Matrix[[7,6], [3,9]].trace

Matrix[[1,2], [3,4], [5,6]].transpose

