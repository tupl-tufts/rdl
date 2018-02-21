RDL.nowrap :Hash

RDL.type_params :Hash, [:k, :v], :all?

RDL.type :Hash, 'self.[]', '(*u) -> Hash<u, u>'  # example: Hash[1,2,3,4]
RDL.type :Hash, 'self.[]', '(Array<[a,b]>) -> Hash<a, b>'
RDL.type :Hash, 'self.[]', '([to_hash: () -> Hash<a, b>]) -> Hash<a, b>'

#RDL.type :Hash, :[], '(k) -> v'

RDL.type :Hash, :[], '(``access_input(trec)``) -> ``access_output(trec, targs)``'

def Hash.access_input(trec)
  case trec
  when RDL::Type::GenericType
    trec.params[0]
  when RDL::Type::NominalType
    vartype_name = RDL::Globals.type_params["Hash"][0][0]
    RDL::Type::VarType.new(vartype_name)
  when RDL::Type::FiniteHashType
    trec.promote.params[0] ## this is the parameter of the promoted generic type
  end
end

def Hash.access_output(trec, targs)
  case trec
  when RDL::Type::GenericType
    trec.params[1]
  when RDL::Type::NominalType
    vartype_name = RDL::Globals.type_params["Hash"][0][1]
    RDL::Type::VarType.new(vartype_name)
  when RDL::Type::FiniteHashType
    case targs[0]
    when RDL::Type::SingletonType
      ## arg is singleton, we can return a precise type
      ## TODO: ask what about strings, constants? These can be keys in FHT but cannot be singleton types.
      if ret_type = trec.elts[targs[0].val]
        return ret_type
      else
        return RDL::Globals.types[:nil]
      end
    else
      ## arg is not singleton, best we can do is return union of value types
      promoted = trec.promote
      return promoted.params[1]
    end
  end
end



#RDL.type :Hash, :[]=, '(k, v) -> v'
RDL.type :Hash, :[]=, '(``assign_input(trec)``, v) -> v'
## TODO: ask, is this right approach for methods with side-effects?
## Seems previous approach was unsound, e.g. if x was FHT, then it would be promoted to more general type,
## and could be given new keys/values which didn't match the original FHT.

def Hash.assign_input(trec)
  ### TODO: Feels like there should be a better way to do this.
  ### This always returns var type `k`, but has side effect of promoting FHT's to Hash.
  ### This will be necessary for any mutating Hash methods
  ### Potentially: maintain a list of methods with side-effects.
  ### Then, in type checker, check this list and promote! there.
  if trec.is_a?(RDL::Type::FiniteHashType)
    raise "Unable to promote tuple #{trec} to Hash." unless trec.promote!
  end
  RDL::Globals.parser.scan_str "#T k"
end






RDL.type :Hash, :store, '(k,v) -> v'


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
RDL.type :Hash, :each, '() { (k,v) -> %any } -> Hash<k,v>'
RDL.type :Hash, :each, '() -> Enumerator<[k, v]>'
RDL.type :Hash, :each_pair, '() { (k,v) -> %any } -> Hash<k,v>'
RDL.type :Hash, :each_pair, '() -> Enumerator<[k, v]>'
RDL.type :Hash, :each_key, '() { (k) -> %any } -> Hash<k,v>'
RDL.type :Hash, :each_key, '() -> Enumerator<[k, v]>'
RDL.type :Hash, :each_value, '() { (v) -> %any } -> Hash<k,v>'
RDL.type :Hash, :each_value, '() -> Enumerator<[k, v]>'
#RDL.type :Hash, :empty?, '() -> %bool'
RDL.type :Hash, :empty?, '() -> ``empty_output(trec)``'

def Hash.empty_output(trec)
  case trec
  when RDL::Type::FiniteHashType
    if trec.elts.empty?
      RDL::Globals.types[:true]
    else
      RDL::Globals.types[:false]
    end
  else
    RDL::Globals.types[:bool]
  end
end

RDL.type :Hash, :fetch, '(k) -> v'
RDL.type :Hash, :fetch, '(k,u) -> u or v'
RDL.type :Hash, :fetch, '(k) { (k) -> u } -> u or v'
RDL.type :Hash, :member?, '(t) -> %bool'
RDL.type :Hash, :has_key?, '(t) -> %bool'
RDL.type :Hash, :key?, '(t) -> %bool'
RDL.type :Hash, :has_value?, '(t) -> %bool'
RDL.type :Hash, :value?, '(t) -> %bool'
RDL.type :Hash, :to_s, '() -> String'
RDL.type :Hash, :inspect, '() -> String'
RDL.type :Hash, :invert, '() -> Hash<v,k>'
RDL.type :Hash, :keep_if, '() { (k,v) -> %bool } -> Hash<k,v>'
RDL.type :Hash, :keep_if, '() -> Enumerator<[k, v]>'
RDL.type :Hash, :key, '(t) -> k'
#RDL.type :Hash, :keys, '() -> Array<k>'
RDL.type :Hash, :keys, '() -> ``keys_output(trec)``'

def Hash.keys_output(trec)
  case trec
  when RDL::Type::FiniteHashType
    key_types = trec.elts.keys.map { |k| RDL::Type::SingletonType.new(k) } ## TODO: what to do about strings and constants?
    return RDL::Type::TupleType.new(*key_types)
  when RDL::Type::GenericType
    return RDL::Globals.parser.scan_str "#T Array<k>"
  else
    return RDL::Globals.types[:array]
  end
end





#RDL.type :Hash, :length, '() -> Integer'
RDL.type :Hash, :length, '() -> ``length_output(trec)``'

def Hash.length_output(trec)
  case trec
  when RDL::Type::FiniteHashType
    RDL::Type::SingletonType.new(trec.elts.length)
  else
    RDL::Globals.types[:integer]
  end
end


RDL.type :Hash, :size, '() -> Integer'
#RDL.type :Hash, :merge, '(Hash<a,b>) -> Hash<a or k, b or v>'
## TODO: ask if we should comment out above and sigs like it, or keep and add to them
RDL.type :Hash, :merge, '(``merge_input(targs)``) -> ``merge_output(trec, targs)``'

def Hash.merge_input(targs)
  case targs[0]
  when RDL::Type::FiniteHashType
    return targs[0]
  when RDL::Type::GenericType
    return RDL::Globals.parser.scan_str "#T Hash<a, b>"
  else
    RDL::Globals.types[:hash]
  end
end

def Hash.merge_output(trec, targs)
  case trec
  when RDL::Type::NominalType
    return RDL::Globals.types[:hash]
  when RDL::Type::GenericType
    case targs[0]
    when RDL::Type::FiniteHashType
      promoted = targs[0].promote
      key_union = RDL::Type::UnionType.new(promoted.params[0], trec.params[0])
      value_union = RDL::Type::UnionType.new(promoted.params[1], trec.params[1])
      return RDL::Type::GenericType.new(trec.base, key_union, value_union)
    when RDL::Type::GenericType
      return RDL::Globals.parser.scan_str "#T Hash<a or k, b or v>"
    else
      ## targs[0] should just be hash here
      return RDL::Globals.types[:hash]
    end
  when RDL::Type::FiniteHashType
    case targs[0]
    when RDL::Type::FiniteHashType
      return RDL::Type::FiniteHashType.new(trec.elts.merge(targs[0].elts), nil)
    when RDL::Type::GenericType
      promoted = trec.promote
      key_union = RDL::Type::UnionType.new(promoted.params[0], targs[0].params[0])
      value_union = RDL::Type::UnionType.new(promoted.params[1], targs[0].params[1])
      return RDL::Type::GenericType.new(targs[0].base, key_union, value_union)
    else
      ## targs[0] should just be Hash here
      return RDL::Globals.types[:hash]
    end
  end

end



RDL.type :Hash, :merge, '(Hash<a,b>) { (k,v,b) -> v or b } -> Hash<a or k, b or v>'
# RDL.type :Hash, :rassoc, '(k) -> Tuple<k,v>'
RDL.type :Hash, :rassoc, '(k) -> Array<k or v>'
RDL.type :Hash, :rehash, '() -> Hash<k,v>'
RDL.type :Hash, :reject, '() -> Enumerator<[k, v]>'
RDL.type :Hash, :reject, '() {(k,v) -> %bool} -> Hash<k,v>'
RDL.type :Hash, :reject!, '() {(k,v) -> %bool} -> Hash<k,v>'
RDL.type :Hash, :select, '() {(k,v) -> %bool} -> Hash<k,v>'
RDL.type :Hash, :select!, '() {(k,v) -> %bool} -> Hash<k,v>'
# RDL.type :Hash, :shift, '() -> Tuple<k,v>'
RDL.type :Hash, :shift, '() -> Array<k or v>'
# RDL.type :Hash, :to_a, '() -> Array<Tuple<k,v>>'
RDL.type :Hash, :to_a, '() -> Array<Array<k or v>>'
RDL.type :Hash, :to_hash, '() -> Hash<k,v>'
RDL.type :Hash, :values, '() -> Array<v>'
RDL.type :Hash, :values_at, '(*k) -> Array<v>'
