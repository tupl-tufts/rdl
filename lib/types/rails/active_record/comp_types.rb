require_relative "#{File.dirname(__FILE__)}/sql-strings.rb"

class ActiveRecord::Base
  extend RDL::Annotate

  type Object, :present?, "() -> %bool", wrap: false
  type :initialize, '(``DBType.rec_to_schema_type(trec, true)``) -> self', wrap: false
  type 'self.create', '(``DBType.rec_to_schema_type(trec, true, include_assocs: true)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type 'self.new', '(``DBType.rec_to_schema_type(trec, true, include_assocs: true)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type 'self.create!', '(``DBType.rec_to_schema_type(trec, true, include_assocs: true)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :initialize, '() -> self', wrap: false
  type 'self.create', '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type 'self.new', '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type 'self.create!', '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :attribute_names, "() -> Array<String>", wrap: false
  type :to_json, "(?{ only: Array<String> }) -> String", wrap: false
  type :update_column, '(``uc_first_arg(trec)``, ``uc_second_arg(trec, targs)``) -> %bool', wrap: false
  type :[], '(Symbol) -> ``access_output(trec, targs)``', wrap: false
  type :save!, '(?{ validate: %bool }) -> %bool', wrap: false
  type 'self.transaction', '() {() -> u} -> u', wrap: false

  type RDL::Globals, 'self.ar_db_schema', "() -> Hash<%any, RDL::Type::GenericType>", wrap: false
  type String, :singularize, "() -> String", wrap: false
  type String, :camelize, "() -> String", wrap: false
  type String, :pluralize, "() -> String", wrap: false
  type String, :underscore, "() -> String", wrap: false

  type Object, :try, "(Symbol) -> ``try_output(trec, targs)``", wrap: false

  def Object.try_output(trec, targs)
    case trec
    when RDL::Type::SingletonType
      klass = trec.val.class
      inst = {self: trec }
    when RDL::Type::NominalType
      klass = trec.klass
      inst = {self: trec }
    when RDL::Type::GenericType
      klass = trec.base.klass
      inst = trec.to_inst.merge(self: trec)
    else
      raise "Unexpected type #{trec}."
    end
    case targs[0]
    when RDL::Type::SingletonType
      meth_types = RDL::Typecheck.lookup({}, klass.to_s, targs[0].val, nil, make_unknown: false)#RDL::Globals.info.get(klass, targs[0].val, :type)
      #meth_types = meth_types[0] if meth_types
      ret_type = meth_types ? RDL::Type::UnionType.new(*meth_types.map { |mt| mt.ret } ).canonical : RDL::Globals.types[:top]
    else
      return RDL::Globals.types[:top]
    end
  end        



  def self.access_output(trec, targs)
    case trec
    when RDL::Type::NominalType
      tname = trec.name.to_sym
      tschema = RDL.type_cast(RDL::Globals.ar_db_schema[tname].params[0], "RDL::Type::FiniteHashType", force: true).elts
      raise "Schema not found." unless tschema
      arg = targs[0]
      case arg
      when RDL::Type::SingletonType
        col = arg.val
        ret = tschema[col]
        ret = RDL::Globals.types[:nil] unless ret
        return ret
      else
        raise "TODO"
      end
    else
      raise 'unexpected type'
    end
  end
  RDL.type ActiveRecord::Base, 'self.access_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", wrap: false, typecheck: :type_code

  def self.uc_first_arg(trec)
    case trec
    when RDL::Type::NominalType
      tname = trec.name.to_sym
      tschema = RDL.type_cast(RDL::Globals.ar_db_schema[tname].params[0], "RDL::Type::FiniteHashType", force: true).elts
      raise "Schema not found." unless tschema
      typs = RDL.type_cast(tschema.keys, "Array<Symbol>", force: true).reject { |k| k == :__associations}.map { |k| RDL::Type::SingletonType.new(k) }
      return RDL::Type::UnionType.new(*RDL.type_cast(typs, "Array<RDL::Type::Type>"))
    else
      raise "unexpected type"
    end
  end
  RDL.type ActiveRecord::Base, 'self.uc_first_arg', "(RDL::Type::Type) -> RDL::Type::UnionType", wrap: false, typecheck: :type_code

  def self.uc_second_arg(trec, targs)
    case trec
    when RDL::Type::NominalType
      tname = trec.name.to_sym
      tschema = RDL.type_cast(RDL::Globals.ar_db_schema[tname].params[0], "RDL::Type::FiniteHashType", force: true).elts
      raise "Schema not found." unless tschema
      raise "Unexpected first arg type." unless targs[0].is_a?(RDL::Type::SingletonType) && RDL.type_cast(targs[0], "RDL::Type::SingletonType<Object>").val.is_a?(Symbol)
      return tschema[RDL.type_cast(targs[0], "RDL::Type::SingletonType<Symbol>").val]
    else
      raise "unexpected type"
    end
  end
  RDL.type ActiveRecord::Base, 'self.uc_second_arg', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", wrap: false, typecheck: :type_code


end

module ActiveRecord::AutosaveAssociation
  extend RDL::Annotate
  type :reload, "() -> %any", wrap: false
end

module ActiveRecord::Transactions
  extend RDL::Annotate
  type :destroy, '() -> self', wrap: false
  type :save, '(?{ validate: %bool }) -> %bool', wrap: false
end

module ActiveRecord::Suppressor
  extend RDL::Annotate

  type :save!, '() -> %bool', wrap: false
end

module ActiveRecord::Core::ClassMethods
  extend RDL::Annotate
  ## Types from this module are used when receiver is ActiveRecord::Base

  type :find, '(Integer or String or Symbol or Array<Integer>) -> ``DBType.find_output_type(trec, targs)``', wrap: false
  #type :find, '(Array<Integer>) -> ``DBType.find_output_type(trec, targs)``', wrap: false
  type :find, '(Integer, Integer, *Integer) -> ``DBType.find_output_type(trec, targs)``', wrap: false
  type :find_by, '(``DBType.find_input_type(trec, targs)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  ## TODO: find_by's with conditions given as string

  type :find_or_create_by, '(``DBType.find_input_type(trec, targs)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :find_or_create_by, '(``DBType.find_input_type(trec, targs)``) {(``DBType.rec_to_nominal(trec)``) -> %any} -> ``DBType.rec_to_nominal(trec)``', wrap: false
  #type :find_or_create_by, '(Boolean) -> Float', wrap: false
end

module ActiveRecord::FinderMethods
  extend RDL::Annotate
  ## Types from this module are used when receiver is ActiveRecord_Relation

  type :find, '(Integer or String) -> ``DBType.find_output_type(trec, targs)``', wrap: false
  type :find, '(Array<Integer>) -> ``DBType.find_output_type(trec, targs)``', wrap: false
  type :find, '(Integer, Integer, *Integer) -> ``DBType.find_output_type(trec, targs)``', wrap: false
  type :find_by, '(``DBType.find_input_type(trec, targs)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :first, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :first!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :first, '(Integer) -> ``DBType.rec_to_array(trec)``', wrap: false
  type :last, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :last!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :last, '(Integer) -> ``DBType.rec_to_array(trec)``', wrap: false
  type :take, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :take!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :take, '(Integer) -> ``DBType.rec_to_array(trec)``', wrap: false
  type :exists?, '(``DBType.exists_input_type(trec, targs)``) -> %bool', wrap: false
end

module ActiveRecord::Querying
  extend RDL::Annotate
  ## Types from this module are used when receiver is ActiveRecord::Base

  type :first, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :first!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :first, '(Integer) -> ``DBType.rec_to_array(trec)``', wrap: false
  type :last, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :last!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :last, '(Integer) -> ``DBType.rec_to_array(trec)``', wrap: false
  type :take, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :take!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :take, '(Integer) -> ``DBType.rec_to_array(trec)``', wrap: false
  type :exists?, '(``DBType.exists_input_type(trec, targs)``) -> %bool', wrap: false

  type :where, '(``DBType.where_input_type(trec, targs)``) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :where, '(String, *%any) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :where, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord::QueryMethods::WhereChain), DBType.rec_to_nominal(trec))``', wrap: false


  type :joins, '(``DBType.joins_one_input_type(trec, targs)``) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :joins, '(``DBType.joins_multi_input_type(trec, targs)``, %any, *%any) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :group, '(*Symbol or String) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :select, '(Symbol or String or Array<String>, *Symbol or String or Array<String>) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :select, '() { (self) -> %bool } -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :order, '(%any) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :includes, '(``DBType.joins_one_input_type(trec, targs)``) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :includes, '(``DBType.joins_multi_input_type(trec, targs)``, %any, *%any) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :preload, '(``DBType.joins_one_input_type(trec, targs)``) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :preload, '(``DBType.joins_multi_input_type(trec, targs)``, %any, *%any) -> ``DBType.joins_output(trec, targs)``', wrap: false

  type :limit, '(Integer) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
  type :count, '() -> Integer', wrap: false
  type :count, '(``DBType.count_input(trec, targs)``) -> Integer', wrap: false
  type :sum, '(``DBType.count_input(trec, targs)``) -> Integer', wrap: false
  type :destroy_all, '() -> ``DBType.rec_to_array(trec)``', wrap: false
  type :delete_all, '() -> Integer', wrap: false
  type :references, '(Symbol, *Symbol) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false
end

module ActiveRecord::Relation::QueryMethods
  extend RDL::Annotate
  ## Types from this module are used when receiver is ActiveRecord_relation

  type :where, '(``DBType.where_input_type(trec, targs)``) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), RDL.type_cast(trec, "RDL::Type::GenericType", force: true).params[0])``', wrap: false
  type :where, '(String, *%any) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), RDL.type_cast(trec, "RDL::Type::GenericType", force: true).params[0])``', wrap: false
  #type :where, '(String, *String) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), trec.params[0])``', wrap: false
  type :where, '() -> ``DBType.where_noarg_output_type(trec)``', wrap: false

  type :joins, '(``DBType.joins_one_input_type(trec, targs)``) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :joins, '(``DBType.joins_multi_input_type(trec, targs)``, %any, *%any) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :group, '(*Symbol or String) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), RDL.type_cast(trec, "RDL::Type::GenericType", force: true).params[0])``', wrap: false
  type :select, '(Symbol or String or Array<String>, *Symbol or String or Array<String>) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), RDL.type_cast(trec, "RDL::Type::GenericType", force: true).params[0])``', wrap: false
  type :select, '() { (``RDL.type_cast(trec, "RDL::Type::GenericType", force: true).params[0]``) -> %bool } -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), RDL.type_cast(trec, "RDL::Type::GenericType", force: true).params[0])``', wrap: false
  type :order, '(%any) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), RDL.type_cast(trec, "RDL::Type::GenericType", force: true).params[0])``', wrap: false
  type :includes, '(``DBType.joins_one_input_type(trec, targs)``) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :includes, '(``DBType.joins_multi_input_type(trec, targs)``, %any, *%any) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :preload, '(``DBType.joins_one_input_type(trec, targs)``) -> ``DBType.joins_output(trec, targs)``', wrap: false
  type :preload, '(``DBType.joins_multi_input_type(trec, targs)``, %any, *%any) -> ``DBType.joins_output(trec, targs)``', wrap: false

  type :limit, '(Integer) -> ``trec``', wrap: false
  type :references, '(Symbol, *Symbol) -> self', wrap: false
end


module ActionController::Instrumentation
  extend RDL::Annotate
=begin
  type :redirect_to, "(``redirect_input(targs)``) -> String", wrap: false

  ## When first input is a VarType, we want to associate that VarType with the first (optional) arg of redirect_to.
  ## Same goes if first input is anything *other than* a FHT.
  ## Otherwise, we drop first optional arg.
  def self.redirect_input(targs)

  end
=end
end

class ActiveRecord::QueryMethods::WhereChain
  extend RDL::Annotate
  type_params [:t], :dummy

  type :not, '(``DBType.not_input_type(trec, targs)``) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), RDL.type_cast(trec, "RDL::Type::GenericType", force: true).params[0])``', wrap: false

end

module ActiveRecord::Delegation
  extend RDL::Annotate

  #type :+, '(%any) -> ``DBType.plus_output_type(trec, targs)``', wrap: false
  type :+, '(ActiveRecord_Relation<x>) -> ``DBType.plus_output_type(trec, targs)``', wrap: false

end

class JoinTable
  extend RDL::Annotate
  type_params [:orig, :joined], :dummy
  ## type param :orig will be nominal type of base table in join
  ## type param :joined will be a union type of all joined tables, or just a nominal type if there's only one

  ## this class is meant to only be the type parameter of ActiveRecord_Relation or WhereChain, expressing multiple joined tables instead of just a single table
end



module ActiveRecord::Scoping::Named::ClassMethods
  extend RDL::Annotate
  type :all, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), DBType.rec_to_nominal(trec))``', wrap: false

end

module ActiveRecord::Persistence
  extend RDL::Annotate
  type :update!, '(``DBType.rec_to_schema_type(trec, true)``) -> %bool', wrap: false
  type :update, '(``DBType.rec_to_schema_type(trec, true)``) -> %bool', wrap: false
  type :update_attribute, '(Symbol, ``DBType.update_attribute_input(trec, targs)``) -> %bool', wrap: false
end

module ActiveRecord::Calculations
  extend RDL::Annotate
  type :count, '() -> Integer', wrap: false
  type :count, '(``DBType.count_input(trec, targs)``) -> Integer', wrap: false
  type :sum, '(``DBType.count_input(trec, targs)``) -> Integer', wrap: false
end

class ActiveRecord_Relation
  ## In practice, this is actually a private class nested within
  ## each ActiveRecord::Base, e.g. Person::ActiveRecord_Relation.
  ## Using this class just for type checking.
  extend RDL::Annotate
  include ActiveRecord::Relation::QueryMethods
  include ActiveRecord::FinderMethods
  include ActiveRecord::Calculations
  include ActiveRecord::Delegation

  type_params [:t], :dummy

  type :each, '() -> ``DBType.each_no_block_ret(trec)``', wrap: false
  type :each, '() { (``DBType.each_block_arg(trec)``) -> %any } -> Array<t>', wrap: false
  type :empty?, '() -> %bool', wrap: false
  type :present?, '() -> %bool', wrap: false
  type :create, '(``DBType.rec_to_schema_type(trec, true, include_assocs: true)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :create, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :create!, '(``DBType.rec_to_schema_type(trec, true, include_assocs: true)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :create!, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :new, '(``DBType.rec_to_schema_type(trec, true)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :new, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :build, '(``DBType.rec_to_schema_type(trec, true)``) -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :build, '() -> ``DBType.rec_to_nominal(trec)``', wrap: false
  type :destroy_all, '() -> ``DBType.rec_to_array(trec)``', wrap: false
  type :delete_all, '() -> Integer', wrap: false
  type :map, '() { (t) -> u } -> Array<u>'
  type :all, '() -> self', wrap: false ### kind of a silly method, always just returns self
  type :collect, "() { (t) -> u } -> Array<u>", wrap: false
  type :find_each, "() { (t) -> x } -> nil", wrap: false
  type :to_a, "() -> ``DBType.rec_to_array(trec)``", wrap: false
  type :[], "(Integer) -> t", wrap: false
  type :size, "() -> Integer", wrap: false
  type :update_all, '(``RDL::Type::UnionType.new(RDL::Globals.types[:string], DBType.rec_to_schema_type(trec, true))``) -> Integer', wrap: false
  type :valid, "() -> self", wrap: false
  type :sort, "() { (t, t) -> Integer } -> Array<t>", wrap: false

  type :as_json, "(?%any) -> ``DBType.rec_as_json(trec, targs)``", wrap: false
end

module ActiveModel::Serializers::JSON
  extend RDL::Annotate

  type :as_json, "(?%any) -> ``DBType.rec_as_json(trec, targs)``", wrap: false

end


class DBType

  ## given an RDL type representing one or more symbols,
  ## extract the symbols out.
  #
  # (RDL::Type) -> Array<Symbol>
  #
  # example:
  #   input: RDL type for [:body, :title]
  #          (which is TupleType { params=[SingletonType { val=:body }, SingletonType { val=:title }]})
  #   output: [:body, :title]
  #
  #   input: RDL type for :body
  #          (which is SingletonType { val=:body })
  #   output: [:body]
  def self.type_to_keys(type)
    case type
    when RDL::Type::SingletonType
      return [type.val]
    when RDL::Type::TupleType
      return type.params.map { |t| t.val }
    else
      raise "Unexpected type encountered when parsing JSON options. Expected SingletonType or TupleType, got #{type}"
    end
  end

  ## Determines the output type for a call to `render`.
  ## Given: `targs` from the `render` call.
  def self.render_output(targs)
    #ap "Comp type: render_output. Called with #{targs}"

    # If the call doesn't look like:
    #     render json: ..., ...
    # 
    # just return string.
    return RDL::Globals.types[:string] unless
      targs && targs.length && targs.length > 0 &&
      targs[0].is_a?(RDL::Type::FiniteHashType) &&
      targs[0].elts[:json]

    # If the `x` in `render json: x` is just a Ruby hash
    # (i.e. FHT), return the serialized type.
    if targs[0].elts[:json].is_a? RDL::Type::FiniteHashType
      return RDL::Type::GenericType.new(
        RDL::Type::NominalType.new("JSON"), # Base
        targs[0].elts[:json] # Generic parameter
      )
    end

    # If the call is `render json: {}`, return
    # JSON<{}>.
    if targs[0].elts[:json].is_empty_hash?
      return RDL::Type::GenericType.new(
        RDL::Type::NominalType.new("JSON"),
        RDL::Type::FiniteHashType.new({}, nil)
      )
    end

    # If the `x` in `render json: x` is /already/ a JSON object
    # (i.e. @model.to_json), return that.
    if (targs[0].elts[:json].is_a? RDL::Type::GenericType) && 
      (targs[0].elts[:json].base.name == "JSON") && 
      (targs[0].elts[:json].params[0].is_a? RDL::Type::FiniteHashType) 
      then
      return targs[0].elts[:json]
    end

    # If the `x` in `render json: x` is an /array/ of JSON objects,
    # (i.e. @models.to_json), return that.
    if (targs[0].elts[:json].is_a? RDL::Type::GenericType) &&
      (targs[0].elts[:json].base.name == "Array") && 
      (targs[0].elts[:json].params[0].is_a? RDL::Type::GenericType) && 
      (targs[0].elts[:json].params[0].base.name == "JSON") && 
      (targs[0].elts[:json].params[0].params[0].is_a? RDL::Type::FiniteHashType)    
      then
      return targs[0].elts[:json]
    end

    # If the `x` in `render json: x` is a VarType, try to extract a solution
    # for it, and retry.
    if (targs[0].elts[:json].is_a? RDL::Type::VarType)

      var = targs[0].elts[:json]

      extracted = RDL::Typecheck.extract_var_sol(var, var.category)

      if extracted != var
        # We were able to extract a solution. Replace it in targs and retry.
        return self.render_output([RDL::Type::FiniteHashType.new(targs[0].elts.merge({json: extracted}), nil)])
      end
    end

    # If the `x` in `render json: x` is a UnionType, call `render_output` on
    # its components. Join their outputs with a UnionType.
    if (targs[0].elts[:json].is_a? RDL::Type::UnionType)
      union = targs[0].elts[:json]

      rendered = union.types.map { |t| DBType.render_output([RDL::Type::FiniteHashType.new(targs[0].elts.merge({json: t}), nil)]) }

      return RDL::Type::UnionType.new(*rendered)
    end

    ## If the `x` in `render json: x` is a Multi/PathType, call `render_output`
    ## on its components. Join their outputs with a MultiType.
    #if (targs[0].elts[:json].is_a? RDL::Type::MultiType) || (targs[0].elts[:json].is_a? RDL::Type::PathType)
    #  # Map<Path, Type>
    #  type_map = targs[0].elts[:json].type_map

    #  rendered_map = type_map.transform_values { |p, t| DBType.render_output([RDL::Type::FiniteHashType.new(targs[0].elts.merge({json: t}))]) }

    #  return RDL::Type::MultiType.new(rendered_map)
    #end
      
    RDL::Logging.log :typecheck, :trace, "Comp type: render_output. trec is an ActiveModel relation. Calling rec_as_json..."

    #                       receiver              render options
    return self.rec_as_json(targs[0].elts[:json], [targs[0]])
  end



  ## given a type (usually representing a receiver type in a method call), this
  ## method returns a finite hash type (FHT) representing its serialized
  ## version.
  # 
  # `options` takes the same form as Rails' `as_json`:
  #      only:   Attribute | List<Attribute>
  #    except:   Attribute | List<Attribute>
  #   methods:      Method | List<Method>       # calls methods with the
  #                                             # model as an arg
  #   include: Association | List<Association>
  #
  # Implementation closely follows `serializable_hash`:
  #    https://apidock.com/rails/ActiveModel/Serialization/serializable_hash
  #
  # (RDL::Type::NominalType, Array<RDL::Type>)
  def self.rec_as_json(trec, options = [RDL::Type::FiniteHashType.new({}, nil)])
    #puts "rec_as_json: called with: trec='#{trec}' :: #{trec.class}      options='#{options}' :: #{options.class}"

    # We will attempt to figure out the precise, JSON type for this call.
    # If we cannot figure it out for any reason, we will default to a 
    # fallback type: "String or Array<String>"
    raise RDL::Typecheck::StaticTypeError, "as_json called with invalid options. Expected Array, got #{options.class.to_s}" unless options.class == Array

    begin
      if options.length < 1
        options[0] = RDL::Type::FiniteHashType.new({}, nil)
      end

      # Step 1. use `rec_to_schema_type` to get the schema type and attribute names.
      model_type = trec # if given an array, use the value type
      model_type = trec.params[0] if (model_type.is_a? RDL::Type::GenericType) && (model_type.base.name == "Array")
      schema = rec_to_schema_type(model_type, true, include_assocs: false, output: true)
      attribute_names = schema.elts.keys

      # Step 2. Filter by `only` and `except`.
      if options and options[0].elts.key?(:only)
        # Extract attribute names from type
        only = type_to_keys(options[0].elts[:only])
        attribute_names &= only
      elsif options and options[0].elts.key?(:except)
        # Extract attribute names from type
        except = type_to_keys(options[0].elts[:except])
        attribute_names -= except
      end
      # actually filter
      schema.elts = schema.elts.filter { |k, v| attribute_names.include?(k) }

      # Step 3. Add `include` associations.
      if options and options[0].elts.key?(:include)
        # Extract `include` value.
        inclusions = options[0].elts[:include]
        
        # Is it a higher order association?
        case inclusions
        when RDL::Type::FiniteHashType
          # Loop over each included model
          inclusions.elts.each do |included_symbol, included_options|
            raise RDL::Typecheck::StaticTypeError, "JSON serialization includes an unknown association: '#{included_symbol}'" unless associated_with?(model_type, included_symbol)

            table_class = Object.const_get(model_type.to_s.to_sym)
            included_class_name = table_class.reflect_on_association(included_symbol).class_name.to_sym

            included_options = [RDL::Type::FiniteHashType.new({}, nil)] unless included_options
            included_options = [included_options] unless included_options.class == Array

            schema.elts[included_symbol] =
              RDL::Type::GenericType.new(RDL::Globals.types[:array],
                rec_as_json(RDL::Type::NominalType.new(included_class_name), included_options))
          end
            

        when RDL::Type::SingletonType # just one inclusion like `:body`
          # get the name of the included Model
          included_symbol = inclusions.val
          raise RDL::Typecheck::StaticTypeError, "JSON serialization includes an unknown association: '#{included_symbol}'" unless associated_with?(model_type, included_symbol)

          table_class = Object.const_get(model_type.to_s.to_sym)
          # get name of associated class
          included_class_name = table_class.reflect_on_association(included_symbol).class_name.to_sym
          
          # add the schem
          schema.elts[included_symbol] = 
            RDL::Type::GenericType.new(RDL::Globals.types[:array], 
              rec_as_json(RDL::Type::NominalType.new(included_class_name)))



          #puts "rec_as_json: table_class: '#{table_class.inspect}'"
          #puts "rec_as_json: included_symbol: '#{included_symbol.inspect}' :: #{included_symbol.class}"
          #puts "rec_as_json: reflected association: #{table_class.reflect_on_association(included_symbol).inspect}"# { |a|
            #puts "rec_as_json: reflecting on association: '#{a.inspect}'"
            #if check_col
            #  assoc_type = RDL::Type::NominalType.new(a.class_name)
            #  if a.name.to_s == a.plural_name
            #    ## association is plural
            #    assoc_hash[a.name] = RDL::Type::OptionalType.new(RDL::Type::GenericType.new(RDL::Globals.types[:array], assoc_type))
            #  else
            #    assoc_hash[a.name] = RDL::Type::OptionalType.new(assoc_type)
            #  end
            #else
            #  assoc_hash[a.name] = RDL::Type::OptionalType.new(RDL::Globals.types[:top])
            #end
          #}
          #tinclusion = RDL.type_cast(included_symbol, 'Class', force: true)
          #raise RDL::Typecheck::StaticTypeError, "Unexpected type `include`'d: '#{tinclusion}'." unless tinclusion.is_a?(Class)
          #included_name = tinclusion.to_s.to_sym

          #tinclusion = table_name_to_schema_type(included_class_name, true)
          #puts "rec_as_json: tinclusion: #{tinclusion.inspect}"


          #val = RDL.type_cast(trec.val, 'Class', force: true)
          #raise RDL::Typecheck::StaticTypeError, "Unexpected receiver type #{trec}." unless val.is_a?(Class)
          #tname = val.to_s.to_sym
          #res = table_name_to_schema_type(tname, check_col, takes_array, include_assocs: include_assocs)
          #puts "Singleton Type tname: #{tname}, res: #{res}"
        end
        
      end

      ret_type = RDL::Type::GenericType.new(
        RDL::Type::NominalType.new("JSON"), # Base
        schema # Generic parameter
      )

      # If rec_as_json was called on an ActiveRecord_Relation or an Array of Models,
      # it will return an array of results.
      if (trec.class == RDL::Type::GenericType) && ((trec.base.name == "ActiveRecord_Relation") || (trec.base.name == "Array"))
        ret_type = RDL::Type::GenericType.new(
          RDL::Type::NominalType.new("Array"), # Base
          ret_type # Generic parameter
        )
      end

     RDL::Logging.log :typecheck, :trace, "rec_as_json: Success! Determined type: #{ret_type}"
      return ret_type
    rescue RDL::Typecheck::StaticTypeError => e
     RDL::Logging.log :typecheck, :trace, "rec_as_json failed to determine a type:"
     RDL::Logging.log :typecheck, :trace, e
     RDL::Logging.log :typecheck, :trace, e.backtrace
      return RDL::Globals.types[:string]
    end
  end
  RDL.type DBType, 'self.rec_as_json', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::FiniteHashType", wrap: false, typecheck: :type_code

  ## given a type (usually representing a receiver type in a method call), this method returns the nominal type version of that type.
  ## if the given type represents a joined table, then we return the nominal type version of the *base* of the joined table.
  ## [+ t +] is the type for which we want the nominal type.
  def self.rec_to_nominal(t)
    case t
    when RDL::Type::SingletonType
      val = RDL.type_cast(t.val, "Class", force: true)
      raise RDL::Typecheck::StaticTypeError, "Expected class singleton type, got #{val} instead." unless val.is_a?(Class)
      return RDL::Type::NominalType.new(val)
    when RDL::Type::GenericType
      raise RDL::Typecheck::StaticTypeError, "got unexpected type #{t}" unless t.base.klass == ActiveRecord_Relation
      param = t.params[0]
      case param
      when RDL::Type::GenericType
        ## should be JoinTable
        ## When getting an indivual record from a join table, record will be of type of the base table in the join
        raise RDL::Typecheck::StaticTypeError, "got unexpected type #{param}" unless param.base.klass == JoinTable
        return param.params[0]
      when RDL::Type::NominalType
        return param
      else
        raise RDL::Typecheck::StaticTypeError, "got unexpected type #{t.params[0]}"
      end
    end
  end
  RDL.type DBType, 'self.rec_to_nominal', "(RDL::Type::Type) -> RDL::Type::Type", wrap: false, typecheck: :type_code

  def self.rec_to_array(trec)
    RDL::Type::GenericType.new(RDL::Globals.types[:array], rec_to_nominal(trec))
  end
    RDL.type DBType, 'self.rec_to_array', "(RDL::Type::Type) -> RDL::Type::GenericType", wrap: false, typecheck: :type_code

  ## given a receiver type in various kinds of query calls, returns the accepted finite hash type input,
  ## or a union of types if the receiver represents joined tables.
  ## [+ trec +] is the type of the receiver in the method call.
  ## [+ check_col +] is a boolean indicating whether or not the column types (i.e., values in the finite hash type) will be checked.
  ## [+ include_assocs +] is a bool indicating whether or not to include associations in returned hash, e.g., for `create` method.
  ## [+ output +] Whether the resulting FHT will be used as output, vs. as
  ##              to an ActiveRecord function. See `table_name_to_schema_type`.
  def self.rec_to_schema_type(trec, check_col, takes_array=false, include_assocs: false, output: false)
    case trec
    when RDL::Type::GenericType
      raise "Unexpected type #{trec}." unless (trec.base.klass == ActiveRecord_Relation) || (trec.base.klass == ActiveRecord::QueryMethods::WhereChain)
      param = trec.params[0]
      case param
      when RDL::Type::GenericType
        ## should be JoinTable
        raise "1. rec_to_schema unexpected type #{trec}" unless param.base.klass == JoinTable
        base_name = RDL.type_cast(param.params[0], "RDL::Type::NominalType", force: true).klass.to_s.singularize.to_sym ### singularized symbol name of first param in JoinTable, which is base table of the joins
        type_hash = table_name_to_schema_type(base_name, check_col, takes_array, include_assocs: include_assocs, output: output).elts
        pp1 = param.params[1]
        case pp1
        when RDL::Type::NominalType
          ## just one table joined to base table
          joined_name = pp1.klass.to_s.singularize.to_sym
          joined_type = RDL::Type::OptionalType.new(table_name_to_schema_type(joined_name, check_col, takes_array, include_assocs: include_assocs, output: output))
          type_hash = type_hash.merge({ joined_name.to_s.pluralize.underscore.to_sym => joined_type })
        when RDL::Type::UnionType
          ## multiple tables joined to base table
          joined_hash = RDL.type_cast(Hash[pp1.types.map { |t|
                               joined_name = RDL.type_cast(t, "RDL::Type::NominalType", force: true).klass.to_s.singularize.to_sym
                               joined_type = RDL::Type::OptionalType.new(table_name_to_schema_type(joined_name, check_col, takes_array, include_assocs: include_assocs, output: output))
                               [joined_name.to_s.pluralize.underscore.to_sym, joined_type]
                             }
                                          ], "Hash<Symbol, RDL::Type::FiniteHashType>", force: true)
          type_hash = type_hash.merge(joined_hash)
        else
          raise "2. rec_to_schema unexpected type #{trec}"
        end
        return RDL::Type::FiniteHashType.new(type_hash, nil)
      when RDL::Type::NominalType
        tname = param.klass.to_s.to_sym
        res = table_name_to_schema_type(tname, check_col, takes_array, include_assocs: include_assocs, output: output)
        return res
      else
        raise RDL::Typecheck::StaticTypeError, "Unexpected type parameter in  #{trec}."
      end
    when RDL::Type::SingletonType
      val = RDL.type_cast(trec.val, 'Class', force: true)
      raise RDL::Typecheck::StaticTypeError, "Unexpected receiver type #{trec}." unless val.is_a?(Class)
      tname = val.to_s.to_sym
      res = table_name_to_schema_type(tname, check_col, takes_array, include_assocs: include_assocs, output: output)
      return res
    when RDL::Type::NominalType
      tname = trec.name.to_sym
      res = table_name_to_schema_type(tname, check_col, takes_array, include_assocs: include_assocs, output: output)
      return res

    else
      
      raise RDL::Typecheck::StaticTypeError, "Unexpected receiver type #{trec}."
    end
  end
  RDL.type DBType, 'self.rec_to_schema_type', "(RDL::Type::Type, %bool, ?%bool) -> RDL::Type::FiniteHashType", wrap: false, typecheck: :type_code

  ## turns a given table name into the appropriate finite hash type based on table schema, with optional or top-type values
  ## [+ tname +] is the table name as a symbol
  ## [+ check_col +] is a boolean indicating whether or not column types will eventually be checked
  ## [+ output +] true if the resulting type will be used for output, as 
  #               opposed to input to an ActiveRecord function. 
  #               For input to a function, all fields will be marked optional, 
  #               and all "String"s will be "(String or Symbol)".
  #
  #               This is enable something like 
  #                   `Model.find(:title => "Hello World")`
  #               Here, the call to `table_name_to_schema_type` is 
  #                    `table_name_to_schema_type("Model", output: false)`
  #
  #               This lets the user specify only some fields, and index column
  #               names using symbols.
  #
  #               When `output` is set to `true`, the resulting FHT will be
  #               accurate with respect to the ActiveModel schema. E.g.,
  #               fields are marked optional unless they have a 
  #               PresenceValidator, and strings are just strings.
  def self.table_name_to_schema_type(tname, check_col, takes_array=false, include_assocs: false, output: false)
    #h = RDL.type_cast({}, "Hash<%any, RDL::Type::Type>", force: true)
    ttype = RDL::Globals.ar_db_schema[tname]
    raise RDL::Typecheck::StaticTypeError, "No table type for #{tname} found." unless ttype
    tschema = RDL.type_cast(ttype.params[0], "RDL::Type::FiniteHashType", force: true).elts.except(:__associations)
    h = Hash[tschema.map { |k, v|
               if check_col
                 # Always strip out the optional type to start. 
                 optional = v.is_a? RDL::Type::OptionalType
                 v = v.type if optional

                 # Modify the type as necessary
                 v = RDL::Type::UnionType.new(v, RDL::Globals.types[:symbol]) if v == RDL::Globals.types[:string] if !output ## ran into cases where symbols can be accepted in addition to string values.
                 v = RDL::Type::UnionType.new(v, RDL::Type::GenericType.new(RDL::Globals.types[:array], v)).canonical if takes_array

                 # Add the optional type back in, if it was already there or if 
                 # it's requested.
                 v = RDL::Type::OptionalType.new(v) if optional || !output
                 [k, v]
               else
                 [k, RDL::Type::OptionalType.new(RDL::Globals.types[:top])]
               end
             }]
    if include_assocs
      ## include associations in schema hash
      table_class = Object.const_get(tname)
      assoc_hash = {}
      table_class.reflect_on_all_associations.each { |a|
        if check_col
          assoc_type = RDL::Type::NominalType.new(a.class_name)
          if a.name.to_s == a.plural_name
            ## association is plural
            assoc_hash[a.name] = RDL::Type::OptionalType.new(RDL::Type::GenericType.new(RDL::Globals.types[:array], assoc_type))
          else
            assoc_hash[a.name] = RDL::Type::OptionalType.new(assoc_type)
          end
        else
          assoc_hash[a.name] = RDL::Type::OptionalType.new(RDL::Globals.types[:top])
        end
      }
      h.merge!(assoc_hash)
    end
    RDL::Type::FiniteHashType.new(RDL.type_cast(h, "Hash<%any, RDL::Type::Type>", force: true), nil)
  end
  RDL.type DBType, 'self.table_name_to_schema_type', "(Symbol, %bool, ?%bool) -> RDL::Type::FiniteHashType", wrap: false, typecheck: :type_code

  def self.where_input_type(trec, targs)
    handle_sql_strings(trec, targs) if targs[0].is_a?(RDL::Type::PreciseStringType) && !targs[1].nil? && !targs[1].kind_of_var_input?
    tschema = rec_to_schema_type(trec, true, true)
    return RDL::Type::UnionType.new(tschema, RDL::Globals.types[:string], RDL::Globals.types[:array]) ## no indepth checking for string or array cases
  end
  RDL.type Object, 'self.handle_sql_strings', "(RDL::Type::Type, Array<RDL::Type::Type>) -> %any", wrap: false
  RDL.type DBType, 'self.where_input_type', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::UnionType", wrap: false, typecheck: :type_code

  def self.find_input_type(trec, targs)
    handle_sql_strings(trec, targs) if targs[0].is_a? RDL::Type::PreciseStringType
    rec_to_schema_type(trec, true)
  end

  def self.update_attribute_input(trec, targs)
    col = targs[0].val
    col_type = targs[1]
    schema = DBType.rec_to_schema_type(trec, true)
    schema.elts[col]
  end

  def self.where_noarg_output_type(trec)
    case trec
    when RDL::Type::SingletonType
      ## where called directly on class
      RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord::QueryMethods::WhereChain), rec_to_nominal(trec))
    when RDL::Type::GenericType
    ## where called on ActiveRecord_Relation
      raise RDL::Typecheck::StaticTypeError, "Unexpected receiver type #{trec}." unless trec.base.klass == ActiveRecord_Relation
      return RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord::QueryMethods::WhereChain), trec.params[0])
    else
      raise RDL::Typecheck::StaticTypeError, "Unexpected receiver type #{trec}."
    end
  end
    RDL.type DBType, 'self.where_noarg_output_type', "(RDL::Type::Type) -> RDL::Type::GenericType", wrap: false, typecheck: :type_code

  def self.not_input_type(trec, targs)
    tschema = rec_to_schema_type(trec, true)
    return RDL::Type::UnionType.new(tschema, RDL::Globals.types[:string], RDL::Globals.types[:array]) ## no indepth checking for string or array cases
  end
  RDL.type DBType, 'self.not_input_type', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::UnionType", wrap: false, typecheck: :type_code

  def self.exists_input_type(trec, targs)
    raise "Unexpected number of arguments to ActiveRecord::Base#exists?." unless targs.size <= 1
    case targs[0]
    when RDL::Type::FiniteHashType
      typ =  rec_to_schema_type(trec, false)
    else
      ## any type can be accepted, only thing we're intersted in is when a hash is given
      ## TODO: what if we get a nominal Hash type?
      typ = targs[0]
    end
    return RDL::Type::OptionalType.new(RDL::Type::UnionType.new(RDL::Globals.types[:integer], RDL::Globals.types[:string], typ))
  end
  RDL.type DBType, 'self.exists_input_type', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", wrap: false, typecheck: :type_code


  def self.find_output_type(trec, targs)
    case targs.size
    when 0
      raise RDL::Typecheck::StaticTypeError, "No arguments given to ActiveRecord::Base#find."
    when 1
      arg0 = targs[0]
      case arg0
      when RDL::Globals.types[:integer], RDL::Globals.types[:string], RDL::Globals.types[:symbol]
        DBType.rec_to_nominal(trec)
      when RDL::Type::SingletonType
      # expecting symbol or integer here
        case arg0.val
        when Integer
          DBType.rec_to_nominal(trec)
        when Symbol
        ## TODO
        ## Actually, this is deprecated in later versions
          raise RDL::Typecheck::StaticTypeError, "Unexpected arg type #{arg0} in call to ActiveRecord::Base#find."
p        else
          raise RDL::Typecheck::StaticTypeError, "Unexpected arg type #{arg0} in call to ActiveRecord::Base#find."
        end
      when RDL::Type::GenericType, RDL::Type::TupleType
        RDL::Type::GenericType.new(RDL::Globals.types[:array], DBType.rec_to_nominal(trec))
      when RDL::Type::VarType
        nom = DBType.rec_to_nominal(trec)
        ###############################################################################################
        # RIGHT HERE: if given a single value, return just `nom`
        #             if given multiple values (i.e. multiple args or an array), return `Array<nom>`
        ###############################################################################################
        #RDL::Type::UnionType.new(RDL::Type::GenericType.new(RDL::Globals.types[:array], nom), nom)
        # If only given one arg, the output type is just 1 object. Not an array.
        nom
      else
        raise RDL::Typecheck::StaticTypeError, "Unexpected arg type #{arg0} in call to ActiveRecord::Base#find."
      end
    else
      DBType.rec_to_nominal(trec)
    end
  end
  RDL.type DBType, 'self.find_output_type', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", wrap: false, typecheck: :type_code

  def self.joins_one_input_type(trec, targs)
    return RDL::Globals.types[:top] unless targs.size == 1 ## trivial case, won't be matched
    case trec
    when RDL::Type::SingletonType
      base_klass = RDL.type_cast(trec, "RDL::Type::SingletonType<Symbol>").val
    when RDL::Type::GenericType
      raise "Unexpected type #{trec}." unless (RDL.type_cast(trec, "RDL::Type::GenericType").base.klass == ActiveRecord_Relation)
      param = RDL.type_cast(trec, "RDL::Type::GenericType").params[0]
      case param
      when RDL::Type::GenericType
        raise "Unexpected type #{trec}." unless (param.base.klass == JoinTable)
        base_klass = RDL.type_cast(param.params[0], "RDL::Type::NominalType", force: true).klass
      when RDL::Type::NominalType
        base_klass = param.klass
      else
        raise "unexpected parameter type in #{trec}"
      end
    else
      raise "unexpected receiver type #{trec}"
    end
    arg0 = targs[0]
    case arg0
    when RDL::Type::SingletonType
      sym = RDL.type_cast(arg0, "RDL::Type::SingletonType<Symbol>").val
      raise RDL::Typecheck::StaticTypeError, "Unexpected arg type #{trec} in call to joins." unless sym.is_a?(Symbol)
      raise RDL::Typecheck::StaticTypeError, "#{trec} has no association to #{arg0}, cannot perform joins." unless associated_with?(RDL.type_cast(base_klass, "Symbol", force: true), sym)
      return arg0
    when RDL::Type::FiniteHashType
      RDL.type_cast(RDL.type_cast(arg0, "RDL::Type::FiniteHashType").elts, "Hash<Symbol, RDL::Type::Type>", force: true).each { |key, val|
        raise RDL::Typecheck::StaticTypeError, "Unexpected hash arg type #{arg0} in call to joins." unless key.is_a?(Symbol) && val.is_a?(RDL::Type::SingletonType) && RDL.type_cast(val, "RDL::Type::SingletonType<Object>").val.is_a?(Symbol)
        val_sym = RDL.type_cast(val, "RDL::Type::SingletonType<Symbol>").val
        raise RDL::Typecheck::StaticTypeError, "#{trec} has no association to #{key}, cannot perform joins." unless associated_with?(RDL.type_cast(base_klass, "Symbol", force: true), key)
        key_klass = key.to_s.singularize.camelize
        raise RDL::Typecheck::StaticTypeError, "#{key} has no association to #{val_sym}, cannot perform joins." unless associated_with?(key_klass, val_sym)
      }
      return arg0
    else
      raise RDL::Typecheck::StaticTypeError, "Unexpected arg type #{arg0} in call to joins."
    end
  end
  RDL.type DBType, 'self.joins_one_input_type', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", wrap: false, typecheck: :type_code

  def self.joins_multi_input_type(trec, targs)
    return RDL::Globals.types[:top] unless targs.size > 1 ## trivial case, won't be matched
    targs.each { |arg|
      joins_one_input_type(trec, [arg])
    }
    return targs[0] ## since this method is called as first argument in type
  end
  RDL.type DBType, 'self.joins_multi_input_type', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", wrap: false, typecheck: :type_code

  def self.associated_with?(rec, sym)
    tschema = RDL::Globals.ar_db_schema[rec.to_s.to_sym]
    raise RDL::Typecheck::StaticTypeError, "No table type for #{rec} found." unless tschema
    schema = RDL.type_cast(tschema.params[0], "RDL::Type::FiniteHashType", force: true).elts
    assoc = schema[:__associations]
    raise RDL::Typecheck::StaticTypeError, "Table #{rec} has no associations, cannot perform joins." unless assoc
    RDL.type_cast(RDL.type_cast(assoc, "RDL::Type::FiniteHashType").elts, "Hash<Symbol, RDL::Type::Type>", force: true).each { |key, value|
      case value
      when RDL::Type::SingletonType
        return true if RDL.type_cast(value.val, "Object", force: true) == sym ## no need to change any plurality here
      when RDL::Type::UnionType
        ## for when rec has multiple of the same kind of association
        value.types.each { |t|
          raise "Unexpected type #{t}." unless t.is_a?(RDL::Type::SingletonType) && (RDL.type_cast(t, "RDL::Type::SingletonType<Object>").val.class == Symbol)
          return true if RDL.type_cast(t, "RDL::Type::SingletonType<Symbol>").val == sym
        }
      else
        raise RDL::Typecheck::StaticTypeError, "Unexpected association type #{value}"
      end
    }
    return false
  end
    RDL.type DBType, 'self.associated_with?', "(Class or Symbol or String, Symbol) -> %bool", wrap: false, typecheck: :type_code

  def self.get_joined_args(targs)
    arg_types = RDL.type_cast([], "Array<RDL::Type::Type>", force: true)
    targs.each { |arg|
    case arg
    when RDL::Type::SingletonType
      raise RDL::Typecheck::StaticTypeError, "Unexpected joins arg type #{arg}" unless (RDL.type_cast(arg.val, "Object", force: true).class == Symbol)
      arg_types = arg_types + [RDL::Type::NominalType.new(RDL.type_cast(arg.val, "Symbol", force: true).to_s.singularize.camelize)]
    when RDL::Type::FiniteHashType
      hsh = arg.elts
      #raise "got #{hsh} but it's not supported" unless hsh.size == 1
      hsh.each { |key, val| 
        #key, val = RDL.type_cast(hsh.first, "[Symbol, RDL::Type::SingletonType<Symbol>]", force: true)
        val = val.val
        arg_types = arg_types + [RDL::Type::UnionType.new(RDL::Type::NominalType.new(key.to_s.singularize.camelize), RDL::Type::NominalType.new(val.to_s.singularize.camelize))]
      }
    else
      raise "Unexpected arg type #{arg} to joins."
    end
    }
    if arg_types.size > 1
      return RDL::Type::UnionType.new(*arg_types)
    elsif arg_types.size == 1
      return arg_types[0]
    else
      raise "oops, didn't expect to get here."
    end
  end
    RDL.type DBType, 'self.get_joined_args', "(Array<RDL::Type::Type>) -> RDL::Type::Type", wrap: false, typecheck: :type_code

  def self.joins_output(trec, targs)
    arg_type = get_joined_args(targs)
    case trec
    when RDL::Type::SingletonType
      joined = arg_type
    when RDL::Type::GenericType
      raise "Unexpected type #{trec}." unless (trec.base.klass == ActiveRecord_Relation)
      param = trec.params[0]
      case param
      when RDL::Type::GenericType
        raise "Unexpected type #{trec}." unless (param.base.klass == JoinTable)
        joined = RDL::Type::UnionType.new(param.params[1], arg_type)
      when RDL::Type::NominalType
        joined = arg_type
      else
        raise "unexpected parameter type in #{trec}"
      end
    else
      raise "joins_output unexpected type #{trec}"
    end
    jt = RDL::Type::GenericType.new(RDL::Type::NominalType.new(JoinTable), rec_to_nominal(trec), joined)
    ret = RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), jt)
    return ret
  end
  RDL.type DBType, 'self.joins_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", wrap: false, typecheck: :type_code

  def self.plus_output_type(trec, targs)
    typs = RDL.type_cast([], "Array<RDL::Type::Type>", force: true)
    [trec, targs[0]].each { |t|
      case t
      when RDL::Type::GenericType
        raise "Expected ActiveRecord_Relation or Array, got #{t} for #{trec} and #{targs}." unless (t.base.name == "ActiveRecord_Relation") or (t.base.name == "Array")
        param0 = t.params[0]
        case param0
        when RDL::Type::GenericType
          raise "Unexpected paramter type in #{t}." unless param0.base.name == "JoinTable"
          typs = typs + [param0.params[0]] ## base of join table
          typs = typs + [param0.params[1]] ## joined tables
        when RDL::Type::NominalType
          typs = typs + [param0]
        else
          raise "unexpected paramater type in #{t}"
        end
      when RDL::Type::VarType
        return RDL::Globals.types[:array]
      else
        #raise "plus unexpected type #{t} with #{trec} and #{targs[0]}"
        return RDL::Globals.types[:bot]
      end
    }
    RDL::Type::GenericType.new(RDL::Type::NominalType.new(Array), RDL::Type::UnionType.new(*typs))
    end
    RDL.type DBType, 'self.plus_output_type', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::GenericType", wrap: false, typecheck: :type_code

    def self.count_input(trec, targs)
      hash_type = rec_to_schema_type(trec, true)## Bug found here. orginally had: rec_to_schema_type(trec, targs).elts
      typs = RDL.type_cast([], "Array<RDL::Type::Type>", force: true)
      hash_type.elts.each { |k, v| ## bug here, originally had: hash_type.each { |k, v|
        if v.is_a?(RDL::Type::FiniteHashType)
          ## will reach this with joined tables, but we're only interested in column names
          RDL.type_cast(v, 'RDL::Type::FiniteHashType', force: true).elts.each { |k1, v1|
            typs = typs + [RDL::Type::SingletonType.new(k1)] unless v1.is_a?(RDL::Type::FiniteHashType) ## potentially two dimensions in joined table
          }
        else
          typs = typs + [RDL::Type::SingletonType.new(k)]
        end
      }
      return RDL::Type::OptionalType.new(RDL::Type::UnionType.new(*typs))
    end
    RDL.type DBType, 'self.count_input', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::OptionalType", wrap: false, typecheck: :type_code


  def self.each_block_arg(trec)
    case trec.params[0]
    when RDL::Type::GenericType
      raise "Expected JoinTable" unless trec.params[0].base.klass == JoinTable
      return trec.params[0].params[0]
    else
      return trec.params[0]
    end
  end

  def self.each_no_block_ret(trec)
    RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), each_block_arg(trec))
  end
    
end

