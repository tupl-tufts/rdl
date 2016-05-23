class RDL::Typecheck

  class StaticTypeError < StandardError; end

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

  def self.typecheck(klass, meth)
    file, line = RDL::Wrap.get_info(klass, meth, :source_location)
    digest = Digest::MD5.file file
    cache_hit = (($__rdl_ruby_parser_cache.has_key? file) &&
                 ($__rdl_ruby_parser_cache[file][0] == digest))
    unless cache_hit
      ast = Parser::CurrentRuby.parse_file file
      mapper = ASTMapper.new(file)
      mapper.process(ast)
      cache = {ast: ast, line_defs: mapper.line_defs}
      $__rdl_ruby_parser_cache[file] = [digest, cache]
    end

  end

end
