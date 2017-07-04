class ActiveRecord::Base
  extend RDL::RDLAnnotate
end

module ActiveRecord::ModelSchema::ClassMethods
  extend RDL::RDLAnnotate

  rdl_post(:load_schema!) { |ret| # load_schema! doesn't return anything interesting
    columns_hash.each { |name, col|
      t = RDL::Rails.column_to_rdl(col.type)
      if col.null
        # may be null; show nullability in return type
        rdl_type name,       "() -> #{t} or nil"     # getter
        rdl_type :"#{name}=", "(#{t}) -> #{t} or nil" # setter
        rdl_type :write_attribute, "(:#{name}, #{t}) -> %bool"
        rdl_type :update_attribute, "(:#{name}, #{t}) -> %bool"
        rdl_type :update_column, "(:#{name}, #{t}) -> %bool"
      else
        # not null; can't truly check in type system but hint via the name
        rdl_type name,       "() -> !#{t}"                 # getter
        rdl_type :"#{name}=", "(!#{t}) -> !#{t}" # setter
        rdl_type :write_attribute, "(:#{name}, !#{t}) -> %bool"
        rdl_type :update_attribute, "(:#{name}, #{t}) -> %bool"
        rdl_type :update_column, "(:#{name}, #{t}) -> %bool"
      end
    }

    attribute_types = RDL::Rails.attribute_types(self)
    rdl_type :'self.find_by', '(' + attribute_types + ") -> #{self} or nil"
    rdl_type :'self.find_by!', '(' + attribute_types + ") -> #{self}"
    rdl_type :update, '(' + attribute_types + ') -> %bool'
    rdl_type :update_columns, '(' + attribute_types + ') -> %bool'
    rdl_type :'attributes=', '(' + attribute_types + ') -> %bool'

    # If called with String arguments, can't check types as precisely
    rdl_type :write_attribute, '(String, %any) -> %bool'
    rdl_type :update_attribute, '(String, %any) -> %bool'
    rdl_type :update_column, '(String, %any) -> %bool'

    rdl_type :'self.joins', "(Symbol or String) -> ActiveRecord::Associations::CollectionProxy<#{self.to_s}>"
    rdl_type :'self.none', "() -> ActiveRecord::Associations::CollectionProxy<#{self.to_s}>"
    rdl_type :'self.where', '(String, *%any) -> ActiveRecord::Associations::CollectionProxy<t>'
    rdl_type :'self.where', '(**%any) -> ActiveRecord::Associations::CollectionProxy<t>'
    true
  }
end
