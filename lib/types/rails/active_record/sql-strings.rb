require 'sql-parser'

# Mocking the SQLVistor internal class behavior to do our own stuff
class ASTVisitor
  def initialize(table, targs)
    @table = table # default table name, if we don't have a qualified column name
    @targs = targs
  end

  def visit(node)
    node.accept(self)
  end

  def binary_op(o)
    table, column = visit(o.left)
    ident = visit(o.right)
    query_type = @targs[ident] || @targs.last
    schema_type = RDL::Globals.ar_db_schema[table.classify.to_sym].params[0].elts[column.to_sym]
    query_type = query_type.elts[column.to_sym] if query_type.is_a? RDL::Type::FiniteHashType
    # puts query_type, schema_type
    raise RDL::Typecheck::StaticTypeError, "type error" unless query_type <= schema_type
  end

  alias_method :visit_Greater, :binary_op
  alias_method :visit_Equals, :binary_op
  alias_method :visit_Less, :binary_op
  alias_method :visit_GreaterOrEquals, :binary_op

  def visit_And(o)
    visit(o.left)
    visit(o.right)
  end

  def visit_Subquery(o)
    raise RDL::Typecheck::StaticTypeError, "only works with SELECT queries now" unless o.query_specification.is_a? SQLParser::Statement::Select
    select_query = o.query_specification
    raise RDL::Typecheck::StaticTypeError, "expected only 1 column in SELECT sub queries" unless select_query.list.is_a? SQLParser::Statement::SelectList and select_query.list.columns.length == 1
    column = select_query.list.columns[0].name
    table = select_query.table_expression.from_clause.tables[0].name
    visitor = ASTVisitor.new table, @targs
    search_cond = select_query.table_expression.where_clause.search_condition
    visitor.visit(search_cond)
    RDL::Type::GenericType.new(RDL::Type::NominalType.new(Array), RDL::Globals.ar_db_schema[table.classify.to_sym].params[0].elts[column.to_sym])
  end

  def visit_In(o)
    table, column = visit(o.left)
    ident = visit(o.right)
    # TODO: add a case where ident is an integer and targs doesn't have named params, but just ?-ed params
    if ident.is_a? Integer and @targs.last.is_a? RDL::Type::FiniteHashType
      # query_params is a finite hash
      query_params = @targs.last.elts
      # this is a hack, assumes keys are in order, which isn't necessarily true
      query_type = query_params[query_params.keys[ident - 1]]
    elsif ident.is_a? RDL::Type::GenericType
      query_type = ident
    else
      # puts "(TODO) Unexpected"
    end

    schema_type = RDL::Globals.ar_db_schema[table.classify.to_sym].params[0].elts[column.to_sym]
    # IN works with arrays
    promoted = if query_type.is_a?(RDL::Type::TupleType) then query_type.promote else query_type end
    if promoted.is_a? RDL::Type::GenericType
      # base type is Array, maybe add check?
      raise RDL::Typecheck::StaticTypeError, "type error" unless promoted.params[0] <= schema_type
    else
      raise RDL::Typecheck::StaticTypeError, "some other type after promotion"
    end
  end

  def visit_Not(o)
    visit(o.value)
  end

  def visit_Integer(o)
    return o.value
  end

  def visit_QualifiedColumn(o)
    [o.table.name, o.column.name]
  end

  def visit_Column(o)
    [@table, o.name]
  end

  def visit_InValueList(o)
    o.values.value
  end
end

def handle_sql_strings(trec, targs)
  parser = SQLParser::Parser.new

  case trec
  when RDL::Type::GenericType
    if trec.base.klass == ActiveRecord_Relation
      handle_sql_strings trec.params[0], targs
    elsif trec.base.klass == JoinTable
      # works only for the base class right now, need to extend for the params as well
      base_klass = trec.params[0]
      joined_with = trec.params[1]
      case joined_with
      when RDL::Type::UnionType
        joined_with.types.each do |klass|
          # add the joining association column on this
          sql_query = "SELECT * FROM `#{base_klass.name.tableize}` INNER JOIN `#{klass.name.tableize}` ON a.id = b.a_id WHERE #{build_string_from_precise_string(targs)}"
          # puts sql_query
          begin
            ast = parser.scan_str(sql_query)
          rescue Racc::ParseError => e
            # puts "There was a parse error with above query, moving on"
            return
          end
          search_cond = ast.query_expression.table_expression.where_clause.search_condition
          visitor = ASTVisitor.new base_klass.name.tableize, targs
          visitor.visit(search_cond)
        end
      else
        # TODO
        # puts "== TODO =="
      end
    else
      # puts "UNEXPECTED #{trec}, #{targs}"
    end
  when RDL::Type::NominalType
    base_klass = trec
    sql_query = "SELECT * FROM `#{base_klass.name.tableize}` WHERE #{build_string_from_precise_string(targs)}"
    # puts sql_query
    ast = parser.scan_str(sql_query)
    search_cond = ast.query_expression.table_expression.where_clause.search_condition
    visitor = ASTVisitor.new base_klass.name.tableize, targs
    visitor.visit(search_cond)
  when RDL::Type::SingletonType
    base_klass = trec
    sql_query = "SELECT * FROM `#{base_klass.val.to_s.tableize}` WHERE #{build_string_from_precise_string(targs)}"
    # puts sql_query
    ast = parser.scan_str(sql_query)
    search_cond = ast.query_expression.table_expression.where_clause.search_condition
    visitor = ASTVisitor.new base_klass.val.to_s.tableize, targs
    visitor.visit(search_cond)
  else
    # puts "UNEXPECTED #{trec}, #{targs}"
  end
end

def build_string_from_precise_string(args)
  str = args[0]
  raise "Bad type!" unless str.is_a? RDL::Type::PreciseStringType
  # TODO: handles only non-interpolated strings for now
  base_query = str.vals[0]

  # Get rid of SQL functions here, that just ends up confusing the parser anyway
  base_query.gsub!('LOWER(', '(')

  counter = 1
  if args[1].is_a? RDL::Type::FiniteHashType
    # the query has named params
    args[1].elts.keys.each { |k| base_query.gsub!(":#{k}", counter.to_s); counter += 1 }
  else
    # the query has ? symbols
    args[1..-1].each { |t| base_query.sub!('?', counter.to_s); counter += 1}
  end
  base_query
end
