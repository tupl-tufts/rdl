# coding: utf-8
module RDL::Typecheck

  class StaticTypeError < StandardError; end
  class BlockTypeError < StaticTypeError; end

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
  # Envs should be immutable
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

    def clone
      result = Hash.new
      result.env = @env.clone
    end

    # force should only be used with care! currently only used when type is being refined to a subtype in a lexical scope
    def bind(var, typ, fixed: false, force: false)
      raise RuntimeError, "Can't update variable with fixed type" if !force && @env[var] && @env[var][:fixed]
      raise RuntimeError, "Can't fix type of already-bound variable" if !force && fixed && @env[var]
      result = Env.new
      result.env = @env.merge(var => {type: typ, fixed: fixed})
      return result
    end

    def has_key?(var)
      return @env.has_key?(var)
    end

    def fix(var, typ, force: false)
      raise RuntimeError, "Can't fix type of already-bound variable" if !force && @env[var]
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

    def to_s
      @env.to_a.map { |k,v| "#{k}: #{if v[:fixed] then '[fixed]' end}#{v[:type]}"}.join(", ")
    end

    # merges bindings in self with bindings in other, preferring bindings in other if there is a common key
    def merge(other)
      result = Env.new
      result.env = @env.merge(other.env)
      return result
    end

    # self is the caller env; other is the env at the end of a block; arg_names are the named block params (Array<Symbol>)
    # returns a new env with everying in (body_env - arg_names) ∩ outer_env added as a weak update to self
    def merge_block_env(other, arg_names)
      return self if other.nil?
      result = Env.new
      @env.each { |k, v|
        if (other.env.has_key? k) && (not (arg_names.include? k))
          # weak update
          unless @env[k][:fixed] == other.env[k][:fixed]
            raise RuntimeError, "Variable #{k} fixed in caller but not in block should be impossible"
          end
          typ = RDL::Type::UnionType.new(v[:type], other.env[k][:type])
          typ = typ.canonical
          if typ.instance_of?(RDL::Type::UnionType)
            sings = 0
            typ.types.each { |t| sings = sings + 1 if t.instance_of?(RDL::Type::SingletonType) }
            typ = typ.widen if sings > RDL::Config.instance.widen_bound
          end
          result.env[k] = {type: typ, fixed: @env[k][:fixed]}
        else
          result.env[k] = v
        end
      }
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
          RDL::Typecheck.error :inconsistent_var_type, [var.to_s], e unless rest.all? { |other| (other.fixed? var) || (not (other.has_key? var)) }
          neq = []
          rest.each { |other|
            other_typ = other[var]
            neq << other_typ unless first_typ == other_typ
          }
          RDL::Typecheck.error :inconsistent_var_type_type, [var.to_s, ([first_typ] + neq).map { |t| t.to_s }.join(' and ')], e unless neq.empty?
          env.env[var] = {type: h[:type], fixed: true}
        else
          typ = RDL::Type::UnionType.new(first_typ, *rest.map { |other| ((other.has_key? var) && other[var]) || RDL::Globals.types[:nil] })
          typ = typ.canonical
          if typ.instance_of?(RDL::Type::UnionType)
            sings = 0
            typ.types.each { |t| sings = sings + 1 if t.instance_of?(RDL::Type::SingletonType) }
            typ = typ.widen if sings > RDL::Config.instance.widen_bound
          end
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

  # report msg at ast's loc
  def self.error(reason, args, ast, block: false)
    errtype = block ? BlockTypeError : StaticTypeError
    raise errtype, ("\n" + (Diagnostic.new :error, reason, args, ast.loc.expression).render.join("\n"))
  end

  def self.note(reason, args, ast)
    puts (Diagnostic.new :note, reason, args, ast.loc.expression).render
  end

  def self.get_leaves(node, r=[])
    node.children.each {|n|
      if n.is_a? AST::Node
        get_leaves(n, r)
      elsif n
        r.push n
      end
    }
    r
  end

  def self.is_RDL(node)
    return node != nil && node.type == :const && node.children[0] == nil && node.children[1] == :RDL
  end

  def self.get_ast(klass, meth)
    file, line = RDL::Globals.info.get(klass, meth, :source_location)

    return nil if file.nil?
    #   return nil if RDL::Config.instance.continue_on_errors
    #
    #   raise RuntimeError, "No file for #{RDL::Util.pp_klass_method(klass, meth)}" if file.nil?
    # end

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
    cache_hit = ((RDL::Globals.parser_cache.has_key? file) &&
                 (RDL::Globals.parser_cache[file][0] == digest))

    unless cache_hit
      begin
        file_ast = Parser::CurrentRuby.parse_file file
        mapper = ASTMapper.new(file)
        mapper.process(file_ast)
        cache = {ast: file_ast, line_defs: mapper.line_defs}
        RDL::Globals.parser_cache[file] = [digest, cache]
      rescue => e
        RDL::Logging.log :typecheck, :error, "Failed to parse #{file}; #{e}"
        return nil if RDL::Config.instance.continue_on_errors

        raise e
      end
    end
    ast = RDL::Globals.parser_cache[file][1][:line_defs][line]
    return ast
  end

  def self.infer(klass, meth)
    _infer(klass, meth)
  rescue => exn
    raise exn unless RDL::Config.instance.continue_on_errors
    RDL::Logging.log :inference, :error, "Error; Skipping inference for #{RDL::Util.pp_klass_method(klass, meth)}"
    RDL::Logging.log :inference, :debug, "... got exception: #{exn}"
    # RDL::Globals.info.set(klass, meth, :type, [RDL::Globals.types[:dyn]])
  end

  def self._infer(klass, meth)
    RDL::Logging.log_header :inference, :debug, "Infering #{RDL::Util.pp_klass_method(klass, meth)}"

    RDL::Config.instance.use_comp_types = true
    RDL::Config.instance.number_mode = true
    @var_cache = {}
    ast = get_ast(klass, meth)
    if ast.nil?
      RDL::Logging.log :inference, :warning, "Warning: Can't find source for class #{RDL::Util.pp_klass_method(klass, meth)}; skipping method"

      # if RDL::Config.instance.continue_on_errors
      #   puts "#{warning_text} recording %dyn" if RDL::Config.instance.convert_to_dyn_verbose
      #   RDL::Globals.info.set(klass, meth, :type, [RDL::Globals.types[:dyn]])
      #   return
      # end

      return
    end
    types = RDL::Globals.info.get(klass, meth, :type)

    if types == [] or types.nil?
      ## in this case, have to create new arg/ret VarTypes for this method
      meth_type = make_unknown_method_type(klass, meth)
      arg_types = meth_type.args
      block_type = meth_type.block
      ret_vartype = meth_type.ret
    else
      ## in this case, a MethodType was found for this method.
      ## it had better be composed of VarTypes so we can infer something.
      raise "Expected just one type composed of VarTypes for method to be inferred." if types.size > 1
      meth_type = types[0]

      arg_types = meth_type.args
      block_type = meth_type.block
      ret_vartype = meth_type.ret

      raise "Expected VarTypes in MethodType to be inferred, got #{meth_type}." unless (arg_types + [block_type] + [ret_vartype]).all? { |t| !t.nil? && (t.kind_of_var_input? || (meth == :initialize)) }
    end

    if ast.type == :def
      name, args, body = *ast
    elsif ast.type == :defs
      _, name, args, body = *ast
    else
      raise RuntimeError, "Unexpected ast type #{ast.type}"
    end

    if name.to_sym != meth
      RDL::Logging.log :inference, :info, "Aliasing #{meth} to #{name}"
      RDL.alias klass, meth, name
      return
    end
    error :internal, "Method #{name} defined where method #{meth} expected", ast if name.to_sym != meth
    context_types = RDL::Globals.info.get(klass, meth, :context_types)

    if RDL::Util.has_singleton_marker(klass)
      # to_class gets the class object itself, so remove singleton marker to get class rather than singleton class
      self_type = RDL::Type::SingletonType.new(RDL::Util.to_class(RDL::Util.remove_singleton_marker(klass)))
    else
      self_type = RDL::Type::NominalType.new(klass)
    end

    inst = {self: self_type}

    meth_type = meth_type.instantiate inst

    scope = { task: :infer, klass: klass, meth: meth, tret: meth_type.ret, tblock: meth_type.block, context_types: context_types }
    # default args seem to be evaluated in the method body, so same scope
    _, targs = args_hash(scope, Env.new(inst), meth_type, args, ast, 'method')
    targs[:self] = self_type

    # TODO: Compute captured?

    if body.nil?
      body_type = RDL::Globals.types[:nil]
    else
      targs_dup = Hash[targs.map { |k, t| [k, t.copy] }] ## args can be mutated in method body. duplicate to avoid this. TODO: check on this
      @num_casts = 0
      _, body_type = tc(scope, Env.new(targs_dup), body) ## TODO: need separate argument indicating we're performing inference? or is this exactly the same as type checking...
    end

    #body_type = self_type if meth == :initialize
    body_type = RDL::Globals.parser.scan_str "#T self" if meth == :initialize # JF: Why not inst.self?
    if body_type.is_a?(RDL::Type::UnionType)
      body_type.types.each { |t| RDL::Type::Type.leq(t, ret_vartype, ast: ast) }
    else
      RDL::Type::Type.leq(body_type, ret_vartype, ast: ast)
    end

    RDL::Globals.info.set(klass, meth, :typechecked, true)

    RDL::Globals.constrained_types << [klass, meth]
    RDL::Logging.log :inference, :debug, "Done with constraint generation."
  end

  def self.typecheck(klass, meth, ast=nil, types = nil)
    # puts "Typechecking #{klass}##{meth}"
    ast = get_ast(klass, meth) unless ast
    raise RuntimeError, "Can't find source for class #{RDL::Util.pp_klass_method(klass, meth)}" if ast.nil?
    types = RDL::Globals.info.get(klass, meth, :type) unless types

    raise RuntimeError, "Can't typecheck method with no types?!" if types.nil? or types == []

    if ast.type == :def
      name, args, body = *ast
    elsif ast.type == :defs
      _, name, args, body = *ast
    else
      raise RuntimeError, "Unexpected ast type #{ast.type}"
    end
    error :internal, "Method #{name} defined where method #{meth} expected", ast if name.to_sym != meth
    context_types = RDL::Globals.info.get(klass, meth, :context_types)
    types.each { |type|
      if RDL::Util.has_singleton_marker(klass)
        # to_class gets the class object itself, so remove singleton marker to get class rather than singleton class
        self_type = RDL::Type::SingletonType.new(RDL::Util.to_class(RDL::Util.remove_singleton_marker(klass)))
      else
        self_type = RDL::Type::NominalType.new(klass)
      end
      if meth == :initialize
        # initialize method must always return "self" or GenericType where base is "self"
        error :bad_initialize_type, [], ast unless ((type.ret.is_a?(RDL::Type::VarType) && type.ret.name == :self) || (type.ret.is_a?(RDL::Type::GenericType) && type.ret.base.is_a?(RDL::Type::VarType) && type.ret.base.name == :self))
      end
      raise RuntimeError, "Type checking of methods with computed types is not currently supported." unless (type.args + [type.ret]).all? { |t| !t.instance_of?(RDL::Type::ComputedType) }
      inst = {self: self_type}
      type = type.instantiate inst
      scope = { task: :check, klass: klass, meth: meth, tret: type.ret, tblock: type.block, context_types: context_types }
      # default args seem to be evaluated in the method body, so same scope
      _, targs = args_hash(scope, Env.new(:self => self_type), type, args, ast, 'method')
      targs[:self] = self_type

      # TODO: Compute captured

      if body.nil?
        body_type = RDL::Globals.types[:nil]
      else
        targs_dup = Hash[targs.map { |k, t| [k, t.copy] }] ## args can be mutated in method body. duplicate to avoid this. TODO: check on this
        @num_casts = 0
        _, body_type = tc(scope, Env.new(targs_dup), body)
      end
      error :bad_return_type, [body_type.to_s, type.ret.to_s], body unless body.nil? || meth == :initialize ||RDL::Type::Type.leq(body_type, type.ret, ast: ast)
    }

    if RDL::Config.instance.check_comp_types
      new_meth = WrapCall.rewrite(ast) # rewrite ast to insert dynamic checks
      RDL::Util.silent_warnings { RDL::Util.to_class(klass).class_eval(new_meth) } # redefine method in the same class
    end
    RDL::Globals.info.set(klass, meth, :typechecked, true)
  end

  def self.get_num_casts
    return @num_casts
  end

  ### TODO: clean up below. Should probably incorporate it into `targs.merge` call in `self.typecheck`.
  def self.widen_scopes(h1, h2)
    h1new = h1.nil? ? nil : {}
    h2new = {}
    [[h1, h1new], [h2, h2new]].each { |hash, newhash|
      next if h1.nil?
      hash.each { |k, v|
        case v
        when RDL::Type::TupleType
          if v.params.size > 10
            newhash[k] = v.promote
          else
            newhash[k] = v
          end
        when RDL::Type::FiniteHashType
          if v.elts.size > 10
            newhash[k] = v.promote
          else
            newhash[k] = v
          end
        when RDL::Type::PreciseStringType
          if v.vals.size > 10 || (v.vals.size == 1 && v.vals[0].size > 10)
            newhash[k] = RDL::Globals.types[:string]
          else
            newhash[k] = v
          end
        when RDL::Type::UnionType
          if v.types.size > 10
            newhash[k] = v.widen
          else
            newhash[k] = v
          end
        else
          newhash[k] = v
        end
      }
    }
    [h1new, h2new]
  end

  def self.widen_envs(e1, e2)
    e1_env = e1.nil? ? nil : e1.env
    e1_hash, e2_hash = widen_scopes(e1_env, e2.env)
    e2.env = e2_hash
    e1.env = e1_hash if e1
    [e1, e2]
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
    args.children.each_with_index { |arg, index|
      error :type_args_fewer, [kind, kind], arg, block: (kind == 'block') if tpos >= type.args.length && arg.type != :blockarg  # blocks could be called with yield
      targ = type.args[tpos]
      (if (targ.is_a?(RDL::Type::AnnotatedArgType) || targ.is_a?(RDL::Type::DependentArgType) || targ.is_a?(RDL::Type::BoundArgType)) then targ = targ.type end)
      if arg.type == :arg
        if kind == 'block'
          targs[arg.children[0]] = (targ.optional? || targ.vararg?) ? targ.type : targ
          env = env.merge(Env.new(arg.children[0] => targ))
          tpos += 1 unless (targ.optional? || targ.vararg?) && !(index == args.children.size - 1)
        else
          error :type_arg_kind_mismatch, [kind, 'optional', 'required'], arg, block: (kind == 'block') if (targ.optional? && !(kind == 'block')) ## block arg type can be optional while actual arg is required
          error :type_arg_kind_mismatch, [kind, 'vararg', 'required'], arg, block: (kind == 'block') if targ.vararg?
          targs[arg.children[0]] = targ
          env = env.merge(Env.new(arg.children[0] => targ))
          tpos += 1
        end
      elsif arg.type == :optarg
        error :type_arg_kind_mismatch, [kind, 'vararg', 'optional'], arg, block: (kind == 'block') if targ.vararg?
        error :type_arg_kind_mismatch, [kind, 'required', 'optional'], arg, block: (kind == 'block') if !targ.optional?
        env, default_type = tc(scope, env, arg.children[1])
        error :optional_default_type, [default_type, targ.type], arg.children[1], block: (kind == 'block') unless RDL::Type::Type.leq(default_type, targ.type, ast: ast)
        targs[arg.children[0]] = targ.type
        env = env.merge(Env.new(arg.children[0] => targ.type))
        tpos += 1
      elsif arg.type == :restarg
        error :type_arg_kind_mismatch, [kind, 'optional', 'vararg'], arg, block: (kind == 'block') if targ.optional?
        error :type_arg_kind_mismatch, [kind, 'required', 'vararg'], arg, block: (kind == 'block') if !targ.vararg?
        targs[arg.children[0]] = RDL::Type::GenericType.new(RDL::Globals.types[:array], targ.type)
        tpos += 1
      elsif arg.type == :kwarg
        error :type_args_no_kws, [kind], arg, block: (kind == 'block') unless targ.is_a?(RDL::Type::FiniteHashType)
        kw = arg.children[0]
        error :type_args_no_kw, [kind, kw], arg, block: (kind == 'block') unless targ.elts.has_key? kw
        tkw = targ.elts[kw]
        error :type_args_kw_mismatch, [kind, 'optional', kw, 'required'], arg, block: (kind == 'block') if tkw.is_a? RDL::Type::OptionalType
        kw_args_matched << kw
        targs[kw] = tkw
        env = env.merge(Env.new(kw => tkw))
      elsif arg.type == :kwoptarg
        error :type_args_no_kws, [kind], arg, block: (kind == 'block') unless targ.is_a?(RDL::Type::FiniteHashType)
        kw = arg.children[0]
        error :type_args_no_kw, [kind, kw], arg, block: (kind == 'block') unless targ.elts.has_key? kw
        tkw = targ.elts[kw]
        error :type_args_kw_mismatch, [kind, 'required', kw, 'optional'], arg, block: (kind == 'block') if !tkw.is_a?(RDL::Type::OptionalType)
        env, default_type = tc(scope, env, arg.children[1])
        error :optional_default_kw_type, [kw, default_type, tkw.type], arg.children[1], block: (kind == 'block') unless RDL::Type::Type.leq(default_type, tkw.type, ast: ast)
        kw_args_matched << kw
        targs[kw] = tkw.type
        env = env.merge(Env.new(kw => tkw.type))
      elsif arg.type == :kwrestarg
        error :type_args_no_kws, [kind], e, block: (kind == 'block') unless targ.is_a?(RDL::Type::FiniteHashType)
        error :type_args_no_kw_rest, [kind], arg, block: (kind == 'block') if targ.rest.nil?
        targs[arg.children[0]] = RDL::Type::GenericType.new(RDL::Globals.types[:hash], RDL::Globals.types[:symbol], targ.rest)
        kw_rest_matched = true
      elsif arg.type == :blockarg
        error :type_arg_block, [kind, kind], arg, block: (kind == 'block') unless type.block
        targs[arg.children[0]] = type.block
        # Note no check that if type.block then method expects block, because blocks can be called with yield
      else
        error :generic_error, ["Don't know what to do with actual argument of type #{arg.type}"], arg
      end
    }
    if (tpos == type.args.length - 1) && type.args[tpos].is_a?(RDL::Type::FiniteHashType)
      rest = type.args[tpos].elts.keys - kw_args_matched
      error :type_args_kw_more, [kind, rest.map { |s| s.to_s }.join(", "), kind], ast, block: (kind == 'block') unless rest.empty?
      error :type_args_kw_rest, [kind], ast, block: (kind == 'block') unless kw_rest_matched || type.args[tpos].rest.nil?
    else
      unless (type.args.length == 1) && (type.args[0].is_a?(RDL::Type::OptionalType) || type.args[0].is_a?(RDL::Type::VarargType)) && args.children.empty?
        error :type_args_more, [kind, kind], (if args.children.empty? then ast else args end), block: (kind == 'block') if (type.args.length != tpos)
      end
    end
    return [env, targs]
  end

  def self.get_super_owner(slf, m)
    case slf
    when RDL::Type::SingletonType
      if slf.nominal.name == 'Class'
        trecv_owner = get_super_owner_from_class(slf.val.singleton_class, m)
        RDL::Type::SingletonType.new(RDL::Util.singleton_class_to_class(trecv_owner))
      else
        raise Exception, "self is singleton class but nominal is not Class, it is #{slf.nominal.name}"
      end
    when RDL::Type::NominalType
      RDL::Type::NominalType.new(get_super_owner_from_class(slf.klass, m))
    else
      raise Exception, 'unsupported self #{slf} in get_super_owner'
    end
  end

  def self.get_super_owner_from_class(cls, m)
    raise Exception, "cls #{cls} is not a Class" if cls.class != Class
    cls.superclass.instance_method(m).owner
  end

  def self.tc(scope, env, e)
    _tc(scope, env, e)
  rescue => exn
    raise exn unless RDL::Config.instance.continue_on_errors

    RDL::Logging.log :typecheck, :debug_error, "#{exn}; returning %dyn"

    [env, RDL::Globals.types[:dyn]]
  end

  # The actual type checking logic.
  # [+ scope +] tracks flow-insensitive information about the current scope, excluding local variables
  # [+ env +] is the (local variable) Env
  # [+ e +] is the expression to type check
  # Returns [env', t], where env' is the type environment at the end of the expression
  # and t is the type of the expression. t is always canonical.
  def self._tc(scope, env, e)
    case e.type
    when :nil
      [env, RDL::Globals.types[:nil]]
    when :true
      [env, RDL::Globals.types[:true]]
    when :false
      [env, RDL::Globals.types[:false]]
    when :str, :string
      t = RDL::Config.instance.use_precise_string ? RDL::Type::PreciseStringType.new(e.children[0]) : RDL::Globals.types[:string]
      [env, t]
    when :complex, :rational # constants
      [env, RDL::Type::NominalType.new(e.children[0].class)]
    when :int, :float
      if RDL::Config.instance.number_mode
        [env, RDL::Type::NominalType.new(Integer)]
      else
        [env, RDL::Type::SingletonType.new(e.children[0])]
      end
    when :sym # singleton
      [env, RDL::Type::SingletonType.new(e.children[0])]
    when :dstr, :xstr # string (or execute-string) with interpolation
      prec_str = []
      envi = env
      e.children.each { |ei|
        envi, ti = tc(scope, envi, ei)
        if RDL::Config.instance.use_precise_string
          if ei.type == :str || ei.type == :string
            ## for strings, just append the string itself
            prec_str << ei.children[0]
          else
            ## for interpolated part, append the interpolated part
            prec_str << (if ti.is_a?(RDL::Type::SingletonType) then ti.val.to_s else ti end)
          end
          t = RDL::Type::PreciseStringType.new(*prec_str)
        else
          t = RDL::Globals.types[:string]
        end
      }
      [envi, t]
    when :dsym # symbol with interpolation
      envi = env
      e.children.each { |ei| envi, _ = tc(scope, envi, ei) }
      [envi, RDL::Globals.types[:symbol]]
    when :regexp
      envi = env
      e.children.each { |ei| envi, _ = tc(scope, envi, ei) unless ei.type == :regopt }
      [envi, RDL::Globals.types[:regexp]]
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
          elsif ti.is_a?(RDL::Type::GenericType) && ti.base == RDL::Globals.types[:array]
            is_array = true
            tis << ti.params[0]
          elsif ti.is_a?(RDL::Type::GenericType) && ti.base == RDL::Globals.types[:hash]
            is_array = true
            tis << RDL::Type::TupleType.new(*ti.params)
          elsif ti.is_a?(RDL::Type::SingletonType) && ti.val.nil?
            # nil gets thrown out
          elsif ti.is_a?(RDL::Type::UnionType) && ti.types.all? { |t| t.is_a?(RDL::Type::GenericType) && t.base == RDL::Globals.types[:array] }
            is_array = true
            tis << RDL::Type::UnionType.new(*ti.types.map { |t| t.params[0] }).canonical
          elsif ti.is_a?(RDL::Type::VarType)
              new_arr_type = RDL::Type::GenericType.new(RDL::Globals.types[:array], v = make_unknown_var_type(ti, :splat_param, "splat param"))
              RDL::Type::Type.leq(ti, new_arr_type, ast: e)
              tis << v
          elsif RDL::Type::Type.leq(RDL::Globals.types[:array], ti, ast: e) || RDL::Type::Type.leq(ti, RDL::Globals.types[:array], ast: e) ||
                RDL::Type::Type.leq(RDL::Globals.types[:hash], ti, ast: e) || RDL::Type::Type.leq(ti, RDL::Globals.types[:hash], ast: e)
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
        [envi, RDL::Type::GenericType.new(RDL::Globals.types[:array], RDL::Type::UnionType.new(*tis).canonical)]
      elsif scope[:task] == :infer && RDL::Config.instance.infer_empties && tis.empty?
        [envi, RDL::Type::GenericType.new(RDL::Globals.types[:array], RDL::Type::VarType.new(cls: scope[:klass], meth: scope[:meth], category: :array_param, name: "array_param_#{e.loc}"))]
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
          elsif tkwsplat.is_a?(RDL::Type::GenericType) && tkwsplat.base == RDL::Globals.types[:hash]
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
        if scope[:task] == :infer && RDL::Config.instance.infer_empties && fh.empty?
          [envi, RDL::Type::GenericType.new(RDL::Globals.types[:hash], RDL::Type::VarType.new(cls: scope[:klass], meth: scope[:meth], category: :hash_param_key, name: "hash_param_key_#{e.loc}"),
                                            RDL::Type::VarType.new(cls: scope[:klass], meth: scope[:meth], category: :hash_param_val, name: "hash_param_val_#{e.loc}"))]
        else
          [envi, RDL::Type::FiniteHashType.new(fh, nil)]
        end
      else
        tleft = RDL::Type::UnionType.new(*tlefts)
        tright = RDL::Type::UnionType.new(*trights)
        [envi, RDL::Type::GenericType.new(RDL::Globals.types[:hash], tleft, tright)]
      end
      #TODO test!
#    when :kwsplat # TODO!
    when :irange, :erange
      env1, t1 = tc(scope, env, e.children[0])
      env2, t2  = tc(scope, env1, e.children[1])
      # promote singleton types to nominal types; safe since Ranges are immutable
      t1 = RDL::Type::NominalType.new(t1.val.class) if t1.is_a? RDL::Type::SingletonType
      t2 = RDL::Type::NominalType.new(t2.val.class) if t2.is_a? RDL::Type::SingletonType
      error :nonmatching_range_type, [t1, t2], e unless t1 <= t2 || t2 <= t1
      [env2, RDL::Type::GenericType.new(RDL::Globals.types[:range], t1)]
    when :self
      [env, env[:self]]
    when :lvar, :ivar, :cvar, :gvar
      tc_var(scope, env, e.type, e.children[0], e)
    when :lvasgn, :ivasgn, :cvasgn, :gvasgn
      x = e.children[0]
      # if local var, lhs is bound to nil before assignment is executed! only matters in type checking for locals
      env = env.bind(x, RDL::Globals.types[:nil]) if ((e.type == :lvasgn) && (not (env.has_key? x)))
      envright, tright = tc(scope, env, e.children[1])
      tc_vasgn(scope, envright, e.type, x, tright, e)
    when :masgn
      # (masgn (mlhs (Xvasgn var-name) ... (Xvasgn var-name)) rhs)
      e.children[0].children.each { |asgn|
        next unless asgn.type == :lvasgn
        x = e.children[0]
        env = env.bind(x, RDL::Globals.types[:nil]) if (not (env.has_key? x)) # see lvasgn
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
          envi, _ = tc_vasgn(scope, envi, splat.children[0].type, splat.children[0].children[0], RDL::Type::TupleType.new(*rhs), splat) if splat.children.any?
          [envi, tright]
        else
          error :masgn_num, [rhs.length, lhs.length], e unless lhs.length == rhs.length
          lhs.zip(rhs).each { |left, right|
            envi, _ = tc_vasgn(scope, envi, left.type, left.children[0], right, left)
          }
          [envi, tright]
        end
      elsif (tright.is_a? RDL::Type::GenericType) && (tright.base == RDL::Globals.types[:array])
        tasgn = tright.params[0]
        lhs.each { |asgn|
          if asgn.type == :splat
            envi, _ = tc_vasgn(scope, envi, asgn.children[0].type, asgn.children[0].children[0], tright, asgn)
          else
            envi, _ = tc_vasgn(scope, envi, asgn.type, asgn.children[0], tasgn, asgn)
          end
        }
        [envi, tright]
      elsif (tright.is_a? RDL::Type::DynamicType)
        tasgn = tright
        lhs.each { |asgn|
          if asgn.type == :splat
            envi, _ = tc_vasgn(scope, envi, asgn.children[0].type, asgn.children[0].children[0], tright, asgn)
          else
            envi, _ = tc_vasgn(scope, envi, asgn.type, asgn.children[0], tasgn, asgn)
          end
        }
        [env, tright]
      elsif tright.is_a?(RDL::Type::VarType)
        splat_ind = lhs.index { |lhs_elt| lhs_elt.type == :splat }
        #raise "not yet implemented" if splat_ind
        if splat_ind
          count = 0
          if splat_ind > 0
            lhs[0..splat_ind-1].each { |left|
              # before splat
              envi, _ = tc_vasgn(scope, envi, left.type, left.children[0], RDL::Type::VarType.new(cls: scope[:klass], meth: scope[:meth], category: :tuple_element, name: "tuple_element_#{count}"), left)
              count += 1
            }
          end
          lhs[splat_ind+1..-1].reverse_each { |left|
          # after splat
            envi, _ = tc_vasgn(scope, envi, left.type, left.children[0], RDL::Type::VarType.new(cls: scope[:klass], meth: scope[:meth], category: :tuple_element, name: "tuple_element_#{count}"), left)
            count += 1
          }
          splat = lhs[splat_ind]
          envi, _ = tc_vasgn(scope, envi, splat.children[0].type, splat.children[0].children[0], RDL::Type::GenericType.new(RDL::Globals.types[:array], RDL::Type::VarType.new(cls: scope[:klass], meth: scope[:meth], category: :tuple_element, name: "array_param_#{count}")), splat) if splat.children.any? ## could be empty splat
          [envi, tright]
        else
          new_tuple = []
          count = 0
          lhs.length.times { new_tuple << RDL::Type::VarType.new(cls: scope[:klass], meth: scope[:meth], category: :tuple_element, name: "tuple_element_#{count}") }
          lhs.zip(new_tuple).each { |left, right|
            envi, _ = tc_vasgn(scope, envi, left.type, left.children[0], right, left)
          }
          #tuple_type = RDL::Type::TupleType.new(*new_tuple)
          #RDL::Type::Type.leq(tright, tuple_type, ast: e) # don't think this is necessary
          [envi, tright]
        end
      else
        error :masgn_bad_rhs, [tright], e.children[1]
      end
    when :op_asgn
      if e.children[0].type == :send
        # (op-asgn (send recv meth) :op operand)
        meth = e.children[0].children[1]
        envleft, trecv = tc(scope, env, e.children[0].children[0]) # recv
        elargs = e.children[0].children[2]

        if elargs
          envleft, elargs = tc(scope, envleft, elargs)
          largs = [elargs]
        else
          largs = []
        end
        envloperand, tloperand = tc_send(scope, envleft, trecv, meth, largs, nil, e.children[0]) # call recv.meth()
        envoperand, troperand = tc(scope, envloperand, e.children[2]) # operand
        envright, tright = tc_send(scope, envoperand, tloperand, e.children[1], [troperand], nil, e) # recv.meth().op(operand)
        tright = largs.push(tright) if largs
        mutation_meth = (meth.to_s + '=').to_sym
        envres, tres = tc_send(scope, envright, trecv, mutation_meth, tright, nil, e, true) # call recv.meth=(recvt.meth().op(operand))
        [envres, tres]
      else
        # (op-asgn (Xvasgn var-name) :op operand)
        x = e.children[0].children[0] # Note don't need to check outer_env here because will be checked by tc_vasgn below
        env = env.bind(x, RDL::Globals.types[:nil]) if ((e.children[0].type == :lvasgn) && (not (env.has_key? x))) # see :lvasgn
        envi, trecv = tc_var(scope, env, @@asgn_to_var[e.children[0].type], x, e.children[0]) # var being assigned to
        envright, tright = tc(scope, envi, e.children[2]) # operand
        envrhs, trhs = tc_send(scope, envright, trecv, e.children[1], [tright], nil, e)
        tc_vasgn(scope, envrhs, e.children[0].type, x, trhs, e)
      end
    when :and_asgn, :or_asgn
      # very similar logic to op_asgn
      if e.children[0].type == :send
        meth = e.children[0].children[1]
        envleft, trecv = tc(scope, env, e.children[0].children[0]) # recv
        elargs = e.children[0].children[2]
        if elargs
          envleft, elargs = tc(scope, envleft, elargs)
          largs = [elargs]
        else
          largs = []
        end
        new_envleft, tleft = tc_send(scope, envleft, trecv, meth, largs, nil, e.children[0]) # call recv.meth()
        envright, tright = tc(scope, new_envleft, e.children[1]) # operand
      else
        x = e.children[0].children[0] # Note don't need to check outer_env here because will be checked by tc_var below
        env = env.bind(x, RDL::Globals.types[:nil]) if ((e.children[0].type == :lvasgn) && (not (env.has_key? x))) # see :lvasgn
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
                      if trecv.is_a?(RDL::Type::VarType)
                        ## we get no new information from including VarType in union of return type. In fact, we can lose info due to promotion. So, leave it out.
                        [envright, tright]
                      else
                        [Env.join(e, envleft, envright), RDL::Type::UnionType.new(tleft, tright).canonical]
                      end
                    end)
      if e.children[0].type == :send
        mutation_meth = (meth.to_s + '=').to_sym
        rhs_array = [*largs, trhs]
        envres, tres = tc_send(scope, envi, trecv, mutation_meth, rhs_array, nil, e)
        [envres, tres]
      else
        tc_vasgn(scope, envi, e.children[0].type, x, trhs, e)
      end
    when :match_with_lvasgn # /regexp/ =~ rhs
      env1, t1 = tc(scope, env, e.children[0]) # the regexp
      env2, t2 = tc(scope, env, e.children[1]) # the rhs
      es, ts = tc_send(scope, env2, RDL::Globals.types[:regexp], :=~, [t2], nil, e)
      [es, ts]
      # (regexp
      #   (str "foo")
      #   (regopt))
      # (str "foo"))
    when :nth_ref, :back_ref
      [env, RDL::Globals.types[:string]]
    when :const
      if e.children[0].nil? && e.children[1] == :ENV
        ## ENV
        c = RDL::Type::GenericType.new(RDL::Globals.types[:hash], RDL::Globals.types[:string], RDL::Globals.types[:string])
      elsif e.children[0].nil? && e.children[1] == :ARGV
        c = RDL::Type::GenericType.new(RDL::Globals.types[:array], RDL::Globals.types[:string])
      else
        c = to_type(find_constant(env, scope, e))
      end
      [env, c]
    when :defined?
      # do not type check subexpression, since it may not be type correct, e.g., undefined variable
      [env, RDL::Globals.types[:string]]
    when :send, :csend
      # children[0] = receiver; if nil, receiver is self
      # children[1] = method name, a symbol
      # children [2..] = actual args
      return tc_var_type(scope, env, e) if (e.children[0].nil? || is_RDL(e.children[0])) && e.children[1] == :var_type
      return tc_type_cast(scope, env, e) if is_RDL(e.children[0]) && e.children[1] == :type_cast && scope[:block].nil?
      return tc_note_type(scope, env, e)  if is_RDL(e.children[0]) && e.children[1] == :note_type
      return tc_instantiate!(scope, env, e)  if is_RDL(e.children[0]) && e.children[1] == :instantiate!
      envi = env
      tactuals = []
      block = scope[:block]
      map_case = false
      e_map_case = ti_map_case = nil
      scope_merge(scope, block: nil, break: env, next: env) { |sscope|
        e.children[2..-1].each { |ei|
          if ei.type == :splat
            envi, ti = tc(sscope, envi, ei.children[0])
            if ti.is_a? RDL::Type::TupleType
              tactuals.concat ti.params
            elsif ti.is_a?(RDL::Type::GenericType) && ti.base == RDL::Globals.types[:array]
              tactuals << RDL::Type::VarargType.new(ti.params[0]) # Turn Array<t> into *t
            elsif ti.is_a?(RDL::Type::VarType)
              v = make_unknown_var_type(ti, :splat_param, "splat param")
              #new_arr_type = RDL::Type::GenericType.new(RDL::Globals.types[:array], v = make_unknown_var_type(ti, :splat_param, "splat param"))
              #RDL::Type::Type.leq(ti, new_arr_type, ast: e)
              tactuals << RDL::Type::VarargType.new(v)
              #tactuals << RDL::Type::VarargType.new(RDL::Globals.types[:top])
            elsif ti.is_a?(RDL::Type::UnionType) && ti.types.all? { |t| t.is_a?(RDL::Type::GenericType) && t.base == RDL::Globals.types[:array] }
              params_union = RDL::Type::UnionType.new(*ti.types.map { |t| t.params[0] }).canonical
              tactuals << RDL::Type::VarargType.new(params_union)
            elsif ti.is_a?(RDL::Type::UnionType) && ti.types.any? { |t| t.is_a?(RDL::Type::TupleType) || (t.is_a?(RDL::Type::GenericType) && t.base == RDL::Globals.types[:array]) }
              raise "TODO"
            else
              #error :cant_splat, [ti], ei.children[0]
              # Turns out you can splat anything!
              tactuals << ti
            end
          elsif ei.type == :block_pass
            raise RuntimeError, "impossible to pass block arg and literal block" if scope[:block]
            envi, ti = tc(sscope, envi, ei.children[0])
            # convert using to_proc if necessary
            if (e.children[1] == :map) || e.children[1] == :sum || e.children[1] == :keep_if
              ## block_pass calling map is a weird case:
              ## it takes a symbol representing method being called,
              ## where receiver is Array elements.
              ## But we haven't type checked the receiver yet,
              ## so we can't really determine the type of the block yet.
              ## So we do that below.
              map_case = true
              e_map_case = ei
              ti_map_case = ti
            else
              envi, ti = tc_send(sscope, envi, ti, :to_proc, [], nil, ei) unless ti.is_a? RDL::Type::MethodType
              block = [ti, ei]
            end
          else
            envi, ti = tc(sscope, envi, ei)
            tactuals << ti
          end
        }
        envi, trecv = if e.children[0].nil? then [envi, envi[:self]] else tc(sscope, envi, e.children[0]) end # if no receiver, self is receiver

        if map_case && trecv.is_a?(RDL::Type::GenericType)
          #raise "Expected GenericType, got #{trecv}." unless trecv.is_a?(RDL::Type::GenericType)
          trecv.is_a?(RDL::Type::GenericType)
          envi, ti_map_case = tc_send(sscope, { self: trecv.params[0] }, ti_map_case, :to_proc, [], nil, e_map_case)
          map_block_type = RDL::Type::MethodType.new([trecv.params[0]], nil, ti_map_case.canonical.ret)
          block = [map_block_type, e_map_case]
        end
        envres, tres = tc_send(sscope, envi, trecv, e.children[1], tactuals, block, e)
        [envres, tres.canonical]
      }
    when :yield
      # very similar to send except the callee is the method's block
      error :no_block, [], e unless scope[:tblock]
      error :block_block, [], e if scope[:tblock].is_a?(RDL::Type::MethodType) && scope[:tblock].block
      scope[:exn] = Env.join(e, scope[:exn], env) if scope.has_key? :exn # assume this call might raise an exception
      envi = env
      tactuals = []
      e.children[0..-1].each { |ei| envi, ti = tc(scope, envi, ei); tactuals << ti }
      if scope[:tblock].is_a?(RDL::Type::VarType)
        block_ret_type = RDL::Type::VarType.new(cls: scope[:klass], meth: scope[:meth], category: :block_ret, name: "block_return")
        block_type = RDL::Type::MethodType.new(tactuals, nil, block_ret_type)
        RDL::Type::Type.leq(scope[:tblock], block_type, ast: e)
        return [envi, block_ret_type]
      else
        unless tc_arg_types(scope[:tblock], tactuals)
          msg = <<RUBY
      Block type: #{scope[:tblock]}
Actual arg types: (#{tactuals.map { |ti| ti.to_s }.join(', ')})
RUBY
          msg.chomp! # remove trailing newline
          error :block_type_error, [msg], e
        end
        return [envi, scope[:tblock].ret]
      end
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
      elsif e.type == :and && !(tleft == RDL::Globals.types[:bool] || tleft == RDL::Globals.types[:false] || tleft.is_a?(RDL::Type::VarType))
        ## when :and and left is NOT false or a variable, then we always get back tright (or nil, which is a subtype of tright)
        ## no equivalent for :or, because if left is nil, could still get right
        [envleft.merge(envright), tright]
      else
        [envleft.merge(envright), RDL::Type::UnionType.new(tleft, tright).canonical]
      end
    # when :not # in latest Ruby, not is a method call that could be redefined, so can't count on its behavior
    #   a1, t1 = tc(scope, a, e.children[0])
    #   if t1.is_a? RDL::Type::SingletonType
    #     if t1.val then [a1, RDL::Globals.types[:false]] else [a1, RDL::Globals.types[:true]] end
    #   else
    #     [a1, RDL::Globals.types[:bool]]
    #   end
    when :if
      envi, tguard = tc(scope, env, e.children[0]) # guard; any type allowed
      # always type check both sides
      envleft, tleft = if e.children[1].nil? then [envi, RDL::Globals.types[:nil]] else tc(scope, envi, e.children[1]) end # then
      envright, tright = if e.children[2].nil? then [envi, RDL::Globals.types[:nil]] else tc(scope, envi, e.children[2]) end # else
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
          envi, _ = tc_send(scope, envi, tguard, :===, [tcontrol], nil, guard) unless tcontrol.nil?
          envguards << envi
        }
        initial_env = Env.join(e, *envguards)
        if (tguards.all? { |typ| typ.is_a?(RDL::Type::SingletonType) && (typ.val.is_a?(Class) || typ.val.nil?) }) && (e.children[0].type == :lvar)
          # Special case! We're branching on the type of the guard, which is a local variable.
          # So rebind that local variable to have the union of the guard types
          var_name = e.children[0].children[0]
          var_type = initial_env[var_name]
          new_typ = RDL::Type::UnionType.new(*(tguards.map { |typ| typ.val.nil? ? typ : RDL::Type::NominalType.new(typ.val) })).canonical
          # TODO adjust following for generics!
          if tcontrol.is_a? RDL::Type::GenericType
            if new_typ == tcontrol.base
              # special case: exact match of control type's base and type of guard; can use
              # geneirc type on this branch
              initial_env = initial_env.bind(var_name, tcontrol, fixed: initial_env.fixed?(var_name), force: true)
            elsif !(tcontrol.base <= new_typ) && !(new_typ <= tcontrol.base)
              next # can't possibly match this branch
            else
              error :generic_error, ["general refinement for generics not implemented yet"], wclause
            end
          else
            next unless tcontrol.is_a?(RDL::Type::VarType) || (tcontrol <= new_typ || new_typ <= tcontrol) # If control can't possibly match type, skip this branch
            initial_env = initial_env.bind(var_name, new_typ, fixed: initial_env.fixed?(var_name), force: true)
            # note force is safe above because the env from this arm will be joined with the other envs
            # (where the type was not refined like this), so after the case the variable will be back to its
            # previous, unrefined type
          end
        end
        if wclause.children[-1] == nil
          envbody = initial_env
          tbody = RDL::Globals.types[:nil]
        else
          envbody, tbody = tc(scope, initial_env, wclause.children[-1]) # last wclause child is body
          # reset type of var_name to its original type
          envbody = envbody.bind(var_name, var_type, fixed: envbody.fixed?(var_name), force: true)
        end

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
        #envelse = envelse.bind(e.children[0].children[0], tcontrol, force: :true) if e.children[0].type == :lvar
        envbodies << envelse
      end
      # before join reset var to original type!
      [Env.join(e, *envbodies), RDL::Type::UnionType.new(*tbodies).canonical]
    when :while, :until
      # break: loop exit, i.e., right after loop guard; may take argument
      # next: before loop guard; argument not allowed
      # retry: not allowed
      # redo: after loop guard, which is same as break
      env_break, _ = tc(scope, env, e.children[0]) # guard can have any type, may exit after checking guard
      scope_merge(scope, break: env_break, tbreak: RDL::Globals.types[:nil], next: env, redo: env_break) { |lscope|
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
      scope_merge(scope, break: nil, tbreak: RDL::Globals.types[:nil], next: nil, redo: nil) { |lscope|
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
        self_klass = tcollect.klass
        teaches = lookup(scope, tcollect.name, :each, e.children[1])
        teaches = filter_comp_types(teaches, RDL::Config.instance.use_comp_types)
      when RDL::Type::GenericType, RDL::Type::TupleType, RDL::Type::FiniteHashType, RDL::Type::PreciseStringType
        unless tcollect.is_a? RDL::Type::GenericType
          error :tuple_finite_hash_promote, (if tcollect.is_a? RDL::Type::TupleType then ['tuple', 'Array'] elsif tcollect.is_a? RDL::Type::PreciseStringType then ['precise string', 'String'] else ['finite hash', 'Hash'] end), e.children[1] unless tcollect.promote!
          tcollect = tcollect.canonical
        end
        self_klass = tcollect.base.klass
        teaches = lookup(scope, tcollect.base.name, :each, e.children[1])
        teaches = filter_comp_types(teaches, RDL::Config.instance.use_comp_types)
        inst = tcollect.to_inst.merge(self: tcollect)
        teaches = teaches.map { |typ|
          block_types = (if typ.block then typ.block.args + [typ.block.ret] else [] end)
          if (typ.args+[typ.ret]+block_types).all? { |t| !t.instance_of?(RDL::Type::ComputedType) }
            typ
          else
            compute_types(typ, self_klass, tcollect, [])
          end
        }
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
        [lscope[:break], lscope[:tbreak].canonical] ## going very conservative on this one
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
      [env, RDL::Globals.types[:bot]]
    when :return
      # TODO return in lambda returns from lambda and not outer scope
      if e.children[0]
         env1, t1 = tc(scope, env, e.children[0])
      else
         env1, t1 = [env, RDL::Globals.types[:nil], [:+, :+]]
      end
      error :bad_return_type, [t1.to_s, scope[:tret]], e unless RDL::Type::Type.leq(t1, scope[:tret], ast: e)
      [env1, RDL::Globals.types[:bot]] # return is a void value expression
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
          error :exn_type, [], exn unless texn.is_a?(RDL::Type::SingletonType) && (texn.val.is_a?(Class) || texn.val.is_a?(Module))
          texns << RDL::Type::NominalType.new(texn.val)
        }
      else
        texns = [RDL::Globals.types[:standard_error]]
      end
      if e.children[1]
        envi, _ = tc_vasgn(scope, envi, :lvasgn, e.children[1].children[0], RDL::Type::UnionType.new(*texns), e.children[1])
      end
      env_fin, t_fin = if e.children[2].nil? then [envi, RDL::Globals.types[:nil]] else tc(scope, envi, e.children[2]) end
      [env_fin, t_fin]
    when :super
      envi = env
      tactuals = []
      block = scope[:block]
=begin
      if block
        raise Exception, 'block in super method with block not supported'
      end
=end
      scope_merge(scope, block: nil, break: env, next: env) { |sscope|
        e.children.each { |ei|
          if ei.type == :splat
            envi, ti = tc(sscope, envi, ei.children[0])
            if ti.is_a? RDL::Type::TupleType
              tactuals.concat ti.params
            elsif ti.is_a?(RDL::Type::GenericType) && ti.base == RDL::Globals.types[:array]
              tactuals << RDL::Type::VarargType.new(ti.params[0]) # Turn Array<t> into *t
            else
              error :cant_splat, [ti], ei.children[0]
            end
          elsif ei.type == :block_pass
            raise RuntimeError, "impossible to pass block arg and literal block" if scope[:block]
            envi, ti = tc(sscope, envi, ei.children[0])
            # convert using to_proc if necessary
            envi, ti = tc_send(sscope, envi, ti, :to_proc, [], nil, ei) unless ti.is_a? RDL::Type::MethodType
            block = [ti, ei]
          else
            envi, ti = tc(sscope, envi, ei)
            tactuals << ti
          end
        }

        trecv = get_super_owner(envi[:self], scope[:meth])
        envres, tres = tc_send(sscope, envi, trecv, scope[:meth], tactuals, block, e)
        [envres, tres.canonical]
      }
    when :zsuper
      envi = env
      block = scope[:block]
=begin
      if block
        raise Exception, 'super method not supported'
      end
=end
      klass = RDL::Util.to_class scope[:klass]
      mname = scope[:meth]
      sklass = get_super_owner_from_class klass, mname
      sklass_str = RDL::Util.to_class_str sklass
      stype = lookup(scope, sklass_str, mname, e)#RDL::Globals.info.get_with_aliases(sklass_str, mname, :type)
      error :no_instance_method_type, [sklass_str, mname], e unless stype
      stype = filter_comp_types(stype, RDL::Config.instance.use_comp_types)
      raise Exception, "unsupported intersection type in super, e = #{e}, stype = #{stype}" if stype.size > 1
      tactuals = stype[0].args

      scope_merge(scope, block: nil, break: env, next: env) { |sscope|
        trecv = get_super_owner(envi[:self], scope[:meth])
        envres, tres = tc_send(sscope, envi, trecv, scope[:meth], tactuals, block, e)
        [envres, tres.canonical]
      }
    else
      error :unsupported_expression, [e.type, e], e
    end
  end

  def self.to_type(val, as_key=false)
    case val
    when Symbol
      if as_key then val else RDL::Type::SingletonType.new(val) end
    when TrueClass, FalseClass, Class, Module
      RDL::Type::SingletonType.new(val)
    when Complex, Rational, Integer, Float
      if RDL::Config.instance.number_mode# && !(val.class == Integer)
        RDL::Type::NominalType.new(Integer)
      else
        RDL::Type::SingletonType.new(val)
      end
    when Array
      tarr = val.map { |v| to_type(v) }
      RDL::Type::TupleType.new(*tarr)
    when Hash
      fh = val.transform_keys { |k| to_type(k, true) }
      fh = fh.transform_values { |v| to_type(v) }
      RDL::Type::FiniteHashType.new(fh, nil)
    else
      RDL::Type::NominalType.new(val.class)
    end
  end

  # [+ kind +] is :lvar, :ivar, :cvar, or :gvar
  # [+ name +] is the variable name, which should be a symbol
  # [+ e +] is the expression for which errors should be reported
  def self.tc_var(scope, env, kind, name, e)
    kind_text = (if kind == :ivar then "instance variable"
                elsif kind == :cvar then "class variable"
                else "global variable" end)
    case kind
    when :lvar  # local variable
      error :undefined_local_or_method, [name], e unless env.has_key? name
      [env, env[name].canonical]
    when :ivar, :cvar, :gvar
      klass = (if kind == :gvar then RDL::Util::GLOBAL_NAME else env[:self].to_s end)
      klass = "Integer" if klass == "Number"
      klass = RDL::Util.remove_singleton_marker klass if RDL::Util.has_singleton_marker klass
      if RDL::Globals.info.has?(klass, name, :type)
        type = RDL::Globals.info.get(klass, name, :type)
      elsif RDL::Config.instance.assume_dyn_type
        type = RDL::Globals.types[:dyn]
      elsif RDL::Config.instance.use_unknown_types || RDL::Globals.to_infer.values.any? { |set| set.include?([klass, name]) }
        type = make_unknown_var_type(klass, name, :var)
      else
        error :untyped_var, [kind_text, name, klass], e
      end
      [env, type.canonical]
    else
      raise RuntimeError, "unknown kind #{kind}"
    end
  end

  # Same arguments as tc_var except
  # [+ tright +] is type of right-hand side
  def self.tc_vasgn(scope, env, kind, name, tright, e)
    error :empty_env, [name], e if env.nil?
    kind_text = (if kind == :ivasgn then "instance variable"
                elsif kind == :cvasgn then "class variable"
                else "global variable" end)
    case kind
    when :lvasgn
      if (env.fixed? name)
        error :vasgn_incompat, [tright, env[name]], e unless RDL::Type::Type.leq(tright, env[name], inst={}, true, ast: e)
        tright.instantiate(inst)
        [env, tright.canonical]
      else
        [env.bind(name, tright), tright.canonical]
      end
    when :ivasgn, :cvasgn, :gvasgn
      klass = (if kind == :gvasgn then RDL::Util::GLOBAL_NAME else env[:self].to_s end)
      klass = "Integer" if klass == "Number"
      klass = RDL::Util.remove_singleton_marker klass if RDL::Util.has_singleton_marker klass
      if RDL::Globals.info.has?(klass, name, :type)
        tleft = RDL::Globals.info.get(klass, name, :type)
      elsif RDL::Config.instance.assume_dyn_type
        tleft = RDL::Globals.types[:dyn]
      elsif RDL::Config.instance.use_unknown_types || RDL::Globals.to_infer.values.any? { |set| set.include?([klass, name]) }
        tleft = make_unknown_var_type(klass, name, :var)
      else
        error :untyped_var, [kind_text, name, klass], e
      end
      error :vasgn_incompat, [tright.to_s, tleft.to_s], e unless RDL::Type::Type.leq(tright, tleft, inst={}, true, ast: e)
      tright.instantiate(inst)
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
      tc_send(scope, envi, trecv, meth, [*typs, tright], nil, e) # call receiver.meth(other args, tright)
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
      typ = RDL::Globals.parser.scan_str("#T " + typ_str)
    rescue Racc::ParseError => err
      error :generic_error, [err.to_s[1..-1]], e.children[3] # remove initial newline
    end
    [env.bind(var, typ, fixed: true), RDL::Globals.types[:nil]]
  end

  def self.tc_type_cast(scope, env, e)
    error :type_cast_format, [], e unless e.children.length <= 5
    typ_str = e.children[3].children[0] if (e.children[3].type == :str) || (e.children[3].type == :string)
    error :type_cast_format, [], e.children[3] if typ_str.nil?
    begin
      if RDL::Util.has_singleton_marker(typ_str)
        typ = RDL::Type::SingletonType.new(RDL::Globals.parser.scan_str("#T #{RDL::Util.remove_singleton_marker(typ_str)}").klass)
      else
        typ = RDL::Globals.parser.scan_str("#T " + typ_str)
      end
    rescue Racc::ParseError => err
      error :generic_error, [err.to_s[1..-1]], e.children[3] # remove initial newline
    end
    if e.children[4]
      fh = e.children[4]
      error :type_cast_format, [], fh unless fh.type == :hash && fh.children.length == 1
      pair = fh.children[0]
      error :type_cast_format, [], fh unless pair.type == :pair && pair.children[0].type == :sym && pair.children[0].children[0] == :force
      force_arg = pair.children[1]
      env, _ = tc(scope, env, force_arg)
    end
    sub_expr = e.children[2]
    env2, _ = tc(scope, env, sub_expr)
    @num_casts += 1
    [env2, typ]
  end

  def self.tc_note_type(scope, env, e)
    error :note_type_format, [], e unless e.children.length == 3 && scope[:block].nil?
    env, typ = tc(scope, env, e.children[2])
    note :note_type, [typ], e.children[2]
    [env, typ]
  end

  def self.tc_instantiate!(scope, env, e)
    error :instantiate_format, [], e if e.children.length < 4
    env, obj_typ = tc(scope, env, e.children[2])
    case obj_typ
    when RDL::Type::GenericType
      klass = obj_typ.base.name.to_s
    when RDL::Type::NominalType
      klass = obj_typ.name.to_s
    when RDL::Type::TupleType
      klass = "Array"
    when RDL::Type::FiniteHashType
      klass = "Hash"
    when RDL::Type::PreciseStringType
      klass = "String"
    when RDL::Type::SingletonType
      klass = if obj_typ.val.is_a?(Class) then obj_typ.val.to_s else obj_typ.val.class.to_s end
    else
      error :bad_inst_type, [obj_typ], e
    end

    formals, _, _ = RDL::Globals.type_params[klass]

    if e.children.last.type == :hash
      typ_args = e.children[3..-2]
    else
      typ_args = e.children[3..-1]
    end
    error :inst_not_param, [klass], e unless formals
    error :inst_num_args, [formals.size, typ_args.size], e unless formals.size == typ_args.size

    new_typs = []
    typ_args.each { |a|
      env, arg_typ = tc(scope, env, a)
      case arg_typ
      when RDL::Type::SingletonType
        error :instantiate_format, [], a unless arg_typ.val.is_a?(Class)
        new_typs << RDL::Globals.parser.scan_str("#T #{arg_typ.val}")
      else
        error :instantiate_format, [], a unless (a.type == :str) || (a.type == :string) || (a.type == :sym)
        new_typs << RDL::Globals.parser.scan_str("#T #{a.children[0]}")
      end
    }

    t = RDL::Type::GenericType.new(RDL::Type::NominalType.new(klass), *new_typs)
    case e.children[2].type
    when :lvar
      var_name = e.children[2].children[0]
    else
      raise RuntimeError, "instantiate! expects local variable as receiver"
      error :inst_lvar, [], e
    end

    env = env.bind(var_name, t)
    [env, t]
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
  # [+ op_asgn +] is a bool telling us that we are type checking the mutation method for an op_asgn node. used for ast rewriting.
  def self.tc_send(scope, env, trecvs, meth, tactuals, block, e, op_asgn=false)
    scope[:exn] = Env.join(e, scope[:exn], env) if scope.has_key? :exn # assume this call might raise an exception
    # convert trecvs to array containing all receiver types
    trecvs = trecvs.canonical
    trecvs = if trecvs.is_a? RDL::Type::UnionType then union = true; trecvs.types else union = false; [trecvs] end

    trets = []
    trecvs.each { |trecv|
      if trecv.is_a?(RDL::Type::ChoiceType)
        choice_hash = { }
        errs = []
        trecv.choices.each { |num, t|
          trecv.activate_all_connected(num) ## type check method call for this particular choice
          begin
            t = t.canonical
            tarms = t.is_a?(RDL::Type::UnionType) ? t.types : [t]
            tarms.each { |t|
              env, ts = tc_send_one_recv(scope, env, t, meth, tactuals, block, e, op_asgn, union)
              choice_hash[num] = RDL::Type::UnionType.new(*ts).canonical
            }
          rescue StaticTypeError => err
            errs << err
            trecv.remove!(num) ## choice num failed to type check, remove it from choice type
            ### TODO: remove env update?
          end
        }
        trecv.deactivate_all_connected
        if choice_hash.empty?
          raise StaticTypeError, "Failed to type check call to method #{meth} for ChoiceType receiver #{trecv}. Errors received were: #{errs.each { |e| puts e }}"
        elsif choice_hash.values.uniq.size == 1
          ts = [choice_hash.values[0]] ## only one type resulted, no need for ChoiceType
        else
          ts = [RDL::Type::ChoiceType.new(choice_hash, [trecv] + trecv.connecteds)]
        end
      else
        env, ts = tc_send_one_recv(scope, env, trecv, meth, tactuals, block, e, op_asgn, union) ### XXX fix
      end

      # TODO: envs is all possible different orders

      trets.concat(ts)
    }
    trets.map! {|t| (t.is_a?(RDL::Type::AnnotatedArgType) || t.is_a?(RDL::Type::BoundArgType)) ? t.type : t}
    return [env, RDL::Type::UnionType.new(*trets)]
  end

  # Like tc_send but trecv should never be a union type
  # Returns [env', Array<Type>], where
  # env' is the new environment, which unions together any weak updates from the block
  # the array contains all possible return types
  # raises exception if there are no possible valid calls
  def self.tc_send_one_recv(scope, env, trecv, meth, tactuals, block, e, op_asgn, union)
    raise "Type checking not currently supported for method #{meth}." if [:define_method, :module_exec].include?(meth)
=begin
    puts "----------------------"
    puts "Type checking method call to #{meth} for receiver #{trecv} and tactuals of size #{tactuals.size}:"
    tactuals.each { |t| puts t }
    puts "----------------------"
=end
    if (trecv == RDL::Globals.types[:array])
      trecv = RDL::Type::GenericType.new(RDL::Globals.types[:array], RDL::Globals.types[:bot])
    elsif (trecv == RDL::Globals.types[:hash])
      trecv = RDL::Type::GenericType.new(RDL::Globals.types[:hash], RDL::Globals.types[:bot], RDL::Globals.types[:bot])
    elsif trecv.is_a?(RDL::Type::AnnotatedArgType) || trecv.is_a?(RDL::Type::DependentArgType)
      trecv = trecv.type
    end
    return [env, tc_send_class(trecv, e)] if (meth == :class) && (tactuals.empty?)
    ts = [] # Array<MethodType>, i.e., an intersection types
    case trecv
    when RDL::Type::SingletonType
      if trecv.val.is_a? Class or trecv.val.is_a? Module
        if (meth == :new) && trecv.val.methods.include?(:new) && trecv.val.method(:new).owner == Class then ## last condition makes sure :new isn't overriden
          meth_lookup = :initialize
          init = true
          trecv_lookup = trecv.val.to_s
          self_inst = RDL::Type::NominalType.new(trecv.val)
        elsif (defined? ApplicationMailer) && trecv.val.ancestors.include?(ApplicationMailer)
          ## Thanks to Rails magic, Mailer instance methods can be called as singletons.
          meth_lookup = meth
          trecv_lookup = trecv.val.to_s
          self_inst = RDL::Type::NominalType.new(trecv.val)
        else
          meth_lookup = meth
          trecv_lookup = RDL::Util.add_singleton_marker(trecv.val.to_s)
          self_inst = trecv
        end
        ts = lookup(scope, trecv_lookup, meth_lookup, e)
        ts = [RDL::Type::MethodType.new([], nil, RDL::Type::NominalType.new(trecv.val))] if init && (ts.nil?) # there's always a nullary new if initialize is undefined
        error :no_singleton_method_type, [trecv.val, meth], e unless ts
        inst = {self: self_inst}
        self_klass = trecv.val
      elsif trecv.val.is_a?(Symbol) && meth == :to_proc
        # Symbol#to_proc on a singleton symbol type produces a Proc for the method of the same name
        if env[:self].is_a?(RDL::Type::NominalType)
          klass = env[:self].klass
        #elsif env[:self].is_a?(
        elsif env[:self].is_a?(RDL::Type::SingletonType) # SingletonType(class)
          klass = env[:self].val
        else
          raise "unsupported self type for to_proc #{env[:self]}"
        end
        ts = lookup(scope, klass.to_s, trecv.val, e)
        ts = filter_comp_types(ts, false) ## no comp types in this case
        error :no_type_for_symbol, [trecv.val.inspect], e if ts.nil?
        return [env, ts]
      else
        klass = trecv.val.class.to_s
        ts = lookup(scope, klass, meth, e)
        error :no_instance_method_type, [klass, meth], e unless ts
        inst = {self: trecv}
        self_klass = trecv.val.class
      end
    when RDL::Type::AstNode
      meth_lookup = meth
      trecv_lookup = RDL::Util.add_singleton_marker(trecv.val.to_s)
      self_inst = trecv
      ts = lookup(scope, trecv_lookup, meth_lookup, e)
      ts = [RDL::Type::MethodType.new([], nil, RDL::Type::NominalType.new(trecv.val))] if (meth == :new) && (ts.nil?) # there's always a nullary new if initialize is undefined
      error :no_singleton_method_type, [trecv.val, meth], e unless ts
      inst = {self: self_inst}
      self_klass = trecv.val
      ts = ts.map { |t| t.instantiate(inst) }
    when RDL::Type::NominalType
      ts = lookup(scope, trecv.name, meth, e)
      unless ts
        klass = RDL::Util.to_class(scope[:klass])
        if klass.class == Module
          # Module mixin handle
          # Here a module method is calling a non-existent method; check for it in all mixees
          # TODO: Handle :extend
          nts = RDL::Globals.module_mixees[klass].map { |k, kind| if kind == :include then RDL::Type::NominalType.new(k) end }
          return [env, [RDL::Globals.types[:bot]]] if nts.empty? # if module not mixed in, this call can't happen; so %bot
          ut = RDL::Type::UnionType.new(*nts)
          env, t = tc_send(scope, env, ut, meth, tactuals, block, e, op_asgn)
          return [env, [t]]
        end
        error :no_instance_method_type, [trecv.name, meth], e
      end
      # error :no_instance_method_type, [trecv.name, meth], e unless ts
      inst = {self: trecv}
      self_klass = RDL::Util.to_class(trecv.name)
    when RDL::Type::GenericType
      ts = lookup(scope, trecv.base.name, meth, e)
      if ts.nil? && (trecv.base.name == "ActiveRecord_Relation") && defined? DBType
        ## ActiveRecord_Relation methods that don't exist are delegated to underlying scoped class.
        ## Maybe there's a way not to bake this in to typechecker, but I can't think of one.
        ts = lookup(scope, "[s]"+DBType.rec_to_nominal(trecv).name, meth, e)
        error :no_instance_method_type, [trecv.base.name, meth], e unless ts
        ts = ts.map { |t| RDL::Type::MethodType.new(t.args, t.block, trecv) }
      end
      error :no_instance_method_type, [trecv.base.name, meth], e unless ts
      inst = trecv.to_inst.merge(self: trecv)
      self_klass = RDL::Util.to_class(trecv.base.name)
    when RDL::Type::TupleType
      if RDL::Config.instance.use_comp_types
        ts = lookup(scope, "Array", meth, e)
        error :no_instance_method_type, ["Array", meth], e unless ts
        #inst = trecv.to_inst.merge(self: trecv)
        t_bind = trecv.promote.params[0].to_s == "t" ? RDL::Globals.types[:bot] : trecv.promote.params[0]
        inst = { self: trecv, t: t_bind }
        self_klass = Array
      else
        ## need to promote in this case
        error :tuple_finite_hash_promote, ['tuple', 'Array'], e unless trecv.promote!
        trecv = trecv.canonical
        ts = lookup(scope, trecv.base.name, meth, e)
        error :no_instance_method_type, [trecv.base.name, meth], e unless ts
        inst = trecv.to_inst.merge(self: trecv)
        self_klass = RDL::Util.to_class(trecv.base.name)
      end
    when RDL::Type::FiniteHashType
      if RDL::Config.instance.use_comp_types
        ts = lookup(scope, "Hash", meth, e)
        error :no_instance_method_type, ["Hash", meth], e unless ts
        #inst = trecv.to_inst.merge(self: trecv)
        k_bind = trecv.promote.params[0].to_s == "k" ? RDL::Globals.types[:bot] : trecv.promote.params[0]
        v_bind = trecv.promote.params[1].to_s == "v" ? RDL::Globals.types[:bot] : trecv.promote.params[1]
        inst = { self: trecv , k: k_bind, v: v_bind }
        self_klass = Hash
      else
        ## need to promote in this case
        error :tuple_finite_hash_promote, ['finite hash', 'Hash'], e unless trecv.promote!
        trecv = trecv.canonical
        ts = lookup(scope, trecv.base.name, meth, e)
        error :no_instance_method_type, [trecv.base.name, meth], e unless ts
        inst = trecv.to_inst.merge(self: trecv)
        self_klass = RDL::Util.to_class(trecv.base.name)
      end
    when RDL::Type::PreciseStringType
      if RDL::Config.instance.use_comp_types
        ts = lookup(scope, "String", meth, e)
        error :no_instance_method_type, ["String", meth], e unless ts
        inst = { self: trecv }
        self_klass = String
      else
      ## need to promote in this case
        error :tuple_finite_hash_promote, ['precise string type', 'String'], e unless trecv.promote!
        trecv = trecv.canonical
        ts = lookup(scope, trecv.name, meth, e)
        error :no_instance_method_type, [trecv.name, meth], e unless ts
        inst = { self: trecv }
        self_klass = RDL::Util.to_class(trecv.name)
      end
    when RDL::Type::VarType
      ## prevent overfitting
      tactuals = tactuals.map { |t|
        if t.is_a?(RDL::Type::PreciseStringType)
          RDL::Globals.types[:string]
        elsif t.is_a?(RDL::Type::SingletonType) && !(t.val.class == Symbol) ## Symbol singletons come in handy for reconstructing finite hash types
          RDL::Type::NominalType.new(t.val.class)
        else
          t
        end }

      if meth == :to_s
        ret_type = RDL::Globals.types[:string]
      elsif meth == :to_i
        ret_type = RDL::Globals.types[:integer]
      else
        if @var_cache.has_key?(e.object_id) ## cache is based on syntactic location of method call
          ret_type = @var_cache[e.object_id]
        else
          ret_type = RDL::Type::VarType.new(cls: trecv, meth: meth, category: :ret, name: "ret")
          @var_cache[e.object_id] = ret_type
        end
      end

      if block
        if block[0].is_a?(RDL::Type::MethodType) || block[0].is_a?(RDL::Type::VarType)
          meth_type = RDL::Type::MethodType.new(tactuals, block[0], ret_type)
        else
          blk_args = block[0].children.map {|a| a.children[0]}
          blk_arg_vartypes = blk_args.map { |a|
            RDL::Type::VarType.new(cls: trecv, meth: meth, category: :block_arg, name: a.to_s ) }#block[0].children[0].to_s) }
          blk_ret_vartype = RDL::Type::VarType.new(cls: trecv, meth: meth, category: :block_ret, name: "block_ret")
          block_type = RDL::Type::MethodType.new(blk_arg_vartypes, nil, blk_ret_vartype)

          meth_type = RDL::Type::MethodType.new(tactuals, block_type, ret_type)

          tmeth_inst = tc_arg_types(meth_type, tactuals)

          raise "Expected method to be instantiated." unless tmeth_inst
          env = tc_block(scope, env, block_type, block, tmeth_inst)
        end
      else
        meth_type = RDL::Type::MethodType.new(tactuals, nil, ret_type)
      end

      RDL::Type::Type.leq(trecv, RDL::Type::StructuralType.new({ meth => meth_type }), ast: e)
      #tmeth_inter = [meth_type]

      #self_klass = nil
    #error :recv_var_type, [trecv], e
      return [env, [ret_type]]
    when RDL::Type::MethodType
      if meth == :call
        # Special case - invokes the Proc
        ts = [trecv]
      else
        # treat as Proc
        return tc_send_one_recv(scope, env, RDL::Globals.types[:proc], meth, tactuals, block, e, op_asgn, union)
      end
    when RDL::Type::DynamicType
      return [env, [trecv]]
    else
      raise RuntimeError, "receiver type #{trecv} of kind #{trecv.class} not supported yet, meth=#{meth}"
    end

    trets = [] # all possible return types
    # there might be more than one return type because multiple cases of an intersection type might match
    tmeth_names = [] ## necessary for more precise error messages with ComputedTypes
    arg_choices = Hash.new { |h, k| h[k] = {} } # Hash<VarType, Hash<Integer, Type>>. The keys are tactual arguments that are VarTypes. The values are choice hashes, to be turned into ChoiceTypes that will be upper bounds on the keys.
    ret_choice = {} # Hash<Integer, Type> for return ChoiceType
    deferred_constraints = [] ## Array<Array<VarType, Type>> of deferred constraints to apply.

    # for ALL of the expanded lists of actuals...
    if RDL::Config.instance.use_comp_types
      ts = filter_comp_types(ts, true)
    else
      ts = filter_comp_types(ts, false)
      error :no_non_dep_types, [trecv, meth], e unless !ts.empty?
    end

    RDL::Type.expand_product(tactuals).each { |tactuals_expanded|
      # AT LEAST ONE of the possible intesection arms must match
      trets_tmp = []
      #deferred_constraints = []
      choice_num = 0
      ts.each_with_index { |tmeth, ind| # MethodType
        got_match = false
        current_dcs = []
        comp_type = false
        choice_num += 1
        current_ret = nil
        if tmeth.is_a? RDL::Type::DynamicType
          trets_tmp << (current_ret = RDL::Type::DynamicType.new)
        elsif ((tmeth.block && block) || (tmeth.block.nil? && block.nil?) || tmeth.block.is_a?(RDL::Type::VarType))
          if trecv.is_a?(RDL::Type::FiniteHashType) && trecv.the_hash
            trecv = trecv.canonical
            inst = trecv.to_inst.merge(self: trecv)
          end
          block_types = (if tmeth.block.is_a?(RDL::Type::MethodType) then tmeth.block.args + [tmeth.block.ret] else [] end)
          unless (tmeth.args+[tmeth.ret]+block_types).all? { |t| !t.instance_of?(RDL::Type::ComputedType) }
            tmeth_old = tmeth
            trecv_old = trecv.copy
            targs_old = tactuals_expanded.map { |t| t.copy }
            binds = tc_bind_arg_types(tmeth, tactuals_expanded)
            #binds = {} if binds.nil?
            tmeth = tmeth_res = compute_types(tmeth, self_klass, trecv, tactuals_expanded, binds) unless binds.nil?
            comp_type = true
          end
          tmeth = tmeth.instantiate(inst) if inst
          tmeth_names << tmeth
          #deferred_constraints = []
          tmeth_inst = tc_arg_types(tmeth, tactuals_expanded, current_dcs)
          #apply_deferred_constraints(deferred_constraints, e) unless deferred_constraints.empty?
          if tmeth_inst
            begin
              old_env = env
              env = tc_block(scope, env, tmeth.block, block, tmeth_inst) if block
            rescue BlockTypeError => _
              block_mismatch = true
              env = old_env
            end

            if init#trecv.is_a?(RDL::Type::SingletonType) && meth == :new
              init_typ = RDL::Type::NominalType.new(trecv.val)
              if (tmeth.ret.instance_of?(RDL::Type::GenericType))
                error :bad_initialize_type, [], e unless (tmeth.ret.base == init_typ)
              elsif (tmeth.ret.instance_of?(RDL::Type::AnnotatedArgType) || tmeth.ret.instance_of?(RDL::Type::DependentArgType) || tmeth.ret.instance_of?(RDL::Type::BoundArgType))
                error :bad_initialize_type, [], e unless (tmeth.ret.type == init_typ)
              else
                error :bad_initialize_type, [], e unless (tmeth.ret == init_typ) unless ((trecv.val == Hash) && tmeth.ret.is_a?(RDL::Type::FiniteHashType)) || ((trecv.val == Array) && tmeth.ret.is_a?(RDL::Type::TupleType))
              end
            #trets_tmp << init_typ unless block_mismatch
              trets_tmp << (current_ret = tmeth.ret.instantiate(tmeth_inst))
              got_match = true
            elsif !block_mismatch
              trets_tmp << (current_ret = (tmeth.ret.instantiate(tmeth_inst))) # found a match for this subunion; add its return type to trets_tmp
              got_match = true
              if comp_type && RDL::Config.instance.check_comp_types && !union
                if (e.type == :op_asgn) && op_asgn
                  ## Hacky trick here. Because the ast `e` is used twice when type checking an op_asgn,
                  ## in one of the cases we will use the object_id of its object_id to get two different mappings.
                  RDL::Globals.comp_type_map[e.object_id.object_id] = [tmeth, tmeth_old, tmeth_res, self_klass, trecv_old, targs_old, (binds || {})]
                else
                  RDL::Globals.comp_type_map[e.object_id] = [tmeth, tmeth_old, tmeth_res, self_klass, trecv_old, targs_old, (binds || {})]
                end
              end
            end
            block_mismatch = false
          end
        end

        if got_match
          deferred_constraints += current_dcs
          if ts.size > 1 && tactuals_expanded.any? { |t| t.is_a?(RDL::Type::VarType) }
            ## need ChoiceTypes in this case

            ## first convert constraints in current_dcs (which is of form [[t1, t2], [t3,t4]...])
            ## into hash of form { t1 => t2, t3 => t4 }, combining multiple upper bounds into Union.
            constraints_hash = current_dcs.inject({}) do |hash, constraint|
              hash[constraint[0]] = RDL::Type::UnionType.new(hash[constraint[0]], constraint[1]).canonical
              hash
            end

            ## next, make the choice hashes and add them to arg_choices
            constraints_hash.each { |vartype, ubound|
              arg_choices[vartype][choice_num] = ubound
            }

            raise "Expected return type." unless current_ret
            ret_choice[choice_num] = RDL::Type::UnionType.new(current_ret, ret_choice[choice_num]).canonical
          end
        end

      }
      if trets_tmp.empty?
        # no arm of the intersection matched this expanded actuals lists, so reset trets to signal error and break loop
        trets = []
        break
      else
        #apply_deferred_constraints(deferred_constraints, e) if !deferred_constraints.empty?
        trets.concat(trets_tmp)
      end
    }
    ## Down here EITHER: apply all deferred constraints, continue with trets OR turn choices into ChoiceTypes, apply those deferred constraints, turn trets into [ret_choice_type]

    if arg_choices.empty?
      apply_deferred_constraints(deferred_constraints, e) if !deferred_constraints.empty?
    else
      new_dcs = []
      ct_args = []
      arg_choices.each { |vartype, choice_hash|
        if choice_hash.values.uniq.size == 1
          new_dcs << [vartype, choice_hash.values[0]]
        else
          t = RDL::Type::ChoiceType.new(choice_hash)
          new_dcs << [vartype, t]
          ct_args << t
        end
      }

      raise "Expected non-empty return choice hash." if ret_choice.empty?
      if ret_choice.values.uniq.size == 1
        new_ret = ret_choice.values[0]
        ct_args.each { |ct| ct.add_connecteds(*ct_args) }
      else
        new_ret = RDL::Type::ChoiceType.new(ret_choice)
        (ct_args+[new_ret]).each { |ct| ct.add_connecteds(new_ret, *ct_args) }
      end
      trets = [new_ret]
      apply_deferred_constraints(new_dcs, e) if !new_dcs.empty?
    end

    if trets.empty? # no possible matching call
      msg = <<RUBY
Method type:
#{ tmeth_names.map { |ti| "        " + ti.to_s }.join("\n") }
Actual arg type#{tactuals.size > 1 ? "s" : ""}:
      (#{tactuals.map { |ti| ti.to_s }.join(', ')}) #{if block then '{ block }' end}
RUBY
      msg.chomp! # remove trailing newline
      name = if trecv.is_a?(RDL::Type::SingletonType) && trecv.val.is_a?(Class) && (meth == :new) then
        trecv.val.to_s
      elsif trecv.is_a? RDL::Type::SingletonType
        trecv.val.class.to_s
      elsif [RDL::Type::NominalType, RDL::Type::GenericType, RDL::Type::FiniteHashType, RDL::Type::TupleType, RDL::Type::AstNode, RDL::Type::PreciseStringType].any? { |t| trecv.is_a? t }
        trecv.to_s
      elsif trecv.is_a?(RDL::Type::MethodType)
        'Proc'
      else
        raise RuntimeError, "impossible to get type #{trecv}"
      end
      error :arg_type_single_receiver_error, [name, meth, msg], e
    end
    # TODO: issue warning if trets.size > 1 ?
    return [env, trets]
  end

  def self.apply_deferred_constraints(deferred_constraints, e)
    if deferred_constraints.size > 2 && deferred_constraints.all? { |t1, t2| t1.equal?(deferred_constraints[0][0]) && t2.is_a?(RDL::Type::NominalType) && t2 <= RDL::Globals.types[:numeric] }
    ## This is a temporary hack for Numeric types.
    ## If all the LHS types are the same single type, and all the RHS types
    ## are Numeric types (which is the case for almost all arithmetic methods),
    ## then only apply the single constraint that t1 <= Numeric.
      RDL::Type::Type.leq(deferred_constraints[0][0], RDL::Globals.types[:numeric], nil, false, ast: e)
    else
      deferred_constraints.each { |t1, t2| RDL::Type::Type.leq(t1, t2, nil, false, ast: e) }
    end
  end

  # Evaluates any ComputedTypes in a method type
  # [+ tmeth +] is a MethodType for which we want to evaluate ComputedType args or return
  # [+ self_klass +] is the class of the receiver to the method call
  # [+ trecv +] is the type of the receiver to the method call
  # [+ tactuals +] is a list Array<Type> of types of the input to a method call
  # [+ binds +] is a Hash<Symbol, Type> mapping bound type names to the corresponding actual type.
  # Returns a new MethodType where all ComputedTypes in tmeth have been evaluated
  def self.compute_types(tmeth, self_klass, trecv, tactuals, binds={})
    bind = nil
    self_klass.class_eval { bind = binding() }
    bind.local_variable_set(:trec, trecv)
    bind.local_variable_set(:targs, tactuals)
    binds.each { |name, t| bind.local_variable_set(name, t) } unless binds.nil?
    new_args = []
    tmeth.args.each { |targ|
      case targ
      when RDL::Type::ComputedType
        new_args << targ.compute(bind)
      when RDL::Type::BoundArgType
        if targ.type.instance_of?(RDL::Type::ComputedType)
          new_args << targ.type.compute(bind)
        else
          new_args << targ
        end
      else
        new_args << targ
      end
    }
    case tmeth.ret
    when RDL::Type::ComputedType
      new_ret = tmeth.ret.compute(bind)
    when RDL::Type::BoundArgType
      if targ.type.instance_of?(RDL::Type::ComputedType)
        new_ret << targ.type.compute(bind)
      else
        new_ret << targ
      end
    else
      new_ret = tmeth.ret
    end
    new_block = compute_types(tmeth.block, self_klass, trecv, tactuals, binds) if tmeth.block
    RDL::Type::MethodType.new(new_args, new_block, new_ret)
  end

  def self.tc_send_class(trecv, e)
    case trecv
    when RDL::Type::SingletonType
      if trecv.val.is_a? Class
        [RDL::Type::SingletonType.new(Class)]
      elsif trecv.val.is_a? Module
        [RDL::Type::SingletonType.new(Module)]
      else
        [RDL::Type::SingletonType.new(trecv.val.class)]
      end
    when RDL::Type::NominalType
      [RDL::Type::SingletonType.new(trecv.klass)]
    when RDL::Type::GenericType
      [RDL::Type::SingletonType.new(trecv.base.klass)]
    when RDL::Type::TupleType
      [RDL::Type::SingletonType.new(Array)]
    when RDL::Type::FiniteHashType
      [RDL::Type::SingletonType.new(Hash)]
    when RDL::Type::PreciseStringType
      [RDL::Type::SingletonType.new(String)]
    when RDL::Type::VarType
      [RDL::Type::NominalType.new(Class)]
      #error :recv_var_type, [trecv], e
    when RDL::Type::MethodType
      [RDL::Type::SingletonType.new(Proc)]
    else
      raise RuntimeError, "Unexpected receiver type #{trecv}"
    end
  end

  # [+ tmeth +] is MethodType
  # [+ actuals +] is Array<Type> containing the actual argument types
  # return instiation (possibly empty) that makes actuals match method type (if any), nil otherwise
  # Very similar to MethodType#pre_cond?
  def self.tc_arg_types(tmeth, tactuals, deferred_constraints=[])
    states = [[0, 0, Hash.new, deferred_constraints]] # position in tmeth, position in tactuals, inst of free vars in tmeth
    tformals = tmeth.args
    until states.empty?
      formal, actual, inst, deferred_constraints = states.pop
      inst = inst.dup # avoid aliasing insts in different states since Type.leq mutates inst arg
      if formal == tformals.size && actual == tactuals.size # Matched everything
        return inst
      end
      next if formal >= tformals.size # Too many actuals to match
      t = tformals[formal]
      if t.instance_of?(RDL::Type::AnnotatedArgType) || t.instance_of?(RDL::Type::BoundArgType)
        t = t.type
      end
      case t
      when RDL::Type::OptionalType
        t = t.type
        if actual == tactuals.size
          states << [formal+1, actual, inst, deferred_constraints] # skip over optinal formal
        elsif (not tactuals[actual].is_a?(RDL::Type::VarargType)) && RDL::Type::Type.leq(tactuals[actual], t, inst, false, deferred_constraints) #&& (not (tactuals[actual].is_a?(RDL::Type::VarargType)))
          states << [formal+1, actual+1, inst, deferred_constraints] # match
          #states << [formal+1, actual, inst, deferred_constraints] unless tactuals[actual].is_a?(RDL::Type::VarType) && tformals[formal+1].is_a?(RDL::Type::FiniteHashType)# skip
        ## I added the `unless` guard above because of cases like `redirect_to @list, action: 'something'`.
        ## The clear intention of the programmer is for @list to match a non-FHT formal arg, so don't
        ## want to match it with the subsequent FHT.
        elsif tactuals[actual].is_a?(RDL::Type::VarargType) && RDL::Type::Type.leq(RDL::Type::GenericType.new(RDL::Globals.types[:array], tactuals[actual].type), t, inst, false, deferred_constraints)
          states << [formal+1, actual+1, inst, deferred_constraints] # match
        else
          states << [formal+1, actual, inst, deferred_constraints] # types don't match; must skip this formal
        end
      when RDL::Type::VarargType
        if actual == tactuals.size
          states << [formal+1, actual, inst, deferred_constraints] # skip to allow empty vararg at end
        elsif (not (tactuals[actual].is_a?(RDL::Type::VarargType))) && RDL::Type::Type.leq(tactuals[actual], t.type, inst, false, deferred_constraints)
          states << [formal, actual+1, inst, deferred_constraints] # match, more varargs coming
          states << [formal+1, actual+1, inst, deferred_constraints] # match, no more varargs
          states << [formal+1, actual, inst, deferred_constraints] # skip over even though matches

        elsif tactuals[actual].is_a?(RDL::Type::VarargType) && RDL::Type::Type.leq(tactuals[actual].type, t.type, inst, false, deferred_constraints) #&& RDL::Type::Type.leq(t.type, tactuals[actual].type, inst, true, deferred_constraints)
          states << [formal+1, actual+1, inst, deferred_constraints] # match, no more varargs; no other choices!
          states << [formal, actual+1, inst, deferred_constraints]
        else
          states << [formal+1, actual, inst, deferred_constraints] # doesn't match, must skip
        end
      else
        if actual == tactuals.size
          next unless t.instance_of? RDL::Type::FiniteHashType
          if @@empty_hash_type <= t
            states << [formal+1, actual, inst, deferred_constraints]
          end
        elsif (not (tactuals[actual].is_a?(RDL::Type::VarargType))) && RDL::Type::Type.leq(tactuals[actual], t, inst, false, deferred_constraints)
          states << [formal+1, actual+1, inst, deferred_constraints] # match!
          # no else case; if there is no match, this is a dead end
        end
      end
    end
    return nil
  end


  # [+ tmeth +] is MethodType
  # [+ actuals +] is Array<Type> containing the actual argument types
  # return binding of BoundArgType names to the corresponding actual type
  # Very similar to MethodType#pre_cond?
  def self.tc_bind_arg_types(tmeth, tactuals)
    states = [[0, 0, Hash.new, Hash.new]] # position in tmeth, position in tactuals, inst of free vars in tmeth
    tformals = tmeth.args
    until states.empty?
      formal, actual, inst, binds = states.pop
      inst = inst.dup # avoid aliasing insts in different states since Type.leq mutates inst arg
      if formal == tformals.size && actual == tactuals.size # Matched everything
        return binds
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
          states << [formal+1, actual, inst, binds] # skip over optinal formal
        elsif (not (tactuals[actual].is_a?(RDL::Type::VarargType))) && RDL::Type::Type.leq(tactuals[actual], t, inst, false, [])
          states << [formal+1, actual+1, inst, binds] # match
          states << [formal+1, actual, inst, binds] # skip
        else
          states << [formal+1, actual, inst, binds] # types don't match; must skip this formal
        end
      when RDL::Type::VarargType
        if actual == tactuals.size
          states << [formal+1, actual, inst, binds] # skip to allow empty vararg at end
        elsif (not (tactuals[actual].is_a?(RDL::Type::VarargType))) && RDL::Type::Type.leq(tactuals[actual], t.type, inst, false, [])
          states << [formal, actual+1, inst, binds] # match, more varargs coming
          states << [formal+1, actual+1, inst, binds] # match, no more varargs
          states << [formal+1, actual, inst, binds] # skip over even though matches
        elsif tactuals[actual].is_a?(RDL::Type::VarargType) && RDL::Type::Type.leq(tactuals[actual].type, t.type, inst, false, []) #&&
                                                               #RDL::Type::Type.leq(t.type, tactuals[actual].type, inst, true, [])
          states << [formal+1, actual+1, inst, binds] # match, no more varargs; no other choices!
          states << [formal, actual+1, inst, binds]
        else
          states << [formal+1, actual, inst, binds] # doesn't match, must skip
        end
      when RDL::Type::ComputedType
        ## arbitrarily count this as a match, we only care about binding names
        ## treat this same as VarargType but without call to leq
      #states << [formal+1, actual+1, inst, binds]
        if actual == tactuals.size
          states << [formal+1, actual, inst, binds] # skip to allow empty vararg at end
        elsif (not (tactuals[actual].is_a?(RDL::Type::VarargType)))
          states << [formal, actual+1, inst, binds] # match, more varargs coming
          states << [formal+1, actual+1, inst, binds] # match, no more varargs
          states << [formal+1, actual, inst, binds] # skip over even though matches
        elsif tactuals[actual].is_a?(RDL::Type::VarargType)
          states << [formal+1, actual+1, inst, binds] # match, no more varargs; no other choices!
        else
          states << [formal+1, actual, inst, binds] # doesn't match, must skip
        end
      else
        if actual == tactuals.size
          next unless t.instance_of? RDL::Type::FiniteHashType
          if @@empty_hash_type <= t
            states << [formal+1, actual, inst, binds]
          end
        elsif (not (tactuals[actual].is_a?(RDL::Type::VarargType))) #&& RDL::Type::Type.leq(tactuals[actual], t, inst, false)
          if t.is_a?(RDL::Type::BoundArgType)
            binds[t.name.to_sym] = tactuals[actual]
            t = t.type
          end
          states << [formal+1, actual+1, inst, binds] if (t.is_a?(RDL::Type::ComputedType) || RDL::Type::Type.leq(tactuals[actual], t, inst, false, []))# match!
          # no else case; if there is no match, this is a dead end
        end
      end
    end
    return nil
  end


  # [+ tblock +] is the type of the block (a MethodType)
  # [+ block +] is a pair [block-args, block-body] from the block AST node OR [block-type, block-arg-AST-node]
  # returns new environment if the block matches type tblock
  # otherwise throws an exception with a type error
  def self.tc_block(scope, env, tblock, block, inst)
    # TODO self is the same *except* instance_exec or instance_eval
    raise RuntimeError, "block with block arg?" unless tblock.is_a?(RDL::Type::VarType) || tblock.block.nil?
    tblock = tblock.instantiate(inst)
    if block[0].is_a?(RDL::Type::MethodType) || block[0].is_a?(RDL::Type::VarType)
      error :bad_block_arg_type, [block[0], tblock], block[1], block: true unless RDL::Type::Type.leq(block[0], tblock, inst, false, ast: block[1])#block[0] <= tblock
      ret_env = env
    elsif block[0].is_a?(RDL::Type::NominalType) && block[0].name == 'Proc'
      error :proc_block_arg_type, [tblock], block[1], block: true
    elsif tblock.is_a?(RDL::Type::VarType)
      args, body = block
      arg_names = args.children.map { |a| a.children[0] }
      args_hash = {}
      arg_vartypes = arg_names.map { |a|
        v = RDL::Type::VarType.new(cls: inst[:self], meth: "block", category: :block_arg, name: a.to_s )
        args_hash[a] = v
        v
      }
      body_env, body_type = if body.nil? then [nil, RDL::Globals.types[:nil]] else tc(scope, env.merge(Env.new(args_hash)), body) end
      block_type = RDL::Type::MethodType.new(arg_vartypes, nil, body_type)
      RDL::Type::Type.leq(block_type, tblock, inst, false, ast: body)
      ret_env = env.merge_block_env(body_env, arg_names)
    else # must be [block-args, block-body]
      args, body = block
      targs_env, targs = args_hash(scope, env, tblock, args, block[1], 'block')
      scope_merge(scope, outer_env: env) { |bscope|
        arg_names = args.children.map { |a| a.children[0] }
        # note: okay if outer_env shadows, since nested scope will include outer scope by next line
        targs_dup = Hash[targs.map { |k, t| [k, t.copy] }] ## args can be mutated in method body. duplicate to avoid this. TODO: check on this
        env_with_targs = targs_env.merge(Env.new(targs_dup))
        body_env, body_type = if body.nil? then [nil, RDL::Globals.types[:nil]] else tc(bscope, env_with_targs, body) end
        error :bad_return_type, [body_type, tblock.ret], body, block: true unless body.nil? || RDL::Type::Type.leq(body_type, tblock.ret, inst, false, ast: body)
        ret_env = env.merge_block_env(body_env, arg_names)
        error :internal, "empty self", block[1] if ret_env.env[:self].nil?
      }
    end
    return ret_env
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
  def self.lookup(scope, klass, name, e, make_unknown: RDL::Config.instance.use_unknown_types)
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
    t = RDL::Globals.info.get_with_aliases(klass, name, :type)
    return t if t # simplest case, no need to walk inheritance hierarchy
    return [make_unknown_method_type(klass, name)] if RDL::Globals.to_infer.values.any? { |set| set.include?([klass, name]) }
    klass_name = RDL::Util.has_singleton_marker(klass) ? RDL::Util.remove_singleton_marker(klass) : klass
    return [make_unknown_method_type(klass, name)] if make_unknown && (name == :initialize) && (RDL::Util.to_class(klass_name).instance_method(:initialize).owner == RDL::Util.to_class(klass_name)) # don't want to walk up hierarchy in initialize case where it is specifically defined for this class
    the_klass = RDL::Util.to_class(klass)
    is_singleton = RDL::Util.has_singleton_marker(klass)
    included = RDL::Util.to_class(klass.gsub("[s]", "")).included_modules
    ancestors = the_klass.ancestors[1..-1]
    ancestors += [Kernel, BasicObject] if (!ancestors.include?(Kernel) && !ancestors.include?(BasicObject)) # Module#ancestors does not include these, even though all modules inherit their methods.
    ancestors.each { |ancestor|
      # assumes ancestors is proper order to walk hierarchy
      # included modules' instance methods get added as instance methods, so can't be in singleton class
      next if (ancestor.instance_of? Module) && (included.member? ancestor) && is_singleton && !(ancestor == Kernel)
      # extended (i.e., not included) modules' instance methods get added as singleton methods, so can't be in class
      next if (ancestor.instance_of? Module) && (not (included.member? ancestor)) && (not is_singleton) && (ancestor != Kernel) && (ancestor != BasicObject)
      if is_singleton #&& !ancestor.instance_of?(Module)
        anc_lookup = get_singleton_name(ancestor.to_s)
      else
        anc_lookup = ancestor.to_s
      end
      tancestor = RDL::Globals.info.get_with_aliases(anc_lookup, name, :type)
      return tancestor if tancestor
      return [make_unknown_method_type(anc_lookup, name)] if RDL::Globals.to_infer.values.any? { |set| set.include?([anc_lookup, name]) }
      # special caes: Kernel's singleton methods are *also* added when included?!
      if ancestor == Kernel
        tancestor = RDL::Globals.info.get_with_aliases(RDL::Util.add_singleton_marker('Kernel'), name, :type)
        return tancestor if tancestor
      end
      if ancestor.instance_methods(false).member?(name)
## Milod: Not sure what the purpose of the below lines is.
=begin
        if RDL::Util.has_singleton_marker klass
          klass = RDL::Util.remove_singleton_marker klass
          klass = '(singleton) ' + klass
        end
=end
        return nil if the_klass.to_s.start_with?('#<Class:') and name == :new and !make_unknown
      end
    }

    if RDL::Config.instance.assume_dyn_type
      # method is nil when it isn't found? maybe log something here or raise exception
      method = the_klass.instance_method(name) rescue nil
      if method
        arity = method.arity
        has_varargs = false
        if arity < 0
          has_varargs = true
          arity = -arity - 1
        end
        args = arity.times.map { RDL::Globals.types[:dyn] }
        args << RDL::Type::VarargType.new(RDL::Globals.types[:dyn]) if has_varargs
      else
        args = [RDL::Type::VarargType.new(RDL::Globals.types[:dyn])]
      end

      ret = RDL::Globals.types[:dyn]
      ret = RDL::Type::NominalType.new(the_klass) if name == :initialize

      return [RDL::Type::MethodType.new(args, nil, ret)]
    else
      #return nil
      ## Trying new approach: create unknown method type for any methods without types.
      if make_unknown
        return [make_unknown_method_type(klass, name)] if (RDL::Util.to_class(klass).instance_methods + RDL::Util.to_class(klass).private_instance_methods).include?(name)
      else
        return nil
      end
    end
  end

  def self.make_unknown_method_type(klass, meth)
    raise "Tried to make unknown method type for class #{klass} method #{meth}, but no such method was found." unless (RDL::Util.to_class(klass).instance_methods + RDL::Util.to_class(klass).private_instance_methods).include?(meth)

    klass_obj = RDL::Util.to_class(klass)

    params = klass_obj.instance_method(meth).parameters
    arg_types = []
    keyword_args = {}
    params.each { |param|
      var_name = param[1]

      case param[0]
      when :req
        arg_types << RDL::Type::VarType.new(cls: klass, meth: meth, category: :arg, name: var_name)
      when :opt
        arg_types << RDL::Type::OptionalType.new(RDL::Type::VarType.new(cls: klass, meth: meth, category: :arg, name: var_name))
      when :rest
        arg_types << RDL::Type::VarargType.new(RDL::Type::VarType.new(cls: klass, meth: meth, category: :arg, name: var_name))
      when :key
        keyword_args[var_name] = RDL::Type::OptionalType.new(RDL::Type::VarType.new(cls: klass, meth: meth, category: :arg, name: var_name))
      when :keyreq
        keyword_args[var_name] = RDL::Type::VarType.new(cls: klass, meth: meth, category: :arg, name: var_name)
      when :block
      ## all method types will be given a variable type for blocks anyway, so no need to add a new param here
      when :keyrest
        raise "Not currently supported, for method #{meth} of class #{klass}"
      else
        raise "Unexpected parameter type #{param[0]}."
      end
    }
    keyword_args = keyword_args.empty? ? [] : [RDL::Type::FiniteHashType.new(keyword_args, nil)]
    arg_types = arg_types + keyword_args
    if meth == :initialize
=begin
      if RDL::Util.has_singleton_marker(klass)
        # to_class gets the class object itself, so remove singleton marker to get class rather than singleton class
        ret_vartype = RDL::Type::SingletonType.new(RDL::Util.to_class(RDL::Util.remove_singleton_marker(klass)))
      else
        ret_vartype = RDL::Type::NominalType.new(klass)
      end
=end
      ret_vartype = RDL::Globals.parser.scan_str "#T self"
    #ret_vartype = RDL::Type::VarType.new(:self) ## TODO: is this right? Or should it include klass/meth info?
    else
      ret_vartype = RDL::Type::VarType.new(cls: klass, meth: meth, category: :ret, name: "ret")
    end

    block_type = RDL::Type::VarType.new(cls: klass, meth: meth, category: :block, name: "block")

    meth_type = RDL::Type::MethodType.new(arg_types, block_type, ret_vartype)
    RDL::Globals.info.add(klass, meth, :type, meth_type)
    return meth_type
  end

  def self.make_unknown_var_type(klass, name, kind_text)
    var_type = RDL::Type::VarType.new(cls: klass, name: name, category: kind_text)
    RDL::Globals.info.set(klass, name, :type, var_type)
    RDL::Globals.constrained_types << [klass, name]
    return var_type
  end

  def self.filter_comp_types(ts, use_dep_types)
    return nil unless ts
    dep_ts = []
    non_dep_ts = []
    ts.each { |typ|
      case typ
      when RDL::Type::MethodType
        block_types = (if typ.block.is_a?(RDL::Type::MethodType) then typ.block.args + [typ.block.ret] else [] end)
        typs = typ.args + block_types + [typ.ret]
        if typs.any? { |t| t.is_a?(RDL::Type::ComputedType) || (t.is_a?(RDL::Type::BoundArgType) && t.type.is_a?(RDL::Type::ComputedType))  }
          dep_ts << typ
        else
          non_dep_ts << typ
        end
      else
        raise "Expected method type."
      end
    }
    if !use_dep_types || dep_ts.empty?
      return non_dep_ts ## if not using dependent types, or if none exist, return non-dependent types
    else
      return dep_ts ## if using dependent types and some exist, then *only* return dependent types
    end
  end

  def self.get_singleton_name(name)
    /#<Class:(.+)>/ =~ name
    return name unless $1 ### possible to get no match for extended modules, or class Class, Module, ..., BasicObject
    new_name = RDL::Util.add_singleton_marker($1)
    new_name
  end


  def self.find_constant(env, scope, e)
    # https://cirw.in/blog/constant-lookup.html
    # First look in Module.nesting for a lexically scoped variable
    const_string = e.loc.expression.source
    raise "Expected class and method in `scope` #{scope[:klass]}." unless scope[:klass] && scope[:meth]
    if (RDL::Util.has_singleton_marker(scope[:klass]))
      klass = RDL::Util.to_class(RDL::Util.remove_singleton_marker(scope[:klass]))
      mod_inst = false
    else
      klass = RDL::Util.to_class(scope[:klass])
      if klass.instance_of?(Module)
        mod_inst = true
      else
        mod_inst = false
        klass = klass.send :allocate
      end
    end
    if RDL::Wrap.wrapped?(scope[:klass], scope[:meth])
      meth_name = RDL::Wrap.wrapped_name(scope[:klass], scope[:meth])
    else
      meth_name = scope[:meth]
    end
    if mod_inst
      method = klass.instance_method(meth_name)
      raise "Expected UnboundMethod, got #{method}." unless method.is_a?(UnboundMethod)
      method_binding = method.bind(BasicObject.new).to_proc.binding ## For modules, just bind the UnboundMethod to an arbitrary BasicObject
    else
      method_binding = klass.method(meth_name).to_proc.binding
    end
    return method_binding.send(:eval, const_string)
  end
end

# Use parser's Diagnostic to output RDL typechecker error messages
class Diagnostic < Parser::Diagnostic

  def message
    RDL_MESSAGES[@reason] % @arguments
  end

  RDL_MESSAGES = {
    bad_return_type: "got type `%s' where return type `%s' expected",
    bad_inst_type: "instantiate! called on object of type `%s' where Generic Type was expected",
    inst_not_param: "instantiate! receiver is of class `%s' which is not parameterized",
    inst_num_args: "instantiate! expecting `%s' type parameters, got `%s' parameters",
    inst_lvar: "instantiate! expects local variable as receiver",
    bad_initialize_type: 'initialize method must always be annotated to return type "self" or a GenericType where the base is "self"',
    undefined_local_or_method: "undefined local variable or method `%s'",
    nonmatching_range_type: "attempt to construct range with non-matching types `%s' and `%s'",
    no_instance_method_type: "no type information for instance method `%s#%s'",
    no_singleton_method_type: "no type information for class/singleton method `%s.%s'",
    arg_type_single_receiver_error: "argument type error for instance method `%s#%s'\n%s",
    untyped_var: "no type for %s `%s' in class %s, and it is not designated to be inferred",
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
    type_cast_format: "type_cast must be called as `type_cast obj, type-string' or `type_cast obj, type-string, force: expr'",
    instantiate_format: "instantiate! must be called as `instantiate! type*' or `instantiate! type*, check: bool' where type is a string, symbol, or class for static type checking.",
    note_type_format: "note_type must be called as `note_type e`",
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
    no_non_dep_types: "no non-dependent types for receiver %s in call to method %s",
    empty_env: "for some reason, environment is nil when type checking assignment to variable %s.",
    unsupported_expression: "Expression kind %s unsupported, for expression %s",

    infer_constraint_error: "%s constraint generated here.",

    internal: "internal error: %s",

    empty: "",
  }
end

class Object

  ## Method to replace dependently typed methods, and insert dynamic checks of types.
  ## This method will check that given args satisfy given type, run the original method,
  ## then check that the returned value satisfies the returned type, and finally return that value.
  ## [+ __rdl_meth +] is a Symbol naming the method being replaced.
  ## [+ node_id +] is an Integer representing the object_id of the relevant AST node to be looked up in the comp_type_map.
  ## [+ *args +], [+ &block +] are the original arguments and blocked passed in a method call.
  ## returns whatever is returned by calling the given method with the given args and block.
  def __rdl_dyn_type_check(__rdl_meth, node_id, *args, &block)
    tmeth, tmeth_old, tmeth_res, self_klass, trecv_old, targs_old, binds = RDL::Globals.comp_type_map[node_id]
    raise RuntimeError, "Could not find cached type-level computation results for method #{__rdl_meth}." unless tmeth
    if RDL::Config.instance.rerun_comp_types
      tmeth_new = RDL::Typecheck.compute_types(tmeth_old, self_klass, trecv_old, targs_old, binds)
      unless tmeth_new == tmeth_res
        raise RDL::Type::TypeError, "Type-level computation evaluated to different result from type checking time for class #{self_klass} method #{__rdl_meth}.\n Got #{tmeth_res} the first time, but #{tmeth_new} the second time."
      end
    end
    bind = binding
    inst = nil
    inst = @__rdl_type.to_inst if ((defined? @__rdl_type) && @__rdl_type.is_a?(RDL::Type::GenericType))
    klass = self.class.to_s
    inst = Hash[RDL::Globals.type_params[klass][0].zip []] if (not(inst) && RDL::Globals.type_params[klass])
    inst = {} if not inst

    matches, args, _, bind = RDL::Type::MethodType.check_arg_types("#{__rdl_meth}", self, bind, [tmeth], inst, *args, &block)

    ret = self.send(__rdl_meth, *args, &block)

    if matches
      ret = RDL::Type::MethodType.check_ret_types(self, "#{__rdl_meth}", [tmeth], inst, matches, ret, bind, *args, &block) unless __rdl_meth == :initialize
    end

    return ret
  end

end

module Parser
  module Source
    class TreeRewriter
      ## Had to add some methods to the parser. Specifically, wanted to use `replace` for not just method being
      ## called, but allso for its receiver and args. Doing so requires aligning the `range` being replaced
      ## with the `buffer` containing the string that is being rewritten, in a way that the Parser did not support.
      def align_replace(range, offset, content)
        align_combine(range, offset, replacement: content)
      end

      def align_combine(range, offset, attributes)
        if range.length > @source_buffer.source.size ## these are expected to be equal since buffer should be created from range source.
          raise IndexError, "The range #{range} is outside the bounds of the source of size #{@source_buffer.source.size}"
        end
        dummy_range = Parser::Source::Range.new(@source_buffer, range.begin_pos - offset, range.end_pos - offset)
        action = TreeRewriter::Action.new(dummy_range, @enforcer, **attributes)
        @action_root = @action_root.combine(action)
        self
      end

    end
  end
end

module Parser
  class TreeRewriter < Parser::AST::Processor

    def align_replace(range, offset, content)
      @source_rewriter.align_replace(range, offset, content)
    end
  end
end



class WrapCall < Parser::TreeRewriter

  def on_send(node)
    rec_ast = node.children[0]
    rec_code = WrapCall.rewrite(rec_ast)+"." if rec_ast.is_a?(AST::Node) ## receiver is nil, or it gets rewritten
    args_code = node.children[2..-1].map { |n| WrapCall.rewrite(n) if n.is_a?(AST::Node) }
    args_code = args_code.empty? ? nil : ","+args_code.join(",") ## no args, or args get rewritten
    unless node.children[1] == :__rdl_dyn_type_check ## I don't believe this check is necessary, but at one point I had this issue so I'm leaving it in
      if RDL::Globals.comp_type_map[node.object_id] ## Only do this if a call is associated with a type in the map. Otherwise, it may be a call to a non-dependently typed method.
        align_replace(node.location.expression, @offset, "#{rec_code}__rdl_dyn_type_check(:#{node.children[1]}, #{node.object_id} #{args_code})")
      end
    end
  end

  def on_op_asgn(node)
    if node.children[0].type == :send
      rec_ast = node.children[0].children[0]
      rec_code = WrapCall.rewrite(rec_ast) + "." if rec_ast.is_a?(AST::Node)

      rec_meth_ast = node.children[0]
      rec_meth_code = WrapCall.rewrite(rec_meth_ast)

      elargs_ast = node.children[0].children[2]
      elargs_code = WrapCall.rewrite(elargs_ast)

      rhs_ast = node.children[2]
      rhs_code = WrapCall.rewrite(rhs_ast)

      op_meth = node.children[1]
      mutation_meth = node.children[0].children[1].to_s + "="

      if RDL::Globals.comp_type_map[node.object_id]
        op_code = "#{rec_meth_code}.__rdl_dyn_type_check(:#{op_meth}, #{node.object_id}, #{rhs_code})"
      else
        op_code = "#{rec_meth_code}.send(:#{op_meth}, #{rhs_code})"
      end

      if RDL::Globals.comp_type_map[node.object_id.object_id]
        align_replace(node.location.expression, @offset, "#{rec_code}__rdl_dyn_type_check(:#{mutation_meth}, #{node.object_id.object_id}, #{elargs_code}, #{op_code})")
      end
    else
      lhs = node.location.name.source
      meth = node.children[1]
      rhs_ast = node.children[2]
      rhs_code = WrapCall.rewrite(rhs_ast)
      if RDL::Globals.comp_type_map[node.object_id]
        align_replace(node.location.expression, @offset, "#{lhs} = #{lhs}.__rdl_dyn_type_check(:#{meth}, #{node.object_id}, #{rhs_code})")
      end
    end
  end

  def on_or_asgn(node)
    if node.children[0].type == :send
      rec_ast = node.children[0].children[0]
      rec_code = WrapCall.rewrite(rec_ast)+"." if rec_ast.is_a?(AST::Node)

      rec_meth_ast = node.children[0]
      rec_meth_code = WrapCall.rewrite(rec_meth_ast)

      elargs_ast = node.children[0].children[2]
      elargs_code = WrapCall.rewrite(elargs_ast)

      rhs_ast = node.children[1]
      rhs_code = WrapCall.rewrite(rhs_ast)

      mutation_meth = node.children[0].children[1].to_s + "="

      if RDL::Globals.comp_type_map[node.object_id]
        align_replace(node.location.expression, @offset, "#{rec_code}__rdl_dyn_type_check(:#{mutation_meth}, #{node.object_id}, #{elargs_code}, #{rec_meth_code} || #{rhs_code})")
      end
    else
      lhs = node.location.name.source
      rhs_ast = node.children[1]
      rhs_code = WrapCall.rewrite(rhs_ast)
      align_replace(node.location.expression, @offset, "#{lhs} = #{lhs} || #{rhs_code}")
    end
  end

  def on_and_asgn(node)
    if node.children[0].type == :send
      rec_ast = node.children[0].children[0]
      rec_code = WrapCall.rewrite(rec_ast)+"." if rec_ast.is_a?(AST::Node)

      rec_meth_ast = node.children[0]
      rec_meth_code = WrapCall.rewrite(rec_meth_ast)

      elargs_ast = node.children[0].children[2]
      elargs_code = WrapCall.rewrite(elargs_ast)

      rhs_ast = node.children[1]
      rhs_code = WrapCall.rewrite(rhs_ast)

      mutation_meth = node.children[0].children[1].to_s + "="

      if RDL::Globals.comp_type_map[node.object_id]
        align_replace(node.location.expression, @offset, "#{rec_code}__rdl_dyn_type_check(:#{mutation_meth}, #{node.object_id}, #{elargs_code}, #{rec_meth_code} && #{rhs_code})")
      end
    else
      lhs = node.location.name.source
      rhs_ast = node.children[1]
      rhs_code = WrapCall.rewrite(rhs_ast)
      align_replace(node.location.expression, @offset, "#{lhs} = #{lhs} && #{rhs_code}")
    end
  end


  def initialize(offset)
    @offset = offset
  end

  def self.rewrite(ast)
    rewriter = WrapCall.new(ast.location.expression.begin_pos)
    buffer = Parser::Source::Buffer.new("(ast)")
    buffer.source = ast.location.expression.source
    rewriter.rewrite(buffer, ast)
  end
end
