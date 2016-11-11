module RDL::Typecheck

  class StaticTypeError < StandardError; end

  @@empty_hash_type = RDL::Type::FiniteHashType.new(Hash.new, nil)
  @@asgn_to_var = { lvasgn: :lvar, ivasgn: :ivar, cvasgn: :cvar, gvasgn: :gvar }

  # Create mapping from file/line numbers to the def that appears at that location
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

    # force should only be used with care! currently only used when type is being refined to a subtype in a lexical scope
    def bind(var, typ, force: false)
      raise RuntimeError, "Can't update variable with fixed type" if !force && @env[var] && @env[var][:fixed]
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

    # merges bindings in self with bindings in other, preferring bindings in other if there is a common key
    def merge(other)
      result = Env.new
      result.env = @env.merge(other.env)
      return result
    end

    # [+ envs +] is Array<Env>
    # any elts of envs that are nil are discarded
    # returns new Env where every key is mapped to the union of its bindings in the envs
    # any fixed binding in any env must be fixed in all envs and at the same type
    def self.join(e, *envs)
      raise RuntimeError, "Expecting AST, got #{e.class}" unless e.is_a? AST::Node
      env = Env.new
      envs.delete(nil)
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

  # Call block with new Hash that is the same as Hash [+ scope +] except mappings in [+ elts +] have been merged.
  # When block returns, copy out mappings in the new Hash to [+ scope +] except keys in [+ elts +].
  def self.scope_merge(scope, **elts)
    new_scope = scope.merge(**elts)
    r = yield(new_scope)
    new_scope.each_pair { |k,v|
      scope[k] = v unless elts.has_key? k
    }
    return r
  end

  # add x:t to the captured map in scope
  def self.capture(scope, x, t)
    if scope[:captured][x]
      scope[:captured][x] = RDL::Type::UnionType.new(scope[:captured][x], t).canonical unless t <= scope[:captured][x]
    else
      scope[:captured][x] = t
    end
  end

  # report msg at ast's loc
  def self.error(reason, args, ast)
    raise StaticTypeError, ("\n" + (Parser::Diagnostic.new :error, reason, args, ast.loc.expression).render.join("\n"))
  end

  def self.note(reason, args, ast)
    puts (Parser::Diagnostic.new :note, reason, args, ast.loc.expression).render
  end

  def self.get_ast(klass, meth)
    file, line = $__rdl_info.get(klass, meth, :source_location)
    raise RuntimeError, "No file for #{RDL::Util.pp_klass_method(klass, meth)}" if file.nil?
    raise RuntimeError, "static type checking in irb not supported" if file == "(irb)"
    if file == "(pry)"
      # no caching...
      if RDL::Wrap.wrapped?(klass, meth)
        meth_name = RDL::Wrap.wrapped_name(klass, meth)
      else
        meth_name = meth
      end
      the_meth = RDL::Util.to_class(klass).instance_method(meth_name)
      code = Pry::Code.from_method the_meth
      return Parser::CurrentRuby.parse code.to_s
    end

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
    return ast
  end

  def self.typecheck(klass, meth)
    ast = get_ast(klass, meth)
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
    context_types = $__rdl_info.get(klass, meth, :context_types)
    types.each { |type|
      if RDL::Util.has_singleton_marker(klass)
        # to_class gets the class object itself, so remove singleton marker to get class rather than singleton class
        self_type = RDL::Type::SingletonType.new(RDL::Util.to_class(RDL::Util.remove_singleton_marker(klass)))
      else
        self_type = RDL::Type::NominalType.new(klass)
      end
      inst = {self: self_type}
      type = type.instantiate inst
      _, targs = args_hash({}, Env.new, type, args, ast, 'method')
      targs[:self] = self_type
      scope = { tret: type.ret, tblock: type.block, captured: Hash.new, context_types: context_types }
      begin
        old_captured = scope[:captured].dup
        if body.nil?
          body_type = $__rdl_nil_type
        else
          _, body_type = tc(scope, Env.new(targs.merge(scope[:captured])), body)
        end
      end until old_captured == scope[:captured]
      error :bad_return_type, [body_type.to_s, type.ret.to_s], body unless body.nil? || body_type <= type.ret
    }
    $__rdl_info.set(klass, meth, :typechecked, true)
  end

  # [+ scope +] is used to typecheck default values for optional arguments
  # [+ env +] is used to typecheck default values for optional arguments
  # [+ type +] is a MethodType
  # [+ args +] is an `args` node from the AST
  # [+ ast +] is where to report an error if `args` is empty
  # [+ kind +] is either `'method'` or `'block'`, and is only used for printing error messages
  # Returns a Hash<Symbol, Type> mapping formal argument names to their types
  def self.args_hash(scope, env, type, args, ast, kind)
    targs = Hash.new
    tpos = 0 # position in type.args
    kw_args_matched = []
    kw_rest_matched = false
    args.children.each { |arg|
      error :type_args_fewer, [kind, kind], arg if tpos >= type.args.length && arg.type != :blockarg  # blocks could be called with yield
      targ = type.args[tpos]
      if arg.type == :arg
        error :type_arg_kind_mismatch, [kind, 'optional', 'required'], arg if targ.optional?
        error :type_arg_kind_mismatch, [kind, 'vararg', 'required'], arg if targ.vararg?
        targs[arg.children[0]] = targ
        tpos += 1
      elsif arg.type == :optarg
        error :type_arg_kind_mismatch, [kind, 'vararg', 'optional'], arg if targ.vararg?
        error :type_arg_kind_mismatch, [kind, 'required', 'optional'], arg if !targ.optional?
        env, default_type = tc(scope, env, arg.children[1])
        error :optional_default_type, [default_type, targ.type], arg.children[1] unless default_type <= targ.type
        targs[arg.children[0]] = targ.type
        tpos += 1
      elsif arg.type == :restarg
        error :type_arg_kind_mismatch, [kind, 'optional', 'vararg'], arg if targ.optional?
        error :type_arg_kind_mismatch, [kind, 'required', 'vararg'], arg if !targ.vararg?
        targs[arg.children[0]] = RDL::Type::GenericType.new($__rdl_array_type, targ.type)
        tpos += 1
      elsif arg.type == :kwarg
        error :type_args_no_kws, [kind], arg unless targ.is_a?(RDL::Type::FiniteHashType)
        kw = arg.children[0]
        error :type_args_no_kw, [kind, kw], arg unless targ.elts.has_key? kw
        tkw = targ.elts[kw]
        error :type_args_kw_mismatch, [kind, 'optional', kw, 'required'], arg if tkw.is_a? RDL::Type::OptionalType
        kw_args_matched << kw
        targs[kw] = tkw
      elsif arg.type == :kwoptarg
        error :type_args_no_kws, [kind], arg unless targ.is_a?(RDL::Type::FiniteHashType)
        kw = arg.children[0]
        error :type_args_no_kw, [kind, kw], arg unless targ.elts.has_key? kw
        tkw = targ.elts[kw]
        error :type_args_kw_mismatch, [kind, 'required', kw, 'optional'], arg if !tkw.is_a?(RDL::Type::OptionalType)
        env, default_type = tc(scope, env, arg.children[1])
        error :optional_default_kw_type, [kw, default_type, tkw.type], arg.children[1] unless default_type <= tkw.type
        kw_args_matched << kw
        targs[kw] = tkw.type
      elsif arg.type == :kwrestarg
        error :type_args_no_kws, [kind], e unless targ.is_a?(RDL::Type::FiniteHashType)
        error :type_args_no_kw_rest, [kind], arg if targ.rest.nil?
        targs[arg.children[0]] = RDL::Type::GenericType.new($__rdl_hash_type, $__rdl_symbol_type, targ.rest)
        kw_rest_matched = true
      elsif arg.type == :blockarg
        error :type_arg_block, [kind, kind], arg unless type.block
        targs[arg.children[0]] = type.block
        # Note no check that if type.block then method expects block, because blocks can be called with yield
      else
        error :generic_error, ["Don't know what to do with actual argument of type #{arg.type}"], arg
      end
    }
    if (tpos == type.args.length - 1) && type.args[tpos].is_a?(RDL::Type::FiniteHashType)
      rest = type.args[tpos].elts.keys - kw_args_matched
      error :type_args_kw_more, [kind, rest.map { |s| s.to_s }.join(", "), kind], ast unless rest.empty?
      error :type_args_kw_rest, [kind], ast unless kw_rest_matched || type.args[tpos].rest.nil?
    else
      error :type_args_more, [kind, kind], (if args.children.empty? then ast else args end) if type.args.length != tpos
    end
    return [env, targs]
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
      is_array = false
      e.children.each { |ei|
        if ei.type == :splat
          envi, ti = tc(scope, envi, ei.children[0]);
          if ti.is_a? RDL::Type::TupleType
            ti.cant_promote! # must remain a tuple
            tis.concat(ti.params)
          elsif ti.is_a? RDL::Type::FiniteHashType
            ti.cant_promote! # must remain a finite hash
            ti.elts.each_pair { |k, t|
              tis << RDL::Type::TupleType.new(RDL::Type::SingletonType.new(k), t)
            }
          elsif ti.is_a?(RDL::Type::GenericType) && ti.base == $__rdl_array_type
            is_array = true
            tis << ti.params[0]
          elsif ti.is_a?(RDL::Type::GenericType) && ti.base == $__rdl_hash_type
            is_array = true
            tis << RDL::Type::TupleType.new(*ti.params)
          elsif ti.is_a?(RDL::Type::SingletonType) && ti.val.nil?
            # nil gets thrown out
          elsif ($__rdl_array_type <= ti) || (ti <= $__rdl_array_type) ||
                ($__rdl_hash_type <= ti) || (ti <= $__rdl_hash_type)
            # might or might not be array...can't splat...
            error :cant_splat, [ti], ei
          else
            tis << ti # splat does nothing
          end
        else
          envi, ti = tc(scope, envi, ei);
          tis << ti
        end
      }
      if is_array
        [envi, RDL::Type::GenericType.new($__rdl_array_type, RDL::Type::UnionType.new(*tis).canonical)]
      else
        [envi, RDL::Type::TupleType.new(*tis)]
      end
    when :hash
      envi = env
      tlefts = []
      trights = []
      is_fh = true
      e.children.each { |p|
        # each child is a pair
        if p.type == :pair
          envi, tleft = tc(scope, envi, p.children[0])
          tlefts << tleft
          envi, tright = tc(scope, envi, p.children[1])
          trights << tright
          is_fh = false unless tleft.is_a?(RDL::Type::SingletonType)
        elsif p.type == :kwsplat
          envi, tkwsplat = tc(scope, envi, p.children[0])
          if tkwsplat.is_a? RDL::Type::FiniteHashType
            tkwsplat.cant_promote! # must remain finite hash
            tlefts.concat(tkwsplat.elts.keys.map { |k| RDL::Type::SingletonType.new(k) })
            trights.concat(tkwsplat.elts.values)
          elsif tkwsplat.is_a?(RDL::Type::GenericType) && tkwsplat.base == $__rdl_hash_type
            is_fh = false
            tlefts << tkwsplat.params[0]
            trights << tkwsplat.params[1]
          else
            error :cant_splat, [tkwsplat], p
          end
        else
          raise "Don't know what to do with #{p.type}"
        end
      }
      if is_fh
        # keys are all symbols
        fh = tlefts.map { |t| t.val }.zip(trights).to_h
        [envi, RDL::Type::FiniteHashType.new(fh, nil)]
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
      error :nonmatching_range_type, [t1, t2], e unless t1 <= t2 || t2 <= t1
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
        # Note don't need to check outer_env here because will be checked by tc_vasgn below
      }
      envi, tright = tc(scope, env, e.children[1])
      lhs = e.children[0].children
      if tright.is_a? RDL::Type::TupleType
        tright.cant_promote! # must always remain a tuple because of the way type checking currently works
        rhs = tright.params
        splat_ind = lhs.index { |lhs_elt| lhs_elt.type == :splat }
        if splat_ind
          if splat_ind > 0
            lhs[0..splat_ind-1].each { |left|
              # before splat
              error :masgn_bad_lhs, [], left if rhs.empty?
              envi, _ = tc_vasgn(scope, envi, left.type, left.children[0], rhs.shift, left)
            }
          end
          lhs[splat_ind+1..-1].reverse_each { |left|
            # after splat
            error :masgn_bad_lhs, [], left if rhs.empty?
            envi, _ = tc_vasgn(scope, envi, left.type, left.children[0], rhs.pop, left)
          }
          splat = lhs[splat_ind]
          envi, _ = tc_vasgn(scope, envi, splat.children[0].type, splat.children[0].children[0], RDL::Type::TupleType.new(*rhs), splat)
          [envi, tright]
        else
          error :masgn_num, [rhs.length, lhs.length], e unless lhs.length == rhs.length
          lhs.zip(rhs).each { |left, right|
            envi, _ = tc_vasgn(scope, envi, left.type, left.children[0], right, left)
          }
          [envi, tright]
        end
      elsif (tright.is_a? RDL::Type::GenericType) && (tright.base == $__rdl_array_type)
        tasgn = tright.params[0]
        lhs.each { |asgn|
          if asgn.type == :splat
            envi, _ = tc_vasgn(scope, envi, asgn.children[0].type, asgn.children[0].children[0], tright, asgn)
          else
            envi, _ = tc_vasgn(scope, envi, asgn.type, asgn.children[0], tasgn, asgn)
          end
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
        tloperand = tc_send(scope, envleft, trecv, meth, [], nil, e.children[0]) # call recv.meth()
        envoperand, troperand = tc(scope, envleft, e.children[2]) # operand
        tright = tc_send(scope, envoperand, tloperand, e.children[1], [troperand], nil, e) # recv.meth().op(operand)
        mutation_meth = (meth.to_s + '=').to_sym
        tres = tc_send(scope, envoperand, trecv, mutation_meth, [tright], nil, e) # call recv.meth=(recv.meth().op(operand))
        [envoperand, tres]
      else
        # (op-asgn (Xvasgn var-name) :op operand)
        x = e.children[0].children[0] # Note don't need to check outer_env here because will be checked by tc_vasgn below
        env = env.bind(x, $__rdl_nil_type) if ((e.children[0].type == :lvasgn) && (not (env.has_key? x))) # see :lvasgn
        envi, trecv = tc_var(scope, env, @@asgn_to_var[e.children[0].type], x, e.children[0]) # var being assigned to
        envright, tright = tc(scope, envi, e.children[2]) # operand
        trhs = tc_send(scope, envright, trecv, e.children[1], [tright], nil, e)
        tc_vasgn(scope, envright, e.children[0].type, x, trhs, e)
      end
    when :and_asgn, :or_asgn
      # very similar logic to op_asgn
      if e.children[0].type == :send
        meth = e.children[0].children[1]
        envleft, trecv = tc(scope, env, e.children[0].children[0]) # recv
        tleft = tc_send(scope, envleft, trecv, meth, [], nil, e.children[0]) # call recv.meth()
        envright, tright = tc(scope, envleft, e.children[1]) # operand
      else
        x = e.children[0].children[0] # Note don't need to check outer_env here because will be checked by tc_var below
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
        tres = tc_send(scope, envi, trecv, mutation_meth, [trhs], nil, e)
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
      when Module
        t = RDL::Type::SingletonType.new(const_get(e.children[1]))
        [env, t]
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
      return tc_var_type(scope, env, e) if e.children[1] == :var_type && e.children[0].nil?
      return tc_type_cast(scope, env, e) if e.children[1] == :type_cast && scope[:block].nil?
      return tc_note_type(scope, env, e) if e.children[1] == :rdl_note_type && e.children[0].nil?
      envi = env
      tactuals = []
      block = scope[:block]
      scope_merge(scope, block: nil) { |sscope|
        e.children[2..-1].each { |ei|
          if ei.type == :splat
            envi, ti = tc(sscope, envi, ei.children[0])
            if ti.is_a? RDL::Type::TupleType
              tactuals.concat ti.params
            elsif ti.is_a?(RDL::Type::GenericType) && ti.base == $__rdl_array_type
              tactuals << RDL::Type::VarargType.new(ti.params[0]) # Turn Array<t> into *t
            else
              error :cant_splat, [ti], ei.children[0]
            end
          elsif ei.type == :block_pass
            raise RuntimeError, "impossible to pass block arg and literal block" if scope[:block]
            envi, ti = tc(sscope, envi, ei.children[0])
            # convert using to_proc if necessary
            ti = tc_send(sscope, envi, ti, :to_proc, [], nil, ei) unless ti.is_a? RDL::Type::MethodType
            block = [ti, ei]
          else
            envi, ti = tc(sscope, envi, ei)
            tactuals << ti
          end
        }
        envi, trecv = if e.children[0].nil? then [envi, envi[:self]] else tc(sscope, envi, e.children[0]) end # if no receiver, self is receiver
        [envi, tc_send(sscope, envi, trecv, e.children[1], tactuals, block, e).canonical]
      }
    when :yield
      # very similar to send except the callee is the method's block
      error :no_block, [], e unless scope[:tblock]
      error :block_block, [], e if scope[:tblock].block
      scope[:exn] = Env.join(e, scope[:exn], env) if scope.has_key? :exn # assume this call might raise an exception
      envi = env
      tactuals = []
      e.children[0..-1].each { |ei| envi, ti = tc(scope, envi, ei); tactuals << ti }
      unless tc_arg_types(scope[:tblock], tactuals)
        msg = <<RUBY
      Block type: #{scope[:tblock]}
Actual arg types: (#{tactuals.map { |ti| ti.to_s }.join(', ')})
RUBY
        msg.chomp! # remove trailing newline
        error :block_type_error, [msg], e
      end
      [envi, scope[:tblock].ret]
      # tblock
    when :block
      # (block send block-args block-body)
      scope_merge(scope, block: [e.children[1], e.children[2]]) { |bscope|
        tc(bscope, env, e.children[0])
      }
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
        tguards = []
        wclause.children[0..-2].each { |guard| # first wclause.length-1 children are the guards
          envi, tguard = tc(scope, envi, guard) # guard type can be anything
          tguards << tguard
          tc_send(scope, envi, tguard, :===, [tcontrol], nil, guard) unless tcontrol.nil?
          envguards << envi
        }
        initial_env = Env.join(e, *envguards)
        if (tguards.all? { |typ| typ.is_a?(RDL::Type::SingletonType) && typ.val.is_a?(Class) }) && (e.children[0].type == :lvar)
          # Special case! We're branching on the type of the guard, which is a local variable.
          # So rebind that local variable to have the union of the guard types
          new_typ = RDL::Type::UnionType.new(*(tguards.map { |typ| RDL::Type::NominalType.new(typ.val) })).canonical
          # TODO adjust following for generics!
          if tcontrol.is_a? RDL::Type::GenericType
            if new_typ == tcontrol.base
              # special case: exact match of control type's base and type of guard; can use
              # geneirc type on this branch
              initial_env = initial_env.bind(e.children[0].children[0], tcontrol, force: true)
            elsif !(tcontrol.base <= new_typ) && !(new_typ <= tcontrol.base)
              next # can't possibly match this branch
            else
              error :generic_error, ["general refinement for generics not implemented yet"], wclause
            end
          else
            next unless tcontrol <= new_typ || new_typ <= tcontrol # If control can't possibly match type, skip this branch
            initial_env = initial_env.bind(e.children[0].children[0], new_typ, force: true)
            # note force is safe above because the env from this arm will be joined with the other envs
            # (where the type was not refined like this), so after the case the variable will be back to its
            # previous, unrefined type
          end
        end
        envbody, tbody = tc(scope, initial_env, wclause.children[-1]) # last wclause child is body
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
      # break: loop exit, i.e., right after loop guard; may take argument
      # next: before loop guard; argument not allowed
      # retry: not allowed
      # redo: after loop guard, which is same as break
      env_break, _ = tc(scope, env, e.children[0]) # guard can have any type, may exit after checking guard
      scope_merge(scope, break: env_break, tbreak: $__rdl_nil_type, next: env, redo: env_break) { |lscope|
        begin
          old_break = lscope[:break]
          old_next = lscope[:next]
          old_tbreak = lscope[:tbreak]
          if e.children[1]
            env_body, _ = tc(lscope, lscope[:break], e.children[1]) # loop runs
            lscope[:next] = Env.join(e, lscope[:next], env_body)
          end
          env_guard, _ = tc(lscope, lscope[:next], e.children[0]) # then guard runs
          lscope[:break] = lscope[:redo] = Env.join(e, lscope[:break], lscope[:redo], env_guard)
        end until old_break == lscope[:break] && old_next == lscope[:next] && old_tbreak == lscope[:tbreak]
        [lscope[:break], lscope[:tbreak].canonical]
      }
    when :while_post, :until_post
      # break: loop exit; note may exit loop before hitting guard once; maybe take argument
      # next: before loop guard; argument not allowed
      # retry: not allowed
      # redo: beginning of body, which is same as after guard, i.e., same as break
      scope_merge(scope, break: nil, tbreak: $__rdl_nil_type, next: nil, redo: nil) { |lscope|
        if e.children[1]
          env_body, _ = tc(lscope, env, e.children[1])
          lscope[:next] = Env.join(e, lscope[:next], env_body)
        end
        begin
          old_break = lscope[:break]
          old_next = lscope[:next]
          old_tbreak = lscope[:tbreak]
          env_guard, _ = tc(lscope, lscope[:next], e.children[0])
          lscope[:break] = lscope[:redo] = Env.join(e, lscope[:break], lscope[:redo], env_guard)
          if e.children[1]
            env_body, _ = tc(lscope, lscope[:break], e.children[1])
            lscope[:next] = Env.join(e, lscope[:next], env_body)
          end
        end until old_break == lscope[:break] && old_next == lscope[:next] && old_tbreak == lscope[:tbreak]
        [lscope[:break], lscope[:tbreak].canonical]
      }
    when :for
      # (for (lvasgn var) collection body)
      # break: loop exit, which is same as top of body, arg allowed
      # next: top of body, arg allowed
      # retry: not allowed
      # redo: top of body
      raise RuntimeError, "Loop variable #{e.children[0]} in for unsupported" unless e.children[0].type == :lvasgn
      # TODO: mlhs in e.children[0]
      x  = e.children[0].children[0] # loop variable
      envi, tcollect = tc(scope, env, e.children[1]) # collection to iterate through
      teaches = nil
      tcollect = tcollect.canonical
      case tcollect
      when RDL::Type::NominalType
        teaches = lookup(scope, tcollect.name, :each, e.children[1])
      when RDL::Type::GenericType, RDL::Type::TupleType, RDL::Type::FiniteHashType
        unless tcollect.is_a? RDL::Type::GenericType
          error :tuple_finite_hash_promote, (if tcollect.is_a? RDL::Type::TupleType then ['tuple', 'Array'] else ['finite hash', 'Hash'] end), e.children[1] unless tcollect.promote!
          tcollect = tcollect.canonical
        end
        teaches = lookup(scope, tcollect.base.name, :each, e.children[1])
        inst = tcollect.to_inst.merge(self: tcollect)
        teaches = teaches.map { |typ| typ.instantiate(inst) }
      else
        error :for_collection, [tcollect], e.children[1]
      end
      teach = nil
      teaches.each { |typ|
        # find `each` method with right type signature:
        #    () { (t1) -> t2 } -> t3
        next unless typ.args.empty?
        next if typ.block.nil?
        next unless typ.block.args.size == 1
        next unless typ.block.block.nil?
        teach = typ
        break
      }
      error :no_each_type, [tcollect.name], e.children[1] if teach.nil?
      envi, _ = tc_vasgn(scope, envi, :lvasgn, x, teach.block.args[0], e.children[0])
      scope_merge(scope, break: envi, next: envi, redo: envi, tbreak: teach.ret, tnext: envi[x])  { |lscope|
        # could exit here
        # if the loop always exits via break, then return type will come only from break, and otherwise the
        # collection is returned. But it's hard to tell statically if there are only exits via break, so
        # conservatively assume that at least the collection is returned.
        begin
          old_break = lscope[:break]
          old_tbreak = lscope[:tbreak]
          old_tnext = lscope[:tnext]
          if e.children[2]
            lscope[:break] = lscope[:break].bind(x, lscope[:tnext])
            env_body, _ = tc(lscope, lscope[:break], e.children[2])
            lscope[:break] = lscope[:next] = lscope[:redo] = Env.join(e, lscope[:break], lscope[:next], lscope[:redo], env_body)
          end
        end until old_break == lscope[:break] && old_tbreak == lscope[:tbreak] && old_tnext == lscope[:tnext]
        [lscope[:break], lscope[:tbreak].canonical]
      }
    when :break, :redo, :next, :retry
      error :kw_not_allowed, [e.type], e unless scope.has_key? e.type
      if e.children[0]
        tkw_name = ('t' + e.type.to_s).to_sym
        error :kw_arg_not_allowed, [e.type], e unless scope.has_key? tkw_name
        env, tkw = tc(scope, env, e.children[0])
        scope[tkw_name] = RDL::Type::UnionType.new(scope[tkw_name], tkw)
      end
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
    when :ensure
      # (ensure main-body ensure-body)
      # TODO exception control flow from main-body, vars initialized to nil
      env_body, tbody = tc(scope, env, e.children[0])
      env_ensure, _ = tc(scope, env_body, e.children[1])
      [env_ensure, tbody] # value of ensure not returned
    when :rescue
      # (rescue main-body resbody1 resbody2 ... (else else-body))
      # resbodyi, else optional
      # local variables assigned to in main-body will all be initialized to nil even if an exception
      # is raised during main-body's execution before those varibles are assigned to.
      # similarly, local variables assigned in resbody will be initialized to nil even if the resbody
      # is never triggered
      scope_merge(scope, retry: env, exn: nil) { |rscope|
        begin
          old_retry = rscope[:retry]
          env_body, tbody = tc(rscope, rscope[:retry], e.children[0])
          tres = [tbody] # note throw away inferred types from previous iterations---should be okay since should be monotonic
          env_res = [env_body]
          if rscope[:exn]
            e.children[1..-2].each { |resbody|
              env_resbody, tresbody = tc(rscope, rscope[:exn], resbody)
              tres << tresbody
              env_res << env_resbody
            }
            if e.children[-1]
              env_else, telse = tc(rscope, rscope[:exn], e.children[-1])
              tres << telse
              env_res << env_else
            end
          end
        end until old_retry == rscope[:retry]
        # TODO: variables newly bound in *env_res should be unioned with nil
        [Env.join(e, *env_res), RDL::Type::UnionType.new(*tres).canonical]
      }
    when :resbody
      # (resbody (array exns) (lvasgn var) rescue-body)
      envi = env
      texns = []
      if e.children[0]
        e.children[0].children.each { |exn|
          envi, texn = tc(scope, envi, exn)
          error :exn_type, [], exn unless texn.is_a?(RDL::Type::SingletonType) && texn.val.is_a?(Class)
          texns << RDL::Type::NominalType.new(texn.val)
        }
      else
        texns = [$__rdl_standard_error_type]
      end
      if e.children[1]
        envi, _ = tc_vasgn(scope, envi, :lvasgn, e.children[1].children[0], RDL::Type::UnionType.new(*texns), e.children[1])
      end
      tc(scope, envi, e.children[2])
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
      error :undefined_local_or_method, [name], e unless env.has_key? name
      capture(scope, name, env[name].canonical) if scope[:outer_env] && (scope[:outer_env].has_key? name) && (not (scope[:outer_env].fixed? name))
      if scope[:captured] && scope[:captured].has_key?(name) then
        [env, scope[:captured][name]]
      else
        [env, env[name].canonical]
      end
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
      if ((scope[:captured] && scope[:captured].has_key?(name)) ||
          (scope[:outer_env] && (scope[:outer_env].has_key? name) && (not (scope[:outer_env].fixed? name))))
        capture(scope, name, tright.canonical)
        [env, scope[:captured][name]]
      elsif (env.fixed? name)
        error :vasgn_incompat, [tright, env[name]], e unless tright <= env[name]
        [env, tright.canonical]
      else
        [env.bind(name, tright), tright.canonical]
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
      [env, tright.canonical]
    when :send
      meth = e.children[1] # note method name include =!
      envi, trecv = tc(scope, env, e.children[0]) # receiver
      typs = []
      if e.children.length > 2
        # special case of []= when there's a second arg (the index)
        # this code is a little more general than it has to be unless other similar operators added
        e.children[2..-1].each { |arg|
          envi, targ = tc(scope, envi, arg)
          typs << targ
        }
      end
      # name is not useful here
      [envi, tc_send(scope, envi, trecv, meth, [*typs, tright], nil, e)] # call receiver.meth(other args, tright)
    else
      raise RuntimeError, "unknown kind #{kind}"
    end
  end

  # [+ e +] is the method call
  def self.tc_var_type(scope, env, e)
    error :var_type_format, [], e unless e.children.length == 4 && scope[:block].nil?
    var = e.children[2].children[0] if e.children[2].type == :sym
    error :var_type_format, [], e.children[2] if var.nil? || (not (var =~ /^[a-z]/))
    typ_str = e.children[3].children[0] if (e.children[3].type == :str) || (e.children[3].type == :string)
    error :var_type_format, [], e.children[3] if typ_str.nil?
    begin
      typ = $__rdl_parser.scan_str("#T " + typ_str)
    rescue Racc::ParseError => err
      error :generic_error, [err.to_s[1..-1]], e.children[3] # remove initial newline
    end
    [env.fix(var, typ), $__rdl_nil_type]
  end

  def self.tc_type_cast(scope, env, e)
    error :type_cast_format, [], e unless e.children.length <= 4
    typ_str = e.children[2].children[0] if (e.children[2].type == :str) || (e.children[2].type == :string)
    error :type_cast_format, [], e.children[2] if typ_str.nil?
    begin
      typ = $__rdl_parser.scan_str("#T " + typ_str)
    rescue Racc::ParseError => err
      error :generic_error, [err.to_s[1..-1]], e.children[2] # remove initial newline
    end
    if e.children[3]
      fh = e.children[3]
      error :type_cast_format, [], fh unless fh.type == :hash && fh.children.length == 1
      pair = fh.children[0]
      error :type_cast_format, [], fh unless pair.type == :pair && pair.children[0].type == :sym && pair.children[0].children[0] == :force
      force_arg = pair.children[1]
      env1, _ = tc(scope, env, force_arg)
    end
    [env1, typ]
  end

  def self.tc_note_type(scope, env, e)
    error :note_type_format, [], e unless e.children.length == 3 && scope[:block].nil?
    env, typ = tc(scope, env, e.children[2])
    note :note_type, [typ], e.children[2]
    [env, typ]
  end

  # Type check a send
  # [+ scope +] is the scope; used only for checking block arguments
  # [+ env +] is the environment; used only for checking block arguments.
  #   Note locals from blocks args don't escape, so no env is returned.
  # [+ trecvs +] is the type of the recevier
  # [+ meth +] is a symbol with the method name
  # [+ tactuals +] are the actual arguments
  # [+ block +] is a pair of expressions [block-args, block-body], from the block AST node OR [block-type, block-arg-AST-node]
  # [+ e +] is the expression at which location to report an error
  def self.tc_send(scope, env, trecvs, meth, tactuals, block, e)
    scope[:exn] = Env.join(e, scope[:exn], env) if scope.has_key? :exn # assume this call might raise an exception

    # convert trecvs to array containing all receiver types
    trecvs = trecvs.canonical
    trecvs = if trecvs.is_a? RDL::Type::UnionType then trecvs.types else [trecvs] end

    trets = []
    trecvs.each { |trecv|
      trets.concat(tc_send_one_recv(scope, env, trecv, meth, tactuals, block, e))
    }
    trets.map! {|t| t.is_a?(RDL::Type::AnnotatedArgType) ? t.type : t}
    return RDL::Type::UnionType.new(*trets)
  end

  # Like tc_send but trecv should never be a union type
  # Returns array of possible return types, or throws exception if there are none
  def self.tc_send_one_recv(scope, env, trecv, meth, tactuals, block, e)
    tmeth_inter = [] # Array<MethodType>, i.e., an intersection types
    case trecv
    when RDL::Type::SingletonType
      if trecv.val.is_a? Class or trecv.val.is_a? Module
        ts = lookup(scope, RDL::Util.add_singleton_marker(trecv.val.to_s), meth, e)
        ts = [RDL::Type::MethodType.new([], nil, RDL::Type::NominalType.new(trecv.val))] if (meth == :new) && (ts.nil?) # there's always a nullary new if initialize is undefined
        error :no_singleton_method_type, [trecv.val, meth], e unless ts
        inst = {self: trecv}
        tmeth_inter = ts.map { |t| t.instantiate(inst) }
      elsif trecv.val.is_a?(Symbol) && meth == :to_proc
        # Symbol#to_proc on a singleton symbol type produces a Proc for the method of the same name
        if env[:self].is_a?(RDL::Type::NominalType)
          klass = env[:self].klass
        else # SingletonType(class)
          klass = env[:self].val
        end
        ts = lookup(scope, klass.to_s, trecv.val, e)
        error :no_type_for_symbol, [trecv.val.inspect], e if ts.nil?
        return ts
      else
        klass = trecv.val.class.to_s
        ts = lookup(scope, klass, meth, e)
        error :no_instance_method_type, [klass, meth], e unless ts
        inst = {self: trecv}
        tmeth_inter = ts.map { |t| t.instantiate(inst) }
      end
    when RDL::Type::NominalType
      ts = lookup(scope, trecv.name, meth, e)
      error :no_instance_method_type, [trecv.name, meth], e unless ts
      inst = {self: trecv}
      tmeth_inter = ts.map { |t| t.instantiate(inst) }
    when RDL::Type::GenericType, RDL::Type::TupleType, RDL::Type::FiniteHashType
      unless trecv.is_a? RDL::Type::GenericType
        error :tuple_finite_hash_promote, (if trecv.is_a? RDL::Type::TupleType then ['tuple', 'Array'] else ['finite hash', 'Hash'] end), e unless trecv.promote!
        trecv = trecv.canonical
      end
      ts = lookup(scope, trecv.base.name, meth, e)
      error :no_instance_method_type, [trecv.base.name, meth], e unless ts
      inst = trecv.to_inst.merge(self: trecv)
      tmeth_inter = ts.map { |t| t.instantiate(inst) }
    when RDL::Type::VarType
      error :recv_var_type, [trecv], e
    when RDL::Type::MethodType
      if meth == :call
        # Special case - invokes the Proc
        tmeth_inter = [trecv]
      else
        # treat as Proc
        tc_send_one_recv(scope, env, $__rdl_proc_type, meth, tactuals, block, e)
      end
    else
      raise RuntimeError, "receiver type #{trecv} not supported yet"
    end

    trets = [] # all possible return types
    # there might be more than one return type because multiple cases of an intersection type might match

    # for ALL of the expanded lists of actuals...
    RDL::Type.expand_product(tactuals).each { |tactuals_expanded|
      # AT LEAST ONE of the possible intesection arms must match
      trets_tmp = []
      tmeth_inter.each { |tmeth| # MethodType
        if ((tmeth.block && block) || (tmeth.block.nil? && block.nil?))
          tmeth_inst = tc_arg_types(tmeth, tactuals_expanded)
          if tmeth_inst
            tc_block(scope, env, tmeth.block, block, tmeth_inst) if block
            trets_tmp << tmeth.ret.instantiate(tmeth_inst) # found a match for this subunion; add its return type to trets_tmp
          end
        end
      }
      if trets_tmp.empty?
        # no arm of the intersection matched this expanded actuals lists, so reset trets to signal error and break loop
        trets = []
        break
      else
        trets.concat(trets_tmp)
      end
    }
    if trets.empty? # no possible matching call
      msg = <<RUBY
Method type:
#{ tmeth_inter.map { |ti| "        " + ti.to_s }.join("\n") }
Actual arg type#{tactuals.size > 1 ? "s" : ""}:
      (#{tactuals.map { |ti| ti.to_s }.join(', ')}) #{if block then '{ block }' end}
RUBY
      msg.chomp! # remove trailing newline
      name = if trecv.is_a?(RDL::Type::SingletonType) && trecv.val.is_a?(Class) && (meth == :new) then
        :initialize
      elsif trecv.is_a? RDL::Type::SingletonType
        trecv.val.class.to_s
      elsif trecv.is_a?(RDL::Type::NominalType) || trecv.is_a?(RDL::Type::GenericType)
        trecv.to_s
      elsif trecv.is_a?(RDL::Type::MethodType)
        'Proc'
      else
        raise RuntimeError, "impossible to get type #{trecv}"
      end
      error :arg_type_single_receiver_error, [name, meth, msg], e
    end
    # TODO: issue warning if trets.size > 1 ?
    return trets
  end

  # [+ tmeth +] is MethodType
  # [+ actuals +] is Array<Type> containing the actual argument types
  # return instiation (possibly empty) that makes actuals match method type (if any), nil otherwise
  # Very similar to MethodType#pre_cond?
  def self.tc_arg_types(tmeth, tactuals)
    states = [[0, 0, Hash.new]] # position in tmeth, position in tactuals, inst of free vars in tmeth
    tformals = tmeth.args
    until states.empty?
      formal, actual, inst = states.pop
      inst = inst.dup # avoid aliasing insts in different states since Type.leq mutates inst arg
      if formal == tformals.size && actual == tactuals.size # Matched everything
        return inst
      end
      next if formal >= tformals.size # Too many actuals to match
      t = tformals[formal]
      if t.instance_of? RDL::Type::AnnotatedArgType
        t = t.type
      end
      case t
      when RDL::Type::OptionalType
        t = t.type
        if actual == tactuals.size
          states << [formal+1, actual, inst] # skip over optinal formal
        elsif (not (tactuals[actual].is_a?(RDL::Type::VarargType))) && RDL::Type::Type.leq(tactuals[actual], t, inst, false)
          states << [formal+1, actual+1, inst] # match
          states << [formal+1, actual, inst] # skip
        else
          states << [formal+1, actual, inst] # types don't match; must skip this formal
        end
      when RDL::Type::VarargType
        if actual == tactuals.size
          states << [formal+1, actual, inst] # skip to allow empty vararg at end
        elsif (not (tactuals[actual].is_a?(RDL::Type::VarargType))) && RDL::Type::Type.leq(tactuals[actual], t.type, inst, false)
          states << [formal, actual+1, inst] # match, more varargs coming
          states << [formal+1, actual+1, inst] # match, no more varargs
          states << [formal+1, actual, inst] # skip over even though matches
        elsif tactuals[actual].is_a?(RDL::Type::VarargType) && RDL::Type::Type.leq(tactuals[actual].type, t.type, inst, false) &&
                                                               RDL::Type::Type.leq(t.type, tactuals[actual].type, inst, true)
          states << [formal+1, actual+1, inst] # match, no more varargs; no other choices!
        else
          states << [formal+1, actual, inst] # doesn't match, must skip
        end
      else
        if actual == tactuals.size
          next unless t.instance_of? RDL::Type::FiniteHashType
          if @@empty_hash_type <= t
            states << [formal+1, actual, inst]
          end
        elsif (not (tactuals[actual].is_a?(RDL::Type::VarargType))) && RDL::Type::Type.leq(tactuals[actual], t, inst, false)
          states << [formal+1, actual+1, inst] # match!
          # no else case; if there is no match, this is a dead end
        end
      end
    end
    return nil
  end

  # [+ tblock +] is the type of the block (a MethodType)
  # [+ block +] is a pair [block-args, block-body] from the block AST node OR [block-type, block-arg-AST-node]
  # returns if the block matches type tblock
  # otherwise throws an exception with a type error
  def self.tc_block(scope, env, tblock, block, inst)
    # TODO self is the same *except* instance_exec or instance_eval
    raise RuntimeError, "block with block arg?" unless tblock.block.nil?
    tblock = tblock.instantiate(inst)
    if block[0].is_a? RDL::Type::MethodType
      error :bad_block_arg_type, [block[0], tblock], block[1] unless block[0] <= tblock
    elsif block[0].is_a?(RDL::Type::NominalType) && block[0].name == 'Proc'
      error :proc_block_arg_type, [tblock], block[1]
    else # must be [block-args, block-body]
      args, body = block
      env, targs = args_hash(scope, env, tblock, args, block, 'block')
      scope_merge(scope, outer_env: env) { |bscope|
        # note: okay if outer_env shadows, since nested scope will include outer scope by next line
        env = env.merge(Env.new(targs))
        _, body_type = if body.nil? then [nil, $__rdl_nil_type] else tc(bscope, env.merge(Env.new(targs)), body) end
        error :bad_return_type, [body_type, tblock.ret], body unless body.nil? || RDL::Type::Type.leq(body_type, tblock.ret, inst, false)
        #
      }
    end
  end

  # [+ klass +] is a string containing the class name
  # [+ name +] is a symbol naming the thing to look up (either a method or field)
  # returns klass#name's type, walking up the inheritance hierarchy if appropriate
  # returns nil if no type found
  # types in scope[:context_type] take precedence

  # *always* included module's instance methods only
  # if included, those methods are added to instance_methods
  # if extended, those methods are added to singleton_methods
  # (except Kernel is special...)
  def self.lookup(scope, klass, name, e)
    if scope[:context_types]
      # return array of all matching types from context_types, if any
      ts = []
      scope[:context_types].each { |ctk, ctm, ctt| ts << ctt if ctk.to_s == klass && ctm == name  }
      return ts unless ts.empty?
    end
    if scope[:context_types]
      scope[:context_types].each { |k, m, t|
        return t if k == klass && m = name
      }
    end
    t = $__rdl_info.get_with_aliases(klass, name, :type)
    return t if t # simplest case, no need to walk inheritance hierarchy
    the_klass = RDL::Util.to_class(klass)
    is_singleton = RDL::Util.has_singleton_marker(the_klass.to_s)
    included = the_klass.included_modules
    the_klass.ancestors[1..-1].each { |ancestor|
      # assumes ancestors is proper order to walk hierarchy
      # included modules' instance methods get added as instance methods, so can't be in singleton class
      next if (ancestor.instance_of? Module) && (included.member? ancestor) && is_singleton
      # extended (i.e., not included) modules' instance methods get added as singleton methods, so can't be in class
      next if (ancestor.instance_of? Module) && (not (included.member? ancestor)) && (not is_singleton)
      tancestor = $__rdl_info.get_with_aliases(ancestor.to_s, name, :type)
      return tancestor if tancestor
      # special caes: Kernel's singleton methods are *also* added when included?!
      if ancestor == Kernel
        tancestor = $__rdl_info.get_with_aliases(RDL::Util.add_singleton_marker('Kernel'), name, :type)
        return tancestor if tancestor
      end
      if ancestor.instance_methods(false).member?(name)
        if RDL::Util.has_singleton_marker klass
          klass = RDL::Util.remove_singleton_marker klass
          klass = '(singleton) ' + klass
        end

        return nil if the_klass.to_s.start_with?('#<Class:') and name ==:new
        error :missing_ancestor_type, [ancestor, klass, name], e
      end
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
  inconsistent_var_type: "local variable `%s' has declared type on some paths but not all",
  inconsistent_var_type_type: "local variable `%s' declared with inconsistent types %s",
  no_each_type: "can't find `each' method with signature `() { (t1) -> t2 } -> t3' in class `%s'",
  tuple_finite_hash_promote: "can't promote `%s' to `%s'",
  masgn_bad_rhs: "multiple assignment has right-hand side of type `%s' where tuple or array expected",
  masgn_num: "can't multiple-assign %d values to %d variables",
  masgn_bad_lhs: "no corresponding right-hand side elemnt for left-hand side assignee",
  kw_not_allowed: "can't use `%s' in current scope",
  kw_arg_not_allowed: "argument to `%s' not allowed in current scope",
  no_block: "attempt to call yield in method not declared to take a block argument",
  block_block: "can't call yield on a block expecting another block argument",
  block_type_error: "argument type error for block\n%s",
  missing_ancestor_type: "ancestor `%s' of `%s' has method `%s' but no type for it",
  type_cast_format: "type_cast must be called as `type_cast type-string' or `type_cast type-string, force: expr'",
  var_type_format: "var_type must be called as `var_type :var-name, type-string'",
  puts_type_format: "puts_type must be called as `puts_type e'",
  generic_error: "%s",
  exn_type: "can't determine exception type",
  cant_splat: "can't type splat with element of type `%s'",
  for_collection: "can't type for with collection of type `%s'",
  note_type: "Type is `%s'",
  note_message: "%s",
  recv_var_type: "receiver whose type is unconstrained variable `%s' not allowed",
  type_args_more: "%s type accepts more arguments than actual %s definition",
  type_args_fewer: "%s type accepts fewer arguments than actual %s definition",
  type_arg_kind_mismatch: "%s type has %s argument but actual argument is %s",
  type_args_no_kws: "%s type does not expect keyword arguments but actual expects keywords",
  type_args_no_kw: "%s type does not expect keyword argument `%s'",
  type_args_kw_mismatch: "%s type has %s keyword `%s' but actual argument is %s",
  type_args_kw_more: "%s type expects keywords `%s' that are not expected by actual %s",
  type_args_no_kw_rest: "%s type has no rest keyword but actual method accepts rest keywords",
  type_args_kw_rest: "%s type has rest keyword but actual method does not accept rest keywords",
  optional_default_type: "default value has type `%s' where type `%s' expected",
  optional_default_kw_type: "default value for `%s' has type `%s' where type `%s' expected",
  type_arg_block: "%s type does not expect block but actual %s takes block",
  bad_block_arg_type: "block argument has type `%s' but expecting type `%s'",
  non_block_block_arg: "block argument should have a block type but instead has type `%s'",
  proc_block_arg_type: "block argument is a Proc; can't tell if it matches expected type `%s'",
  no_type_for_symbol: "can't find type for method corresponding to `%s.to_proc'",
}
old_messages = Parser::MESSAGES
Parser.send(:remove_const, :MESSAGES)
Parser.const_set :MESSAGES, (old_messages.merge(type_error_messages))
