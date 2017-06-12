class ActiveRecord::Associations::CollectionProxy
  type_params [:t], :all?
end

rdl_nowrap :'ActiveRecord::Associations::CollectionProxy'
type :'ActiveRecord::Associations::CollectionProxy', :<<, '(*(t or Array<t>)) -> self'
type :'ActiveRecord::Associations::CollectionProxy', :==, '(%any) -> %bool'
type :'ActiveRecord::Associations::CollectionProxy', :any?, '() ?{ (t) -> %bool } -> %bool'
rdl_alias :'ActiveRecord::Associations::CollectionProxy', :append, :<<
type :'ActiveRecord::Associations::CollectionProxy', :build, '(Hash<Symbol, %any> or Array<Hash<Symbol, %any>>) -> self'
type :'ActiveRecord::Associations::CollectionProxy', :clear, '() -> self'
type :'ActiveRecord::Associations::CollectionProxy', :concat, '(*t) -> self'
type :'ActiveRecord::Associations::CollectionProxy', :count, '() -> Integer'
type :'ActiveRecord::Associations::CollectionProxy', :create, '(Hash<Symbol, %any> or Array<Hash<Symbol, %any>>) -> self'
type :'ActiveRecord::Associations::CollectionProxy', :create!, '(Hash<Symbol, %any> or Array<Hash<Symbol, %any>>) -> self'
type :'ActiveRecord::Associations::CollectionProxy', :delete, '(*t) -> Array<t>'
type :'ActiveRecord::Associations::CollectionProxy', :delete_all, '(?Symbol dependent) -> Array<t>'
type :'ActiveRecord::Associations::CollectionProxy', :destroy, '(*t) -> Array<t>'
type :'ActiveRecord::Associations::CollectionProxy', :destroy_all, '() -> %any'
type :'ActiveRecord::Associations::CollectionProxy', :distinct, '() -> self'
type :'ActiveRecord::Associations::CollectionProxy', :empty?, '() -> %bool'
type :'ActiveRecord::Associations::CollectionProxy', :find, '(Integer) -> t'
type :'ActiveRecord::Associations::CollectionProxy', :find, '(Integer, Integer, *Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
type :'ActiveRecord::Associations::CollectionProxy', :include?, '(t) -> %bool'
type :'ActiveRecord::Associations::CollectionProxy', :length, '() -> Integer'
type :'ActiveRecord::Associations::CollectionProxy', :load_target, '() -> %any'
type :'ActiveRecord::Associations::CollectionProxy', :loaded?, '() -> %bool'
type :'ActiveRecord::Associations::CollectionProxy', :many?, '() ?{ (t) -> %bool } -> %bool'
rdl_alias :'ActiveRecord::Associations::CollectionProxy', :new, :build
rdl_alias :'ActiveRecord::Associations::CollectionProxy', :push, :<<
type :'ActiveRecord::Associations::CollectionProxy', :reload, '() -> self'
type :'ActiveRecord::Associations::CollectionProxy', :replace, '(Array<t>) -> %any'
type :'ActiveRecord::Associations::CollectionProxy', :reset, '() -> self'
type :'ActiveRecord::Associations::CollectionProxy', :scope, '() -> ActiveRecord::Relation' # TODO fix
type :'ActiveRecord::Associations::CollectionProxy', :select, '(*Symbol) -> t'
type :'ActiveRecord::Associations::CollectionProxy', :select, '() { (t) -> %bool } -> ActiveRecord::Associations::CollectionProxy<t>'
type :'ActiveRecord::Associations::CollectionProxy', :size, '() -> Integer'
rdl_alias :'ActiveRecord::Associations::CollectionProxy', :spawn, :scope
type :'ActiveRecord::Associations::CollectionProxy', :take, '() -> t or nil'
type :'ActiveRecord::Associations::CollectionProxy', :take, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
type :'ActiveRecord::Associations::CollectionProxy', :to_ary, '() -> Array<t>'
rdl_alias :'ActiveRecord::Associations::CollectionProxy', :to_a, :to_ary
rdl_alias :'ActiveRecord::Associations::CollectionProxy', :unique, :distinct

type :'ActiveRecord::Associations::CollectionProxy', :first, '() -> t or nil'
type :'ActiveRecord::Associations::CollectionProxy', :first, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
type :'ActiveRecord::Associations::CollectionProxy', :second, '() -> t or nil'
type :'ActiveRecord::Associations::CollectionProxy', :second, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
type :'ActiveRecord::Associations::CollectionProxy', :third, '() -> t or nil'
type :'ActiveRecord::Associations::CollectionProxy', :third, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
type :'ActiveRecord::Associations::CollectionProxy', :fourth, '() -> t or nil'
type :'ActiveRecord::Associations::CollectionProxy', :fourth, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
type :'ActiveRecord::Associations::CollectionProxy', :fifth, '() -> t or nil'
type :'ActiveRecord::Associations::CollectionProxy', :fifth, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
type :'ActiveRecord::Associations::CollectionProxy', :forty_two, '() -> t or nil'
type :'ActiveRecord::Associations::CollectionProxy', :forty_two, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
type :'ActiveRecord::Associations::CollectionProxy', :third_to_last, '() -> t or nil'
type :'ActiveRecord::Associations::CollectionProxy', :third_to_last, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
type :'ActiveRecord::Associations::CollectionProxy', :second_to_last, '() -> t or nil'
type :'ActiveRecord::Associations::CollectionProxy', :second_to_last, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'
type :'ActiveRecord::Associations::CollectionProxy', :last, '() -> t or nil'
type :'ActiveRecord::Associations::CollectionProxy', :last, '(Integer) -> ActiveRecord::Associations::CollectionProxy<t>'

module ActiveRecord::Associations::ClassMethods

  # TODO: Check presence of methods required by, e.g., foreign_key, primary_key, etc.
  # TODO: Check counter_cache, add to model attr_readonly_type


  type :belongs_to, '(%symstr name, ?{ (?ActiveRecord::Base) -> %any } scope, class_name: ?%symstr, foreign_key: ?%symstr,' +
                    'primary_key: ?%symstr, dependent: ?(:delete or :destroy), counter_cache: ?(%bool or %symstr),' +
                    'polymorphic: ?%bool, validate: ?%bool, autosave: ?%bool, touch: ?(%bool or %symstr),' +
                    'inverse_of: ?%symstr, optional: ?%bool, required: ?%bool, anonymous_class: ?Class) -> %any'

  pre :belongs_to do |name, scope=nil, class_name: nil, foreign_key: nil, primary_key: nil,
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
    type name, "(?%bool force_reload) -> #{assoc_type}"
    type "#{name}=", "(#{assoc_type}) -> #{assoc_type}"
    unless polymorphic
      rdl_at(:model) { |sym|
        assoc_attribute_types = RDL::Rails.attribute_types(assoc_type.constantize)
        type "build_#{name}", "(#{assoc_attribute_types}) -> #{assoc_type}"
        type "create_#{name}", "(#{assoc_attribute_types}) -> #{assoc_type}"
        type "create_#{name}!", "(#{assoc_attribute_types}) -> #{assoc_type}"
      }
    end
    true
  end

  type :has_one, '(%symstr name, ?{ (?ActiveRecord::Base) -> %any } scope, class_name: ?%symstr,'+
                 'dependent: ?(:destroy or :delete or :nullify or :restrict_with_exception or :restrict_with_error),' +
                 'foreign_key: ?%symstr, foreign_type: ?%symstr, primary_key: ?%symstr, as: ?%symstr,' +
                 'through: ?%symstr, source: ?%symstr, source_type: ?%symstr, validate: ?%bool, autosave: ?%bool,' +
                 'inverse_of: ?%symstr, required: ?%bool, anonymous_class: ?Class) -> %any'

  pre :has_one do |name, scope=nil, class_name: nil, dependent: nil, foreign_key: nil,
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
   type name, "(?%bool force_reload) -> #{assoc_type}"
   type "#{name}=", "(#{assoc_type}) -> #{assoc_type}"
   unless as
     rdl_at(:model) { |sym|
       assoc_attribute_types = RDL::Rails.attribute_types(assoc_type.constantize)
       type "build_#{name}", "(#{assoc_attribute_types}) -> #{assoc_type}"
       type "create_#{name}", "(#{assoc_attribute_types}) -> #{assoc_type}"
       type "create_#{name}!", "(#{assoc_attribute_types}) -> #{assoc_type}"
     }
   end
  end

  type :has_many, '(%symstr name, ?{ (?ActiveRecord::Base) -> %any } scope, class_name: ?%symstr,' +
                  'foreign_key: ?%symstr, foreign_type: ?%symstr, primary_key: ?%symstr,' +
                  'dependent: ?(:destroy or :delete_all or :nullify or :restrict_with_exception or :restrict_with_error),' +
                  'counter_cache: ?(%bool or %symstr), as: ?%symstr, through: ?%symstr, source: ?%symstr,' +
                  'source_type: ?%symstr, validate: ?%bool, inverse_of: ?%symstr, extend: ?(Module or Array<Module>))' +
                  '?{ () -> %any } -> %any'

  pre :has_many do |name, scope=nil, class_name: nil, foreign_key: nil, foreign_type: nil, primary_key: nil,
                    dependent: nil, counter_cache: nil, as: nil, through: nil, source: nil, source_type: nil,
                    validate: nil, inverse_of: nil, extend: nil|
    if class_name
      collect_type = class_name.to_s.classify
    else
      collect_type = name.to_s.singularize.classify
    end
    type name, "() -> ActiveRecord::Associations::CollectionProxy<#{collect_type}>"
    type "#{name}=", "(Array<t>) -> ActiveRecord::Associations::CollectionProxy<#{collect_type}>" # TODO not sure of type
    id_type = RDL::Rails.column_to_rdl(collect_type.constantize.columns_hash['id'].type) # TODO assumes id field is "id"
    type "#{name.to_s.singularize}_ids", "() -> Array<#{id_type}>"
    type "#{name.to_s.singularize}_ids=", "() -> Array<#{id_type}>"

    true
  end

  type :has_and_belongs_to_many, '(%symstr name, ?{ (?ActiveRecord::Base) -> %any } scope, class_name: ?%symstr,' +
                                 'join_table: ?%symstr, foreign_key: ?%symstr, association_foreign_key: ?%symstr,' +
                                 'validate: ?%bool, autosave: ?%bool) ?{ () -> %any } -> %any'

  pre :has_and_belongs_to_many do |name, scope=nil, class_name: nil, join_table: nil,
                                  foreign_key: nil, association_foreign_key: nil,
                                  validate: nil, autosave: nil|
    if class_name
      collect_type = class_name.to_s.classify
    else
      collect_type = name.to_s.singularize.classify
    end
    type name, "() -> ActiveRecord::Associations::CollectionProxy<#{collect_type}>"
    type "#{name}=", "(Array<t>) -> ActiveRecord::Associations::CollectionProxy<#{collect_type}>" # TODO not sure of type
    id_type = RDL::Rails.column_to_rdl(collect_type.constantize.columns_hash['id'].type) # TODO assumes id field is "id"
    type "#{name.to_s.singularize}_ids", "() -> Array<#{id_type}>"
    type "#{name.to_s.singularize}_ids=", "() -> Array<#{id_type}>"

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
    true
  end

end
