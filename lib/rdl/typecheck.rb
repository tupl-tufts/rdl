class RDL::Typecheck

  class StaticTypeError < StandardError; end

  def self.typecheck(klass, meth)
    c = RDL::Util.to_class(klass)
    m = c.instance_method(meth)
    file, line = m.source_location

    ast = nil
    if $__rdl_ruby_parser_cache.has_key? file
      old_digest, old_ast = $__rdl_ruby_parser_cache[file]
      new_digest = Digest::MD5.file file
      if old_digest == new_digest
        ast = old_ast
      else
        ast = Parser::CurrentRuby.parse_file file
        $__rdl_ruby_parser_cache[file] = [new_digest, ast]
      end
    else
      digest = Digest::MD5.file file
      ast = Parser::CurrentRuby.parse_file file
      $__rdl_ruby_parser_cache[file] = [digest, ast]
    end
  end

end
