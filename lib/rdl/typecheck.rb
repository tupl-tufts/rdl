module RDL::Typecheck

  class StaticTypeError < StandardError; end

  @@empty_hash_type = RDL::Type::FiniteHashType.new(Hash.new)
  @@asgn_to_var = { lvasgn: :lvar, ivasgn: :ivar, cvasgn: :cvar, gvasgn: :gvar }

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
      # (def name args body)
      name, _, body = *node
      if @line_defs[node.loc.line]
        raise RuntimeError, "Multiple defs per line (#{name} and #{@line_defs[node.loc.line].children[1]} in #{@file}) currently not allowed"
      end
      @line_defs[node.loc.line] = node
      process body
      node.updated(nil, nil)
    end

    def on_defs(node)
      # (defs (self) name args body)
      _, name, _, body = *node
      if @line_defs[node.loc.line]
        raise RuntimeError, "Multiple defs per line (#{name} and #{@line_defs[node.loc.line].children[1]} in #{@file}) currently not allowed"
      end
      @line_defs[node.loc.line] = node
      process body
      node.updated(nil, nil)
    end

  end

  # Local variable environment
  # tracks the types of local variables, and whether they're "fixed," i.e.,
  # whether they should be treated flow-insensitively
  class Env
    attr_accessor :env

    # [+ params +] is a map from Symbols to Types. This initial variable mapping
    # is added to the Env, and these initial mappings are fixed. If params
    # is nil, initial Env is empty.
    def initialize(params = nil)
      @env = Hash.new
      unless params.nil?
        params.each_pair { |var, typ|
          @env[var] = {type: typ, fixed: true}
        }
      end
    end

    # [+ var +] is a Symbol
    def [](var)
      return @env[var][:type]
    end

    def bind(var, typ)
      raise RuntimeError, "Can't update variable with fixed type" if @env[var] && @env[var][:fixed]
      result = Env.new
      result.env = @env.merge(var => {type: typ, fixed: false})
      return result
    end

    def has_key?(var)
      return @env.has_key?(var)
    end

    def fix(var, typ)
      raise RuntimeError, "Can't fix type of already-bound variable" if @env[var]
      result = Env.new
      result.env = @env.merge(var => {type: typ, fixed: true})
      return result
    end

    def fixed?(var)
      return @env[var] && @env[var][:fixed]
    end

    def ==(other)
      return false unless other.is_a? Env
      return @env == other.env
    end

    # [+ envs +] is Array<Env>
    def self.join(e, *envs)
      raise RuntimeError, "Expecting AST, got #{e.class}" unless e.is_a? AST::Node
      env = Env.new
      return env if envs.empty?
      return envs[0] if envs.size == 1
      first = envs[0]
      rest = envs[1..-1]
      first.env.each_pair { |var, h|
        first_typ = h[:type]
        if h[:fixed]
          error :inconsistent_var_type, [var.to_s], e unless rest.all? { |other| (other.fixed? var) || (not (other.has_key? var)) }
          neq = []
          rest.each { |other|
            other_typ = other[var]
            neq << other_typ unless first_typ == other_typ
          }
          error :inconsistent_var_type_type, [var.to_s, (first_typ + neq).map { |t| t.to_s }.join(' and ')], e unless neq.empty?
          env.env[var] = {type: h[:type], fixed: true}
        else
          typ = RDL::Type::UnionType.new(first_typ, *rest.map { |other| ((other.has_key? var) && other[var]) || $__rdl_nil_type })
          typ = typ.canonical
          env.env[var] = {type: typ, fixed: false}
        end
      }
      return env
    end
  end

  # report msg at ast's loc
  def self.error(reason, args, ast)
    raise StaticTypeError, ("\n" + (Parser::Diagnostic.new :error, reason, args, ast.loc.expression).render.join("\n"))
  end

  def self.typecheck(klass, meth)
    file, line = $__rdl_info.get(klass, meth, :source_location)
    raise RuntimeError, "static type checking in irb not supported" if file == "(irb)"
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
    raise RuntimeError, "Can't find source for class #{RDL::Util.pp_klass_method(klass, meth)}" if ast.nil?
    types = $__rdl_info.get(klass, meth, :type)
    raise RuntimeError, "Can't typecheck method with no types?!" if types.nil? or types == []

    if ast.type == :def
      name, args, body = *ast
    elsif ast.type == :defs
      _, name, args, body = *ast
    else
      raise RuntimeError, "Unexpected ast type #{ast.type}"
    end
    raise RuntimeError, "Method #{name} defined where method #{meth} expected" if name.to_sym != meth
    types.each { |type|
      # TODO will need fancier logic here for matching up more complex arg lists
      if RDL::Util.has_singleton_marker(klass)
        # to_class gets the class object itself, so remove singleton marker to get class rather than singleton class
        self_type = RDL::Type::SingletonType.new(RDL::Util.to_class(RDL::Util.remove_singleton_marker(klass)))
      else
        self_type = RDL::Type::NominalType.new(klass)
      end
      inst = {self: self_type}
      type = type.instantiate inst
      a = args.children.map { |arg| arg.children[0] }.zip(type.args).to_h
      a[:self] = self_type
      scope = {tret: type.ret, tblock: type.block }
      _, body_type = if body.nil? then [nil, $__rdl_nil_type] else tc(scope, Env.new(a), body) end
      error :bad_return_type, [body_type.to_s, type.ret.to_s], body unless body_type.nil? || body_type <= type.ret
    }
  end

  # The actual type checking logic.
  # [+ scope +] tracks flow-insensitive information about the current scope, excluding local variables
  # [+ env +] is the (local variable) Env
  # [+ e +] is the expression to type check
  # Returns [env', t], where env' is the type environment at the end of the expression
  # and t is the type of the expression. t is always canonical.
  def self.tc(scope, env, e)
    case e.type
    when :nil
      [env, $__rdl_nil_type]
    when :true
      [env, $__rdl_true_type]
    when :false
      [env, $__rdl_false_type]
    when :complex, :rational, :str, :string # constants
      [env, RDL::Type::NominalType.new(e.children[0].class)]
    when :int, :float, :sym # singletons
      [env, RDL::Type::SingletonType.new(e.children[0])]
    when :dstr, :xstr # string (or execute-string) with interpolation
      envi = env
      e.children.each { |ei| envi, _ = tc(scope, envi, ei) }
      [envi, $__rdl_string_type]
    when :dsym # symbol with interpolation
      envi = env
      e.children.each { |ei| envi, _ = tc(scope, envi, ei) }
      [envi, $__rdl_symbol_type]
    when :regexp
      envi = env
      e.children.each { |ei| envi, _ = tc(scope, envi, ei) unless ei.type == :regopt }
      [envi, $__rdl_regexp_type]
    when :array
      envi = env
      tis = []
      e.children.each { |ei| envi, ti = tc(scope, envi, ei); tis << ti }
      [envi, RDL::Type::TupleType.new(*tis)]
#    when :splat # TODO!
    when :hash
      envi = env
      tlefts = []
      trights = []
      is_fh = true
      e.children.each { |p|
        # each child is a pair
        envi, tleft = tc(scope, envi, p.children[0])
        tlefts << tleft
        envi, tright = tc(scope, envi, p.children[1])
        trights << tright
        is_fh = false unless tleft.is_a?(RDL::Type::SingletonType) && tleft.val.is_a?(Symbol)
      }
      if is_fh
        # keys are all symbols
        fh = tlefts.map { |t| t.val }.zip(trights).to_h
        [envi, RDL::Type::FiniteHashType.new(fh)]
      else
        tleft = RDL::Type::UnionType.new(*tlefts)
        tright = RDL::Type::UnionType.new(*trights)
        [envi, RDL::Type::GenericType.new($__rdl_hash_type, tleft, tright)]
      end
      #TODO test!
#    when :kwsplat # TODO!
    when :irange, :erange
      env1, t1 = tc(scope, env, e.children[0])
      env2, t2 = tc(scope, env1, e.children[1])
      # promote singleton types to nominal types; safe since Ranges are immutable
      t1 = RDL::Type::NominalType.new(t1.val.class) if t1.is_a? RDL::Type::SingletonType
      t2 = RDL::Type::NominalType.new(t2.val.class) if t2.is_a? RDL::Type::SingletonType
      error :nonmatching_range_type, [t1, t2], e if t1 != t2
      [env2, RDL::Type::GenericType.new($__rdl_range_type, t1)]
    when :self
      [env, env[:self]]
    when :lvar, :ivar, :cvar, :gvar
      tc_var(scope, env, e.type, e.children[0], e)
    when :lvasgn, :ivasgn, :cvasgn, :gvasgn
      x = e.children[0]
      # if local var, lhs is bound to nil before assignment is executed! only matters in type checking for locals
      env = env.bind(x, $__rdl_nil_type) if ((e.type == :lvasgn) && (not (env.has_key? x)))
      envright, tright = tc(scope, env, e.children[1])
      tc_vasgn(scope, envright, e.type, x, tright, e)
    when :masgn
      # (masgn (mlhs (Xvasgn var-name) ... (Xvasgn var-name)) rhs)
      e.children[0].children.each { |asgn|
        next unless asgn.type == :lvasgn
        x = e.children[0]
        env = env.bind(x, $__rdl_nil_type) if (not (env.has_key? x)) # see lvasgn
      }
      envi, tright = tc(scope, env, e.children[1])
      if tright.is_a? RDL::Type::TupleType
        tright.cant_promote! # must always remain a tuple because of the way type checking currently works
        lhs = e.children[0].children
        rhs = tright.params
        error :masgn_num, [rhs.length, lhs.length], e unless lhs.length == rhs.length
        lhs.zip(rhs).each { |left, right|
          envi, _ = tc_vasgn(scope, envi, left.type, left.children[0], right, left)
        }
        [envi, tright]
      elsif (tright.is_a? RDL::Type::GenericType) && (tright.base == $__rdl_array_type)
        tasgn = tright.params[0]
        e.children[0].children.each { |asgn|
          envi, _ = tc_vasgn(scope, envi, asgn.type, asgn.children[0], tasgn, asgn)
        }
        [envi, tright]
      else
        error :masgn_bad_rhs, [tright], e.children[1]
      end
    when :op_asgn
      if e.children[0].type == :send
        # (op-asgn (send recv meth) :op operand)
        meth = e.children[0].children[1]
        envleft, trecv = tc(scope, env, e.children[0].children[0]) # recv
        tloperand = tc_send(trecv, meth, [], e.children[0]) # call recv.meth()
        envoperand, troperand = tc(scope, envleft, e.children[2]) # operand
        tright = tc_send(tloperand, e.children[1], [troperand], e) # computer recv.meth().op(operand)
        mutation_meth = (meth.to_s + '=').to_sym
        tres = tc_send(trecv, mutation_meth, [tright], e) # call recv.meth=(recv.meth().op(operand))
        [envoperand, tres]
      else
        # (op-asgn (Xvasgn var-name) :op operand)
        x = e.children[0].children[0]
        env = env.bind(x, $__rdl_nil_type) if ((e.children[0].type == :lvasgn) && (not (env.has_key? x))) # see :lvasgn
        envi, trecv = tc_var(scope, env, @@asgn_to_var[e.children[0].type], x, e.children[0]) # var being assigned to
        envright, tright = tc(scope, envi, e.children[2]) # operand
        trhs = tc_send(trecv, e.children[1], [tright], e)
        tc_vasgn(scope, envright, e.children[0].type, x, trhs, e)
      end
    when :and_asgn, :or_asgn
      # very similar logic to op_asgn
      if e.children[0].type == :send
        meth = e.children[0].children[1]
        envleft, trecv = tc(scope, env, e.children[0].children[0]) # recv
        tleft = tc_send(trecv, meth, [], e.children[0]) # call recv.meth()
        envright, tright = tc(scope, envleft, e.children[1]) # operand
      else
        x = e.children[0].children[0]
        env = env.bind(x, $__rdl_nil_type) if ((e.children[0].type == :lvasgn) && (not (env.has_key? x))) # see :lvasgn
        envleft, tleft = tc_var(scope, env, @@asgn_to_var[e.children[0].type], x, e.children[0]) # var being assigned to
        envright, tright = tc(scope, envleft, e.children[1])
      end
      envi, trhs = (if tleft.is_a? RDL::Type::SingletonType
                      if e.type == :and_asgn
                        if tleft.val then [envright, tright] else [envleft, tleft] end
                      else # e.type == :or_asgn
                        if tleft.val then [envleft, tleft] else [envright, tright] end
                      end
                    else
                      [Env.join(e, envleft, envright), RDL::Type::UnionType.new(tleft, tright).canonical]
                    end)
      if e.children[0].type == :send
        mutation_meth = (meth.to_s + '=').to_sym
        tres = tc_send(trecv, mutation_meth, [trhs], e)
        [envi, tres]
      else
        tc_vasgn(scope, envi, e.children[0].type, x, trhs, e)
      end
    when :nth_ref, :back_ref
      [env, $__rdl_string_type]
    when :const
      c = nil
      if e.children[0].nil?
        c = env[:self].klass.const_get(e.children[1])
      elsif e.children[0].type == :cbase
        raise "const cbase not implemented yet" # TODO!
      elsif e.children[0].type == :lvar
        raise "const lvar not implemented yet" # TODO!
      else
        raise "const other not implemented yet"
      end
      case c
      when TrueClass, FalseClass, Complex, Rational, Fixnum, Bignum, Float, Symbol, Class
        [env, RDL::Type::SingletonType.new(c)]
      else
        [env, RDL::Type::NominalType.new(const_get(e.children[1]).class)]
      end
    when :defined?
      # do not type check subexpression, since it may not be type correct, e.g., undefined variable
      [env, $__rdl_string_type]
    when :send, :csend
      # children[0] = receiver; if nil, receiver is self
      # children[1] = method name, a symbol
      # children [2..] = actual args
      return tc_var_type(scope, env, e) if e.children[0].nil? && e.children[1] == :var_type
      envi = env
      tactuals = []
      e.children[2..-1].each { |ei| envi, ti = tc(scope, envi, ei); tactuals << ti }
      envi, trecv = if e.children[0].nil? then [envi, envi[:self]] else tc(scope, envi, e.children[0]) end # if no receiver, self is receiver
      [envi, tc_send(trecv, e.children[1], tactuals, e).canonical]
    when :and, :or
      envleft, tleft = tc(scope, env, e.children[0])
      envright, tright = tc(scope, envleft, e.children[1])
      if tleft.is_a? RDL::Type::SingletonType
        if e.type == :and
          if tleft.val then [envright, tright] else [envleft, tleft] end
        else # e.type == :or
          if tleft.val then [envleft, tleft] else [envright, tright] end
        end
      else
        [Env.join(e, envleft, envright), RDL::Type::UnionType.new(tleft, tright).canonical]
      end
    # when :not # in latest Ruby, not is a method call that could be redefined, so can't count on its behavior
    #   a1, t1 = tc(scope, a, e.children[0])
    #   if t1.is_a? RDL::Type::SingletonType
    #     if t1.val then [a1, $__rdl_false_type] else [a1, $__rdl_true_type] end
    #   else
    #     [a1, $__rdl_bool_type]
    #   end
    when :if
      envi, tguard = tc(scope, env, e.children[0]) # guard; any type allowed
      # always type check both sides
      envleft, tleft = if e.children[1].nil? then [envi, $__rdl_nil_type] else tc(scope, envi, e.children[1]) end # then
      envright, tright = if e.children[2].nil? then [envi, $__rdl_nil_type] else tc(scope, envi, e.children[2]) end # else
      if tguard.is_a? RDL::Type::SingletonType
        if tguard.val then [envleft, tleft] else [envright, tright] end
      else
        [Env.join(e, envleft, envright), RDL::Type::UnionType.new(tleft, tright).canonical]
      end
    when :case
      envi = env
      envi, tcontrol = tc(scope, envi, e.children[0]) unless e.children[0].nil? # the control expression, which make be nil
      # for each guard, invoke guard === control expr, then possibly do body, possibly short-circuiting arbitrary later stuff
      tbodies = []
      envbodies = []
      e.children[1..-2].each { |wclause|
        raise RuntimeError, "Don't know what to do with case clause #{wclause.type}" unless wclause.type == :when
        envguards = []
        wclause.children[0..-2].each { |guard| # first wclause.length-1 children are the guards
          envi, tguard = tc(scope, envi, guard) # guard type can be anything
          tc_send(tguard, :===, [tcontrol], guard) unless tcontrol.nil?
          envguards << envi
        }
        envbody, tbody = tc(scope, Env.join(e, *envguards), wclause.children[-1]) # last wclause child is body
        tbodies << tbody
        envbodies << envbody
      }
      if e.children[-1].nil?
        # no else clause, might fall through having missed all cases
        envbodies << envi
      else
        # there is an else clause
        envelse, telse = tc(scope, envi, e.children[-1])
        tbodies << telse
        envbodies << envelse
      end
      return [Env.join(e, *envbodies), RDL::Type::UnionType.new(*tbodies).canonical]
    when :while, :until
      # break: loop exit
      # next: before loop guard
      # retry: not allowed
      # redo: after loop header, which is same as break
      env_break, _ = tc(scope, env, e.children[0]) # guard can have any type, may exit after checking guard
      scope = scope.merge(break: env_break, next: env, redo: env_break)
      begin
        old_break = scope[:break]
        old_next = scope[:next]
        if e.children[1]
          env_body, _ = tc(scope, scope[:break], e.children[1]) # loop runs
          scope[:next] = Env.join(e, scope[:next], env_body)
        end
        env_guard, _ = tc(scope, scope[:next], e.children[0]) # then guard runs
        scope[:break] = scope[:redo] = Env.join(e, scope[:break], scope[:redo], env_guard)
      end until old_break == scope[:break] && old_next == scope[:next]
      [scope[:break], $__rdl_nil_type]
    when :while_post, :until_post
      # break: loop exit; note may exit loop before hitting guard
      # next: before loop guard
      # retry: same as next
      # redo: jumps to beginning of body
      envi = env
      envi, _ = tc(scope, envi, e.children[1]) if e.children[1] # loop runs once, may be nil
      envi, _ = tc(scope, envi, e.children[0]) # guard checked once
      begin
        envold = envi
        envi, _ = tc(scope, envi, e.children[1]) if e.children[1] # loop runs
        envi, _ = tc(scope, envi, e.children[0]) # guard checked again
        envi = Env.join(e, envi, envold)
      end until envi == envold
      [envi, $__rdl_nil_type]
    when :for
      raise RuntimeError, "Loop variable #{e.children[0]} in for unsupported" unless e.children[0].type == :lvasgn
      x  = e.children[0].children[0] # loop variable
      envi, tcollect = tc(scope, env, e.children[1]) # collection to iterate through
      teaches = nil
      tcollect = tcollect.canonical
      case tcollect
      when RDL::Type::NominalType
        teaches = lookup(tcollect.name, :each)
      when RDL::Type::GenericType, RDL::Type::TupleType, RDL::Type::FiniteHashType
        unless tcollect.is_a? RDL::Type::GenericType
          error :tuple_finite_hash_promote, (if tcollect.is_a? RDL::Type::TupleType then ['tuple', 'Array'] else ['finite hash', 'Hash'] end), e.children[1] unless tcollect.promote!
          tcollect = tcollect.canonical
        end
        teaches = lookup(tcollect.base.name, :each)
        inst = tcollect.to_inst
        teaches = teaches.map { |t| t.instantiate(inst) }
      else
        raise RuntimeError, "Collection of type #{tcollect.to_s} in for unsupported"
      end
      teach = nil
      teaches.each { |t|
        # find `each` method with right type signature:
        #    () { (t1) -> t2 } -> t3
        next unless t.args.empty?
        next if t.block.nil?
        next unless t.block.args.size == 1
        next unless t.block.block.nil?
        teach = t
        break
      }
      error :no_each_type, [tcollect.name], e.children[1] if teach.nil?
      envi = envi.bind(x, teach.block.args[0])
      envold = nil
      until envold == envi
        envold = envi
        envi, _ = tc(scope, envi, e.children[2]) if e.children[2] # may be nil
        envi = Env.join(e, envold, envi)
      end
      [envi, teach.ret]
    when :break, :redo, :next, :retry
      raise RuntimeError, "#{e.type} arguments not supported" unless e.children[0].nil?
      error :kw_not_allowed, [e.type.to_s], e unless scope.has_key? e.type
      scope[e.type] = Env.join(e, scope[e.type], env)
      [env, $__rdl_bot_type]
    when :return
      # TODO return in lambda returns from lambda and not outer scope
      env1, t1 = tc(scope, env, e.children[0])
      error :bad_return_type, [t1.to_s, scope[:tret]], e unless t1 <= scope[:tret]
      [env1, $__rdl_bot_type] # return is a void value expression
    when :begin, :kwbegin # sequencing
      envi = env
      ti = nil
      e.children.each { |ei| envi, ti = tc(scope, envi, ei) }
      [envi, ti]
    else
      raise RuntimeError, "Expression kind #{e.type} unsupported"
    end
  end

  # [+ kind +] is :lvar, :ivar, :cvar, or :gvar
  # [+ name +] is the variable name, which should be a symbol
  # [+ e +] is the expression for which errors should be reported
  def self.tc_var(scope, env, kind, name, e)
    case kind
    when :lvar  # local variable
      error :undefined_local_or_method, name.to_s, e unless env.has_key? name
      [env, env[name].canonical]
    when :ivar, :cvar, :gvar
      klass = (if kind == :gvar then RDL::Util::GLOBAL_NAME else env[:self] end)
      unless $__rdl_info.has?(klass, name, :type)
        kind_text = (if kind == :ivar then "instance"
                     elsif kind == :cvar then "class"
                     else "global" end)
        error :untyped_var, [kind_text, name], e
      end
      [env, $__rdl_info.get(klass, name, :type).canonical]
    else
      raise RuntimeError, "unknown kind #{kind}"
    end
  end

  # Same arguments as tc_var except
  # [+ tright +] is type of right-hand side
  def self.tc_vasgn(scope, env, kind, name, tright, e)
    case kind
    when :lvasgn
      if env.fixed? name
        error :vasgn_incompat, [tright, env[name]], e unless tright <= env[name]
        [env, tright]
      else
        [env.bind(name, tright), tright]
      end
    when :ivasgn, :cvasgn, :gvasgn
      klass = (if kind == :gvasgn then RDL::Util::GLOBAL_NAME else env[:self] end)
      unless $__rdl_info.has?(klass, name, :type)
        kind_text = (if kind == :ivasgn then "instance"
                    elsif kind == :cvasgn then "class"
                    else "global" end)
        error :untyped_var, [kind_text, name], e
      end
      tleft = $__rdl_info.get(klass, name, :type)
      error :vasgn_incompat, [tright.to_s, tleft.to_s], e unless tright <= tleft
      [env, tright]
    else
      raise RuntimeError, "unknown kind #{kind}"
    end
  end

  # [+ e +] is the method call
  def self.tc_var_type(scope, env, e)
    error :var_type_num_args, [e.children.length - 2], e unless e.children.length == 4
    var = e.children[2].children[0] if e.children[2].type == :sym
    error :var_type_var, [], e.children[2] if var.nil? || (not (var =~ /^[a-z]/))
    typ_str = e.children[3].children[0] if (e.children[3].type == :str) || (e.children[3].type == :string)
    error :var_type_type, [], e.children[3] if typ_str.nil?
    typ = $__rdl_parser.scan_str("#T " + typ_str)
    [env.fix(var, typ), $__rdl_nil_type]
  end

  # Type check a send
  # [+ trecvs +] is the type of the recevier
  # [+ meth +] is a symbol with the method name
  # [+ tactuals +] are the actual arguments
  # [+ e +] is the expression at which location to report an error
  def self.tc_send(trecvs, meth, tactuals, e)
    # convert trecvs to array containing all receiver types
    trecvs = trecvs.canonical
    trecvs = if trecvs.is_a? RDL::Type::UnionType then trecvs.types else [trecvs] end

    trets = []
    trecvs.each { |trecv|
      trets.concat(tc_send_one_recv(trecv, meth, tactuals, e))
    }
    return RDL::Type::UnionType.new(*trets)
  end

  # Like tc_send but trecv should never be a union type
  # Returns array of possible return types, or throws exception if there are none
  def self.tc_send_one_recv(trecv, meth, tactuals, e)
    tmeth_inter = [] # Array<MethodType>, i.e., an intersection types
    case trecv
    when RDL::Type::SingletonType
      if trecv.val.is_a? Class
        if meth == :new then name = :initialize else name = meth end
        ts = lookup(RDL::Util.add_singleton_marker(trecv.val.to_s), name)
        ts = [RDL::Type::MethodType.new([], nil, RDL::Type::NominalType.new(trecv.val))] if (meth == :new) && (ts.nil?) # there's always a nullary new if initialize is undefined
        error :no_singleton_method_type, [trecv.val, meth], e unless ts
        inst = {self: trecv}
        tmeth_inter = ts.map { |t| t.instantiate(inst) }
      else
        klass = trecv.val.class.to_s
        ts = lookup(klass, meth)
        error :no_instance_method_type, [klass, meth], e unless ts
        inst = {self: trecv}
        tmeth_inter = ts.map { |t| t.instantiate(inst) }
      end
    when RDL::Type::NominalType
      ts = lookup(trecv.name, meth)
      error :no_instance_method_type, [trecv.name, meth], e unless ts
      inst = {self: trecv}
      tmeth_inter = ts.map { |t| t.instantiate(inst) }
    when RDL::Type::GenericType, RDL::Type::TupleType, RDL::Type::FiniteHashType
      unless trecv.is_a? RDL::Type::GenericType
        error :tuple_finite_hash_promote, (if trecv.is_a? RDL::Type::TupleType then ['tuple', 'Array'] else ['finite hash', 'Hash'] end), e unless trecv.promote!
        trecv = trecv.canonical
      end
      ts = lookup(trecv.base.name, meth)
      error :no_instance_method_type, [trecv.base.name, meth], e unless ts
      inst = trecv.to_inst.merge(self: trecv)
      tmeth_inter = ts.map { |t| t.instantiate(inst) }
    else
      raise RuntimeError, "receiver type #{t} not supported yet"
    end

    trets = [] # all possible return types
    # there might be more than one return type because multiple cases of an intersection type might match
    tmeth_inter.each { |tmeth| # MethodType
      trets << tmeth.ret if check_arg_types_one(tmeth, tactuals)
    }
    if trets.empty? # no possible matching call
      msg = <<RUBY
Method type:
#{ tmeth_inter.map { |ti| "        " + ti.to_s }.join("\n") }
Actual arg types#{tactuals.size > 1 ? "s" : ""}:
      (#{tactuals.map { |ti| ti.to_s }.join(', ')})
RUBY
      msg.chomp! # remove trailing newline
      name = if (trecv.is_a? RDL::Type::SingletonType) && (trecv.val.is_a? Class) && (meth == :new) then
        :initialize
      elsif trecv.is_a? RDL::Type::SingletonType
        trecv.val.class.to_s
      elsif trecv.is_a? RDL::Type::NominalType
        trecv.name
      else
        raise RutimeError, "impossible"
      end
      error :arg_type_single_receiver_error, [name, meth, msg], e
    end
    # TODO: issue warning if trets.size > 1 ?
    return trets
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
    name = $__rdl_aliases[klass][name] if $__rdl_aliases[klass] && $__rdl_aliases[klass][name]
    t = $__rdl_info.get(klass, name, :type)
    return t if t # simplest case, no need to walk inheritance hierarchy
    RDL::Util.to_class(klass).ancestors.each { |ancestor|
      # assumes ancestors is proper order to walk hierarchy
      tancestor = $__rdl_info.get(ancestor.to_s, name, :type)
      return tancestor if tancestor
    }
    return nil
  end
end

# Modify Parser::MESSAGES so can use the awesome parser diagnostics printing!
type_error_messages = {
  bad_return_type: "got type `%s' where return type `%s' expected",
  undefined_local_or_method: "undefined local variable or method `%s'",
  nonmatching_range_type: "attempt to construct range with non-matching types `%s' and `%s'",
  no_instance_method_type: "no type information for instance method `%s#%s'",
  no_singleton_method_type: "no type information for class/singleton method `%s.%s'",
  arg_type_single_receiver_error: "argument type error for instance method `%s#%s'\n%s",
  untyped_var: "no type for %s variable `%s'",
  vasgn_incompat: "incompatible types: `%s' can't be assigned to variable of type `%s'",
  var_type_num_args: "var_type expects 2 arguments but got %d arguments",
  var_type_var: "var_type expects first argument to be a symbol with a local variable name",
  var_type_type: "var_type expects second argument to be a constant string describing a type",
  inconsistent_var_type: "local variable `%s' has declared type on some paths but not all",
  inconsistent_var_type_type: "local variable `%s' declared with inconsistent types %s",
  no_each_type: "can't find `each' method with signature `() { (t1) -> t2 } -> t3' in class `%s'",
  tuple_finite_hash_promote: "can't promote %s to %s",
  masgn_bad_rhs: "multiple assignment has right-hand side of type `%s' where tuple or array expected",
  masgn_num: "can't multiple-assign %d values to %d variables",
  kw_not_allowed: "can't use %s in current scope",
}
old_messages = Parser::MESSAGES
Parser.send(:remove_const, :MESSAGES)
Parser.const_set :MESSAGES, (old_messages.merge(type_error_messages))
