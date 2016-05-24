class RDL::Typecheck

  class StaticTypeError < StandardError; end

  @@type_true = RDL::Type::NominalType.new TrueClass
  @@type_false = RDL::Type::NominalType.new FalseClass
  @@type_string = RDL::Type::NominalType.new String

  class ASTMapper < AST::Processor
    attr_accessor :line_defs

    def initialize(file)
      @file = file
      @line_defs = Hash.new # map from line numbers to defs
    end

    def handler_missing(node)
      node.children.each { |n| process n if n.is_a?(AST::Node) }
    end

    def on_def(node)
      name, _, body = *node
      if @line_defs[node.loc.line]
        raise RuntimeError, "Multiple defs per line (#{name} and #{@line_defs[node.loc.line].children[1]} in #{@file}) currently not allowed"
      end
      @line_defs[node.loc.line] = node
      process body
      node.updated(nil, nil)
    end
  end

  # report msg at ast's loc
  def self.error(reason, args, ast)
    raise StaticTypeError, ("\n" + (Parser::Diagnostic.new :error, reason, args, ast.loc.expression).render.join("\n"))
  end

  def self.typecheck(klass, meth)
    file, line = $__rdl_meths.get(klass, meth, :source_location)
    digest = Digest::MD5.file file
    cache_hit = (($__rdl_ruby_parser_cache.has_key? file) &&
                 ($__rdl_ruby_parser_cache[file][0] == digest))
    unless cache_hit
      file_ast = Parser::CurrentRuby.parse_file file
      mapper = ASTMapper.new(file)
      mapper.process(file_ast)
      cache = {ast: file_ast, line_defs: mapper.line_defs}
      $__rdl_ruby_parser_cache[file] = [digest, cache]
    end
    ast = $__rdl_ruby_parser_cache[file][1][:line_defs][line]
    types = $__rdl_meths.get(klass, meth, :type)
    raise RuntimeError, "Can't typecheck method with no types?!" if types.nil? or types == []

    name, args, body = *ast
    raise RuntimeError, "Method #{name} defined where method #{meth} expected" if name.to_sym != meth
    types.each { |type|
      # TODO will need fancier logic here for matching up more complex arg lists
      a = args.children.map { |arg| arg.children[0] }.zip(type.args).to_h
      _, body_type = tc(a, body)
      error :bad_return_type, [body_type.to_s, type.ret.to_s], body unless body_type <= type.ret
    }
  end

  # The actual type checking logic.
  # [+ a +] is the (local variable) type environment mapping variables (symbols) to types
  # [+ e +] is the expression to type check
  # Returns [a', t], where a' is the type environment at the end of the expression
  # and t is the type of the expression
  def self.tc(a, e)
    case e.type
    when :true
      [a, @@type_true]
    when :false
      [a, @@type_false]
    when :str, :string
      [a, @@type_string]
    when :lvar  # local variable
      [a, a[e.children[0]]]
    else
      raise RuntimeError, "Expression kind #{e.type} unsupported"
    end
  end

end

# Modify Parser::MESSAGES so can use the awesome parser diagnostics printing!
type_error_messages = {
  bad_return_type: 'Got type %s where return type %s expected',
}
old_messages = Parser::MESSAGES
Parser.send(:remove_const, :MESSAGES)
Parser.const_set :MESSAGES, (old_messages.merge(type_error_messages))
