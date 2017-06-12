class ActiveRecord::Base
  extend RDL::Annotate # probably not a good idea...

  def self.add_schema_types
  end

  post('self.add_schema_types') { |ret| # load_schema! doesn't return anything interesting
    type 'self.where', "(*%any) -> ActiveRecord::Relation<#{self}>"

    columns_hash.each { |name, col|
      t = RDL::Rails.column_to_rdl(col.type)
      if col.null
        # may be null; show nullability in return type
        type name,       "() -> #{t} or nil"     # getter
        type "#{name}_id",       "() -> #{t} or nil"     # getter
        type "#{name}=", "(#{t}) -> #{t} or nil" # setter
        type "write_attribute", "(:#{name}, #{t}) -> %bool"
        type "update_attribute", "(:#{name}, #{t}) -> %bool"
        type "update_column", "(:#{name}, #{t}) -> %bool"
      else
        # not null; can't truly check in type system but hint via the name
        type name,       "() -> !#{t}"                 # getter
        type "#{name}_id",       "() -> !#{t}"                 # getter
        type "#{name}=", "(!#{t}) -> !#{t}" # setter
        type "write_attribute", "(:#{name}, !#{t}) -> %bool"
        type "update_attribute", "(:#{name}, #{t}) -> %bool"
        type "update_column", "(:#{name}, #{t}) -> %bool"
      end
    }

    attribute_types = RDL::Rails.attribute_types(self)

    type 'self.find', "(Fixnum) -> #{self}"
    type 'self.find', "(String) -> #{self}"
    type 'self.find', '({' + attribute_types + "}) -> #{self}"

=begin
    type 'self.find_by', '(' + attribute_types + ") -> #{self} or nil"
    type 'self.find_by!', '(' + attribute_types + ") -> #{self}"
    type 'update', '(' + attribute_types + ') -> %bool'
    type 'update_columns', '(' + attribute_types + ') -> %bool'
    type 'attributes=', '(' + attribute_types + ') -> %bool'

    # If called with String arguments, can't check types as precisely
    type 'write_attribute', '(String, %any) -> %bool'
    type 'update_attribute', '(String, %any) -> %bool'
    type 'update_column', '(String, %any) -> %bool'
=end
    true
  }
end
