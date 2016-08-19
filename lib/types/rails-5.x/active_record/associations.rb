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

  type :has_and_belongs_to_many, '(%symstr name, ?{ (?ActiveRecord::Base) -> %any } scope, class_name: ?%symstr,' +
                                 'join_table: ?%symstr, foreign_key: ?%symstr, association_foreign_key: ?%symstr,' +
                                 'validate: ?%bool, autosave: ?%bool) ?{ () -> %any } -> %any'

  pre :has_and_belongs_to_many do |name, scope=nil, class_name: nil, join_table: nil,
                                  foreign_key: nil, association_foreign_key: nil,
                                  validate: nil, autosave: nil|

                                  # collection
                                  # collection<<(object, ...)
                                  # collection.delete(object, ...)
                                  # collection.destroy(object, ...)
                                  # collection=(objects)
                                  # collection_singular_ids
                                  # collection_singular_ids=(ids)
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
