class SequelDB
  extend RDL::Annotate

  type 'self.[]', '(Symbol) -> ``gen_output_type(targs[0])``', wrap: false
  type '[]', '(Symbol) -> ``gen_output_type(targs[0])``', wrap: false
  type :transaction, "() { () -> %any } -> self", wrap: false


  type RDL::Globals, 'self.seq_db_schema', "()-> Hash<Symbol, RDL::Type::FiniteHashType>", wrap: false, effect: [:+, :+]

  def self.gen_output_type(targ)
    case targ
    when RDL::Type::SingletonType
      t = RDL::Globals.seq_db_schema[RDL.type_cast(targ.val, "Symbol", force: true)]
      raise "no schema for table #{targ}" if t.nil?
      new_t = t.elts.clone.merge({__selected: RDL::Globals.types[:nil], __last_joined: targ, __all_joined: targ, __orm: RDL::Globals.types[:false] })
      new_fht = RDL::Type::FiniteHashType.new(new_t, nil)
      return RDL::Type::GenericType.new(RDL::Type::NominalType.new(Table), new_fht)
    else
      raise "unexpected type"
    end
  end

  RDL.type SequelDB, 'self.gen_output_type', "(RDL::Type::Type) -> RDL::Type::GenericType", typecheck: :type_code, wrap: false, effect: [:+, :+]
end

module Sequel::Mysql2; end

class Sequel::Mysql2::Database
  extend RDL::Annotate
  ## This class is identical to SequelDB (above), except its name.
  ## Necessary to support different apps.

  type 'self.[]', '(Symbol) -> ``gen_output_type(targs[0])``', wrap: false
  type '[]', '(Symbol) -> ``gen_output_type(targs[0])``', wrap: false
  type :transaction, "() { () -> %any } -> self", wrap: false


  type RDL::Globals, 'self.seq_db_schema', "()-> Hash<Symbol, RDL::Type::FiniteHashType>", wrap: false, effect: [:+, :+]

  def self.gen_output_type(targ)
    case targ
    when RDL::Type::SingletonType
      t = RDL::Globals.seq_db_schema[RDL.type_cast(targ.val, "Symbol", force: true)]
      raise "no schema for table #{targ}" if t.nil?
      new_t = t.elts.clone.merge({__selected: RDL::Globals.types[:nil], __last_joined: targ, __all_joined: targ, __orm: RDL::Globals.types[:false] })
      new_fht = RDL::Type::FiniteHashType.new(new_t, nil)
      return RDL::Type::GenericType.new(RDL::Type::NominalType.new(Table), new_fht)
    else
      raise "unexpected type #{targ.class}"
    end
  end
  RDL.type Sequel::Mysql2::Database, 'self.gen_output_type', "(RDL::Type::Type) -> RDL::Type::GenericType", typecheck: :type_code, wrap: false, effect: [:+, :+]

end


module Sequel
  extend RDL::Annotate

  type 'self.sqlite', '() -> DBVal', wrap: false

  type 'self.[]', '(Symbol) -> ``gen_output_type(targs[0])``', wrap: false
  type 'self.qualify', '(Symbol, Symbol) -> ``qualify_output_type(targs)``', wrap: false

  def self.gen_output_type(targ)
    case targ
    when RDL::Type::SingletonType
      RDL::Type::GenericType.new(RDL::Type::NominalType.new(SeqIdent), targ)
    else
      raise "unexpected type"
    end
  end
  RDL.type Sequel, 'self.gen_output_type', "(RDL::Type::Type) -> RDL::Type::GenericType", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.qualify_output_type(targs)
    raise "unexpected types" unless targs.all? { |a| a.is_a?(RDL::Type::SingletonType) }
    RDL::Type::GenericType.new(RDL::Type::NominalType.new(SeqQualIdent), targs[0], targs[1])
  end
  RDL.type Sequel, 'self.qualify_output_type', "(Array<RDL::Type::Type>) -> RDL::Type::GenericType", typecheck: :type_code, wrap: false, effect: [:+, :+]
end
class SeqIdent
  extend RDL::Annotate
  type_params [:t], :all?
  type :[], '(Symbol) -> ``gen_output_type(trec, targs[0])``', wrap: false

  def self.gen_output_type(trec, targ)
    case trec
    when RDL::Type::GenericType
      param = trec.params[0]
      case targ
      when RDL::Type::SingletonType
        return RDL::Type::GenericType.new(RDL::Type::NominalType.new(SeqQualIdent), param, targ)
      else
        raise "expected singleton"
      end
    else
      raise "unexpected trec type"
    end
  end
  RDL.type SeqIdent, 'self.gen_output_type', "(RDL::Type::Type, RDL::Type::Type) -> RDL::Type::GenericType", typecheck: :type_code, wrap: false, effect: [:+, :+]

end

class SeqQualIdent
  extend RDL::Annotate
  type_params [:table, :column], :all?

end

class Table
  extend RDL::Annotate
  type_params [:t], :all?

  type :join, "(Symbol, %any) -> ``join_ret_type(trec, targs)``", wrap: false
  type :join, "(Symbol, %any, %any) -> ``join_ret_type(trec, targs)``", wrap: false

  RDL.rdl_alias :Table, :inner_join, :join
  RDL.rdl_alias :Table, :left_join, :join
  RDL.rdl_alias :Table, :left_outer_join, :join

  def self.get_schema(hash)
    hash.select { |key, val| ![:__last_joined, :__all_joined, :__selected, :__orm].member?(key) }
  end
  RDL.type Table, 'self.get_schema', "(Hash<%any, RDL::Type::Type>) -> Hash<%any, RDL::Type::Type>", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.get_all_joined(t)
    case t
    when RDL::Type::SingletonType
      sing = RDL.type_cast(t, "RDL::Type::SingletonType<Symbol>", force: true)
      raise "unexpected type #{t} in __all_joined clause" unless sing.val.is_a?(Symbol)
      return [sing.val]
    when RDL::Type::UnionType
      all = t.types.map { |subt|
        raise "unexpected type #{subt} in union type within __all_joined clause" unless subt.is_a?(RDL::Type::SingletonType) && RDL.type_cast(subt, "RDL::Type::SingletonType<Symbol>", force: true).val.is_a?(Symbol)
        RDL.type_cast(subt, "RDL::Type::SingletonType<Symbol>", force: true).val
      }
      return all
    when nil
      return RDL.type_cast([], "Array<Symbol>", force: true)
    else
      raise "unexpected type #{t} in __all_joined clause"
    end
  end
  RDL.type Table, 'self.get_all_joined', "(RDL::Type::Type) -> Array<Symbol>", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.join_ret_type(trec, targs)
    raise RDL::Typecheck::StaticTypeError, "Unexpected number of arguments to `join`." unless targs.size == 2
    targ1, targ2 = *targs
    raise RDL::Typecheck::StaticTypeError, "Unexpected second argument type #{targ2} to `join`." unless targ2.is_a?(RDL::Type::FiniteHashType)
    arg_join_column = RDL.type_cast(RDL.type_cast(targ2, "RDL::Type::FiniteHashType").elts.keys[0], "Symbol", force: true) ## column name of arg table which is joined on
    rec_join_column = RDL.type_cast(RDL.type_cast(targ2, "RDL::Type::FiniteHashType").elts[arg_join_column], "Symbol", force: true) ## column name of receiver table which is joined on
    case trec
    when RDL::Type::GenericType
      raise RDL::Typecheck::StaticTypeError, "unexpceted generic type in call to join" unless trec.base.name == "Table"
      receiver_param = RDL.type_cast(trec.params[0], "RDL::Type::FiniteHashType", force: true).elts
      receiver_schema = get_schema(receiver_param)
      join_source_schema = get_schema(RDL::Globals.seq_db_schema[RDL.type_cast(receiver_param[:__last_joined], "RDL::Type::SingletonType<Symbol>", force: true).val].elts)
      rec_all_joined = get_all_joined(receiver_param[:__all_joined])

      case rec_join_column
      when RDL::Type::SingletonType
        ## given symbol for second column to join on
        if rec_join_column.to_s.include?("__")
          ## qualified column name in old versions of sequel.
          check_qual_column(rec_join_column, rec_all_joined)
        else
          raise RDL::Typecheck::StaticTypeError, "No column #{rec_join_column} for receiver in call to `join`." if join_source_schema[rec_join_column.val].nil?
        end
      when RDL::Type::GenericType
      ## given qualified column, e.g. Sequel[:people][:name]
        raise RDL::Typecheck::StaticTypeError, "unexpected generic type #{rec_join_column}" unless rec_join_column.base.name == "SeqQualIdent"
        qual_table, qual_column = rec_join_column.params.map { |t| t.val }
        raise RDL::Typecheck::StaticTypeError, "qualified table #{qual_table} is not joined in receiver table, and so its columns cannot be joined on" unless rec_all_joined.include?(qual_table)
        qual_table_schema = get_schema(RDL::Globals.seq_db_schema[qual_table].elts)
        raise RDL::Typecheck::StaticTypeError, "No column #{qual_column} in table #{qual_table}." if qual_table_schema[qual_column].nil?
      else
        raise "Unexpected column #{rec_join_column} to join on"
      end
      case targ1
      when RDL::Type::SingletonType
        val = RDL.type_cast(targ1.val, "Symbol", force: true)
        raise RDL::Typecheck::StaticTypeError, "Expected Symbol for first argument to `join`." unless val.is_a?(Symbol)
        table_name = val
        table_schema = RDL::Globals.seq_db_schema[table_name]
        raise "No schema found for table #{table_name}." unless table_schema
        arg_schema = get_schema(table_schema.elts)  ## look up table schema for argument
        raise RDL::Typecheck::StaticTypeError, "No column #{arg_join_column} for arg in call to `join`." if arg_schema[arg_join_column].nil?
        result_schema = receiver_schema.merge(arg_schema).merge({ __all_joined: RDL::Type::UnionType.new(*[receiver_param[:__all_joined], targ1]), __last_joined: targ1, __selected: receiver_param[:__selected], __orm: receiver_param[:__orm] })  ## resulting schema as hash
        result_fht = RDL::Type::FiniteHashType.new(result_schema, nil) ## resulting schema as FiniteHashType

        return RDL::Type::GenericType.new(trec.base, result_fht)
      when RDL::Type::NominalType
      ## TODO: this will catch case that first argument is a non-singleton Symbol
        raise "not implemented, likely not needed in practice"
      else
        raise RDL::Typecheck::StaticTypeError, "Unexpected type of first argument to `join`."
      end
    when RDL::Type::NominalType
      raise RDL::Typecheck::StaticTypeError unless trec.name == "Table"
    else
      raise RDL::Typecheck::StaticTypeError, "Unexpected receiver type in call to `join`."
    end
  end
  RDL.type Table, 'self.join_ret_type', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]


  type :insert, "(``insert_arg_type(trec, targs)``) -> Integer", wrap: false
  type :insert, "(``insert_arg_type(trec, targs, true)``, %any) -> Integer", wrap: false
  type :where, "(``where_arg_type(trec, targs)``) -> self", wrap: false
  type :where, "(``where_arg_type(trec, targs, true)``, %any) -> self", wrap: false
  type :exclude, "(``where_arg_type(trec, targs)``) -> self", wrap: false
  type :exclude, "(``where_arg_type(trec, targs, true)``, %any) -> self", wrap: false
  type :[], "(``where_arg_type(trec, targs)``) -> ``first_output(trec)``", wrap: false
  type :first, "() -> ``first_output(trec)``", wrap: false
  type :first, "(``if targs[0] then where_arg_type(trec, targs) else RDL::Globals.types[:bot] end``) -> ``first_output(trec)``", wrap: false
  type :get, '(``get_input(trec)``) -> ``get_output(trec, targs)``', wrap: false
  type :order, '(``order_input(trec, targs)``) -> self', wrap: false
  type Sequel, 'self.desc', '(%any) -> ``targs[0]``', wrap: false ## args will ultimately be checked by `order`
  type :select_map, '(Symbol) -> ``select_map_output(trec, targs, :select_map)``', wrap: false
  type :pluck, '(Symbol) -> ``select_map_output(trec, targs, :select_map)``', wrap: false
  type :any?, "() -> %bool", wrap: false
  type :select, "(*%any) -> ``select_map_output(trec, targs, :select)``", wrap: false
  type :all, "() -> ``all_output(trec)``", wrap: false
  type Sequel, 'self.lit', "(%any) -> String", wrap: false
  type :server, "(Symbol) -> self", wrap: false
  type :empty?, '() -> %bool', wrap: false
  type :update, "(``insert_arg_type(trec, targs)``) -> Integer", wrap: false
  type :count, "() -> Integer", wrap: false
  type :map, "() { (``map_block_input(trec)``) -> x } -> Array<x>", wrap: false
  type :each, "() { (``map_block_input(trec)``) -> x } -> self", wrap: false
  type :import, "(``import_arg_type(trec, targs)``, Array<u>) -> Array<String>", wrap: false

  def self.order_input(trec, targs)
    case trec
    when RDL::Type::GenericType
      trp0 = RDL.type_cast(trec.params[0], "RDL::Type::FiniteHashType", force: true)
      sym_keys = get_schema(trp0.elts).keys
      all_joined = get_all_joined(trp0.elts[:__all_joined])
      targs.each { |a|
        case a
        when RDL::Type::SingletonType
          return RDL::Globals.types[:bot] unless sym_keys.include?(a.val)
        when RDL::Type::GenericType
          return RDL::Globals.types[:bot] unless a.base.name == "SeqQualIdent"
          check_qual_column(a, all_joined)
        end
      }
      return RDL::Type::VarargType.new(RDL::Type::UnionType.new(*targs))
    else
      raise "unexpected type #{trec}"
    end
  end
  RDL.type Table, 'self.order_input', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.map_block_input(trec)
    schema = get_schema(RDL.type_cast(trec.params[0], "RDL::Type::FiniteHashType", force: true).elts)
    RDL::Type::FiniteHashType.new(schema, nil)
  end
  RDL.type Table, 'self.map_block_input', "(RDL::Type::GenericType) -> RDL::Type::FiniteHashType", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.all_output(trec)
    f = first_output(trec)
    if f.is_a?(RDL::Type::FiniteHashType)
      trp0 = RDL.type_cast(RDL.type_cast(trec, "RDL::Type::GenericType").params[0], "RDL::Type::FiniteHashType", force: true)
      selected = trp0.elts[:__selected]
      all_joined = get_all_joined(trp0.elts[:__all_joined])
      if !(selected == RDL::Globals.types[:nil])
        ## something is selected
        sel_arr = RDL.type_cast(selected.is_a?(RDL::Type::UnionType) ? RDL.type_cast(selected, "RDL::Type::UnionType").types : [selected], "Array<RDL::Type::SingletonType<Symbol>>", force: true)
        new_hash = Hash[sel_arr.map { |sel|
          if sel.val.to_s.include?("__")
            t = check_qual_column(sel.val, all_joined)
            _, col_name = sel.val.to_s.split "__"
            col_name = col_name.to_sym
            [col_name, t]
          else
            raise "no selected column found" unless (t = RDL.type_cast(f, "RDL::Type::FiniteHashType", force: true).elts[sel.val])
            [sel.val, t]
          end
        }]
        new_hash_type = RDL::Type::FiniteHashType.new(RDL.type_cast(new_hash, "Hash<%any, RDL::Type::Type>", force: true), nil)
        return RDL::Type::GenericType.new(RDL::Globals.types[:array], new_hash_type)
      else
        return RDL::Type::GenericType.new(RDL::Globals.types[:array], f)
      end
    else
      return RDL::Type::GenericType.new(RDL::Globals.types[:array], f)
    end
  end
  RDL.type Table, 'self.all_output', "(RDL::Type::Type) -> RDL::Type::GenericType", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.select_map_output(trec, targs, meth)
    case trec
    when RDL::Type::GenericType
      raise RDL::Typecheck::StaticTypeError, 'unexpected type' unless trec.base.name == "Table"
      receiver_param = RDL.type_cast(trec.params[0], "RDL::Type::FiniteHashType", force: true).elts
      all_joined = get_all_joined(receiver_param[:__all_joined])

      map_types = targs.map { |arg|
        case arg
        when RDL::Type::SingletonType
          column = RDL.type_cast(arg.val, "Symbol", force: true)
          raise "unexpected arg type #{arg}" unless column.is_a?(Symbol)
          raise "Ambiguous column identifier #{arg}." unless unique_ids?([column], receiver_param[:__all_joined])
          if column.to_s.include?("__")
            check_qual_column(column, all_joined)
          else
            raise "No column #{column} in receiver table." unless receiver_param[column]
            receiver_param[column]
          end
        when RDL::Type::GenericType
          raise "unexpected arg type #{arg}" unless arg.base.name == "SeqQualIdent"
          check_qual_column(arg, all_joined)
        else
          raise "unexpected arg type #{arg}"
        end
      }

      targs.each { |arg|
        case arg
        when RDL::Type::SingletonType
          column = RDL.type_cast(arg.val, "Symbol", force: true)
          raise "unexpected arg type #{arg}" unless column.is_a?(Symbol)
          raise "Ambiguous column identifier #{arg}." unless unique_ids?([column], receiver_param[:__all_joined])
          if column.to_s.include?("__")
            map_types = map_types + [check_qual_column(column, all_joined)]
          else
            raise "No column #{column} in receiver table." unless receiver_param[column]
            map_types = map_types + [receiver_param[column]]
          end
        when RDL::Type::GenericType
          raise "unexpected arg type #{arg}" unless arg.base.name == "SeqQualIdent"
          map_types = map_types + [check_qual_column(arg, all_joined)]
        else
          raise "unexpected arg type #{arg}"
        end
      }
      if meth == :select
        result_schema = receiver_param.clone.merge({ __selected: RDL::Type::UnionType.new(*targs).canonical })
        return RDL::Type::GenericType.new(trec.base, RDL::Type::FiniteHashType.new(result_schema, nil))
      elsif meth == :select_map
        if targs.size >1
          return RDL::Type::GenericType.new(RDL::Globals.types[:array], RDL::Type::TupleType.new(*map_types))
        else
          return RDL::Type::GenericType.new(RDL::Globals.types[:array], map_types[0])
        end
      else
        raise 'unexpected'
      end
    else
      raise 'unexpected type #{trec}'
    end
  end
  RDL.type Table, 'self.select_map_output', "(RDL::Type::Type, Array<RDL::Type::Type>, Symbol) -> RDL::Type::GenericType", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.get_input(trec)
    case trec
    when RDL::Type::GenericType
      sym_keys = get_schema(RDL.type_cast(trec.params[0], "RDL::Type::FiniteHashType", force: true).elts).keys
      RDL::Type::UnionType.new(*RDL.type_cast(sym_keys.map { |k| RDL::Type::SingletonType.new(k) }, "Array<RDL::Type::Type>"))
    else
      raise 'unexpected type #{trec}'
    end
  end
  RDL.type Table, 'self.get_input', "(RDL::Type::Type) -> RDL::Type::UnionType", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.get_output(trec, targs)
    RDL.type_cast(RDL.type_cast(trec, "RDL::Type::GenericType").params[0], "RDL::Type::FiniteHashType", force: true).elts[RDL.type_cast(targs[0], "RDL::Type::SingletonType<Symbol>", force: true).val]
  end
  RDL.type Table, 'self.get_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.first_output(trec)
    case trec
    when RDL::Type::GenericType
      raise RDL::Typecheck::StaticTypeError, 'unexpected type' unless trec.base.name == "Table"
      receiver_param = RDL.type_cast(trec.params[0], "RDL::Type::FiniteHashType", force: true).elts
      if !(receiver_param[:__orm] == RDL::Globals.types[:false])
        receiver_param[:__orm]
      else
        RDL::Type::FiniteHashType.new(get_schema(receiver_param), nil)
      end
    else
      raise 'unexpected type #{trec}'
    end
  end
  RDL.type Table, 'self.first_output', "(RDL::Type::Type) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.insert_arg_type(trec, targs, tuple=false)
    raise "Cannot insert/update for joined table." if RDL.type_cast(RDL.type_cast(trec, "RDL::Type::GenericType").params[0], "RDL::Type::FiniteHashType", force: true).elts[:__all_joined].is_a?(RDL::Type::UnionType)
    if tuple
      schema_arg_tuple_type(trec, targs, :insert)
    else
      schema_arg_type(trec, targs, :insert)
    end
  end
  RDL.type Table, 'self.insert_arg_type', "(RDL::Type::Type, Array<RDL::Type::Type>, ?%bool) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.import_arg_type(trec, targs)
    raise "Cannot import for joined table." if RDL.type_cast(RDL.type_cast(trec, "RDL::Type::GenericType").params[0], "RDL::Type::FiniteHashType", force: true).elts[:__all_joined].is_a?(RDL::Type::UnionType)
    raise "Expected tuple for first arg to `import`, got #{targs[0]} instead." unless targs[0].is_a?(RDL::Type::TupleType)
    arg1 = targs[1]
    case arg1
    when RDL::Type::TupleType
      arg1.params.each { |t| schema_arg_tuple_type(trec, [targs[0], t], :import) } ## check each individual tuple inside second arg tuple
    when RDL::Type::GenericType
      raise "expected Array, got #{arg1}" unless (arg1.base == RDL::Globals.types[:array])
      raise "`import` type not yet implemented for type #{arg1}" unless arg1.params[0].is_a?(RDL::Type::TupleType)
      schema_arg_tuple_type(trec, [targs[0], arg1.params[0]], :import)
    else
      raise "Not yet implemented for type #{arg1}."
    end
    return targs[0]
  end
  RDL.type Table, 'self.import_arg_type', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.get_nominal_where_type(type)
    ## `where` can accept arrays/tuples and tables with a single column selected
    ## this method just extracts the parameter type
    case type
    when RDL::Type::GenericType
      if type.base == RDL::Globals.types[:array]
        type.params[0]
      elsif type.base == RDL::Type::NominalType.new(Table)
        schema = RDL.type_cast(type.params[0], "RDL::Type::FiniteHashType", force: true).elts
        sel = schema[:__selected]
        raise "Call to where expects table with a single column selected, got #{type}" unless sel.is_a?(RDL::Type::SingletonType)
        nominal = schema[RDL.type_cast(sel, "RDL::Type::SingletonType", force: true).val]
        raise "No type found for column #{sel} in call to `where`." unless nominal
        nominal
      else
        type
      end
    when RDL::Type::TupleType
      type = type.promote.params[0]
      raise "`where` passed tuple containing different types." if type.is_a?(RDL::Type::UnionType)
      type
    else
      type
    end
  end

  RDL.type Table, 'self.get_nominal_where_type', "(RDL::Type::Type) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.schema_arg_type(trec, targs, meth)
    return RDL::Type::NominalType.new(Hash) if targs.size != 1
    case trec
    when RDL::Type::GenericType
      raise RDL::Typecheck::StaticTypeError, 'unexpected type' unless trec.base.name == "Table"
      receiver_param = RDL.type_cast(trec.params[0], "RDL::Type::FiniteHashType", force: true).elts
      receiver_schema = get_schema(receiver_param)
      all_joined = get_all_joined(receiver_param[:__all_joined])
      arg0 = targs[0]
      case arg0
      when RDL::Type::FiniteHashType
        insert_hash = arg0.elts
        insert_hash.each { |column_name, type|
          cn = RDL.type_cast(column_name, "Symbol", force: true)
          if cn.to_s.include?("__") && (meth == :where)
            check_qual_column(cn, all_joined, type)
          else
            raise RDL::Typecheck::StaticTypeError, "No column #{column_name} for receiver #{trec}." unless receiver_schema.has_key?(cn)
            type = get_nominal_where_type(type) if (meth == :where)
            raise RDL::Typecheck::StaticTypeError, "Incompatible column types #{type} and #{receiver_schema[column_name]} for column #{cn} in call to #{meth}." unless RDL::Type::Type.leq(type, receiver_schema[cn])
          end
        }
        return arg0
      else
        return arg0 if (meth==:where) && targs[0] <= RDL::Globals.types[:string]
        raise "TODO WITH #{trec} AND #{targs} AND #{meth}"
      end
    when RDL::Type::NominalType
    ##TODO
    else

    end
  end
  RDL.type Table, 'self.schema_arg_type', "(RDL::Type::Type, Array<RDL::Type::Type>, Symbol) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

  ## [+ column_name +] if a symbol or SeqQualIdent Generic type of the qualified column name, e.g. :person__age
  ## [+ all_joined +] is an array of symbols of joined tables (must check if qualifying table is a member)
  ## [+ type +] is optional RDL type. If given, we check that it matches the type of the column in the schema.
  ## returns type of given column
  def self.check_qual_column(column_name, all_joined, type=nil)
    case column_name
    when RDL::Type::GenericType
      cn = RDL.type_cast(column_name, "RDL::Type::GenericType", force: true)
      raise "Expected qualified column type." unless cn.base.name == "SeqQualIdent"
      qual_table, qual_column = cn.params.map { |t| RDL.type_cast(t, "RDL::Type::SingletonType<Symbol>", force: true).val }
    else
      ## symbol with name including underscores
      qual_table, qual_column = RDL.type_cast(column_name, "Symbol", force: true).to_s.split "__"
      qual_table = if qual_table.start_with?(":") then qual_table[1..-1].to_sym else qual_table.to_sym end
      qual_column = qual_column.to_sym
    end
    raise RDL::Typecheck::StaticTypeError, "qualified table #{qual_table} is not joined in receiver table, cannot reference its columns" unless all_joined.include?(qual_table)
    qual_table_schema = get_schema(RDL::Globals.seq_db_schema[qual_table].elts)
    raise RDL::Typecheck::StaticTypeError, "No column #{qual_column} in table #{qual_table}." if qual_table_schema[qual_column].nil?
    if type
      types = (if type.is_a?(RDL::Type::UnionType) then RDL.type_cast(type, "RDL::Type::UnionType", force: true).types else [type] end)
      types.each { |t|
        t = RDL.type_cast(t, "RDL::Type::GenericType", force: true).params[0] if t.is_a?(RDL::Type::GenericType) && (RDL.type_cast(t, "RDL::Type::GenericType", force: true).base == RDL::Globals.types[:array]) ## only happens if meth is where, don't need to check
        raise RDL::Typecheck::StaticTypeError, "Incompatible column types. Given #{t} but expected #{qual_table_schema[qual_column]} for column #{column_name}." unless RDL::Type::Type.leq(t, qual_table_schema[qual_column])
      }
    end
    return qual_table_schema[qual_column]
  end
  RDL.type Table, 'self.check_qual_column', "(Symbol or RDL::Type::GenericType, Array<Symbol>, ?RDL::Type::Type) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.schema_arg_tuple_type(trec, targs, meth)
    return RDL::Type::NominalType.new(Array) if targs.size != 2
    case trec
    when RDL::Type::GenericType
      raise RDL::Typecheck::StaticTypeError, 'unexpected type' unless trec.base.name == "Table"
      receiver_param = RDL.type_cast(trec.params[0], "RDL::Type::FiniteHashType", force: true).elts
      all_joined = get_all_joined(receiver_param[:__all_joined])
      receiver_schema = get_schema(receiver_param)
      if targs[0].is_a?(RDL::Type::TupleType) && targs[1].is_a?(RDL::Type::TupleType)
        RDL.type_cast(targs[0], "RDL::Type::TupleType", force: true).params.each_with_index { |column_name, i|
          cn = RDL.type_cast(column_name, "RDL::Type::SingletonType<Symbol>", force: true)
          raise "Expected singleton symbol in call to insert, got #{column_name}" unless cn.is_a?(RDL::Type::SingletonType) && cn.val.is_a?(Symbol)
          type = RDL.type_cast(targs[1], "RDL::Type::TupleType", force: true).params[i]
          if cn.val.to_s.include?("__") && (meth == :where)
            check_qual_column(cn.val, all_joined, type)
          else
            raise RDL::Typecheck::StaticTypeError, "No column #{column_name} for receiver in call to `insert`." unless receiver_schema.has_key?(cn.val)
            type = get_nominal_where_type(type) if (meth == :where)
            raise RDL::Typecheck::StaticTypeError, "Incompatible column types." unless RDL::Type::Type.leq(type, receiver_schema[cn.val])
          end
        }
        return targs[0]
      else
        raise "not yet implemented for types #{targs[0]} and #{targs[1]}"
      end
    else
      raise 'not yet implemented'
    end
  end
  RDL.type Table, 'self.schema_arg_tuple_type', "(RDL::Type::Type, Array<RDL::Type::Type>, Symbol) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.where_arg_type(trec, targs, tuple=false)
    trp0 = RDL.type_cast(RDL.type_cast(trec, "RDL::Type::GenericType").params[0], "RDL::Type::FiniteHashType", force: true)
    if trp0.elts[:__all_joined].is_a?(RDL::Type::UnionType)
      arg0 = targs[0]
      case arg0
      when RDL::Type::TupleType
        raise "Unexpected column type." unless arg0.params.all? { |t| t.is_a?(RDL::Type::SingletonType) && RDL.type_cast(t, "RDL::Type::SingletonType<Object>", force: true).val.is_a?(Symbol) }
        raise "Ambigious identifier in call to where." unless unique_ids?(arg0.params.map { |t| RDL.type_cast(t, "RDL::Type::SingletonType<Symbol>", force: true).val }, trp0.elts[:__all_joined])
      when RDL::Type::FiniteHashType
        raise "Ambigious identifier in call to where." unless unique_ids?(RDL.type_cast(arg0.elts.keys, "Array<Symbol>", force: true), trp0.elts[:__all_joined])
      else
        raise "unexpected arg type #{arg0}"
      end
    end
    if tuple
      schema_arg_tuple_type(trec, targs, :where)
    else
      schema_arg_type(trec, targs, :where)
    end
  end
  RDL.type Table, 'self.where_arg_type', "(RDL::Type::Type, Array<RDL::Type::Type>, ?%bool) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

  def self.unique_ids?(ids, joined)
    j = get_all_joined(joined)
    count = Hash[ids.map { |id| [id, 0] }]

    j.each { |t1|
      schema1 = RDL::Globals.seq_db_schema[t1]
      raise "schema not found" unless schema1
      j.each { |t2|
        schema2 = RDL::Globals.seq_db_schema[t2]
        ids.each { |id|
          return false if schema1.elts.has_key?(id) && schema2.elts.has_key?(id) && (t1 != t2)
        }
      }
    }
    return true
  end
  RDL.type Table, 'self.unique_ids?', "(Array<Symbol>, RDL::Type::Type) -> %bool", typecheck: :type_code, wrap: false, effect: [:+, :+]

end
