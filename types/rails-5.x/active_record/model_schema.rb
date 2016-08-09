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
            find_by_args << "#{name}: ?#{t}"
          else
            # not null; can't truly check in type system but hint via the name
            type name,       "() -> !#{t}"                 # getter
            type "#{name}=", "(!#{t}) -> !#{t}" # setter
            find_by_args << "#{name}: ?!#{t}"
          end
        }
        type 'self.find_by', '(' + find_by_args.join(',') + ') -> self or nil'
        type 'self.find_by!', '(' + find_by_args.join(',') + ') -> self'

        true
      }
    end
  end
end
