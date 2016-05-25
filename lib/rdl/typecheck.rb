module RDL::Typecheck

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
      self_type = RDL::Type::NominalType.new(klass)
      inst = {self: self_type}
      type = type.instantiate inst
      a = args.children.map { |arg| arg.children[0] }.zip(type.args).to_h
      a[:self] = self_type
      _, body_type = tc(Hash.new, a, body)
      error :bad_return_type, [body_type.to_s, type.ret.to_s], body unless body_type <= type.ret
    }
  end

  # The actual type checking logic.
  # [+ env +] is the current environemnt excluding local variables
  # [+ a +] is the (local variable) type environment mapping variables (symbols) to types
  # [+ e +] is the expression to type check
  # Returns [a', t], where a' is the type environment at the end of the expression
  # and t is the type of the expression
  def self.tc(env, a, e)
    case e.type
    when :nil
      [a, RDL::Type::NilType.new]
    when :true
      [a, RDL::Type::NominalType.new(TrueClass)]
    when :false
      [a, RDL::Type::NominalType.new(FalseClass)]
    when :complex, :rational, :str, :string # constants
      puts "True!" if e.type == :true
      [a, RDL::Type::NominalType.new(e.children[0].class)]
    when :int, :float, :sym # singletons
      [a, RDL::Type::SingletonType.new(e.children[0])]
    when :dstr, :xstr # string (or execute-string) with interpolation
      ai = a
      e.children.each { |ei| ai, _ = tc(env, ai, ei) }
      [ai, RDL::Type::NominalType.new(String)]
    when :dsym # symbol with interpolation
      ai = a
      e.children.each { |ei| ai, _ = tc(env, ai, ei) }
      [ai, RDL::Type::NominalType.new(Symbol)]
#    when :regexp # TODO! Options a bit complex
    when :array
      ai = a
      tis = []
      e.children.each { |ei| ai, ti = tc(env, ai, ei); tis << ti }
      [a, RDL::Type::TupleType.new(*tis)]
#    when :splat # TODO!
#    when :hash # TODO!
#    when :kwsplat # TODO!
    when :irange, :erange
      a1, t1 = tc(env, a, e.children[0])
      a2, t2 = tc(env, a1, e.children[1])
      # promote singleton types to nominal types; safe since Ranges are immutable
      t1 = RDL::Type::NominalType.new(t1.val.class) if t1.is_a? RDL::Type::SingletonType
      t2 = RDL::Type::NominalType.new(t2.val.class) if t2.is_a? RDL::Type::SingletonType
      error :nonmatching_range_type, [t1, t2], e if t1 != t2
      [a2, RDL::Type::GenericType.new(RDL::Type::NominalType.new(Range), t1)]
    when :self
      [a, a[:self]]
    when :lvar  # local variable
      [a, a[e.children[0]]]
    # when :ivar # TODO!
    # when :cvar # TODO!
    # when :gvar # TODO!
    when :nth_ref
      [a, RDL::Type::NominalType.new(String)]
    when :begin # sequencing
      ai = a
      ti = nil
      e.children.each { |ei| ai, ti = tc(env, ai, ei) }
      [ai, ti]
    else
      raise RuntimeError, "Expression kind #{e.type} unsupported"
    end
  end

end

# Modify Parser::MESSAGES so can use the awesome parser diagnostics printing!
type_error_messages = {
  bad_return_type: 'Got type %s where return type %s expected',
  nonmatching_range_type: 'Attempt to construct range with non-matching types %s and %s'
}
old_messages = Parser::MESSAGES
Parser.send(:remove_const, :MESSAGES)
Parser.const_set :MESSAGES, (old_messages.merge(type_error_messages))
