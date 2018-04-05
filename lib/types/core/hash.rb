RDL.nowrap :Hash

RDL.type_params :Hash, [:k, :v], :all?

def Hash.output_type(trec, targs, meth_name, default1, default2=default1, nil_default: false, use_sing_val: true)
  case trec
  when RDL::Type::FiniteHashType    
    if targs.empty? || targs.all? { |t| t.is_a?(RDL::Type::SingletonType) }
      vals = (if use_sing_val then targs.map { |t| t.val } else targs end)
      res = trec.elts.send(meth_name, *vals)
      if nil_default && res.nil?
        if default1 == :promoted_val
          return trec.promote.params[1]
        elsif default1 == :promoted_key
          return trec.promote.params[0]
        else
          return RDL::Globals.parser.scan_str "#T #{default1}"
        end
      end
      to_type(res)
    else
      if default1 == :promoted_val
        trec.promote.params[1]
      elsif default1 == :promoted_key
        trec.promote.params[0]
      else
        RDL::Globals.parser.scan_str "#T #{default1}"
      end
    end
  else
    RDL::Globals.parser.scan_str "#T #{default2}"
  end
end


def Hash.to_type(t)
  case t
  when RDL::Type::Type
    t
  when Array
    RDL::Type::TupleType.new(*(t.map { |i| to_type(i) }))
  else
    ## symbols, ints, nil, ...
    RDL::Type::SingletonType.new(t)
  end
end

def Hash.any_or_k(trec)
  case trec
  when RDL::Type::FiniteHashType
    RDL::Globals.types[:top]
  else
    RDL::Globals.parser.scan_str "#T k"
  end
end

def Hash.any_or_v(trec)
  case trec
  when RDL::Type::FiniteHashType
    RDL::Globals.types[:top]
  else
    RDL::Globals.parser.scan_str "#T v"
  end
end

def Hash.promoted_or_v(trec)
  case trec
  when RDL::Type::FiniteHashType
    trec.promote.params[1]
  else
    RDL::Globals.parser.scan_str "#T v"
  end
end

def Hash.weak_promote(val)
  case val
  when RDL::Type::UnionType
    if val.types.all? { |t| t.is_a?(RDL::Type::SingletonType) }
      klass = val.types[0].nominal.klass
      if val.types.all? { |t| t.nominal.klass == klass }
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


RDL.type :Hash, 'self.[]', '(*%any) -> ``hash_create_output(targs)``'

def Hash.hash_create_output(targs)
  raise RDL::Typecheck::StaticTypeError, "Hash.[] expects an even number of arguments." if targs.size.odd?
  args = []
  targs.each_with_index { |a, i|
    args[i] = (if i.even? && a.is_a?(RDL::Type::SingletonType) then a.val else a end)
  }
  RDL::Type::FiniteHashType.new(Hash[*args], nil)
end

RDL.type :Hash, :[], '(``any_or_k(trec)``) -> ``output_type(trec, targs, :[], :promoted_val, "v", nil_default: true)``'

RDL.type :Hash, :[]=, '(``any_or_k(trec)``, ``any_or_v(trec)``) -> ``assign_output(trec, targs)``'

def Hash.assign_output(trec, targs)
  case trec
  when RDL::Type::FiniteHashType
    case targs[0]
    when RDL::Type::SingletonType ### TODO: adjust for strings
      trec.elts[targs[0].val] = RDL::Type::UnionType.new(trec.elts[targs[0].val], targs[1]).canonical
      trec.elts[targs[0].val] = weak_promote(trec.elts[targs[0].val]) if RDL::Config.instance.weak_update_promote
      raise RDL::Typecheck::StaticTypeError, "Failed to mutate hash: new hash does not match prior type constraints." unless trec.check_bounds(true)
      return targs[1]
    else
      raise "Unable to promote tuple #{trec} to Hash." unless trec.promote!(targs[0], targs[1])
      return targs[1]
    end
  else
    RDL::Globals.parser.scan_str "#T v"
  end
end


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
      if trec.elts.include?(targs[0].val)
        trec.elts[targs[0].val]
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
    t = (if block then "u or v" else "v" end)
    RDL::Globals.parser.scan_str "#T #{t}"
  end
end

RDL.type :Hash, :delete_if, '() { (``any_or_k(trec)``, ``any_or_v(trec)``) -> %any } -> self'
RDL.type :Hash, :delete_if, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), RDL::Type::TupleType.new([any_or_k(trec), any_or_v(trec)]))``'
RDL.type :Hash, :each, '() { (``any_or_k(trec)``, ``any_or_v(trec)``) -> %any } -> self'
RDL.type :Hash, :each, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), RDL::Type::TupleType.new([any_or_k(trec), any_or_v(trec)]))``'
RDL.type :Hash, :each_pair, '() { (``any_or_k(trec)``, ``any_or_v(trec)``) -> %any } -> self'
RDL.type :Hash, :each_pair, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), RDL::Type::TupleType.new([any_or_k(trec), any_or_v(trec)]))``'
RDL.type :Hash, :each_key, '() { (``any_or_k(trec)``) -> %any } -> self'
RDL.type :Hash, :each_key, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), any_or_k(trec))``'
RDL.type :Hash, :each_value, '() { (``any_or_v(trec)``) -> %any } -> self'
RDL.type :Hash, :each_value, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), any_or_v(trec))``'
RDL.type :Hash, :empty?, '() -> ``output_type(trec, targs, :empty?, "%bool")``'
RDL.type :Hash, :fetch, '(``any_or_k(trec)``) -> ``output_type(trec, targs, :fetch, :promoted_val, "v", nil_default: true)``'
RDL.type :Hash, :fetch, '(``any_or_k(trec)``, u) -> ``RDL::Type::UnionType.new(RDL::Globals.parser.scan_str("u"), output_type(trec, targs, :fetch, :promoted_val, "v", nil_default: true))``'
RDL.type :Hash, :fetch, '(``any_or_k(trec)``) { (``any_or_k(trec)``) -> u } -> ``RDL::Type::UnionType.new(RDL::Globals.parser.scan_str("u"), output_type(trec, targs, :fetch, :promoted_val, "v", nil_default: true))``'
RDL.type :Hash, :member?, '(%any) -> ``output_type(trec, targs, :member?, "%bool")``'
RDL.type :Hash, :has_key?, '(%any) -> ``output_type(trec, targs, :has_key?, "%bool")``'
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
    hash.each { |key, value| if !value.is_a?(RDL::Type::Type) then hash[key] = RDL::Type::SingletonType.new(value) end } ## necessary for symbols in FHT's
    RDL::Type::FiniteHashType.new(hash, nil)
  else
    RDL::Globals.parser.scan_str "#T Hash<v, k>"
  end
end

RDL.type :Hash, :keep_if, '() { (``any_or_k(trec)``,``any_or_v(trec)``) -> %bool } -> self'
RDL.type :Hash, :keep_if, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), RDL::Type::TupleType.new([any_or_k(trec), any_or_v(trec)]))``'
RDL.type :Hash, :key, '(%any) -> ``output_type(trec, targs, :key, :promoted_key, "k", nil_default: true, use_sing_val: false)``'
RDL.type :Hash, :keys, '() -> ``output_type(trec, targs, :keys, "Array<k>")``'
RDL.type :Hash, :length, '() -> ``output_type(trec, targs, :length, "Integer")``'
RDL.type :Hash, :size, '() -> ``output_type(trec, targs, :size, "Integer")``'
RDL.type :Hash, :merge, '(``merge_input(targs)``) -> ``merge_output(trec, targs)``'
RDL.type :Hash, :merge!, '(``merge_input(targs, true)``) -> ``merge_output(trec, targs, true)``'

def Hash.merge_input(targs, mutate=false)
  case targs[0]
  when RDL::Type::FiniteHashType
    return targs[0]
  when RDL::Type::GenericType
    if mutate
      return RDL::Globals.parser.scan_str "#T Hash<k, v>"
    else
      return RDL::Globals.parser.scan_str "#T Hash<a, b>"
    end
  else
    RDL::Globals.types[:hash]
  end
end

def Hash.merge_output(trec, targs, mutate=false)
  case trec
  when RDL::Type::NominalType
    return RDL::Globals.types[:hash]
  when RDL::Type::GenericType
    case targs[0]
    when RDL::Type::FiniteHashType
      promoted = targs[0].promote
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
      if mutate
        targs[0].each { |k, v|
          case k
          when RDL::Type::SingletonType
            trec.elts[k.val] = RDL::Type::UnionType.new(trec.elts[k.val], v).canonical
            trec.elts[k.val] = weak_promote(trec.elts[k.val]) if RDL::Config.instance.weak_update_promote
          else
            arg_key = targs[0].promote.params[0]
            arg_val = targs[0].promote.params[1]
            raise "Unable to promote tuple #{trec} to Hash." unless trec.promote!(arg_key, arg_val)
            return trec
          end
        }
        raise RDL::Typecheck::StaticTypeError, "Failed to mutate hash: new hash does not match prior type constraints." unless trec.check_bounds(true)
        return trec
      else
        return RDL::Type::FiniteHashType.new(trec.elts.merge(targs[0].elts), nil)
      end
    when RDL::Type::GenericType
      promoted = trec.promote
      key_union = RDL::Type::UnionType.new(promoted.params[0], targs[0].params[0]).canonical
      value_union = RDL::Type::UnionType.new(promoted.params[1], targs[0].params[1]).canonical
      if mutate
        raise "Unable to promote tuple #{trec} to Hash." unless trec.promote!(targs[0].params[0], targs[0].params[1])
        return trec        
      else
        return RDL::Type::GenericType.new(targs[0].base, key_union, value_union)
      end
    else
      ## targs[0] should just be Hash here
      return RDL::Globals.types[:hash]
    end
  end

end


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
    RDL::Type::TupleType.new(promoted.params)
  else
    RDL::Globals.parser.scan_str "#T [k, v]"
  end
end


RDL.type :Hash, :to_a, '() -> ``output_type(trec, targs, :to_a, "Array<[k, v]>")``'
RDL.type :Hash, :to_hash, '() -> self'
RDL.type :Hash, :values, '() -> ``output_type(trec, targs, :keys, "Array<k>")``'
RDL.type :Hash, :values_at, '(``values_at_input(trec)``) -> ``values_at_output(trec, targs)``'

def Hash.values_at_input(trec)
  case trec
  when RDL::Type::FiniteHashType
    RDL::Type::VarargType.new(RDL::Globals.types[:top])
  else
    RDL::Type::VarargType.new(RDL::Type::VarType.new("k"))
  end
end

def Hash.values_at_output(trec, targs)
  case trec
  when RDL::Type::FiniteHashType
    if targs.all? { |t| t.is_a? RDL::Type::SingletonType }
      res = trec.elts.values_at(*targs.map { |t| t.val })
      if res.all? { |t| !t.nil? }
        to_type(res)
      else
        RDL::Type::GenericType.new(RDL::Type::NominalType.new(Array), trec.promote.params[1])
      end
    else
      RDL::Type::GenericType.new(RDL::Type::NominalType.new(Array), trec.promote.params[1])
    end
  else
    RDL::Globals.parser.scan_str "#T Array<v>"
  end
end

