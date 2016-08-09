module ActiveRecord
  module ModelSchema
    module ClassMethods
      post(:load_schema!) { |ret| # load_schema! doesn't return anything interesting
        columns_hash.each { |name, col|
          t = RDL::Rails.column_to_rdl(col.type)
          if col.null
            # may be null; show nullability in return type
            type name,       "() -> #{t} or nil"     # getter
            type "#{name}=", "(#{t}) -> #{t} or nil" # setter
          else
            # not null; can't truly check in type system but hint via the name
            type name,       "() -> !#{t}"                 # getter
            type "#{name}=", "(!#{t}) -> !#{t}" # setter
          end
        }
        true
      }
    end
  end
end

# module ActiveRecord
#   class Base
# # class ApplicationRecord < ActiveRecord::Base
#
#     # Create types for the object's database columns
#     # We could do this in ActiveRecord::Schema.define, but that's a little more complex
#
#     singleton_class.send :alias_method, :__rdl_inherited_saved, :inherited # save current inherited method
#
#     def self.inherited(subclass)
#       puts "inherited by #{subclass}, abstract_class: #{subclass.abstract_class?.inspect}"
#       unless subclass.abstract_class?
#         puts "Columns for #{subclass}"
#         subclass.columns.each { |k, t|
#           puts "#{k.inspect} => #{t.inspect}"
#         }
#         puts "Done columns for #{subclass}"
#       end
#       return __rdl_inherited_saved(subclass)
#     end
#
#   end
# end
