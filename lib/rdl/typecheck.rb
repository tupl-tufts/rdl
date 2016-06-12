module RDL::Typecheck

  class StaticTypeError < StandardError; end

  @@empty_hash_type = RDL::Type::FiniteHashType.new(Hash.new)

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
    raise RuntimeError, "singleton method typechecking not supported yet" if RDL::Util.has_singleton_marker(klass)
    file, line = $__rdl_info.get(klass, meth, :source_location)
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
    types = $__rdl_info.get(klass, meth, :type)
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
      _, body_type = if body.nil? then [nil, $__rdl_nil_type] else tc(Hash.new, a, body) end
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
      [a, $__rdl_nil_type]
    when :true
      [a, $__rdl_true_type]
    when :false
      [a, $__rdl_false_type]
    when :complex, :rational, :str, :string # constants
      puts "True!" if e.type == :true
      [a, RDL::Type::NominalType.new(e.children[0].class)]
    when :int, :float, :sym # singletons
      [a, RDL::Type::SingletonType.new(e.children[0])]
    when :dstr, :xstr # string (or execute-string) with interpolation
      ai = a
      e.children.each { |ei| ai, _ = tc(env, ai, ei) }
      [ai, $__rdl_string_type]
    when :dsym # symbol with interpolation
      ai = a
      e.children.each { |ei| ai, _ = tc(env, ai, ei) }
      [ai, $__rdl_symbol_type]
    when :regexp
      ai = a
      e.children.each { |ei| ai, _ = tc(env, ai, ei) unless ei.type == :regopt }
      [ai, $__rdl_regexp_type]
    when :array
      ai = a
      tis = []
      e.children.each { |ei| ai, ti = tc(env, ai, ei); tis << ti }
      [a, RDL::Type::TupleType.new(*tis)]
#    when :splat # TODO!
    when :hash
      ai = a
      tlefts = []
      trights = []
      is_fh = true
      e.children.each { |p|
        # each child is a pair
        ai, tleft = tc(env, ai, p.children[0])
        tlefts << tleft
        ai, tright = tc(env, ai, p.children[1])
        trights << tright
        is_fh = false unless tleft.is_a?(RDL::Type::SingletonType) && tleft.val.is_a?(Symbol)
      }
      if is_fh
        # keys are all symbols
        fh = tlefts.map { |t| t.val }.zip(trights).to_h
        [ai, RDL::Type::FiniteHashType.new(fh)]
      else
        tleft = RDL::Type::UnionType.new(*tlefts)
        tright = RDL::Type::UnionType.new(*trights)
        [ai, RDL::Type::GenericType.new($__rdl_hash_type, tleft, tright)]
      end
      #TODO test!
#    when :kwsplat # TODO!
    when :irange, :erange
      a1, t1 = tc(env, a, e.children[0])
      a2, t2 = tc(env, a1, e.children[1])
      # promote singleton types to nominal types; safe since Ranges are immutable
      t1 = RDL::Type::NominalType.new(t1.val.class) if t1.is_a? RDL::Type::SingletonType
      t2 = RDL::Type::NominalType.new(t2.val.class) if t2.is_a? RDL::Type::SingletonType
      error :nonmatching_range_type, [t1, t2], e if t1 != t2
      [a2, RDL::Type::GenericType.new($__rdl_range_type, t1)]
    when :self
      [a, a[:self]]
    when :lvar  # local variable
      x = e.children[0] # the variable
      error :undefined_local_or_method, x.to_s, e unless a.has_key? x
      [a, a[x]]
    when :ivar, :cvar, :gvar
      x = e.children[0] # the variable
      klass = (if e.type == :gvar then RDL::Util::GLOBAL_NAME else a[:self] end)
      unless $__rdl_info.has?(klass, x, :type)
        kind = (if e.type == :ivar then "instance"
                elsif e.type == :cvar then "class"
                else "global" end)
        error :untyped_var, [kind, x], e
      end
      [a, $__rdl_info.get(klass, x, :type)]
    when :nth_ref, :back_ref
      [a, $__rdl_string_type]
    when :const
      c = nil
      if e.children[0].nil?
        c = a[:self].klass.const_get(e.children[1])
      elsif e.children[0].type == :cbase
        raise "const cbase not implemented yet" # TODO!
      elsif e.children[0].type == :lvar
        raise "const lvar not implemented yet" # TODO!
      else
        raise "const other not implemented yet"
      end
      case c
      when TrueClass, FalseClass, Complex, Rational, Fixnum, Bignum, Float, Symbol, Class
        [a, RDL::Type::SingletonType.new(c)]
      else
        [a, RDL::Type::NominalType.new(const_get(e.children[1]).class)]
      end
    when :defined?
      # do not type check subexpression, since it may not be type correct, e.g., undefined variable
      [a, $__rdl_string_type]
    when :lvasgn
      x = e.children[0] # the variable
      a1, t1 = tc(env, a, e.children[1])
      [a1.merge(x => t1), t1]
    when :ivasgn, :cvasgn, :gvasgn
      x = e.children[0] # the variable
      aright, tright = tc(env, a, e.children[1])
      klass = (if e.type == :gvasgn then RDL::Util::GLOBAL_NAME else a[:self] end)
      unless $__rdl_info.has?(klass, x, :type)
        kind = (if e.type == :ivasgn then "instance"
                elsif e.type == :cvasgn then "class"
                else "global" end)
        error :untyped_var, [kind, x], e
      end
      tleft = $__rdl_info.get(klass, x, :type)
      error :vasgn_incompat, [tright.to_s, tleft.to_s], e unless tright <= tleft
      [aright, tright]
    when :send, :csend
      # children[0] = receiver; if nil, receiver is self
      # children[1] = method name, a symbol
      # children [2..] = actual args
      ai = a
      tactuals = []
      e.children[2..-1].each { |ei| ai, ti = tc(env, ai, ei); tactuals << ti }
      ai, trecv = if e.children[0].nil? then [ai, ai[:self]] else tc(env, ai, e.children[0]) end # if no receiver, self is receiver

      tmeth_inters = [] # Array<Array<MethodType>>, array of intersection types, since recv might not resolve to a single type

      if (trecv.is_a? RDL::Type::SingletonType) && (trecv.val.is_a? Class) && (e.children[1] == :new)
        t = lookup(RDL::Util.add_singleton_marker(trecv.val.to_s), :initialize)
        t = [RDL::Type::MethodType.new([], nil, RDL::Type::NominalType.new(trecv.val))] unless t # there's always a nullary new if initialize is undefined
        tmeth_inters << t
      elsif trecv.is_a? RDL::Type::SingletonType
        klass = trecv.val.class.to_s
        t = lookup(klass, e.children[1])
        error :no_instance_method_type, [klass, e.children[1]], e unless t
        tmeth_inters << t
      elsif trecv.is_a? RDL::Type::NominalType
        t = lookup(trecv.name, e.children[1])
        error :no_instance_method_type, [trecv.name, e.children[1]], e unless t
        tmeth_inters << t
      else
        raise RuntimeError, "receiver type #{trecv} not supported yet"
      end

      trets = [] # all possible return types
      # there might be more than one return type because:
      #   multiple cases of an intersection type might match
      #   there might be multiple types in tmeth_inters
      tmeth_inters.each { |tmeth_inter| # Array<MethodType>; tmeth_inter is an intersection
        tmeth_inter.each { |tmeth| # MethodType
          trets << tmeth.ret if check_arg_types_one(tmeth, tactuals)
        }
      }
      if trets.empty?
        if tmeth_inters.size == 1
          msg = <<RUBY
Method type:
#{ tmeth_inters[0].map { |ti| "        " + ti.to_s }.join("\n") }
Actual arg types#{tactuals.size > 1 ? "s" : ""}:
        (#{tactuals.map { |ti| ti.to_s }.join(', ')})
RUBY
          msg.chomp! # remove trailing newline
          name = if (trecv.is_a? RDL::Type::SingletonType) && (trecv.val.is_a? Class) && (e.children[1] == :new) then
            :initialize
          elsif trecv.is_a? RDL::Type::SingletonType
            trecv.val.class.to_s
          elsif trecv.is_a? RDL::Type::NominalType
            trecv.name
          else
            raise RutimeError, "impossible"
          end
          error :arg_type_single_receiver_error, [name, e.children[1], msg], e
        else
          # TODO more complicated error message here
          raise RuntimeError, "Not implemented yet #{tmeth_inters}"
        end
      end
      # TODO: issue warning if trets.size > 1 ?
      [ai, RDL::Type::UnionType.new(*trets)]
    when :and
      aleft, tleft = tc(env, a, e.children[0])
      aright, tright = tc(env, aleft, e.children[1])
      if tleft.is_a? RDL::Type::SingletonType
        if tleft.val then [aright, tright] else [aleft, tleft] end
      else
        [ajoin(aleft, aright), RDL::Type::UnionType.new(tleft, tright)]
      end
    when :or
      aleft, tleft = tc(env, a, e.children[0])
      aright, tright = tc(env, aleft, e.children[1])
      if tleft.is_a? RDL::Type::SingletonType
        if tleft.val then [aleft, tleft] else [aright, tright] end
      else
        [ajoin(aleft, aright), RDL::Type::UnionType.new(tleft, tright)]
      end
    # when :not # in latest Ruby, not is a method call that could be redefined, so can't count on its behavior
    #   a1, t1 = tc(env, a, e.children[0])
    #   if t1.is_a? RDL::Type::SingletonType
    #     if t1.val then [a1, $__rdl_false_type] else [a1, $__rdl_true_type] end
    #   else
    #     [a1, $__rdl_bool_type]
    #   end
    when :if
      ai, tguard = tc(env, a, e.children[0]) # guard; any type allowed
      # always type check both sides
      aleft, tleft = if e.children[1].nil? then [ai, $__rdl_nil_type] else tc(env, ai, e.children[1]) end # then
      aright, tright = if e.children[2].nil? then [ai, $__rdl_nil_type] else tc(env, ai, e.children[2]) end # else
      if tguard.is_a? RDL::Type::SingletonType
        if tguard.val then [aleft, tleft] else [aright, tright] end
      else
        [ajoin(aleft, aright), RDL::Type::UnionType.new(tleft, tright)]
      end
    when :begin # sequencing
      ai = a
      ti = nil
      e.children.each { |ei| ai, ti = tc(env, ai, ei) }
      [ai, ti]
    else
      raise RuntimeError, "Expression kind #{e.type} unsupported"
    end
  end

  # [+ tmeth +] is MethodType
  # [+ actuals +] is Array<Type> containing the actual argument types
  # return true if actuals match method type, false otherwise
  # Very similar to MethodType#pre_cond?
  def self.check_arg_types_one(tmeth, tactuals)
    states = [[0, 0]] # position in tmeth, position in tactuals
    tformals = tmeth.args
    until states.empty?
      formal, actual = states.pop
      if formal == tformals.size && actual == tactuals.size # Matched everything
        return true
      end
      next if formal >= tformals.size # Too many actuals to match
      t = tformals[formal]
      if t.instance_of? RDL::Type::AnnotatedArgType
        t = t.type
      end
      case t
      when RDL::Type::OptionalType
        t = t.type #TODO .instantiate(inst)
        if actual == tactuals.size
          states << [formal+1, actual] # skip over optinal formal
        elsif tactuals[actual] <= t
          states << [formal+1, actual+1] # match
          states << [formal+1, actual] # skip
        else
          states << [formal+1, actual] # types don't match; must skip this formal
        end
      when RDL::Type::VarargType
        t = t.type #TODO .instantiate(inst)
        if actual == tactuals.size
          states << [formal+1, actual] # skip to allow empty vararg at end
        elsif tactuals[actual] <= t
          states << [formal, actual+1] # match, more varargs coming
          states << [formal+1, actual+1] # match, no more varargs
          states << [formal+1, actual] # skip over even though matches
        else
          states << [formal+1, actual] # doesn't match, must skip
        end
      else
        if actual == tactuals.size
          next unless t.instance_of? RDL::Type::FiniteHashType
          if @@empty_hash_type <= t
            states << [formal+1, actual]
          end
          # TODO: finite hash
        elsif tactuals[actual] <= t
          states << [formal+1, actual+1] # match!
          # no else case; if there is no match, this is a dead end
        end
      end
    end
    false
  end


  # [+ klass +] is a string containing the class name
  # [+ name +] is a symbol naming the thing to look up (either a method or field)
  # returns klass#name's type, walking up the inheritance hierarchy if appropriate
  # returns nil if no type found
  def self.lookup(klass, name)
    t = $__rdl_info.get(klass, name, :type)
    return t if t # simplest case, no need to walk inheritance hierarchy
    RDL::Util.to_class(klass).ancestors.each { |ancestor|
      # assumes ancestors is proper order to walk hierarchy
      tancestor = $__rdl_info.get(ancestor.to_s, name, :type)
      return tancestor if tancestor
    }
    return nil
  end

  # [+ a1 +] and [+ a2 +] are local variable type envrionments
  # returns join of evironments
  def self.ajoin(a1, a2)
    a = Hash.new
    a1.each_pair { |k, t| a[k] = RDL::Type::UnionType.new(t, a2[k]) if a2.has_key? k }
    return a
  end

end

# Modify Parser::MESSAGES so can use the awesome parser diagnostics printing!
type_error_messages = {
  bad_return_type: "got type `%s' where return type `%s' expected",
  undefined_local_or_method: "undefined local variable or method `%s'",
  nonmatching_range_type: "attempt to construct range with non-matching types `%s' and `%s'",
  no_instance_method_type: "no type information for instance method `%s#%s'",
  arg_type_single_receiver_error: "argument type error for instance method `%s#%s'\n%s",
  untyped_var: "no type for %s variable `%s'",
  vasgn_incompat: "incompatible types: `%s' can't be assigned to `%s'"
}
old_messages = Parser::MESSAGES
Parser.send(:remove_const, :MESSAGES)
Parser.const_set :MESSAGES, (old_messages.merge(type_error_messages))
