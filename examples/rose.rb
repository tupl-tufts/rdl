# http://hsume2.github.com/rose/

require 'rose'
require 'set'
require 'rdl'

module Kernel
  def implies(test)
    test ? yield : true
  end
end

def get_col_names(obj) 
  obj.row.attributes.map {|n| n.column_name}
end

module Rose
  class Shell
    extend RDL

    spec :photosynthesize do
      pre_cond "column name must be valid" do |*args|
        # args[0] is the list of objects

        implies args[1].keys.include?(:with) do
          args[1][:with].all? {|k, v|
            cols = get_col_names(self)
            c = v.to_a[0][0]
            k.to_i < args[0].size and cols.include?(c)
          }
        end
      end
    end
  end
end

class << Rose
  extend RDL 

  check_col_spec = RDL.create_spec do |method_name|
    pre_cond "Column name must have been defined in Rose.make" do |col|
      get_col_names(self).include?(col)       
    end
  end

  spec :make do 
    pre_task do |name, options|
      RDL.state[:__rtc_rose_name] = name # current name in Rose.make

      if options.class == Hash and options.keys.include?(:class)
        RDL.state[:__rtc_rose_class] = options[:class] # current class
      else
        RDL.state[:__rtc_rose_class] = nil # current class
      end
    end

    pre_cond "argument class must be < Struct" do |*args, options|
      implies (options.class == Hash and options.keys.include?(:class)) do
        options[:class].ancestors.include?(Struct)
      end
    end

    dsl do
      spec :sort do 
        include_spec check_col_spec

        pre_cond "sort order must be :ascending or :descending" do |col, order|
          order == :ascending or order == :descending
        end
      end

      spec :summary do
        include_spec check_col_spec
      end

      spec :pivot do
        include_spec check_col_spec
      end

      spec :rows do
        dsl do
          spec :column do 
            pre_cond "hash key must be a Struct field" do |*args|            
              cls = RDL.state[:__rtc_rose_class]

              implies (cls and (args[0].class == Hash)) do
                cls.members.include?(args[0].to_a[0][0])
              end
            end
          end
        end
      end
    end
  end
end
