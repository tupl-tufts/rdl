module ActiveRecord
  module Associations
    module ClassMethods
      extend RDL

      def __rdl_option_keys_valid?(spec_valid_options, options_used)
        # Original class association options can be found with
        # ActiveRecord::Associations::Builder::Association.valid_options
        # + some more found in ancestors.

        common_options = [:class_name, :foreign_key, :select, :conditions, :include, :extend, :readonly, :validate, :autosave]
        valid_options = common_options + spec_valid_options
        options_used.keys.all? {|k| valid_options.include?(k)}
      end

      def __rdl_arg_objects_defined?(arg_name, arg_options)
        if arg_options.keys.include?(:class_name)
          n = arg_options[:class_name]
        else
          n = arg_name.to_s.singularize.camelize
        end

        r = true

        if not (arg_options.keys.include?(:polymorphic) and arg_options[:polymorphic] == true)
          begin
            r = eval(n).ancestors.include?(ActiveRecord::Base)
          rescue
            r = false
          end
        end

        r
      end

      def __rdl_collection_methods_added?(collection, arg_options)
        cstr = collection.to_s
        cstr_s = cstr.singularize
        new_self_methods = [cstr, "#{cstr}=", "#{cstr_s}_ids", "#{cstr_s}_ids="]
        new_self_methods.map! {|m| m.to_sym}

        # TODO: self.new is ok to call here, but may mutate global state in certain classes
        # The class of self.new is Array here.

        collection_obj = eval("#{self}.new.#{collection.to_s}")

        new_collection_methods = [:push, :concat, :build, :create, :create!, :size, :length, :count, :sum, :empty?, :clear, :delete, :delete_all, :destroy_all, :find, :exists?, :uniq, :<<]
        # TODO: reset is also defined on obj, according to the comment in associations.rb
        # but collection_obj.respond(:reset) returns false
        # However, http://guides.rubyonrails.org/association_basics.html does not list :reset
        # as well as several methods from the above as auto-generated methods.

        methods_added_on_self = new_self_methods.all? {|m| 
          self.instance_methods.include?(m)
        }

        methods_added_on_collection = new_collection_methods.all? {|m|
          collection_obj.respond_to?(m)
        }

        methods_added_on_self and methods_added_on_collection

      end

      def __rdl_singular_methods_added?(type, assoc, arg_options)
        new_methods = []

        if type == :belongs_to
          if arg_options.keys.include?(:polymorphic) and arg_options[:polymorphic] == true 
            new_methods = [assoc, "#{assoc}="]
          else
            new_methods = [assoc, "#{assoc}=", "build_#{assoc}", "create_#{assoc}", "create_#{assoc}!"]
          end
        elsif type == :has_one
          new_methods = [assoc, "#{assoc}=", "build_#{assoc}", "create_#{assoc}", "create_#{assoc}!"]
        else
          raise Exception, "type must be a singular association"
        end

        new_methods.map! {|m| m.to_sym}
        new_methods.all? {|m| self.instance_methods.include?(m)}
      end

      spec :belongs_to do
        pre_task do |*args|
          $belongs_to_arg_name = args[0]

          if args.size == 2
            $belongs_to_arg_options = args[1].dup 
          else
            $belongs_to_arg_options = {}
          end

          $belongs_to_self = self      
        end

        pre_cond do |*args|
          $belongs_to_arg_name = args[0]
          arg_name = $belongs_to_arg_name

          if args.size == 2
            $belongs_to_arg_options = args[1].dup 
          else
            $belongs_to_arg_options = {}
          end

          slf = eval("self")
          arg_options = $belongs_to_arg_options 

          spec_valid_options = [:foreign_type, :polymorphic, :touch, :remote, :dependent, :counter_cache, :primary_key, :inverse_of]
          option_keys_valid = __rdl_option_keys_valid?(spec_valid_options, arg_options)
          arg_classes_defined = __rdl_arg_objects_defined?(arg_name, arg_options)

          if arg_options.keys.include?(:foreign_key) 
            fk = arg_options[:foreign_key]
          else
            fk = "#{arg_name.to_s.underscore}_id" 
          end

          col_names = slf.columns.map {|x| x.name}
          foreign_key_col_exist = col_names.include?(fk)

          counter_cache_col_exist = true

          if (arg_options.keys.include?(:counter_cache) and arg_options[:counter_cache]) and not (arg_options.keys.include?(:polymorphic) and arg_options[:polymorphic])
            if arg_options.keys.include?(:class_name)
              assoc = arg_options[:class_name]
            else
              assoc = arg_name.to_s.singularize.camelize
            end

            assoc_cls = eval(assoc)
            assoc_cols = assoc_cls.columns.map {|x| x.name}

            # can specify a symbol to override default 
            if arg_options[:counter_cache] != true
              cid = arg_options[:counter_cache]
            else
              cid = "#{slf.to_s.pluralize.camelize(:lower)}_count"
            end

            counter_cache_col_exist = assoc_cols.include?(cid.to_s)            
          end

          option_keys_valid and
          arg_classes_defined and
          foreign_key_col_exist and
          counter_cache_col_exist 
        end

        post_cond do |ret, *args|
          arg_name = $belongs_to_arg_name
          arg_options = $belongs_to_arg_options
          slf = $belongs_to_self

          correct_methods_added = __rdl_singular_methods_added?(:belongs_to, arg_name, arg_options)


          if arg_options.keys.include?(:foreign_key)
            fk = arg_options[:foreign_key]
          else
            fk = "#{arg_name.to_s.underscore}_id"
          end

          foreign_key_added = (slf.reflections.keys.include?(arg_name) and
                               (slf.reflections[arg_name].foreign_key == fk))

          correct_methods_added and foreign_key_added
        end
      end

      spec :has_one do
        pre_task do |*args|
          $has_to_arg_name = args[0]

          if args.size == 2
            $has_to_arg_options = args[1].dup 
          else
            $has_to_arg_options = {}
          end

          $has_to_self = self          
        end

        pre_cond do |*args|
          $has_one_arg_name = args[0]
          arg_name = $has_one_arg_name

          if args.size == 2
            $has_one_arg_options = args[1].dup 
          else
            $has_one_arg_options = {}
          end

          slf = eval("self")
          arg_options = $has_one_arg_options 

          spec_valid_options = [:order, :as, :through, :remote, :dependent, :counter_cache, :primary_key, :inverse_of]
          option_keys_valid = __rdl_option_keys_valid?(spec_valid_options, arg_options)
          arg_classes_defined = __rdl_arg_objects_defined?(arg_name, arg_options)          

          option_keys_valid and
          arg_classes_defined
        end

        post_cond do |ret, *args|
          arg_name = $has_one_arg_name
          arg_options = $has_one_arg_options
          slf = $has_one_self

          correct_methods_added = __rdl_singular_methods_added?(:has_one, arg_name, arg_options)

          correct_methods_added
        end
      end


      spec :has_many do
        pre_task do |*args|
          $has_many_arg_name = args[0]

          if args.size == 2
            $has_many_arg_options = args[1].dup 
          else
            $has_many_arg_options = {}
          end

          $has_many_self = self          
        end

        pre_cond do |*args|
          arg_name = args[0]

          if args.size == 2
            arg_options = args[1].dup 
          else
            arg_options = {}
          end

          slf = eval("self")

          spec_valid_options = [:primary_key, :dependent, :as, :through, :source, :source_type, :inverse_of, :table_name, :order, :group, :having, :limit, :offset, :uniq, :finder_sql, :counter_sql, :before_add, :after_add, :before_remove, :after_remove]
          option_keys_valid = __rdl_option_keys_valid?(spec_valid_options, arg_options)
          arg_classes_defined = __rdl_arg_objects_defined?(arg_name, arg_options)
          
          option_keys_valid and
          arg_classes_defined
        end

        post_cond do |ret, *args|
          arg_name = $has_many_arg_name
          arg_options = $has_many_arg_options
          slf = $has_many_self

          correct_methods_added = __rdl_collection_methods_added?(arg_name, arg_options)

          if arg_options.keys.include?(:foreign_key)
            fk = arg_options[:foreign_key]
          elsif arg_options.keys.include?(:as)
            fk = arg_options[:as].to_s + "_id"
          elsif arg_options.keys.include?(:class_name)
            fk = arg_options[:class_name].to_s.underscore.camelize(:lower) + "_id"
          else
            fk = "#{slf.to_s.camelize(:lower)}_id"
          end

          foreign_key_added = (slf.reflections.keys.include?(arg_name) and
                               (slf.reflections[arg_name].foreign_key == fk))

          if arg_options.keys.include?(:foreign_key) 
            bad_fk = arg_options[:foreign_key]
          else
            bad_fk = "#{arg_name.to_s.underscore}_id" 
          end

          col_names = slf.columns.map {|x| x.name}
          bad_foreign_key_col_not_exist = (not col_names.include?(fk))

          correct_methods_added and foreign_key_added and
          bad_foreign_key_col_not_exist
        end
      end

      spec :has_and_belongs_to_many do
        pre_task do |*args|
          $has_and_belongs_to_many_arg_name = args[0]

          if args.size == 2
            $has_and_belongs_to_many_arg_options = args[1].dup 
          else
            $has_and_belongs_to_many_arg_options = {}
          end

          $has_and_belongs_to_many_self = self          
        end

        pre_cond do |*args|
          $has_and_belongs_to_many_arg_name = args[0]
          arg_name = $has_and_belongs_to_many_arg_name

          if args.size == 2
            $has_and_belongs_to_many_arg_options = args[1].dup 
          else
            $has_and_belongs_to_many_arg_options = {}
          end

          slf = eval("self")
          arg_options = $has_and_belongs_to_many_arg_options 

          spec_valid_options = [:join_table, :association_foreign_key, :delete_sql, :insert_sql, :table_name, :order, :group, :having, :limit, :offset, :uniq, :finder_sql, :counter_sql, :before_add, :after_add, :before_remove, :after_remove]
          option_keys_valid = __rdl_option_keys_valid?(spec_valid_options, arg_options)

          arg_classes_defined = __rdl_arg_objects_defined?(arg_name, arg_options)
          
          option_keys_valid and
          arg_classes_defined
        end

        post_cond do |ret, *args|
          arg_name = $has_and_belongs_to_many_arg_name
          arg_options = $has_and_belongs_to_many_arg_options
          slf = $has_and_belongs_to_many_self

          correct_methods_added = __rdl_collection_methods_added?(arg_name, arg_options)

          if arg_options.keys.include?(:foreign_key)
            fk = arg_options[:foreign_key]
          elsif arg_options.keys.include?(:as)
            fk = arg_options[:as].to_s + "_id"
          elsif arg_options.keys.include?(:class_name)
            fk = arg_options[:class_name].to_s.underscore.camelize(:lower) + "_id"
          else
            fk = "#{slf.to_s.camelize(:lower)}_id"
          end

          foreign_key_added = (slf.reflections.keys.include?(arg_name) and
                               (slf.reflections[arg_name].foreign_key == fk))

          correct_methods_added and foreign_key_added
        end
      end
    end
  end
end
