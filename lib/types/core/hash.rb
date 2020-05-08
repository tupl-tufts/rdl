RDL.nowrap :Hash

RDL.type_params :Hash, [:k, :v], :all?

def Hash.output_type(trec, targs, meth_name, default1, default2=default1, nil_default: false, use_sing_val: true)
  case trec
  when RDL::Type::FiniteHashType
    if targs.empty? || targs.all? { |t| t.is_a?(RDL::Type::SingletonType) }
      vals = RDL.type_cast((if use_sing_val then targs.map { |t| RDL.type_cast(t, "RDL::Type::SingletonType").val } else targs end), "Array<%any>", force: true)
      res = RDL.type_cast(trec.elts.send(meth_name, *vals), "Object", force: true)
      if nil_default && res.nil?
        if default1 == :promoted_val
          # ret = trec.promote.params[1]
          return trec.promote.params[1]
        elsif default1 == :promoted_key
          return trec.promote.params[0]
        elsif default1 == :default_or_promoted_val
          if trec.default then
            return assign_output(trec, targs + [trec.default])
          else
            return trec.promote.params[1]
          end
        else
          return RDL::Globals.parser.scan_str "#T #{default1}"
        end
      end
      to_type(res)
    else
      if default1 == :promoted_val
        return trec.promote.params[1]
      elsif default1 == :promoted_key
        return trec.promote.params[0]
      elsif default1 == :default_or_promoted_val
        if trec.default then
          return assign_output(trec, targs + [trec.default])
        else
          return trec.promote.params[1]
        end
      else
        RDL::Globals.parser.scan_str "#T #{default1}"
      end
    end
  else
    if default2 == "k"
      trec.params[0] ## equivalent of k in Hash<k, v>
    elsif default2 == "v"
      if trec.to_s == 'ActionController::Parameters'
        return RDL::Globals.parser.scan_str "#T (Symbol or String)"
      else
        trec.params[1] ## equivalent of v in Hash<k, v>
      end
    else
      RDL::Globals.parser.scan_str "#T #{default2}"
    end
  end
end
RDL.type Hash, 'self.output_type', "(RDL::Type::Type, Array<RDL::Type::Type>, Symbol, Symbol or String, ?(Symbol or String), { nil_default: ?%bool, use_sing_val: ?%bool } ) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]


def Hash.to_type(t)
  if t.is_a?(RDL::Type::Type)
    t
  elsif t.is_a? Array
    RDL::Type::TupleType.new(*(t.map { |i| to_type(i) }))
  elsif t.is_a? Numeric
    if RDL::Config.instance.number_mode
      RDL::Type::NominalType.new(Integer)
    else
      RDL::Type::SingletonType.new(t)
    end
  elsif t.is_a?(Symbol) || t.is_a?(TrueClass) || t.is_a?(FalseClass) || t.is_a?(Module)
    RDL::Type::SingletonType.new(t)
  else
    RDL::Type::NominalType.new(t.class)
  end
end
RDL.type Hash, 'self.to_type', "(%any) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

def Hash.any_or_k(trec)
  case trec
  when RDL::Type::FiniteHashType
    RDL::Globals.types[:top]
  when RDL::Type::GenericType
    #RDL::Globals.parser.scan_str "#T k"
    trec.params[0] ## equivalent of k in Hash<k, v>
  when RDL::Type::NominalType
    if trec.to_s == 'ActionController::Parameters'
      return RDL::Globals.parser.scan_str "#T (Symbol or String)"
    else
      return RDL::Globals.parser.scan_str "#T k"
    end
  else
    raise "unexpected, got #{trec}"
  end
end
RDL.type Hash, 'self.any_or_k', "(RDL::Type::Type) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

def Hash.any_or_v(trec)
  case trec
  when RDL::Type::FiniteHashType
    RDL::Globals.types[:top]
  when RDL::Type::GenericType
  #RDL::Globals.parser.scan_str "#T v"
    trec.params[1] ## equivalent of v in Hash<k, v>
  else
    raise "unexpected"
  end
end
RDL.type Hash, 'self.any_or_v', "(RDL::Type::Type) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

def Hash.promoted_or_v(trec)
  case trec
  when RDL::Type::FiniteHashType
    trec.promote.params[1]
  when RDL::Type::GenericType
    #RDL::Globals.parser.scan_str "#T v"
    trec.params[1]
  else
    raise "unexpected"
  end
end
RDL.type Hash, 'self.promoted_or_v', "(RDL::Type::Type) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

def Hash.promoted_or_k(trec)
  case trec
  when RDL::Type::FiniteHashType
    trec.promote.params[0]
  when RDL::Type::GenericType
    #RDL::Globals.parser.scan_str "#T v"
    trec.params[0]
  else
    raise "unexpected"
  end
end


def Hash.weak_promote(val)
  case val
  when RDL::Type::UnionType
    if val.types.all? { |t| t.is_a?(RDL::Type::SingletonType) }
      klass = RDL.type_cast(val.types[0], "RDL::Type::SingletonType", force: true).nominal.klass
      if val.types.all? { |t| RDL.type_cast(t, "RDL::Type::SingletonType", force: true).nominal.klass == klass }
        return RDL::Type::NominalType.new(klass)
      else
        return val
      end
    else
      return val
    end
  else
    val
  end
end
RDL.type Hash, 'self.weak_promote', "(RDL::Type::Type) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

#RDL.type :Hash, 'self.[]', '(*%any) -> ``hash_create_output_from_list(targs)``'
RDL.type :Hash, 'self.[]', '(*%any) -> ``hash_create_output(targs)``'

def Hash.hash_create_output_from_list(targs)
  raise RDL::Typecheck::StaticTypeError, "Hash[...] expect only 1 argument. Have #{targs}." if targs.size > 1
  raise RDL::Typecheck::StaticTypeError, "The argument has to be an array or tuple, got #{targs[0]}" unless ((targs[0].is_a?(RDL::Type::GenericType) && targs[0].base.klass == Array) || targs[0].is_a?(RDL::Type::VarType))

  case targs[0]
  when RDL::Type::VarType
    return RDL::Globals.types[:hash]
  else
    case targs[0].params[0]
    when RDL::Type::GenericType
      return RDL::Globals.parser.scan_str "#T Hash<#{targs[0].params[0].params[0]}, #{targs[0].params[0].params[0]}>"
    when RDL::Type::TupleType
      return RDL::Type::GenericType.new(RDL::Type::NominalType.new(Hash), targs[0].params[0].params[0], targs[0].params[0].params[1])
    end
  end
end

def Hash.hash_create_output(targs)
  return hash_create_output_from_list(targs) if targs.size == 1

  raise RDL::Typecheck::StaticTypeError, "Hash.[] expects an even number of arguments. Have #{targs}." if targs.size.odd?
  args = RDL.type_cast([], "Array<%any>", force: true)
  i = -1
  args = targs.map { |a| i = i+1 ; if i.even? && a.is_a?(RDL::Type::SingletonType) then RDL.type_cast(a, "RDL::Type::SingletonType", force: true).val else a end }
  RDL::Type::FiniteHashType.new(RDL.type_cast(Hash[*args], "Hash<%any, RDL::Type::Type>", force: true), nil)
end
RDL.type Hash, 'self.hash_create_output', "(Array<RDL::Type::Type>) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

RDL.type :Hash, :[], '(``any_or_k(trec)``) -> ``output_type(trec, targs, :[], :default_or_promoted_val, "v", nil_default: true)``', effect: [:+, :+]

RDL.type :Hash, :[]=, '(``any_or_k(trec)``, ``any_or_v(trec)``) -> ``assign_output(trec, targs)``'


def Hash.assign_output(trec, targs)
  case trec
  when RDL::Type::FiniteHashType
    case targs[0]
    when RDL::Type::SingletonType ### TODO: adjust for strings
      argval = RDL.type_cast(targs[0], "RDL::Type::SingletonType", force: true).val
      trec.elts[argval] = RDL::Type::UnionType.new(trec.elts[argval], targs[1]).canonical
      trec.elts[argval] = weak_promote(trec.elts[argval]) if RDL::Config.instance.weak_update_promote
      raise RDL::Typecheck::StaticTypeError, "Failed to mutate hash: new hash does not match prior type constraints." unless trec.check_bounds(true)
      return targs[1]
    else
      raise "Unable to promote tuple #{trec} to Hash." unless trec.promote!(targs[0], targs[1])
      return targs[1]
    end
  else
    #RDL::Globals.parser.scan_str "#T v"
    trec.params[1]
  end
end
RDL.type Hash, 'self.assign_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:~, :+]

RDL.type Hash, :initialize, "(*%any) -> ``RDL::Type::FiniteHashType.new({}, nil, default: targs[0])``"
RDL.type Hash, :initialize, "() { (Hash<a, b>, x) -> y } -> ``RDL::Type::GenericType.new(RDL::Globals.types[:hash], RDL::Globals.types[:top], RDL::Globals.types[:top])``"

RDL.type :Hash, :store, '(``any_or_k(trec)``, ``any_or_v(trec)``) -> ``assign_output(trec, targs)``'
RDL.type :Hash, :assoc, '(``any_or_k(trec)``) -> ``RDL::Type::TupleType.new(targs[0], output_type(trec, targs, :[], :promoted_val, "v", nil_default: true))``'
RDL.type :Hash, :clear, '() -> self'
RDL.type :Hash, :compare_by_identity, '() -> self'
RDL.type :Hash, :compare_by_identity?,  '() -> %bool'
RDL.type :Hash, :default, '() -> ``promoted_or_v(trec)``'
RDL.type :Hash, :default, '(``any_or_k(trec)``) -> ``promoted_or_v(trec)``'
RDL.type :Hash, :default=, '(``promoted_or_v(trec)``) -> ``promoted_or_v(trec)``'

RDL.type :Hash, :delete, '(``any_or_k(trec)``) -> ``delete_output(trec, targs, false)``'
RDL.type :Hash, :delete, '(``any_or_k(trec)``) { (``any_or_k(trec)``) -> u } -> ``delete_output(trec, targs, true)``'

def Hash.delete_output(trec, targs, block)
  case trec
  when RDL::Type::FiniteHashType
    case targs[0]
    when RDL::Type::SingletonType
      argval = RDL.type_cast(targs[0], "RDL::Type::SingletonType", force: true).val
      if trec.elts.include?(argval)
        trec.elts[argval]
      else
        trec.promote.params[1]
      end
    else
      if block
        RDL::Type::UnionType.new(trec.promote.params[1], RDL::Globals.parser.scan_str("#T u"))
      else
        trec.promote.params[1]
      end
    end
  else
    return RDL::Globals.types[:nil] if trec.to_s == "ActionController::Parameters"
    t = (if block then "u or v" else "v" end)
    RDL::Globals.parser.scan_str "#T #{t}"
  end
end
RDL.type Hash, 'self.delete_output', "(RDL::Type::Type, Array<RDL::Type::Type>, %bool) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

RDL.type :Hash, :delete_if, '() { (``promoted_or_k(trec)``, ``promoted_or_v(trec)``) -> %any } -> self'
RDL.type :Hash, :delete_if, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), RDL::Type::TupleType.new(any_or_k(trec), any_or_v(trec)))``' ## I had made a mistake here, type checker caught it.
RDL.type :Hash, :each, '() { (``promoted_or_k(trec)``, ``promoted_or_v(trec)``) -> %any } -> self'
RDL.type :Hash, :each, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), RDL::Type::TupleType.new(any_or_k(trec), any_or_v(trec)))``' ## I had made a mistake here, type checker caught it.
RDL.type :Hash, :each_pair, '() { (``promoted_or_k(trec)``, ``promoted_or_v(trec)``) -> %any } -> self'
RDL.type :Hash, :each_pair, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), RDL::Type::TupleType.new(any_or_k(trec), any_or_v(trec)))``' ## I had made a mistake here, type checker caught it.
RDL.type :Hash, :each_key, '() { (``promoted_or_k(trec)``) -> %any } -> self'
RDL.type :Hash, :each_key, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), any_or_k(trec))``'
RDL.type :Hash, :each_value, '() { (``promoted_or_v(trec)``) -> %any } -> self'
RDL.type :Hash, :each_value, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), any_or_v(trec))``'
RDL.type :Hash, :empty?, '() -> ``output_type(trec, targs, :empty?, "%bool")``'
RDL.type :Hash, :fetch, '(``any_or_k(trec)``) -> ``output_type(trec, targs, :fetch, :promoted_val, "v", nil_default: true)``'
#RDL.type :Hash, :fetch, '(``any_or_k(trec)``, u) -> ``RDL::Type::UnionType.new(RDL::Globals.parser.scan_str("#T u"), output_type(trec, targs, :fetch, :promoted_val, "v", nil_default: true))``'
RDL.type :Hash, :fetch, '(``any_or_k(trec)``, ``targs[1] ? targs[1] : RDL::Globals.types[:top]``) -> ``RDL::Type::UnionType.new(targs[1] ? targs[1] : RDL::Globals.types[:top], output_type(trec, targs, :fetch, :promoted_val, "v", nil_default: true))``'
RDL.type :Hash, :fetch, '(``any_or_k(trec)``) { (``any_or_k(trec)``) -> u } -> ``RDL::Type::UnionType.new(RDL::Globals.parser.scan_str("#T u"), output_type(trec, targs, :fetch, :promoted_val, "v", nil_default: true))``'
RDL.type :Hash, :fetch, '(``any_or_k(trec)``) { () -> u } -> ``RDL::Type::UnionType.new(RDL::Globals.parser.scan_str("#T u"), output_type(trec, targs, :fetch, :promoted_val, "v", nil_default: true))``'
RDL.type :Hash, :first, '() -> ``output_type(trec, targs, :first, :default_or_promoted_val, "v", nil_default: true)``', effect: [:+, :+]
RDL.type :Hash, :member?, '(%any) -> ``output_type(trec, targs, :member?, "%bool")``'
RDL.type :Hash, :has_key?, '(%any) -> ``output_type(trec, targs, :has_key?, "%bool")``', effect: [:+, :+]
RDL.type :Hash, :key?, '(%any) -> ``output_type(trec, targs, :key?, "%bool")``'
RDL.type :Hash, :has_value?, '(%any) -> ``output_type(trec, targs, :has_value?, "%bool")``'
RDL.type :Hash, :value?, '(%any) -> ``output_type(trec, targs, :value?, "%bool")``'
RDL.type :Hash, :to_s, '() -> String'
RDL.type :Hash, :inspect, '() -> String'
RDL.type :Hash, :invert, '() -> ``invert_output(trec)``'


def Hash.invert_output(trec)
  case trec
  when RDL::Type::FiniteHashType
    hash = trec.elts.invert
    hash = Hash[hash.map { |k, v| if !RDL.type_cast(v, "Object", force: true).is_a?(RDL::Type::Type) then [k, RDL::Type::SingletonType.new(v)] else [k, v] end }]
    RDL::Type::FiniteHashType.new(RDL.type_cast(hash, "Hash<%any, RDL::Type::Type>", force: true), nil)
  else
    RDL::Type::GenericType.new(RDL::Globals.types[:hash], trec.params[1], trec.params[0])
    #RDL::Globals.parser.scan_str "#T Hash<v, k>"
  end
end
RDL.type Hash, 'self.invert_output', "(RDL::Type::Type) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

RDL.type :Hash, :keep_if, '() { (``any_or_k(trec)``,``any_or_v(trec)``) -> %bool } -> self'
RDL.type :Hash, :keep_if, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), RDL::Type::TupleType.new(any_or_k(trec), any_or_v(trec)))``' ## I had made a mistake here, type checker caught it.
RDL.type :Hash, :key, '(%any) -> ``output_type(trec, targs, :key, :promoted_key, "k", nil_default: true, use_sing_val: false)``'
RDL.type :Hash, :keys, '() -> ``output_type(trec, targs, :keys, "Array<k>")``'
RDL.type :Hash, :length, '() -> ``output_type(trec, targs, :length, "Integer")``'
RDL.type :Hash, :size, '() -> ``output_type(trec, targs, :size, "Integer")``'
RDL.type :Hash, :merge, '(``merge_input(trec, targs)``) -> ``merge_output(trec, targs)``'
RDL.type :Hash, :merge!, '(``merge_input(trec, targs, true)``) -> ``merge_output(trec, targs, true)``'


def Hash.merge_input(trec, targs, mutate=false)
  case targs[0]
  when RDL::Type::FiniteHashType
    return targs[0]
  when RDL::Type::GenericType, RDL::Type::VarType
    if mutate
      raise "Unable to promote #{trec}." if trec.is_a?(RDL::Type::FiniteHashType) && !trec.promote!
      return trec.canonical
      #return RDL::Globals.parser.scan_str "#T Hash<k, v>"
    else
      if trec.is_a?(RDL::Type::GenericType)
        return RDL::Globals.parser.scan_str "#T Hash<a, b>"
      else
        return targs[0]
      end
    end
  else
    RDL::Globals.types[:hash]
  end
end
RDL.type Hash, 'self.merge_input', "(RDL::Type::Type, Array<RDL::Type::Type>, ?%bool) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]


def Hash.merge_output(trec, targs, mutate=false)
  case trec
  when RDL::Type::NominalType
    return RDL::Globals.types[:hash]
  when RDL::Type::GenericType
    case targs[0]
    when RDL::Type::FiniteHashType
      promoted = RDL.type_cast(targs[0], "RDL::Type::FiniteHashType", force: true).promote
      key_union = RDL::Type::UnionType.new(promoted.params[0], trec.params[0]).canonical
      value_union = RDL::Type::UnionType.new(promoted.params[1], trec.params[1]).canonical
      if mutate
        raise "Call to `merge!` would change type of Hash." unless (key_union == trec.params[0]) && (value_union == trec.params[1])
        return trec
      else
        return RDL::Type::GenericType.new(trec.base, key_union, value_union)
      end
    when RDL::Type::GenericType
      ret = (if mutate then "Hash<k, v>" else "Hash<a or k, b or v>" end)
      return RDL::Globals.parser.scan_str "#T #{ret}"
    else
      ## targs[0] should just be hash here
      return RDL::Globals.types[:hash]
    end
  when RDL::Type::FiniteHashType
    case targs[0]
    when RDL::Type::FiniteHashType
      arg = RDL.type_cast(targs[0], "RDL::Type::FiniteHashType", force: true)
      if mutate
        if arg.elts.any? { |k, v| !RDL.type_cast(k, "Object", force: true).is_a?(Symbol) }
          arg_key = arg.promote.params[0]
          arg_val = arg.promote.params[1]
          raise "Unable to promote tuple #{trec} to Hash." unless trec.promote!(arg_key, arg_val)
          return trec
        end
        trec.elts = RDL.type_cast(Hash[trec.elts.map { |k, v| if arg.elts.has_key?(k) then [k, RDL::Type::UnionType.new(arg.elts[k], v).canonical] else [k, v] end } ].merge(arg.elts), "Hash<%any, RDL::Type::Type>", force: true)
        raise RDL::Typecheck::StaticTypeError, "Failed to mutate hash: new hash does not match prior type constraints." unless trec.check_bounds(true)
        return trec
      else
        return RDL::Type::FiniteHashType.new(trec.elts.merge(arg.elts), nil)
      end
    when RDL::Type::GenericType
      arg0 = RDL.type_cast(targs[0], "RDL::Type::GenericType", force: true)
      promoted = trec.promote
      key_union = RDL::Type::UnionType.new(promoted.params[0], arg0.params[0]).canonical
      value_union = RDL::Type::UnionType.new(promoted.params[1], arg0.params[1]).canonical
      if mutate
        raise "Unable to promote tuple #{trec} to Hash." unless trec.promote!(arg0.params[0], arg0.params[1])
        return trec
      else
        return RDL::Type::GenericType.new(arg0.base, key_union, value_union)
      end
    else
      ## targs[0] should just be Hash here
      return RDL::Globals.types[:hash]
      #return RDL::Globals.parser.scan_str "#T Hash<k, v>"
    end
  end

end
RDL.type Hash, 'self.merge_output', "(RDL::Type::Type, Array<RDL::Type::Type>, ?%bool) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:~, :+]

RDL.type :Hash, :merge, '(Hash<a,b>) { (k,v,b) -> v or b } -> Hash<a or k, b or v>'
RDL.type :Hash, :rassoc, '(``any_or_v(trec)``) -> ``RDL::Type::TupleType.new(output_type(trec, targs, :key, :promoted_key, "k", nil_default: true, use_sing_val: false),targs[0])``'
RDL.type :Hash, :rehash, '() -> self'
RDL.type :Hash, :reject, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), any_or_k(trec), any_or_v(trec))``'
RDL.type :Hash, :reject, '() {(``any_or_k(trec)``,``any_or_v(trec)``) -> %bool} -> self'
RDL.type :Hash, :reject!, '() {(``any_or_k(trec)``,``any_or_v(trec)``) -> %bool} -> self'
RDL.type :Hash, :select, '() {(``any_or_k(trec)``,``any_or_v(trec)``) -> %bool} -> self'
RDL.type :Hash, :select!, '() {(``any_or_k(trec)``,``any_or_v(trec)``) -> %bool} -> self'
RDL.type :Hash, :shift, '() -> ``shift_output(trec)``'


def Hash.shift_output(trec)
  case trec
  when RDL::Type::FiniteHashType
    promoted = trec.promote
    RDL::Type::TupleType.new(*promoted.params) ## Type error found by type checker here.
  else
    #RDL::Globals.parser.scan_str "#T [k, v]"
    RDL::Type::TupleType.new(trec.params[0], trec.params[1])
  end
end
RDL.type Hash, 'self.shift_output', "(RDL::Type::Type) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:+, :+]

#RDL.type :Hash, :to_a, '() -> ``output_type(trec, targs, :to_a, "Array<[k, v]>")``'
RDL.type :Hash, :to_a, '() -> ``to_a_output_type(trec)")``'

def Hash.to_a_output_type(trec)
  case trec
  when RDL::Type::FiniteHashType
    to_type(trec.elts.to_a)
  else
    RDL::Type::GenericType.new(RDL::Globals.types[:array], RDL::Type::TupleType.new(trec,params[0], trec.params[1]))
  end
end


#RDL.type :Hash, :values, '() -> ``output_type(trec, targs, :values, "Array<v>")``'
RDL.type :Hash, :values, '() -> ``values_output(trec)``'
def Hash.values_output(trec)
  case trec
  when RDL::Type::FiniteHashType
    to_type(trec.elts.values)
  else
    RDL::Type::GenericType.new(RDL::Globals.types[:array], trec.params[1])
  end
end

RDL.type :Hash, :values_at, '(``values_at_input(trec)``) -> ``values_at_output(trec, targs)``'


def Hash.values_at_input(trec)
  case trec
  when RDL::Type::FiniteHashType
    RDL::Type::VarargType.new(RDL::Globals.types[:top])
  else
    RDL::Type::VarargType.new(trec.params[0])
  end
end
RDL.type Hash, 'self.values_at_input', "(RDL::Type::Type) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:~, :+]


def Hash.values_at_output(trec, targs)
  case trec
  when RDL::Type::FiniteHashType
    if targs.all? { |t| t.is_a? RDL::Type::SingletonType }
      res = trec.elts.values_at(*targs.map { |t| RDL.type_cast(t, "RDL::Type::SingletonType<%any>", force: true).val })
      if res.all? { |t| !t.nil? }
        to_type(res)
      else
        RDL::Type::GenericType.new(RDL::Type::NominalType.new(Array), trec.promote.params[1])
      end
    else
      RDL::Type::GenericType.new(RDL::Type::NominalType.new(Array), trec.promote.params[1])
    end
  else
    RDL::Type::GenericType.new(RDL::Type::NominalType.new(Array), trec.params[1])
  end
end
RDL.type Hash, 'self.values_at_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", typecheck: :type_code, wrap: false, effect: [:~, :+]





######### Non-dependent types below #########

RDL.type :Hash, 'self.[]', '(*u) -> Hash<u, u>', effect: [:+, :+]  # example: Hash[1,2,3,4]
RDL.type :Hash, 'self.[]', '(Array<[a,b]>) -> Hash<a, b>', effect: [:+, :+]
RDL.type :Hash, 'self.[]', '([to_hash: () -> Hash<a, b>]) -> Hash<a, b>', effect: [:+, :+]

RDL.type :Hash, :[], '(k) -> v'
RDL.type :Hash, :[]=, '(k, v) -> v', effect: [:-, :+]
RDL.type :Hash, :store, '(k,v) -> v'

RDL.type :Hash, :any?, "() { (k, v) -> %any } -> %bool", effect: [:blockdep, :blockdep]
# RDL.type :Hash, :assoc, '(k) -> [k, v]' # TODO
RDL.type :Hash, :assoc, '(k) -> Array<k or v>'
RDL.type :Hash, :clear, '() -> Hash<k,v>'
RDL.type :Hash, :compare_by_identity, '() -> Hash<k,v>'
RDL.type :Hash, :compare_by_identity?,  '() -> %bool'
RDL.type :Hash, :default, '(?k) -> v'
RDL.type :Hash, :default, '(k) {(k) -> v} -> v'
RDL.type :Hash, :default=, '(v) -> v'

# TODO: check on default_proc
# RDL.type :Hash, :default_proc, '() -> (Hash<k,v>,k) -> v'
# RDL.type :Hash, :default_proc=, '((Hash<k,v>,k) -> v) -> (Hash<k,v>,k) -> v'

RDL.type :Hash, :delete, '(k) -> v'
RDL.type :Hash, :delete, '(k) { (k) -> u } -> u or v'
RDL.type :Hash, :delete_if, '() { (k,v) -> %bool } -> Hash<k,v>'
RDL.type :Hash, :delete_if, '() -> Enumerator<[k, v]>'
RDL.type :Hash, :each, '() { (k,v) -> %any } -> Hash<k,v>', effect: [:blockdep, :blockdep]
RDL.type :Hash, :each, '() -> Enumerator<[k, v]>', effect: [:blockdep, :blockdep]
RDL.type :Hash, :each_pair, '() { (k,v) -> %any } -> Hash<k,v>'
RDL.type :Hash, :each_pair, '() -> Enumerator<[k, v]>'
RDL.type :Hash, :each_key, '() { (k) -> %any } -> Hash<k,v>', effect: [:blockdep, :blockdep]
RDL.type :Hash, :each_key, '() -> Enumerator<[k, v]>', effect: [:blockdep, :blockdep]
RDL.type :Hash, :each_value, '() { (v) -> %any } -> Hash<k,v>'
RDL.type :Hash, :each_value, '() -> Enumerator<[k, v]>'
RDL.type :Hash, :empty?, '() -> %bool'
RDL.type :Hash, :except, '(%any) -> self', effect: [:+, :+]
RDL.type :Hash, :fetch, '(k) -> v'
RDL.type :Hash, :fetch, '(k,u) -> u or v'
RDL.type :Hash, :fetch, '(k) { (k) -> u } -> u or v'
RDL.type :Hash, :map, "() { (k, v) -> x } -> Array<x>", effect: [:+, :blockdep]
RDL.type :Hash, :member?, '(t) -> %bool'
RDL.type :Hash, :has_key?, '(t) -> %bool'
RDL.type :Hash, :key?, '(t) -> %bool'
RDL.type :Hash, :has_value?, '(t) -> %bool'
RDL.type :Hash, :value?, '(t) -> %bool'
RDL.type :Hash, :to_s, '() -> String'
RDL.type :Hash, :include?, '(%any) -> %bool', effect: [:+, :+]
RDL.type :Hash, :inspect, '() -> String'
RDL.type :Hash, :invert, '() -> Hash<v,k>', effect: [:+, :+]
RDL.type :Hash, :keep_if, '() { (k,v) -> %bool } -> Hash<k,v>'
RDL.type :Hash, :keep_if, '() -> Enumerator<[k, v]>'
RDL.type :Hash, :key, '(t) -> k'
RDL.type :Hash, :keys, '() -> Array<k>', effect: [:+, :+]
RDL.type :Hash, :length, '() -> Integer'
RDL.type :Hash, :size, '() -> Integer', effect: [:+, :+]
RDL.type :Hash, :merge, '(Hash<a,b>) -> Hash<a or k, b or v>', effect: [:+, :+]
RDL.type :Hash, :merge, '(Hash<a,b>) { (k,v,b) -> v or b } -> Hash<a or k, b or v>', effect: [:+, :+]
# RDL.type :Hash, :rassoc, '(k) -> Tuple<k,v>'
RDL.type :Hash, :rassoc, '(k) -> Array<k or v>'
RDL.type :Hash, :rehash, '() -> Hash<k,v>'
RDL.type :Hash, :reject, '() -> Enumerator<[k, v]>'
RDL.type :Hash, :reject, '() {(k,v) -> %bool} -> Hash<k,v>'
RDL.type :Hash, :reject!, '() {(k,v) -> %bool} -> Hash<k,v>'
RDL.type :Hash, :select, '() {(k,v) -> %bool} -> Hash<k,v>', effect: [:+, :blockdep]
RDL.type :Hash, :select!, '() {(k,v) -> %bool} -> Hash<k,v>'
# RDL.type :Hash, :shift, '() -> Tuple<k,v>'
RDL.type :Hash, :shift, '() -> Array<k or v>'
# RDL.type :Hash, :to_a, '() -> Array<Tuple<k,v>>'
RDL.type :Hash, :to_a, '() -> Array<Array<k or v>>'
RDL.type :Hash, :to_hash, '() -> self'
RDL.type :Hash, :to_h, '() -> self'
RDL.type :Hash, :values, '() -> Array<v>'
RDL.type :Hash, :values_at, '(*k) -> Array<v>', effect: [:+, :+]
RDL.type :Hash, :with_indifferent_access, '() -> self'
