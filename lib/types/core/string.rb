RDL.nowrap :String

def String.output_type(trec, targs, meth, type)
  case trec
  when RDL::Type::PreciseStringType
    return RDL::Globals.parser.scan_str "#T #{type}" unless trec.vals.size == 1 ## Can maybe get more precise than this for some methods, but in most cases we have to sacrifice precision. Might return to this.
    if targs.empty?
      res = trec.vals[0].send(meth)
    elsif targs.size == 1
      case targs[0]
      when RDL::Type::SingletonType
        res = trec.vals[0].send(meth, targs[0].val)
      when RDL::Type::PreciseStringType
        res = trec.vals[0].send(meth, targs.vals[0])
      else
        RDL::Globals.parser.scan_str "#T #{type}"
      end
    elsif targs.size > 1 && targs.all? { |a| a.is_a?(RDL::Type::SingletonType) }
      vals = targs.map { |t| t.val }
      to_type(trec.vals[0].send(meth, *vals))
    else
      #raise "not yet implemented with method #{meth} and trec #{trec} and targs #{targs} and type #{type}"
      RDL::Globals.parser.scan_str "#T #{type}"
    end
    to_type(res)
  else
    RDL::Globals.parser.scan_str "#T #{type}"
  end
end

RDL.type String, 'self.output_type', "(RDL::Type::Type, Array<RDL::Type::Type>, Symbol, String) -> RDL::Type::Type", effect: [:+, :+]

def String.to_type(v)
  case v
  when RDL::Type::Type
    v
  when Array
    RDL::Type::TupleType.new(*(v.map { |i| to_type(i) }))
  when String
    RDL::Type::PreciseStringType.new(v)
  when Symbol, Integer, Float, Class, TrueClass, FalseClass
    RDL::Type::SingletonType.new(v)
  else
    RDL::Type::NominalType.new(v.class)
  end
end

RDL.type String, 'self.to_type', "(%any) -> RDL::Type::Type", effect: [:+, :+]

def String.any_string(a)
  case a
  when RDL::Type::PreciseStringType
    a
  else
    RDL::Globals.types[:string]
  end
end

RDL.type String, 'self.any_string', "(%any) -> RDL::Type::Type", effect: [:+, :+]

def String.string_promote!(trec)
  case trec
  when RDL::Type::PreciseStringType
    raise "Unable to promote string #{trec}." unless trec.promote!
    trec
  else
    RDL::Globals.types[:string]
  end
end

RDL.type String, 'self.string_promote!', "(%any) -> RDL::Type::Type", effect: [:~, :+]


RDL.type :String, :initialize, '(?String str) -> self new_str'
RDL.type :String, 'self.try_convert', '(Object obj) -> String or nil new_string'
RDL.type :String, :%, '(Object) -> ``output_type(trec, targs, :%, "String")``'
RDL.type :String, :*, '(Numeric) -> ``output_type(trec, targs, :*, "String")``'

def String.plus_output(trec, targs)
  if trec.is_a?(RDL::Type::PreciseStringType) && targs[0].is_a?(RDL::Type::PreciseStringType)
  then RDL::Type::PreciseStringType.new(*(trec.vals+targs[0].vals))
  else RDL::Globals.types[:string]
  end
end

RDL.type String, 'self.plus_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", effect: [:+, :+]


RDL.type :String, :+, '(``any_string(targs[0])``) -> ``plus_output(trec, targs)``'
RDL.type :String, :<<, '(Object) -> ``append_output(trec, targs)``'

def String.append_output(trec, targs)
  if trec.is_a?(RDL::Type::PreciseStringType) && targs[0].is_a?(RDL::Type::PreciseStringType)
    targs[0].vals.each { |v|
      if trec.vals.last.is_a?(String) && v.is_a?(String)
        trec.vals.last << v
      else
        trec.vals << v
      end
    }
    raise RDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds
    trec
  elsif trec.is_a?(RDL::Type::PreciseStringType)
    trec.promote!
    trec
  else
    RDL::Globals.types[:string]
  end
end

RDL.type String, 'self.append_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", effect: [:+, :+]

RDL.type :String, :<=>, '(String other) -> ``output_type(trec, targs, :<=>, "Integer")``'
RDL.type :String, :==, '(%any) -> ``output_type(trec, targs, :==, "%bool")``', effect: [:+, :+]
RDL.type :String, :===, '(%any) -> ``output_type(trec, targs, :===, "%bool")``'
RDL.type :String, :=~, '(Object) -> ``output_type(trec, targs, :=~, "Integer")``', wrap: false # Wrapping this messes up $1 etc
RDL.type :String, :[], '(Integer, ?Integer) -> ``output_type(trec, targs, :[], "String")``', effect: [:+, :+]
RDL.type :String, :[], '(Range<Integer> or Regexp) -> ``output_type(trec, targs, :[], "String")``', effect: [:+, :+]
RDL.type :String, :[], '(Regexp, Integer) -> ``output_type(trec, targs, :[], "String")``', effect: [:+, :+]
RDL.type :String, :[], '(Regexp, String) -> ``output_type(trec, targs, :[], "String")``', effect: [:+, :+]
RDL.type :String, :[], '(String) -> ``output_type(trec, targs, :[], "String")``', effect: [:+, :+]
RDL.type :String, :ascii_only?, '() -> ``output_type(trec, targs, :ascii_only?, "%bool")``'
RDL.type :String, :b, '() -> ``output_type(trec, targs, :b, "String")``'
RDL.type :String, :bytes, '() -> ``output_type(trec, targs, :bytes, "Array")``' 
RDL.type :String, :bytesize, '() -> ``output_type(trec, targs, :bytesize, "Integer")``'
RDL.type :String, :byteslice, '(Integer, ?Integer) -> ``output_type(trec, targs, :byteslice, "String")``'
RDL.type :String, :byteslice, '(Range<Integer>) -> ``output_type(trec, targs, :byteslice, "String")``'
RDL.type :String, :capitalize, '() -> ``output_type(trec, targs, :capitalize, "String")``'
RDL.type :String, :capitalize!, '() -> ``cap_down_output(trec, :capitalize!)``'
def String.cap_down_output(trec, meth)
  case trec
  when RDL::Type::PreciseStringType
    trec.vals.each { |v| v.send(meth) if v.is_a?(String) }
    raise RDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds
    trec
  else
    RDL::Globals.types[:string]
  end      
end

RDL.type String, 'self.cap_down_output', "(RDL::Type::Type, Symbol) -> RDL::Type::Type", effect: [:+, :+]
  
RDL.type :String, :casecmp, '(String) -> ``output_type(trec, targs, :casecmp, "Integer")``'
RDL.type :String, :center, '(Integer, ?String) -> ``output_type(trec, targs, :center, "String")``'
RDL.type :String, :chars, '() -> ``output_type(trec, targs, :chars, "Array")``'  #deprecated
RDL.type :String, :chomp, '(?String) -> ``output_type(trec, targs, :chomp, "String")``'
RDL.type :String, :chomp!, '(?String) -> ``string_promote!(trec)``' ## chomp! depends on the value of $/, which is hard to reason about during type checking. So, keeping this imprecise.
RDL.type :String, :chop, '() -> ``output_type(trec, targs, :chop, "String")``'
RDL.type :String, :chop!, '() -> ``chop_output(trec)``'

def String.chop_output(trec)
  case trec
  when RDL::Type::PreciseStringType
    if trec.vals.last.is_a?(String)
      trec.vals.last.chop!
      raise RDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds
      trec
    else
      trec.promote!
      trec
    end
  else
    RDL::Globals.types[:string]
  end
end

RDL.type String, 'self.chop_output', "(RDL::Type::Type) -> RDL::Type::Type", effect: [:+, :+]

RDL.type :String, :chr, '() -> ``output_type(trec, targs, :chr, "String")``'
RDL.type :String, :clear, '() -> ``clear_output(trec)``'

def String.clear_output(trec)
  case trec
  when RDL::Type::PreciseStringType
    trec.vals = [""]
    raise RDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds
    trec
  else
    RDL::Type::PreciseStringType.new("")
  end
end

RDL.type String, 'self.clear_output', "(RDL::Type::Type) -> RDL::Type::Type", effect: [:+, :+]

RDL.type :String, :codepoints, '() -> ``output_type(trec, targs, :codepoints, "Array<Integer>")``'
RDL.type :String, :concat, '(Integer or Object) -> ``append_output(trec, targs)``'
RDL.type :String, :count, '(String, *String) -> ``output_type(trec, targs, :count, "Integer")``'
RDL.type :String, :crypt, '(String) -> ``output_type(trec, targs, :crypt, "String")``'
RDL.type :String, :delete, '(String, *String) -> ``output_type(trec, targs, :delete, "String")``'
RDL.type :String, :delete!, '(String, *String) -> ``string_promote!(trec)``'
RDL.type :String, :downcase, '() -> ``output_type(trec, targs, :downcase, "String")``'
RDL.type :String, :downcase!, '() -> ``cap_down_output(trec, :downcase!)``'
RDL.type :String, :dump, '() -> ``output_type(trec, targs, :dump, "String")``'
RDL.type :String, :each_byte, '() {(Integer) -> %any} -> String'
RDL.type :String, :each_byte, '() -> Enumerator'
RDL.type :String, :each_char, '() {(String) -> %any} -> String'
RDL.type :String, :each_char, '() -> Enumerator'
RDL.type :String, :each_codepoint, '() {(Integer) -> %any} -> String'
RDL.type :String, :each_codepoint, '() -> Enumerator'
RDL.type :String, :each_line, '(?String) {(Integer) -> %any} -> String'
RDL.type :String, :each_line, '(?String) -> Enumerator'
RDL.type :String,  :empty?, '() ->``output_type(trec, targs, :empty?, "%bool")``'
# RDL.type :String, :encode, '(?Encoding, ?Encoding, *Symbol) -> String' # TODO: fix Hash arg:String,
# RDL.type :String, :encode!, '(Encoding, ?Encoding, *Symbol) -> String'
RDL.type :String, :encoding, '() -> Encoding'
RDL.type :String, :end_with?, '(*String) -> ``output_type(trec, targs, :end_with?, "%bool")``'
RDL.type :String, :eql?, '(String) -> ``output_type(trec, targs, :eql?, "%bool")``'
RDL.type :String, :force_encoding, '(String or Encoding) -> String'
RDL.type :String, :getbyte, '(Integer) -> ``output_type(trec, targs, :getbyte, "Integer")``'
RDL.type :String, :gsub, '(Regexp or String, String) -> ``output_type(trec, targs, :gsub, "String")``', wrap: false # Can't wrap these:String, , since they mess with $1 etc
RDL.type :String, :gsub, '(Regexp or String, Hash) -> ``output_type(trec, targs, :gsub, "String")``'
RDL.type :String, :gsub, '(Regexp or String, String) -> ``output_type(trec, targs, :gsub, "String")``', wrap: false
RDL.type :String, :gsub, '(Regexp or String) {(String) -> %any } -> ``output_type(trec, targs, :gsub, "String")``'
RDL.type :String, :gsub, '(Regexp or String, String) -> ``output_type(trec, targs, :gsub, "String")``', wrap: false
RDL.type :String, :gsub, '(Regexp or String) ->  ``output_type(trec, targs, :gsub, "String")``'
RDL.type :String, :gsub!, '(Regexp or String, String) -> ``string_promote!(trec)``', wrap: false
RDL.type :String, :gsub!, '(Regexp or String) {(String) -> %any } -> ``string_promote!(trec)``', wrap: false
RDL.type :String, :gsub!, '(Regexp or String) -> ``string_promote!(trec); RDL::Type::NominalType.new(Enumerator)``', wrap: false
RDL.type :String, :hash, '() -> Integer'
RDL.type :String, :hex, '() -> ``output_type(trec, targs, :getbyte, "Integer")``'
RDL.type :String, :include?, '(String) -> ``output_type(trec, targs, :include?, "%bool")``', effect: [:+, :+]
RDL.type :String, :index, '(Regexp or String, ?Integer) -> ``output_type(trec, targs, :index, "Integer")``'
RDL.type :String, :replace, '(String) -> ``replace_output(trec, targs)``'

def String.replace_output(trec, targs)
  case trec
  when RDL::Type::PreciseStringType
    case targs[0]
    when RDL::Type::PreciseStringType
      trec.vals = targs[0].vals
      raise RDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds
      trec
    else
      raise RDL::Typecheck::StaticTypeError, "Failed to promote string #{trec}." unless trec.promote!
      trec
    end      
  else
    trec
  end
end

RDL.type String, 'self.replace_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", effect: [:+, :+]

RDL.type :String, :insert, '(Integer, String) -> String' ## TODO

def String.insert_output(trec, targs)
  case trec
  when RDL::Type::PreciseStringType
    if targs[0].is_a?(RDL::Type::SingletonType) && targs[1].is_a?(RDL::Type::PreciseStringType) && targs[1].all? { |v| v.is_a?(String) } && trec.vals.all? { |v| v.is_a?(String) }
      rec_str = trec.vals.join
      arg_int = targs[0].val
      arg_str = targs[1].vals.join
      trec.vals = [rec_str.insert(arg_int, arg_str)]
      raise RDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds
      trec
    else
      raise RDL::Typecheck::StaticTypeError, "Failed to promote string #{trec}." unless trec.promote!
      trec
    end
  else
    trec
  end
end

RDL.type String, 'self.insert_output', "(RDL::Type::Type, Array<RDL::Type::Type>) -> RDL::Type::Type", effect: [:+, :+]

RDL.type :String, :inspect, '() -> ``output_type(trec, targs, :inspect, "String")``'
RDL.type :String, :intern, '() -> ``output_type(trec, targs, :intern, "Symbol")``'
RDL.type :String, :length, '() -> ``output_type(trec, targs, :length, "Integer")``'
RDL.type :String, :lines, '(?String) -> ``output_type(trec, targs, :lines, "Array<String>")``'
RDL.type :String, :ljust, '(Integer, ?String) -> ``output_type(trec, targs, :ljust, "String")``'
RDL.type :String, :lstrip, '() -> ``output_type(trec, targs, :getbyte, "String")``'
RDL.type :String, :lstrip!, '() -> ``lrstrip_output(trec, :lstrip!)``' ## TODO

def String.lrstrip_output(trec, meth)
  check = (if meth == :lstrip! then :start_with? elsif meth == :rstrip! then :end_with? else raise "unexpected val #{meth}" end)
  case trec
  when RDL::Type::PreciseStringType
    if trec.vals[0].is_a?(String)
      if trec.vals[0].send(check, " ")
        trec.vals[0].send(meth)
        raise RDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds
        trec        
      else
        trec
      end
    else
      raise RDL::Typecheck::StaticTypeError, "Failed to promote string #{trec}." unless trec.promote!
      trec
    end
  else
    trec
  end
end

RDL.type String, 'self.lrstrip_output', "(RDL::Type::Type, Symbol) -> RDL::Type::Type", effect: [:+, :+]

RDL.type :String, :match, '(Regexp or String) -> MatchData'
RDL.type :String, :match, '(Regexp or String, Integer) -> MatchData'
RDL.type :String, :next, '() -> ``output_type(trec, targs, :next, "String")``'
RDL.type :String, :next!, '() -> ``mutate_output(trec, :next!)``' ## TODO

def String.mutate_output(trec, meth)
  case trec
  when RDL::Type::PreciseStringType
    if trec.vals.all? { |v| v.is_a?(String) }
      trec.vals = [trec.vals.join.send(meth)]
      raise RDL::Typecheck::StaticTypeError, "Failed to mutate string: new string #{trec} does not match prior constraints." unless trec.check_bounds
      trec        
    else
      raise RDL::Typecheck::StaticTypeError, "Failed to promote string #{trec}." unless trec.promote!
      trec
    end
  else
    trec
  end
end

RDL.type String, 'self.mutate_output', "(RDL::Type::Type, Symbol) -> RDL::Type::Type", effect: [:+, :+]


RDL.type :String, :oct, '() -> ``output_type(trec, targs, :oct, "Integer")``'
RDL.type :String, :ord, '() -> ``output_type(trec, targs, :ord, "Integer")``'
RDL.type :String, :partition, '(Regexp or String) -> ``output_type(trec, targs, :partition, "Array<String>")``'
RDL.type :String, :prepend, '(String) -> ``output_type(trec, targs, :prepend, "String")``'
RDL.type :String, :reverse, '() -> ``output_type(trec, targs, :reverse, "String")``'
RDL.type :String, :rindex, '(String or Regexp, ?Integer) -> ``output_type(trec, targs, :rindex, "Integer")``'
RDL.type :String, :rjust, '(Integer, ?String) -> ``output_type(trec, targs, :rjust, "String")``'
RDL.type :String, :rpartition, '(String or Regexp) -> ``output_type(trec, targs, :rpartition, "Array<String>")``'
RDL.type :String, :rstrip, '() -> ``output_type(trec, targs, :rstrip, "String")``'
RDL.type :String, :rstrip!, '() -> ``lrstrip_output(trec, :rstrip!)``'
RDL.type :String, :scan, '(Regexp or String) -> ``output_type(trec, targs, :scan, "Array<String or Array<String>>")``', wrap: false # :String, Can't wrap or screws up last_match
RDL.type :String, :scan, '(Regexp or String) {(*%any) -> %any} -> ``output_type(trec, targs, :scan, "Array<String or Array<String>>")``', wrap: false
RDL.type :String, :scrub, '(?String) -> ``output_type(trec, targs, :scrub, "String")``'
RDL.type :String, :scrub, '(?String) {(%any) -> %any} -> String'
RDL.type :String, :scrub!, '(?String) -> ``string_promote!(trec)``'
RDL.type :String, :scrub!, '(?String) {(%any) -> %any} -> ``string_promote!(trec)``'
RDL.type :String, :size, '() -> ``output_type(trec, targs, :size, "Integer")``'
RDL.rdl_alias :String, :slice, :[]
RDL.type :String, :slice!, '(Integer, ?Integer) -> ``string_promote!(trec)``'
RDL.type :String, :slice!, '(Range<Integer> or Regexp) -> ``string_promote!(trec)``'
RDL.type :String, :slice!, '(Regexp, Integer) -> ``string_promote!(trec)``'
RDL.type :String, :slice!, '(Regexp, String) -> ``string_promote!(trec)``'
RDL.type :String, :slice!, '(String) -> ``string_promote!(trec)``'
RDL.type :String, :split, '(?(Regexp or String), ?Integer) -> ``output_type(trec, targs, :split, "Array<String>")``', effect: [:+, :+]
RDL.type :String, :split, '(?Integer) -> ``output_type(trec, targs, :split, "Array<String>")``', effect: [:+, :+]
RDL.type :String, :squeeze, '() -> ``output_type(trec, targs, :squeeze, "String")``'
RDL.type :String, :squeeze!, '() -> ``mutate_output(trec, :squeeze!)``'
RDL.type :String, :start_with?, '(* String) -> ``output_type(trec, targs, :start_with?, "%bool")``', effect: [:+, :+]
RDL.type :String, :strip, '() -> ``output_type(trec, targs, :strip, "String")``'
RDL.type :String, :strip!, '() -> ``mutate_output(trec, :strip!)``'
RDL.type :String, :sub, '(Regexp or String, String or Hash) -> ``output_type(trec, targs, :sub, "String")``', wrap: false # Can't wrap these, since they mess with $1 etc
RDL.type :String, :sub, '(Regexp or String) {(String) -> %any} -> ``output_type(trec, targs, :sub, "String")``', wrap: false
RDL.type :String, :sub!, '(Regexp or String, String) -> ``string_promote!(trec)``', wrap: false
RDL.type :String, :sub!, '(Regexp or String) {(String) -> %any} -> ``string_promote!(trec)``', wrap: false
RDL.type :String, :succ, '() -> ``output_type(trec, targs, :succ, "String")``'
RDL.type :String, :sum, '(?Integer) -> ``output_type(trec, targs, :sum, "Integer")``'
RDL.type :String, :swapcase, '() -> ``output_type(trec, targs, :swapcase, "String")``'
RDL.type :String, :swapcase!, '() -> ``mutate_output(trec, :swapcase!)``'
RDL.type :String, :to_c, '() -> Complex'
RDL.type :String, :to_f, '() -> ``output_type(trec, targs, :to_f, "Float")``'
RDL.type :String, :to_i, '(?Integer) -> ``output_type(trec, targs, :to_i, "Integer")``'
RDL.type :String, :to_r, '() -> Rational'
RDL.type :String, :to_s, '() -> self', effect: [:+, :+]
RDL.type :String, :to_str, '() -> self'
RDL.type :String, :to_sym, '() -> ``output_type(trec, targs, :to_sym, "Symbol")``', effect: [:+, :+]
RDL.type :String, :tr, '(String, String) -> ``output_type(trec, targs, :tr, "String")``'
RDL.type :String, :tr!, '(String, String) -> ``string_promote!(trec)``'
RDL.type :String, :tr_s, '(String, String) -> ``output_type(trec, targs, :tr_s, "String")``'
RDL.type :String, :tr_s!, '(String, String) -> ``string_promote!(trec)``'
RDL.type :String, :unpack, '(String) -> ``output_type(trec, targs, :unpack, "Array<String>")``'
RDL.type :String, :upcase, '() -> ``output_type(trec, targs, :upcase, "String")``'
RDL.type :String, :upcase!, '() -> ``mutate_output(trec, :upcase!)``'
RDL.type :String, :upto, '(String, ?bool) -> Enumerator'
RDL.type :String, :upto, '(String, ?bool) {(String) -> %any } -> String'
RDL.type :String, :valid_encoding?, '() -> ``output_type(trec, targs, :valid_encoding?, "%bool")``'











### non-dependent types






RDL.type :String, :initialize, '(?String str) -> self new_str'
RDL.type :String, :'self.try_convert', '(Object obj) -> String or nil new_string'
RDL.type :String, :%, '(Object) -> String'
RDL.type :String, :*, '(Integer) -> String'
RDL.type :String, :+, '(String) -> String'
RDL.type :String, :<<, '(Object) -> String'
RDL.type :String, :<=>, '(String other) -> Integer or nil ret'
RDL.type :String, :==, '(%any) -> %bool', effect: [:+, :+]
RDL.type :String, :===, '(%any) -> %bool'
RDL.type :String, :=~, '(Object) -> Integer or nil', wrap: false # Wrapping this messes up $1 etc
RDL.type :String, :[], '(Integer, ?Integer) -> String or nil', effect: [:+, :+]
RDL.type :String, :[], '(Range<Integer> or Regexp) -> String or nil', effect: [:+, :+]
RDL.type :String, :[], '(Regexp, Integer) -> String or nil', effect: [:+, :+]
RDL.type :String, :[], '(Regexp, String) -> String or nil', effect: [:+, :+]
RDL.type :String, :[], '(String) -> String or nil', effect: [:+, :+]
RDL.type :String, :ascii_only?, '() -> %bool'
RDL.type :String, :b, '() -> String'
RDL.type :String, :bytes, '() -> Array' # TODO: bindings to parameterized (vars)
RDL.type :String, :bytesize, '() -> Integer'
RDL.type :String, :byteslice, '(Integer, ?Integer) -> String or nil'
RDL.type :String, :byteslice, '(Range<Integer>) -> String or nil'
RDL.type :String, :capitalize, '() -> String'
RDL.type :String, :capitalize!, '() -> String or nil'
RDL.type :String, :casecmp, '(String) -> nil or Integer'
RDL.type :String, :center, '(Integer, ?String) -> String'
RDL.type :String, :chars, '() -> Array'  #deprecated
RDL.type :String, :chomp, '(?String) -> String'
RDL.type :String, :chomp!, '(?String) -> String or nil'
RDL.type :String, :chop, '() -> String'
RDL.type :String, :chop!, '() -> String or nil'
RDL.type :String, :chr, '() -> String'
RDL.type :String, :clear, '() -> String'
RDL.type :String, :codepoints, '() -> Array<Integer>' # TODO
RDL.type :String, :codepoints, '() {(?%any) -> %any} -> Array<Integer>' # TODO
RDL.type :String, :concat, '(Integer or Object) -> String'
RDL.type :String, :count, '(String, *String) -> Integer'
RDL.type :String, :crypt, '(String) -> String'
RDL.type :String, :delete, '(String, *String) -> String'
RDL.type :String, :delete!, '(String, *String) -> String or nil'
RDL.type :String, :downcase, '() -> String'
RDL.type :String, :downcase!, '() -> String or nil'
RDL.type :String, :dump, '() -> String'
RDL.type :String, :each_byte, '() {(Integer) -> %any} -> String'
RDL.type :String, :each_byte, '() -> Enumerator'
RDL.type :String, :each_char, '() {(String) -> %any} -> String'
RDL.type :String, :each_char, '() -> Enumerator'
RDL.type :String, :each_codepoint, '() {(Integer) -> %any} -> String'
RDL.type :String, :each_codepoint, '() -> Enumerator'
RDL.type :String, :each_line, '(?String) {(Integer) -> %any} -> String'
RDL.type :String, :each_line, '(?String) -> Enumerator'
RDL.type :String,  :empty?, '() -> %bool'
# RDL.type :String, :encode, '(?Encoding, ?Encoding, *Symbol) -> String' # TODO: fix Hash arg:String,
# RDL.type :String, :encode!, '(Encoding, ?Encoding, *Symbol) -> String'
RDL.type :String, :encoding, '() -> Encoding'
RDL.type :String, :end_with?, '(*String) -> %bool'
RDL.type :String, :eql?, '(String) -> %bool'
RDL.type :String, :force_encoding, '(String or Encoding) -> String'
RDL.type :String, :getbyte, '(Integer) -> Integer or nil'
RDL.type :String, :gsub, '(Regexp or String, String) -> String', wrap: false # Can't wrap these:String, , since they mess with $1 etc
RDL.type :String, :gsub, '(Regexp or String, Hash) -> String', wrap: false
RDL.type :String, :gsub, '(Regexp or String) {(String) -> %any } -> String', wrap: false
RDL.type :String, :gsub, '(Regexp or String) ->  Enumerator', wrap: false
RDL.type :String, :gsub, '(Regexp or String) -> String', wrap: false
RDL.type :String, :gsub!, '(Regexp or String, String) -> String or nil', wrap: false
RDL.type :String, :gsub!, '(Regexp or String) {(String) -> %any } -> String or nil', wrap: false
RDL.type :String, :gsub!, '(Regexp or String) -> Enumerator', wrap: false
RDL.type :String, :hash, '() -> Integer'
RDL.type :String, :hex, '() -> Integer'
RDL.type :String, :include?, '(String) -> %bool', effect: [:+, :+]
RDL.type :String, :index, '(Regexp or String, ?Integer) -> Integer or nil'
RDL.type :String, :replace, '(String) -> String'
RDL.type :String, :insert, '(Integer, String) -> String'
RDL.type :String, :inspect, '() -> String'
RDL.type :String, :intern, '() -> Symbol'
RDL.type :String, :length, '() -> Integer'
RDL.type :String, :lines, '(?String) -> Array<String>'
RDL.type :String, :ljust, '(Integer, ?String) -> String' # TODO
RDL.type :String, :lstrip, '() -> String'
RDL.type :String, :lstrip!, '() -> String or nil'
RDL.type :String, :match, '(Regexp or String) -> MatchData'
RDL.type :String, :match, '(Regexp or String, Integer) -> MatchData'
RDL.type :String, :next, '() -> String'
RDL.type :String, :next!, '() -> String'
RDL.type :String, :oct, '() -> Integer'
RDL.type :String, :ord, '() -> Integer'
RDL.type :String, :partition, '(Regexp or String) -> Array<String>'
RDL.type :String, :prepend, '(String) -> String'
RDL.type :String, :reverse, '() -> String'
RDL.type :String, :rindex, '(String or Regexp, ?Integer) -> Integer or nil' # TODO
RDL.type :String, :rjust, '(Integer, ?String) -> String' # TODO
RDL.type :String, :rpartition, '(String or Regexp) -> Array<String>'
RDL.type :String, :rstrip, '() -> String'
RDL.type :String, :rstrip!, '() -> String'
RDL.type :String, :scan, '(Regexp or String) -> Array<String or Array<String>>', wrap: false # :String, Can't wrap or screws up last_match
RDL.type :String, :scan, '(Regexp or String) {(*%any) -> %any} -> Array<String or Array<String>>', wrap: false
RDL.type :String, :scrub, '(?String) -> String'
RDL.type :String, :scrub, '(?String) {(%any) -> %any} -> String'
RDL.type :String, :scrub!, '(?String) -> String'
RDL.type :String, :scrub!, '(?String) {(%any) -> %any} -> String'
RDL.type :String, :setbyte, '(Integer, Integer) -> Integer'
RDL.type :String, :size, '() -> Integer'
RDL.type :String, :slice!, '(Integer, ?Integer) -> String or nil'
RDL.type :String, :slice!, '(Range<Integer> or Regexp) -> String or nil'
RDL.type :String, :slice!, '(Regexp, Integer) -> String or nil'
RDL.type :String, :slice!, '(Regexp, String) -> String or nil'
RDL.type :String, :slice!, '(String) -> String or nil'
RDL.type :String, :split, '(?(Regexp or String), ?Integer) -> Array<String>', effect: [:+, :+]
RDL.type :String, :split, '(?Integer) -> Array<String>', effect: [:+, :+]
RDL.type :String, :squeeze, '(?String) -> String'
RDL.type :String, :squeeze!, '(?String) -> String'
RDL.type :String, :start_with?, '(* String) -> %bool', effect: [:+, :+]
RDL.type :String, :strip, '() -> String'
RDL.type :String, :strip!, '() -> String'
RDL.type :String, :sub, '(Regexp or String, String or Hash) -> String', wrap: false # Can't wrap these, since they mess with $1 etc
RDL.type :String, :sub, '(Regexp or String) {(String) -> %any} -> String', wrap: false
RDL.type :String, :sub!, '(Regexp or String, String) -> String', wrap: false # TODO: Does this really not allow Hash?
RDL.type :String, :sub!, '(Regexp or String) {(String) -> %any} -> String', wrap: false
RDL.type :String, :succ, '() -> String'
RDL.type :String, :sum, '(?Integer) -> Integer'
RDL.type :String, :swapcase, '() -> String'
RDL.type :String, :swapcase!, '() -> String or nil'
RDL.type :String, :to_c, '() -> Complex'
RDL.type :String, :to_f, '() -> Float'
RDL.type :String, :to_i, '(?Integer) -> Integer'
RDL.type :String, :to_r, '() -> Rational'
RDL.type :String, :to_s, '() -> String', effect: [:+, :+]
RDL.type :String, :to_str, '() -> self'
RDL.type :String, :to_sym, '() -> Symbol', effect: [:+, :+]
RDL.type :String, :tr, '(String, String) -> String'
RDL.type :String, :tr!, '(String, String) -> String or nil'
RDL.type :String, :tr_s, '(String, String) -> String'
RDL.type :String, :tr_s!, '(String, String) -> String or nil'
RDL.type :String, :unpack, '(String) -> Array<String>'
RDL.type :String, :upcase, '() -> String'
RDL.type :String, :upcase!, '() -> String or nil'
RDL.type :String, :upto, '(String, ?bool) -> Enumerator'
RDL.type :String, :upto, '(String, ?bool) {(String) -> %any } -> String'
RDL.type :String, :valid_encoding?, '() -> %bool'

