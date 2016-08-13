module ActiveRecord
  module ModelSchema
    module ClassMethods
      post(:load_schema!) { |ret| # load_schema! doesn't return anything interesting
        find_by_args = []

        columns_hash.each { |name, col|
          t = RDL::Rails.column_to_rdl(col.type)
          if col.null
            # may be null; show nullability in return type
            type name,       "() -> #{t} or nil"     # getter
            type "#{name}=", "(#{t}) -> #{t} or nil" # setter
            type "write_attribute", "(:#{name}, #{t}) -> %bool"
            type "update_attribute", "(:#{name}, #{t}) -> %bool"
            type "update_column", "(:#{name}, #{t}) -> %bool"
            find_by_args << "#{name}: ?#{t}"
          else
            # not null; can't truly check in type system but hint via the name
            type name,       "() -> !#{t}"                 # getter
            type "#{name}=", "(!#{t}) -> !#{t}" # setter
            type "write_attribute", "(:#{name}, !#{t}) -> %bool"
            type "update_attribute", "(:#{name}, #{t}) -> %bool"
            type "update_column", "(:#{name}, #{t}) -> %bool"
            find_by_args << "#{name}: ?!#{t}"
          end
        }
        hash_args = find_by_args.join(',')
        type 'self.find_by', '(' + hash_args + ") -> #{self} or nil"
        type 'self.find_by!', '(' + hash_args + ") -> #{self}"
        type 'update', '(' + hash_args + ') -> %bool'
        type 'update_columns', '(' + hash_args + ') -> %bool'
        type 'attributes=', '(' + hash_args + ') -> %bool'

        # If called with String arguments, can't check types as precisely
        type 'write_attribute', '(String, %any) -> %bool'
        type 'update_attribute', '(String, %any) -> %bool'
        type 'update_column', '(String, %any) -> %bool'
        true
      }
    end
  end
end
