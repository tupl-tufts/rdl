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
          error :inconsistent_var_type, [var.to_s], e unless rest.all? { |other| other.fixed? var }
          neq = []
          rest.each { |other|
            other_typ = other[var]
            neq << other_typ unless first_typ == other_typ
          }
          error :inconsistent_var_type_type, [var.to_s, (first_typ + neq).map { |t| t.to_s }.join(' and ')], e unless neq.empty?
          env.env[var] = {type: h[:type], fixed: true}
        else
          typ =  RDL::Type::UnionType.new(first_typ, *rest.map { |other| ((other.has_key? var) && other[var]) || $__rdl_nil_type })
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
    raise RuntimeError, "singleton method typechecking not supported yet" if RDL::Util.has_singleton_marker(klass)
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
      _, body_type = if body.nil? then [nil, $__rdl_nil_type] else tc(Hash.new, Env.new(a), body) end
      error :bad_return_type, [body_type.to_s, type.ret.to_s], body unless body_type <= type.ret
    }
  end

  # The actual type checking logic.
  # [+ scope +] tracks flow-insensitive information about the current scope, excluding local variables
  # [+ env +] is the (local variable) Env
  # [+ e +] is the expression to type check
  # Returns [env', t], where env' is the type environment at the end of the expression
  # and t is the type of the expression
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
    when :lvar  # local variable
      x = e.children[0] # the variable
      error :undefined_local_or_method, x.to_s, e unless env.has_key? x
      [env, env[x]]
    when :ivar, :cvar, :gvar
      x = e.children[0] # the variable
      klass = (if e.type == :gvar then RDL::Util::GLOBAL_NAME else env[:self] end)
      unless $__rdl_info.has?(klass, x, :type)
        kind = (if e.type == :ivar then "instance"
                elsif e.type == :cvar then "class"
                else "global" end)
        error :untyped_var, [kind, x], e
      end
      [env, $__rdl_info.get(klass, x, :type)]
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
    when :lvasgn
      x = e.children[0] # the variable
      env1, t1 = tc(scope, env, e.children[1])
      if env1.fixed? x
        error :vasgn_incompat, [t1, env1[x]], e unless t1 <= env1[x]
        [env1, t1]
      else
        [env1.bind(x, t1), t1]
      end
    when :ivasgn, :cvasgn, :gvasgn
      x = e.children[0] # the variable
      envright, tright = tc(scope, env, e.children[1])
      klass = (if e.type == :gvasgn then RDL::Util::GLOBAL_NAME else env[:self] end)
      unless $__rdl_info.has?(klass, x, :type)
        kind = (if e.type == :ivasgn then "instance"
                elsif e.type == :cvasgn then "class"
                else "global" end)
        error :untyped_var, [kind, x], e
      end
      tleft = $__rdl_info.get(klass, x, :type)
      error :vasgn_incompat, [tright.to_s, tleft.to_s], e unless tright <= tleft
      [envright, tright]
    when :send, :csend
      # children[0] = receiver; if nil, receiver is self
      # children[1] = method name, a symbol
      # children [2..] = actual args
      return tc_var_type(scope, env, e) if e.children[0].nil? && e.children[1] == :var_type
      envi = env
      tactuals = []
      e.children[2..-1].each { |ei| envi, ti = tc(scope, envi, ei); tactuals << ti }
      envi, trecv = if e.children[0].nil? then [envi, envi[:self]] else tc(scope, envi, e.children[0]) end # if no receiver, self is receiver
      [envi, tc_send(trecv, e.children[1], tactuals, e)]
    when :and
      envleft, tleft = tc(scope, env, e.children[0])
      envright, tright = tc(scope, envleft, e.children[1])
      if tleft.is_a? RDL::Type::SingletonType
        if tleft.val then [envright, tright] else [envleft, tleft] end
      else
        [Env.join(e, envleft, envright), RDL::Type::UnionType.new(tleft, tright)]
      end
    when :or
      envleft, tleft = tc(scope, env, e.children[0])
      envright, tright = tc(scope, envleft, e.children[1])
      if tleft.is_a? RDL::Type::SingletonType
        if tleft.val then [envleft, tleft] else [envright, tright] end
      else
        [Env.join(e, envleft, envright), RDL::Type::UnionType.new(tleft, tright)]
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
        [Env.join(e, envleft, envright), RDL::Type::UnionType.new(tleft, tright)]
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
      return [Env.join(e, *envbodies), RDL::Type::UnionType.new(*tbodies)]
    when :begin # sequencing
      envi = env
      ti = nil
      e.children.each { |ei| envi, ti = tc(scope, envi, ei) }
      [envi, ti]
    else
      raise RuntimeError, "Expression kind #{e.type} unsupported"
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
  # [+ trecv +] is the type of the recevier
  # [+ meth +] is a symbol with the method name
  # [+ tactuals +] are the actual arguments
  # [+ e +] is the expression at which location to report an error
  def self.tc_send(trecv, meth, tactuals, e)
    tmeth_inters = [] # Array<Array<MethodType>>, array of intersection types, since recv might not resolve to a single type

    if (trecv.is_a? RDL::Type::SingletonType) && (trecv.val.is_a? Class) && (meth == :new)
      t = lookup(RDL::Util.add_singleton_marker(trecv.val.to_s), :initialize)
      t = [RDL::Type::MethodType.new([], nil, RDL::Type::NominalType.new(trecv.val))] unless t # there's always a nullary new if initialize is undefined
      tmeth_inters << t
    elsif trecv.is_a? RDL::Type::SingletonType
      klass = trecv.val.class.to_s
      t = lookup(klass, meth)
      error :no_instance_method_type, [klass, meth], e unless t
      tmeth_inters << t
    elsif trecv.is_a? RDL::Type::NominalType
      t = lookup(trecv.name, meth)
      error :no_instance_method_type, [trecv.name, meth], e unless t
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
      else
        # TODO more complicated error message here
        raise RuntimeError, "Not implemented yet #{tmeth_inters}"
      end
    end
    # TODO: issue warning if trets.size > 1 ?
    return RDL::Type::UnionType.new(*trets)
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

  # [+ as +] is an array of local variable type environments
  # returns join of evironments
  # def self.ajoin(*as)
  #   a = Hash.new
  #   return a if as.empty?
  #   return as[0] if as.size == 1
  #   first = as[0]
  #   rest = as[1..-1]
  #   first.each_pair { |k, t|
  #     if rest.all? { |h| h.has_key? k}
  #       a[k] = RDL::Type::UnionType.new(t, *rest.map { |h| h[k] })
  #     end
  #   }
  #   return a
  # end

end

# Modify Parser::MESSAGES so can use the awesome parser diagnostics printing!
type_error_messages = {
  bad_return_type: "got type `%s' where return type `%s' expected",
  undefined_local_or_method: "undefined local variable or method `%s'",
  nonmatching_range_type: "attempt to construct range with non-matching types `%s' and `%s'",
  no_instance_method_type: "no type information for instance method `%s#%s'",
  arg_type_single_receiver_error: "argument type error for instance method `%s#%s'\n%s",
  untyped_var: "no type for %s variable `%s'",
  vasgn_incompat: "incompatible types: `%s' can't be assigned to variable of type `%s'",
  var_type_num_args: "var_type expects 2 arguments but got %d arguments",
  var_type_var: "var_type expects first argument to be a symbol with a local variable name",
  var_type_type: "var_type expects second argument to be a constant string describing a type",
  inconsistent_var_type: "local variable `%s' has declared type on some paths but not all",
  inconsistent_var_type_type: "local variable `%s' declared with inconsistent types %s",
}
old_messages = Parser::MESSAGES
Parser.send(:remove_const, :MESSAGES)
Parser.const_set :MESSAGES, (old_messages.merge(type_error_messages))
