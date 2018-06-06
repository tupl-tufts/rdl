RDL.nowrap :Array

RDL.type_params :Array, [:t], :all?

def Array.to_type(t)
  case t
  when RDL::Type::Type
    t
  when Array
    RDL.type_cast(RDL::Type::TupleType.new(*(t.map { |i| to_type(i) })), "RDL::Type::TupleType", force: true)
  else
    t = "nil" if t.nil?
    RDL::Globals.parser.scan_str "#T #{t}"
  end
end
RDL.type Array, 'self.to_type', "(Object) -> RDL::Type::Type", wrap: false, typecheck: :type_code


def Array.output_type(trec, targs, meth_name, default1, default2=default1, use_sing_val: true, nil_false_default: false)
  case trec
  when RDL::Type::TupleType
    if targs.empty? || targs.all? { |t| t.is_a?(RDL::Type::SingletonType) }
      vals = RDL.type_cast((if use_sing_val then targs.map { |t| t.val } else targs end), "Array<%any>", force: true)
      res = RDL.type_cast(trec.params.send(meth_name, *vals), "Object", force: true)
      if !res && nil_false_default
        if default1 == :promoted_param
          trec.promote.params[0]
        elsif default1 == :promoted_array
          trec.promote
        else
          RDL::Globals.parser.scan_str "#T #{default1}"
        end
      else
        to_type(res)
      end        
    else
      if default1 == :promoted_param
        trec.promote.params[0]
      elsif default1 == :promoted_array
        trec.promote
      else
        RDL::Globals.parser.scan_str "#T #{default1}"
      end
    end
  else
    RDL::Globals.parser.scan_str "#T #{default2}"
  end
end
RDL.type Array, 'self.output_type', "(RDL::Type::Type, Array<RDL::Type::Type>, Symbol, String or Symbol, ?(String or Symbol), { use_sing_val: ?%bool, nil_false_default: ?%bool }) -> RDL::Type::Type", wrap: false, typecheck: :type_code


def Array.any_or_t(trec, vararg=false)
  case trec
  when RDL::Type::TupleType
    ret = RDL::Globals.types[:top]
    if vararg then RDL::Type::VarargType.new(ret) else ret end
  else
    ret = RDL::Globals.parser.scan_str "#T t"
    if vararg then RDL::Type::VarargType.new(ret) else ret end
  end
end
RDL.type Array, 'self.any_or_t', "(RDL::Type::Type, ?%bool) -> RDL::Type::Type", wrap: false, typecheck: :type_code


def Array.promoted_or_t(trec, vararg=false)
  case trec
  when RDL::Type::TupleType
    ret = trec.promote.params[0]
    if vararg then RDL::Type::VarargType.new(ret) else ret end
  else
    ret = RDL::Globals.parser.scan_str "#T t"
    if vararg then RDL::Type::VarargType.new(ret) else ret end
  end
end
RDL.type Array, 'self.promoted_or_t', "(RDL::Type::Type, ?%bool) -> RDL::Type::Type", wrap: false, typecheck: :type_code


def Array.promote_tuple(trec)
  case trec
  when RDL::Type::TupleType
    trec.promote
  else
    trec
  end
end
RDL.type Array, 'self.promote_tuple', "(RDL::Type::Type) -> RDL::Type::Type", wrap: false, typecheck: :type_code


def Array.promote_tuple!(trec)
  case trec
  when RDL::Type::TupleType
    raise "Unable to promote tuple." unless trec.promote!
    trec
  else
    trec
  end
end
RDL.type Array, 'self.promote_tuple!', "(RDL::Type::Type) -> RDL::Type::Type", wrap: false, typecheck: :type_code

RDL.type :Array, :<<, '(``any_or_t(trec)``) -> ``append_push_output(trec, targs, :<<)``'


def Array.append_push_output(trec, targs, meth)
  case trec
  when RDL::Type::TupleType
    RDL.type_cast(trec.params.send(meth, *targs), "%any", force: true)
    raise RDL::Typecheck::StaticTypeError, "Failed to mutate tuple: new tuple does not match prior type constraints." unless trec.check_bounds(true)
    trec
  else
    RDL::Globals.parser.scan_str "#T Array<t>"
  end
end
RDL.type Array, 'self.append_push_output', "(RDL::Type::Type, Array<RDL::Type::Type>, Symbol) -> RDL::Type::Type", typecheck: :type_code, wrap: false

RDL.type :Array, :[], '(Range<Integer>) -> ``output_type(trec, targs, :[], :promoted_array, "Array<t>")``'
RDL.type :Array, :[], '(Integer or Float) -> ``output_type(trec, targs, :[], :promoted_param, "t")``'
RDL.type :Array, :[], '(Integer, Integer) -> ``output_type(trec, targs, :[], :promoted_array, "Array<t>")``'
RDL.type :Array, :&, '(Array<u>) -> ``output_type(trec, targs, :&, :promoted_array, "Array<t>")``'
RDL.type :Array, :*, '(Integer) -> ``output_type(trec, targs, :*, :promoted_array, "Array<t>")``'
RDL.type :Array, :*, '(String) -> String'
RDL.type :Array, :+, '(``plus_input(targs)``) -> ``plus_output(trec, targs)``'


def Array.plus_input(targs)
  case targs[0]
  when RDL::Type::TupleType
    return targs[0]
  when RDL::Type::GenericType
    return RDL::Globals.parser.scan_str "#T Array<u>"
  else
    RDL::Globals.types[:array]
  end
end
RDL.type Array, 'self.plus_input', "(Array<RDL::Type::Type>) -> RDL::Type::Type", typecheck: :type_code, wrap: false


def Array.plus_output(trec, targs)
  case trec
  when RDL::Type::NominalType
    return RDL::Globals.types[:array]
  when RDL::Type::GenericType
    case targs[0]
    when RDL::Type::TupleType
      promoted = RDL.type_cast(targs[0], "RDL::Type::TupleType", force: true).promote
      param_union = RDL::Type::UnionType.new(promoted.params[0], trec.params[0])
      return RDL::Type::GenericType.new(trec.base, param_union)
    when RDL::Type::GenericType
      return RDL::Globals.parser.scan_str "#T Array<u or t>"
    else
      ## targs[0] should just be array here
      return RDL::Globals.types[:array]
    end
  when RDL::Type::TupleType
    case targs[0]
    when RDL::Type::TupleType
      return RDL::Type::TupleType.new(*(trec.params + RDL.type_cast(targs[0], "RDL::Type::TupleType", force: true).params))
    when RDL::Type::GenericType
      promoted = trec.promote
      param_union = RDL::Type::UnionType.new(promoted.params[0], RDL.type_cast(targs[0], "RDL::Type::GenericType", force: true).params[0] )
      return RDL::Type::GenericType.new(RDL.type_cast(targs[0], "RDL::Type::GenericType", force: true).base, param_union)
    else
      ## targs[0] should just be Array here
      return RDL::Globals.types[:array]
    end
  end
end
RDL.type Array, 'self.plus_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", typecheck: :type_code, wrap: false

RDL.type :Array, :-, '(Array<u>) -> ``output_type(trec, targs, :-, :promoted_array, "Array<t>")``'
RDL.type :Array, :slice, '(Range<Integer>) -> ``output_type(trec, targs, :slice, :promoted_array, "Array<t>")``'
RDL.type :Array, :slice, '(Integer) -> ``output_type(trec, targs, :slice, :promoted_param, "t")``'
RDL.type :Array, :slice, '(Integer, Integer) -> ``output_type(trec, targs, :slice, :promoted_array, "Array<t>")``'
RDL.type :Array, :[]=, '(Integer, ``any_or_t(trec)``) -> ``assign_output(trec, targs)``'


def Array.assign_output(trec, targs)
  case trec
  when RDL::Type::TupleType
    case targs[0]
    when RDL::Type::SingletonType
      argval = RDL.type_cast(targs[0], "RDL::Type::SingletonType<Integer>", force: true).val
      if v = trec.params[argval]
        trec.params[argval] = RDL::Type::UnionType.new(v, targs[1])
        trec.params[argval] = Hash.weak_promote(trec.params[argval]) if RDL::Config.instance.weak_update_promote
        raise RDL::Typecheck::StaticTypeError, "Failed to mutate tuple: new tuple does not match previous constraints." unless trec.check_bounds(true)
        targs[1]
      else
        trec.params[RDL.type_cast(targs[0], "RDL::Type::SingletonType<Integer>", force: true).val] = targs[1]
        raise RDL::Typecheck::StaticTypeError, "Failed to mutate tuple: new tuple does not match previous constraints." unless trec.check_bounds(true)
        targs[1]
      end
    else
      raise "Unable to promote tuple." unless trec.promote!(targs[1])
      trec
    end
  else
    RDL::Globals.parser.scan_str "#T t"
  end
end
RDL.type Array, 'self.assign_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", typecheck: :type_code, wrap: false

RDL.type :Array, :[]=, '(Integer, Integer, ``any_or_t(trec)``) -> t'


def Array.multi_assign_output(trec, targs)
  ## this method could get more precise, but it would require many more cases
  return RDL::Globals.types[:top] ### TODO: remove this. This is here to avoid promote!-ing when type does not actually match. Have to figure out better solution.
  case trec
  when RDL::Type::TupleType
    element = (if targs.size > 2 then targs[2] else targs[1] end)
    raise "Unable to promote tuple." unless trec.promote!(element)
    element
  else
    RDL::Globals.parser.scan_str "#T t"
  end
end
RDL.type Array, 'self.multi_assign_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", typecheck: :type_code, wrap: false

RDL.type :Array, :[]=, '(Range<Integer>, ``any_or_t(trec)``) -> ``multi_assign_output(trec, targs)``'
RDL.type :Array, :assoc, '(t) -> Array<t>'
RDL.type :Array, :at, '(Integer) -> ``output_type(trec, targs, :at, :promoted_param, "t")``'
RDL.type :Array, :clear, '() -> self'
RDL.type :Array, :map, '() {(``promoted_or_t(trec)``) -> u } -> Array<u>'
RDL.type :Array, :map, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :map!, '() {(``promoted_or_t(trec)``) -> u} -> ``map_output(trec)``'


def Array.map_output(trec)
  case trec
  when RDL::Type::TupleType
    trec.params.map! { |e| RDL::Globals.parser.scan_str "#T u" } ## set each element to type u
    raise RDL::Typecheck::StaticTypeError, "Failed to mutate tuple: new tuple does not match previous constraints." unless trec.check_bounds(true)
    trec
  else
    RDL::Globals.parser.scan_str "#T Array<u>"
  end
end
RDL.type Array, 'self.map_output', "(RDL::Type::Type) -> RDL::Type::Type", typecheck: :type_code, wrap: false
  
RDL.type :Array, :map!, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :collect, '() {(``promoted_or_t(trec)``) -> u} -> Array<u>'
RDL.type :Array, :collect, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :combination, '(Integer) { (self) -> %any } -> self'
RDL.type :Array, :combination, '(Integer) -> Enumerator<self>'
RDL.type :Array, :push, '(``any_or_t(trec, true)``) -> ``append_push_output(trec, targs, :push)``'
RDL.type ::Array, :compact, '() -> ``RDL::Type::GenericType.new(RDL::Globals.types[:array], promoted_or_t(trec))``'
RDL.type :Array, :compact!, '() -> ``promote_tuple!(trec)``'
RDL.type :Array, :concat, '(``promote_tuple(trec)``) -> ``promote_tuple!(trec)``' ## could be more precise here
RDL.type :Array, :count, '() -> ``output_type(trec, targs, :count, "Integer")``'
RDL.type :Array, :count, '(``any_or_t(trec)``) -> Integer'
RDL.type :Array, :count, '() { (``promoted_or_t(trec)``) -> %bool } -> Integer'
RDL.type :Array, :cycle, '(?Integer) { (``promoted_or_t(trec)``) -> %any } -> %any'
RDL.type :Array, :cycle, '(?Integer) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :delete, '(u) -> ``promote_tuple!(trec); targs[0]``'
RDL.type :Array, :delete, '(u) { () -> v } -> ``promote_tuple!(trec); RDL::Globals.parser.scan_str "#T u or v"``'
RDL.type :Array, :delete_at, '(Integer) -> ``promote_tuple!(trec)``'
RDL.type :Array, :delete_if, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple!(trec)``'
RDL.type :Array, :delete_if, '() -> ``promote_tuple!(trec); RDL::Globals.parser.scan_str "#T Enumerator<t>"``'
RDL.type :Array, :drop, '(Integer) -> ``promote_tuple!(trec)``'
RDL.type :Array, :drop_while, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple!(trec)``'
RDL.type :Array, :drop_while, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :each, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :each, '() { (``promoted_or_t(trec)``) -> %any } -> self'
RDL.type :Array, :each_index, '() { (Integer) -> %any } -> self'
RDL.type :Array, :each_index, '() -> Enumerator<Integer>'
RDL.type :Array, :empty?, '() -> ``output_type(trec, targs, :empty?, "%bool")``'
RDL.type :Array, :fetch, '(Integer) -> ``output_type(trec, targs, :[], :promoted_param, "t")``'
RDL.type :Array, :fetch, '(Integer, u) -> ``RDL::Type::UnionType.new(RDL::Globals.parser.scan_str("u"), output_type(trec, targs, :[], :promoted_param, "t"))``'
RDL.type :Array, :fetch, '(Integer) { (Integer) -> u } -> ``RDL::Type::UnionType.new(RDL::Globals.parser.scan_str("u"), output_type(trec, targs, :[], :promoted_param, "t"))``'
RDL.type :Array, :fill, '(``any_or_t(trec)``) -> ``fill_output(trec, targs)``'


def Array.fill_output(trec, targs)
  case trec
  when RDL::Type::TupleType
    trec.params.each_with_index { |e, i|
      trec.params[i] = RDL::Type::UnionType.new(e, targs[0]).canonical
      trec.params[i] = Hash.weak_promote(trec.params[i]) if RDL::Config.instance.weak_update_promote ## There was a type error here, caught by the type checker (receiver of `weak_promote` call was originally self).
    }
    trec.check_bounds(true)
    trec
  else
    RDL::Globals.parser.scan_str "#T Array<t>"
  end
end
RDL.type Array, 'self.fill_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", typecheck: :type_code, wrap: false

RDL.type :Array, :fill, '(``promoted_or_t(trec)``, Integer, ?Integer) -> ``promote_tuple!(trec)``' ## can be more precise for this one, but would require many cases
RDL.type :Array, :fill, '(``promoted_or_t(trec)``, Range<Integer>) -> ``promote_tuple!(trec)``'
RDL.type :Array, :fill, '() { (Integer) -> ``promoted_or_t(trec)`` } -> ``promote_tuple!(trec)``'
RDL.type :Array, :fill, '(Integer, ?Integer) { (Integer) -> ``promoted_or_t(trec)`` } -> ``promote_tuple!(trec)``'
RDL.type :Array, :fill, '() { (Range<Integer>) -> ``promoted_or_t(trec)`` } -> ``promote_tuple!(trec)``'
RDL.type :Array, :flatten, '() -> Array<%any>' # Can't give a more precise RDL.type
RDL.type :Array, :index, '(u) -> ``t = output_type(trec, targs, :index, "Integer", use_sing_val: false, nil_false_default: true)``'
RDL.type :Array, :index, '() { (``promoted_or_t(trec)``) -> %bool } -> Integer'
RDL.type :Array, :index, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :first, '() -> ``output_type(trec, targs, :first, :promoted_param, "t")``'
RDL.type :Array, :first, '(Integer) -> ``output_type(trec, targs, :first, :promoted_array, "Array<t>")``'
RDL.type :Array, :include?, '(%any) -> ``output_type(trec, targs, :include?, "%bool", use_sing_val: false, nil_false_default: true)``'


def Array.include_output(trec, targs)
  case trec
  when RDL::Type::TupleType
    case targs[0]
    when RDL::Type::SingletonType
      if trec.params.include?(targs[0])
        RDL::Globals.types[:true]
      else
        ## in this case, still can't say false because arg may be in tuple, but without singleton type.
        RDL::Globals.types[:bool]
      end
    else
      RDL::Globals.types[:bool]
    end
  else
    RDL::Globals.types[:bool]
  end
end
RDL.type Array, 'self.include_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", typecheck: :type_code, wrap: false


RDL.type :Array, :initialize, '() -> self'
RDL.type :Array, :initialize, '(Integer) -> self'
RDL.type :Array, :initialize, '(Integer, t) -> self<t>'
RDL.type :Array, :insert, '(Integer, ``promoted_or_t(trec)``) -> ``promote_tuple!(trec)``'
RDL.type :Array, :inspect, '() -> String'
RDL.type :Array, :join, '(?String) -> String'
RDL.type :Array, :keep_if, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple!(trec)``'
RDL.type :Array, :last, '() -> ``output_type(trec, targs, :last, :promoted_param, "t")``'
RDL.type :Array, :last, '(Integer) -> ``output_type(trec, targs, :last, :promoted_array, "Array<t>")``'
RDL.type :Array, :member?, '(u) -> ``output_type(trec, targs, :member?, "%bool", use_sing_val: false, nil_false_default: true)``'
RDL.type :Array, :length, '() -> ``output_type(trec, targs, :length, "Integer")``'
RDL.type :Array, :permutation, '(?Integer) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :permuation, '(?Integer) { (``promote_tuple(trec)``) -> %any } -> ``promote_tuple(trec)``'
RDL.type :Array, :pop, '(Integer) -> ``promote_tuple!(trec)``'
RDL.type :Array, :pop, '() -> ``promote_tuple(trec); RDL::Globals.parser.scan_str "#T t"``'
RDL.type :Array, :product, '(*Array<u>) -> ``RDL::Type::GenericType.new(RDL::Globals.types[:array], RDL::Type::GenericType.new(RDL::Globals.types[:array], RDL::Type::UnionType.new(promoted_or_t(trec), RDL::Globals.parser.scan_str("#T u"))))``'
RDL.type :Array, :rassoc, '(u) -> ``promoted_or_t(trec)``'
RDL.type :Array, :reject, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple(trec)``'
RDL.type :Array, :reject, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :reject!, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple!(trec)``'
RDL.type :Array, :reject!, '() -> Enumerator<t>'
RDL.type :Array, :repeated_combination, '(Integer) { (``promote_tuple(trec)``) -> %any } -> ``promote_tuple(trec)``'
RDL.type :Array, :repeated_combination, '(Integer) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :repeated_permutation, '(Integer) { (``promote_tuple(trec)``) -> %any } -> ``promote_tuple(trec)``'
RDL.type :Array, :repeated_permutation, '(Integer) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :reverse, '() -> ``output_type(trec, targs, :reverse, :promoted_array, "Array<t>")``'
RDL.type :Array, :reverse!, '() -> ``reverse_output(trec)``'


def Array.reverse_output(trec)
  case trec
  when RDL::Type::TupleType
    rev = trec.params.reverse
    trec.params.each_with_index { |e, i|
      trec.params[i] = RDL::Type::UnionType.new(e, rev[i]).canonical
      trec.params[i] = Hash.weak_promote(trec.params[i]) if RDL::Config.instance.weak_update_promote ## There was a type error here, caught by the type checker (receiver of `weak_promote` call was originally self).
    }
    trec.check_bounds(true)
    trec
  else
    RDL::Globals.parser.scan_str "#T Array<t>"
  end
end
RDL.type Array, 'self.reverse_output', "(RDL::Type::Type) -> RDL::Type::Type", typecheck: :type_code, wrap: false

RDL.type :Array, :reverse_each, '() { (``promoted_or_t(trec)``) -> %any } -> self'
RDL.type :Array, :reverse_each, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :rindex, '(u) -> ``promoted_or_t(trec)``'
RDL.type :Array, :rindex, '() { (``promoted_or_t(trec)``) -> %bool } -> Integer'
RDL.type :Array, :rindex, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :rotate, '(?Integer) -> ``output_type(trec, targs, :rotate, :promoted_array, "Array<t>")``'
RDL.type :Array, :rotate!, '(?Integer) -> ``promote_tuple!(trec)``'
RDL.type :Array, :sample, '() -> ``promoted_or_t(trec)``'
RDL.type :Array, :sample, '(Integer) -> ``promote_tuple(trec)``'
RDL.type :Array, :select, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple(trec)``'
RDL.type :Array, :select, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :select!, '() { (``promoted_or_t(trec)``) -> %bool } -> ``promote_tuple!(trec)``'
RDL.type :Array, :select!, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :shift, '() -> ``promote_tuple!(trec); RDL::Globals.parser.scan_str "#T t"``'
RDL.type :Array, :shift, '(Integer) -> ``promote_tuple!(trec)``'
RDL.type :Array, :shuffle, '() -> ``promote_tuple(trec)``'
RDL.type :Array, :shuffle!, '() -> ``promote_tuple!(trec)``'
RDL.rdl_alias :Array, :size, :length
RDL.rdl_alias :Array, :slice, :[]
RDL.type :Array, :slice!, '(Range<Integer>) -> ``promote_tuple!(trec)``'
RDL.type :Array, :slice!, '(Integer, Integer) -> ``promote_tuple!(trec)``'
RDL.type :Array, :slice!, '(Integer or Float) -> ``promote_tuple!(trec); RDL::Globals.parser.scan_str "#T t"``'
RDL.type :Array, :sort, '() -> ``promote_tuple(trec)``'
RDL.type :Array, :sort, '() { (``promoted_or_t(trec)``, ``promoted_or_t(trec)``) -> Integer } -> ``promote_tuple(trec)``'
RDL.type :Array, :sort!, '() -> ``promote_tuple!(trec)``'
RDL.type :Array, :sort!, '() { (``promoted_or_t(trec)``,``promoted_or_t(trec)``) -> Integer } -> ``promote_tuple!(trec)``'
RDL.type :Array, :sort_by!, '() { (``promoted_or_t(trec)``) -> u } -> ``promote_tuple!(trec)``'
RDL.type :Array, :sort_by!, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :take, '(Integer) -> ``output_type(trec, targs, :take, :promoted_array, "Array<t>")``'
RDL.type :Array, :take_while, '() { (``promoted_or_t(trec)``) ->%bool } -> ``promote_tuple(trec)``'
RDL.type :Array, :take_while, '() -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(Enumerator), promoted_or_t(trec))``'
RDL.type :Array, :to_a, '() -> self'
RDL.type :Array, :to_ary, '() -> self'
RDL.rdl_alias :Array, :to_s, :inspect
RDL.type :Array, :transpose, '() -> ``promote_tuple(trec)``'
RDL.type :Array, :uniq, '() -> ``promote_tuple(trec)``'
RDL.type :Array, :uniq!, '() -> ``promote_tuple!(trec)``'
RDL.type :Array, :unshift, '(``any_or_t(trec, true)``) -> ``promote_tuple!(trec)``'
RDL.type :Array, :values_at, '(*Integer) -> ``output_type(trec, targs, :values_at, :promoted_array, "Array<t>")``'
RDL.type :Array, :values_at, '(Range<Integer>) -> ``promote_tuple(trec)``'
RDL.type :Array, :zip, '(*Array<u>) -> ``RDL::Type::GenericType.new(RDL::Globals.types[:array], RDL::Type::GenericType.new(RDL::Globals.types[:array], RDL::Type::UnionType.new(promoted_or_t(trec), RDL::Globals.parser.scan_str("#T u"))))``'
RDL.type :Array, :|, '(*Array<u>) -> ``RDL::Type::GenericType.new(RDL::Globals.types[:array], RDL::Type::UnionType.new(promoted_or_t(trec), RDL::Globals.parser.scan_str("#T u")))``'





######### Non-dependet types below #########

RDL.type :Array, :<<, '(t) -> Array<t>'
RDL.type :Array, :[], '(Range<Integer>) -> Array<t>'
RDL.type :Array, :[], '(Integer or Float) -> t'
RDL.type :Array, :[], '(Integer, Integer) -> Array<t>'
RDL.type :Array, :&, '(Array<u>) -> Array<t>'
RDL.type :Array, :*, '(Integer) -> Array<t>'
RDL.type :Array, :*, '(String) -> String'
RDL.type :Array, :+, '(Enumerable<u>) -> Array<u or t>'
RDL.type :Array, :+, '(Array<u>) -> Array<u or t>'
RDL.type :Array, :-, '(Array<u>) -> Array<u or t>'
RDL.type :Array, :slice, '(Range<Integer>) -> Array<t>'
RDL.type :Array, :slice, '(Integer) -> t'
RDL.type :Array, :slice, '(Integer, Integer) -> Array<t>'
RDL.type :Array, :[]=, '(Integer, t) -> t'
RDL.type :Array, :[]=, '(Integer, Integer, t) -> t'
# RDL.type :Array, :[]=, '(Integer, Integer, Array<t>) -> Array<t>'
# RDL.type :Array, :[]=, '(Range, Array<t>) -> Array<t>'
RDL.type :Array, :[]=, '(Range<Integer>, t) -> t'
RDL.type :Array, :assoc, '(t) -> Array<t>'
RDL.type :Array, :at, '(Integer) -> t'
RDL.type :Array, :clear, '() -> Array<t>'
RDL.type :Array, :map, '() {(t) -> u} -> Array<u>'
RDL.type :Array, :map, '() -> Enumerator<t>'
RDL.type :Array, :map!, '() {(t) -> u} -> Array<u>'
RDL.type :Array, :map!, '() -> Enumerator<t>'
RDL.type :Array, :collect, '() { (t) -> u } -> Array<u>'
RDL.type :Array, :collect, '() -> Enumerator<t>'
RDL.type :Array, :combination, '(Integer) { (Array<t>) -> %any } -> Array<t>'
RDL.type :Array, :combination, '(Integer) -> Enumerator<t>'
RDL.type :Array, :push, '(*t) -> Array<t>'
RDL.type :Array, :compact, '() -> Array<t>'
RDL.type :Array, :compact!, '() -> Array<t>'
RDL.type :Array, :concat, '(Array<t>) -> Array<t>'
RDL.type :Array, :count, '() -> Integer'
RDL.type :Array, :count, '(t) -> Integer'
RDL.type :Array, :count, '() { (t) -> %bool } -> Integer'
RDL.type :Array, :cycle, '(?Integer) { (t) -> %any } -> %any'
RDL.type :Array, :cycle, '(?Integer) -> Enumerator<t>'
RDL.type :Array, :delete, '(u) -> t'
RDL.type :Array, :delete, '(u) { () -> v } -> t or v'
RDL.type :Array, :delete_at, '(Integer) -> Array<t>'
RDL.type :Array, :delete_if, '() { (t) -> %bool } -> Array<t>'
RDL.type :Array, :delete_if, '() -> Enumerator<t>'
RDL.type :Array, :drop, '(Integer) -> Array<t>'
RDL.type :Array, :drop_while, '() { (t) -> %bool } -> Array<t>'
RDL.type :Array, :drop_while, '() -> Enumerator<t>'
RDL.type :Array, :each, '() -> Enumerator<t>'
RDL.type :Array, :each, '() { (t) -> %any } -> Array<t>'
RDL.type :Array, :each_index, '() { (Integer) -> %any } -> Array<t>'
RDL.type :Array, :each_index, '() -> Enumerator<t>'
RDL.type :Array, :empty?, '() -> %bool'
RDL.type :Array, :fetch, '(Integer) -> t'
RDL.type :Array, :fetch, '(Integer, u) -> u'
RDL.type :Array, :fetch, '(Integer) { (Integer) -> u } -> t or u'
RDL.type :Array, :fill, '(t) -> Array<t>'
RDL.type :Array, :fill, '(t, Integer, ?Integer) -> Array<t>'
RDL.type :Array, :fill, '(t, Range<Integer>) -> Array<t>'
RDL.type :Array, :fill, '() { (Integer) -> t } -> Array<t>'
RDL.type :Array, :fill, '(Integer, ?Integer) { (Integer) -> t } -> Array<t>'
RDL.type :Array, :fill, '(Range<Integer>) { (Integer) -> t } -> Array<t>'
RDL.type :Array, :flatten, '() -> Array<%any>' # Can't give a more precise RDL.type
RDL.type :Array, :index, '(u) -> Integer'
RDL.type :Array, :index, '() { (t) -> %bool } -> Integer'
RDL.type :Array, :index, '() -> Enumerator<t>'
RDL.type :Array, :first, '() -> t'
RDL.type :Array, :first, '(Integer) -> Array<t>'
RDL.type :Array, :include?, '(u) -> %bool'
RDL.type :Array, :initialize, '() -> self'
RDL.type :Array, :initialize, '(Integer) -> self'
RDL.type :Array, :initialize, '(Integer, t) -> self<t>'
RDL.type :Array, :insert, '(Integer, *t) -> Array<t>'
RDL.type :Array, :inspect, '() -> String'
RDL.type :Array, :join, '(?String) -> String'
RDL.type :Array, :keep_if, '() { (t) -> %bool } -> Array<t>'
RDL.type :Array, :last, '() -> t'
RDL.type :Array, :last, '(Integer) -> Array<t>'
RDL.type :Array, :member, '(u) -> %bool'
RDL.type :Array, :length, '() -> Integer'
RDL.type :Array, :permutation, '(?Integer) -> Enumerator<t>'
RDL.type :Array, :permutation, '(?Integer) { (Array<t>) -> %any } -> Array<t>'
RDL.type :Array, :pop, '(Integer) -> Array<t>'
RDL.type :Array, :pop, '() -> t'
RDL.type :Array, :product, '(*Array<u>) -> Array<Array<t or u>>'
RDL.type :Array, :rassoc, '(u) -> t'
RDL.type :Array, :reject, '() { (t) -> %bool } -> Array<t>'
RDL.type :Array, :reject, '() -> Enumerator<t>'
RDL.type :Array, :reject!, '() { (t) -> %bool } -> Array<t>'
RDL.type :Array, :reject!, '() -> Enumerator<t>'
RDL.type :Array, :repeated_combination, '(Integer) { (Array<t>) -> %any } -> Array<t>'
RDL.type :Array, :repeated_combination, '(Integer) -> Enumerator<t>'
RDL.type :Array, :repeated_permutation, '(Integer) { (Array<t>) -> %any } -> Array<t>'
RDL.type :Array, :repeated_permutation, '(Integer) -> Enumerator<t>'
RDL.type :Array, :reverse, '() -> Array<t>'
RDL.type :Array, :reverse!, '() -> Array<t>'
RDL.type :Array, :reverse_each, '() { (t) -> %any } -> Array<t>'
RDL.type :Array, :reverse_each, '() -> Enumerator<t>'
RDL.type :Array, :rindex, '(u) -> t'
RDL.type :Array, :rindex, '() { (t) -> %bool } -> Integer'
RDL.type :Array, :rindex, '() -> Enumerator<t>'
RDL.type :Array, :rotate, '(?Integer) -> Array<t>'
RDL.type :Array, :rotate!, '(?Integer) -> Array<t>'
RDL.type :Array, :sample, '() -> t'
RDL.type :Array, :sample, '(Integer) -> Array<t>'
RDL.type :Array, :select, '() { (t) -> %bool } -> Array<t>'
RDL.type :Array, :select, '() -> Enumerator<t>'
RDL.type :Array, :select!, '() { (t) -> %bool } -> Array<t>'
RDL.type :Array, :select!, '() -> Enumerator<t>'
RDL.type :Array, :shift, '() -> t'
RDL.type :Array, :shift, '(Integer) -> Array<t>'
RDL.type :Array, :shuffle, '() -> Array<t>'
RDL.type :Array, :shuffle!, '() -> Array<t>'
RDL.type :Array, :slice!, '(Range<Integer>) -> Array<t>'
RDL.type :Array, :slice!, '(Integer, Integer) -> Array<t>'
RDL.type :Array, :slice!, '(Integer or Float) -> t'
RDL.type :Array, :sort, '() -> Array<t>'
RDL.type :Array, :sort, '() { (t,t) -> Integer } -> Array<t>'
RDL.type :Array, :sort!, '() -> Array<t>'
RDL.type :Array, :sort!, '() { (t,t) -> Integer } -> Array<t>'
RDL.type :Array, :sort_by!, '() { (t) -> u } -> Array<t>'
RDL.type :Array, :sort_by!, '() -> Enumerator<t>'
RDL.type :Array, :take, '(Integer) -> Array<t>'
RDL.type :Array, :take_while, '() { (t) ->%bool } -> Array<t>'
RDL.type :Array, :take_while, '() -> Enumerator<t>'
RDL.type :Array, :to_a, '() -> Array<t>'
RDL.type :Array, :to_ary, '() -> Array<t>'
RDL.type :Array, :transpose, '() -> Array<t>'
RDL.type :Array, :uniq, '() -> Array<t>'
RDL.type :Array, :uniq!, '() -> Array<t>'
RDL.type :Array, :unshift, '(*t) -> Array<t>'
RDL.type :Array, :values_at, '(*Range<Integer> or Integer) -> Array<t>'
RDL.type :Array, :zip, '(*Array<u>) -> Array<Array<t or u>>'
RDL.type :Array, :|, '(Array<u>) -> Array<t or u>'
