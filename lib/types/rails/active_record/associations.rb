RDL.nowrap :'ActiveRecord::Associations::CollectionProxy'

RDL.type_params :'ActiveRecord::Associations::CollectionProxy', [:t], :all?

RDL.type :'ActiveRecord::Associations::CollectionProxy', :<<, '(*(t or Array<t>)) -> self'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :==, '(%any) -> %bool'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :any?, '() ?{ (t) -> %bool } -> %bool'
RDL.rdl_alias :'ActiveRecord::Associations::CollectionProxy', :append, :<<
RDL.type :'ActiveRecord::Associations::CollectionProxy', :build, '(Hash<Symbol, %any> or Array<Hash<Symbol, %any>>) -> self'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :clear, '() -> self'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :concat, '(*t) -> self'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :count, '() -> Integer'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :create, '(Hash<Symbol, %any> or Array<Hash<Symbol, %any>>) -> self'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :create!, '(Hash<Symbol, %any> or Array<Hash<Symbol, %any>>) -> self'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :delete, '(*t) -> Array<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :delete_all, '(?Symbol dependent) -> Array<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :destroy, '(*t) -> Array<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :destroy_all, '() -> %any'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :distinct, '() -> self'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :empty?, '() -> %bool'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :find, '(Integer) -> t'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :find, '(Integer, Integer, *Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :include?, '(t) -> %bool'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :length, '() -> Integer'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :load_target, '() -> %any'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :loaded?, '() -> %bool'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :many?, '() ?{ (t) -> %bool } -> %bool'
RDL.rdl_alias :'ActiveRecord::Associations::CollectionProxy', :new, :build
RDL.rdl_alias :'ActiveRecord::Associations::CollectionProxy', :push, :<<
RDL.type :'ActiveRecord::Associations::CollectionProxy', :reload, '() -> self'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :replace, '(Array<t>) -> %any'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :reset, '() -> self'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :scope, '() -> ActiveRecord::Relation' # TODO fix
RDL.type :'ActiveRecord::Associations::CollectionProxy', :select, '(*Symbol) -> t'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :select, '() { (t) -> %bool } -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :size, '() -> Integer'
RDL.rdl_alias :'ActiveRecord::Associations::CollectionProxy', :spawn, :scope
RDL.type :'ActiveRecord::Associations::CollectionProxy', :take, '() -> t or nil'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :take, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :to_ary, '() -> Array<t>'
RDL.rdl_alias :'ActiveRecord::Associations::CollectionProxy', :to_a, :to_ary
RDL.rdl_alias :'ActiveRecord::Associations::CollectionProxy', :unique, :distinct

RDL.type :'ActiveRecord::Associations::CollectionProxy', :first, '() -> t or nil'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :first, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :second, '() -> t or nil'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :second, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :third, '() -> t or nil'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :third, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :fourth, '() -> t or nil'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :fourth, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :fifth, '() -> t or nil'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :fifth, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :forty_two, '() -> t or nil'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :forty_two, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :third_to_last, '() -> t or nil'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :third_to_last, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :second_to_last, '() -> t or nil'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :second_to_last, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :last, '() -> t or nil'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :last, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'

RDL.type :'ActiveRecord::Associations::CollectionProxy', :where, '(String, *%any) -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :where, '(**%any) -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :group, '(Symbol) -> ActiveRecord::Associations::CollectionProxy<t>'
RDL.type :'ActiveRecord::Associations::CollectionProxy', :order, '(Symbol) -> ActiveRecord::Associations::CollectionProxy<t>'


# Remaining methods are from CollectionProxy
# TODO give these precise types for this particular model
# collection<<(object, ...)
# collection.delete(object, ...)
# collection.destroy(object, ...)
# collection.clear
# collection.empty?
# collection.size
# collection.find(...)
# collection.where(...)
# collection.exists?(...)
# collection.build(attributes = {})
# collection.create(attributes = {})
# collection.create!(attributes = {})


module ActiveRecord::Associations::ClassMethods

  # TODO: Check presence of methods required by, e.g., foreign_key, primary_key, etc.
  # TODO: Check counter_cache, add to model attr_readonly_type

  extend RDL::RDLAnnotate

  rdl_type :'ActiveRecord::Associations::ClassMethods', :belongs_to,
    '(%symstr name, ?{ (?ActiveRecord::Base) -> %any } scope, class_name: ?%symstr, foreign_key: ?%symstr,' +
    'primary_key: ?%symstr, dependent: ?(:delete or :destroy), counter_cache: ?(%bool or %symstr),' +
    'polymorphic: ?%bool, validate: ?%bool, autosave: ?%bool, touch: ?(%bool or %symstr),' +
    'inverse_of: ?%symstr, optional: ?%bool, required: ?%bool, anonymous_class: ?Class) -> %any'

  rdl_pre :'ActiveRecord::Associations::ClassMethods', :belongs_to do
    |name, scope=nil, class_name: nil, foreign_key: nil, primary_key: nil,
     dependent: nil, counter_cache: nil, polymorphic: nil,
     validate: nil, autosave: nil, touch: nil, inverse_of: nil,
     optional: nil, required: nil, anonymous_class: nil|

    if polymorphic
      assoc_type = '%any' # type is data-driven, can't determine statically
    elsif class_name
      assoc_type = class_name.to_s.classify
    elsif anonymous_class
      assoc_type = anonymous_class.to_s
    else
      assoc_type = name.to_s.classify # camelize?
    end
    rdl_type name, "(?%bool force_reload) -> #{assoc_type}"
    rdl_type "#{name}=", "(#{assoc_type}) -> #{assoc_type}"
    unless polymorphic
      RDL.at(:model) { |sym|
        assoc_attribute_types = RDL::Rails.attribute_types(assoc_type.constantize)
        rdl_type "build_#{name}", "(#{assoc_attribute_types}) -> #{assoc_type}"
        rdl_type "create_#{name}", "(#{assoc_attribute_types}) -> #{assoc_type}"
        rdl_type "create_#{name}!", "(#{assoc_attribute_types}) -> #{assoc_type}"
      }
    end
    true
  end

  rdl_type :'ActiveRecord::Associations::ClassMethods', :has_one,
    '(%symstr name, ?{ (?ActiveRecord::Base) -> %any } scope, class_name: ?%symstr,'+
    'dependent: ?(:destroy or :delete or :nullify or :restrict_with_exception or :restrict_with_error),' +
    'foreign_key: ?%symstr, foreign_type: ?%symstr, primary_key: ?%symstr, as: ?%symstr,' +
    'through: ?%symstr, source: ?%symstr, source_type: ?%symstr, validate: ?%bool, autosave: ?%bool,' +
    'inverse_of: ?%symstr, required: ?%bool, anonymous_class: ?Class) -> %any'

  rdl_pre :'ActiveRecord::Associations::ClassMethods', :has_one do
    |name, scope=nil, class_name: nil, dependent: nil, foreign_key: nil,
     foreign_type: nil, primary_key: nil, as: nil, through: nil, source: nil,
     source_type: nil, vadliate: nil, autosave: nil, inverse_of: nil,
     required: nil|

    if as
     assoc_type = '%any' # type is data-driven, can't determine statically
    elsif class_name
     assoc_type = class_name.to_s.classify
    elsif anonymous_class # not sure this has anonymou_class
     assoc_type = anonymous_class.to_s.classify
    else
     assoc_type = name.to_s.classify # camelize?
    end
    rdl_type name, "(?%bool force_reload) -> #{assoc_type}"
    rdl_type "#{name}=", "(#{assoc_type}) -> #{assoc_type}"
    unless as
      RDL.at(:model) { |sym|
       assoc_attribute_types = RDL::Rails.attribute_types(assoc_type.constantize)
       rdl_type "build_#{name}", "(#{assoc_attribute_types}) -> #{assoc_type}"
       rdl_type "create_#{name}", "(#{assoc_attribute_types}) -> #{assoc_type}"
       rdl_type "create_#{name}!", "(#{assoc_attribute_types}) -> #{assoc_type}"
     }
    end
  end

  rdl_type :'ActiveRecord::Associations::ClassMethods', :has_many,
    '(%symstr name, ?{ (?ActiveRecord::Base) -> %any } scope, class_name: ?%symstr,' +
    'foreign_key: ?%symstr, foreign_type: ?%symstr, primary_key: ?%symstr,' +
    'dependent: ?(:destroy or :delete_all or :nullify or :restrict_with_exception or :restrict_with_error),' +
    'counter_cache: ?(%bool or %symstr), as: ?%symstr, through: ?%symstr, source: ?%symstr,' +
    'source_type: ?%symstr, validate: ?%bool, inverse_of: ?%symstr, extend: ?(Module or Array<Module>))' +
    '?{ () -> %any } -> %any'

  rdl_pre :'ActiveRecord::Associations::ClassMethods', :has_many do
    |name, scope=nil, class_name: nil, foreign_key: nil, foreign_type: nil, primary_key: nil,
     dependent: nil, counter_cache: nil, as: nil, through: nil, source: nil, source_type: nil,
     validate: nil, inverse_of: nil, extend: nil|

    if class_name
      collect_type = class_name.to_s.classify
    else
      collect_type = name.to_s.singularize.classify
    end
    rdl_type name, "() -> ActiveRecord::Associations::CollectionProxy<#{collect_type}>"
    rdl_type "#{name}=", "(Array<t>) -> ActiveRecord::Associations::CollectionProxy<#{collect_type}>" # TODO not sure of type
    if primary_key # not every model has a primary key
      RDL.at(:model) {
        # primary_key is not available when has_many is first called!
        id_type = RDL::Rails.column_to_rdl(collect_type.constantize.columns_hash[primary_key].type)
        rdl_type "#{name.to_s.singularize}_ids", "() -> Array<#{id_type}>"
        rdl_type "#{name.to_s.singularize}_ids=", "() -> Array<#{id_type}>"
      }
    end
    true
  end

  rdl_type :'ActiveRecord::Associations::ClassMethods', :has_and_belongs_to_many,
    '(%symstr name, ?{ (?ActiveRecord::Base) -> %any } scope, class_name: ?%symstr,' +
    'join_table: ?%symstr, foreign_key: ?%symstr, association_foreign_key: ?%symstr,' +
    'validate: ?%bool, autosave: ?%bool) ?{ () -> %any } -> %any'

  rdl_pre :'ActiveRecord::Associations::ClassMethods', :has_and_belongs_to_many do
    |name, scope=nil, class_name: nil, join_table: nil,
     foreign_key: nil, association_foreign_key: nil,
     validate: nil, autosave: nil|

    if class_name
      collect_type = class_name.to_s.classify
    else
      collect_type = name.to_s.singularize.classify
    end
    rdl_type name, "() -> ActiveRecord::Associations::CollectionProxy<#{collect_type}>"
    rdl_type "#{name}=", "(Array<t>) -> ActiveRecord::Associations::CollectionProxy<#{collect_type}>" # TODO not sure of type
    if primary_key # not every model has a primary key
      RDL.at(:model) {
        # primary_key is not available when has_and_belongs_to_many is first called!
        id_type = RDL::Rails.column_to_rdl(collect_type.constantize.columns_hash[primary_key].type)
        rdl_type "#{name.to_s.singularize}_ids", "() -> Array<#{id_type}>"
        rdl_type "#{name.to_s.singularize}_ids=", "() -> Array<#{id_type}>"
      }
    end

    true
  end

end
