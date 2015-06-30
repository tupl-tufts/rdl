class Array
  nowrap
  type_params [:t]
  def __rdl_member?(inst)
    t = inst[:t]
    all? { |x| t.member? x }
  end
  
  type :[], '(Range) -> Array<t>'
  type :[], '(Fixnum) -> t'
  type :[], '(Fixnum, Fixnum) -> Array<t>'
  type :[], '(Float) -> t'
  type :&, '(Array<u>) -> Array<t>'
  type :*, '(Fixnum) -> Array<t>'
  type :*, '(String) -> String'
  type :+, '(Array<u>) -> Array<u or t>'
  type :-, '(Array<u>) -> Array<u or t>'
  type :slice, '(Range) -> Array<t>'
  type :slice, '(Fixnum) -> t'
  type :slice, '(Fixnum, Fixnum) -> Array<t>'
  type :[]=, '(Fixnum, t) -> t'
  type :[]=, '(Fixnum, Fixnum, t) -> t'
  #type :[]=, '(Fixnum, Fixnum, Array<t>) -> Array<t>'
  #type :[]=, '(Range, Array<t>) -> Array<t>'
  type :[]=, '(Range, t) -> t'
  type :assoc, '(t) -> Array<t>'
  type :at, '(Fixnum) -> t'
  type :clear, '() -> Array<t>'
  type :map, '() {(t) ->u} -> Array<u>'
  type :map, '() -> Enumerator'
  type :collect, '() { (t) -> u } -> Array<u>'
  type :collect, '() -> Enumerator'
  type :combination, '(Fixnum) { (Array<t>) -> %any } -> Array<t>'
  type :combination, '(Fixnum) -> Enumerator'
  type :push, '(t) -> Array<t>'
  type :compact, '() -> Array<t>'
  type :compact!, '() -> Array<t>'
  type :concat, '(Array<t>) -> Array<t>'
  type :count, '() -> Fixnum'
  type :count, '(t) -> Fixnum'
  type :count, '() { (t) -> %bool } -> Fixnum'
  type :cycle, '(?Fixnum) { (t) -> %any } -> %any'
  type :cycle, '(?Fixnum) -> Enumerator'
  type :delete, '(u) -> t'
  type :delete, '(u) { () -> v } -> t or v'
  type :delete_at, '(Fixnum) -> Array<t>'
  type :delete_if, '() { (t) -> %bool } -> Array<t>'
  type :delete_if, '() -> Enumerator'
  type :drop, '(Fixnum) -> Array<t>'
  type :drop_while, '() { (t) -> %bool } -> Array<t>'
  type :drop_while, '() -> Enumerator'
  type :each, '() -> Enumerator'
  type :each, '() { (t) -> %any } -> Array<t>'
  type :each_index, '() { (Fixnum) -> %any } -> Array<t>'
  type :each_index, '() -> Enumerator'
  type :empty?, '() -> %bool'
  type :fetch, '(Fixnum) -> t'
  type :fetch, '(Fixnum, u) -> u'
  type :fetch, '(Fixnum) { (Fixnum) -> u } -> t or u'
  type :fill, '(t) -> Array<t>'
  type :fill, '(t,Fixnum,?Fixnum) -> Array<t>'
  type :fill, '(t, Range) -> Array<t>'
  type :fill, '() { (Fixnum) -> t } -> Array<t>'
  type :fill, '(Fixnum,?Fixnum) { (Fixnum) -> t } -> Array<t>'
  type :fill, '(Range) { (Fixnum) -> t } -> Array<t>'
  type :index, '(u) -> Fixnum'
  type :index, '() { (t) -> %bool } -> Fixnum'
  type :index, '() -> Enumerator'
  type :first, '() -> t'
  type :first, '(Fixnum) -> Array<t>'
  type :include?, '(u) -> %bool'
  type :insert, '(Fixnum, *t) -> Array<t>'
  type :inspect, '() -> String'
  type :join, '(?String) -> String'
  type :keep_if, '() { (t) -> %bool } -> Array<t>'
  type :last, '() -> t'
  type :last, '(Fixnum) -> Array<t>'
  type :length, '() -> Fixnum'
  type :permutation, '(?Fixnum) -> Enumerator'
  type :permutation, '(?Fixnum) { (Array<t>) -> %any } -> Array<t>'
  type :pop, '(Fixnum) -> Array<t>'
  type :pop, '() -> t'
  type :product, '(*Array<u>) -> Array<Array<t or u>>'
  type :rassoc, '(u) -> t'
  type :reject, '() { (t) -> %bool } -> Array<t>'
  type :reject, '() -> Enumerator'
  type :reject!, '() { (t) -> %bool } -> Array<t>'
  type :reject!, '() -> Enumerator'
  type :repeated_combination, '(Fixnum) { (Array<t>) -> %any } -> Array<t>'
  type :repeated_combination, '(Fixnum) -> Enumerator'
  type :repeated_permutation, '(Fixnum) { (Array<t>) -> %any } -> Array<t>'
  type :repeated_permutation, '(Fixnum) -> Enumerator'
  type :reverse, '() -> Array<t>'
  type :reverse!, '() -> Array<t>'
  type :reverse_each, '() { (t) -> %any } -> Array<t>'
  type :reverse_each, '() -> Enumerator'
  type :rindex, '(u) -> t'
  type :rindex, '() { (t) -> %bool } -> Fixnum'
  type :rindex, '() -> Enumerator'
  type :rotate, '(?Fixnum) -> Array<t>'
  type :rotate!, '(?Fixnum) -> Array<t>'
  type :sample, '() -> t'
  type :sample, '(Fixnum) -> Array<t>'
  type :select, '() { (t) -> %bool } -> Array<t>'
  type :select, '() -> Enumerator'
  type :select!, '() { (t) -> %bool } -> Array<t>'
  type :select!, '() -> Enumerator'
  type :shift, '() -> t'
  type :shift, '(Fixnum) -> Array<t>'
  type :shuffle, '() -> Array<t>'
  type :shuffle!, '() -> Array<t>'
  rdl_alias :size, :length
  rdl_alias :slice, :[]
  type :slice!, '(Range) -> Array<t>'
  type :slice!, '(Fixnum, Fixnum) -> Array<t>'
  type :slice!, '(Fixnum) -> t'
  type :slice!, '(Float) -> t'
  type :sort, '() -> Array<t>'
  type :sort, '() { (t,t) -> Fixnum } -> Array<t>'
  type :sort!, '() -> Array<t>'
  type :sort!, '() { (t,t) -> Fixnum } -> Array<t>'
  type :sort_by!, '() { (t) -> u } -> Array<t>'
  type :sort_by!, '() -> Enumerator'
  type :take, '(Fixnum) -> Array<t>'
  type :take_while, '() { (t) ->%bool } -> Array<t>'
  type :take_while, '() -> Enumerator'
  type :to_a, '() -> Array<t>'
  type :to_ary, '() -> Array<t>'
  rdl_alias :to_s, :inspect
  type :transpose, '() -> Array<t>'
  type :uniq, '() -> Array<t>'
  type :uniq!, '() -> Array<t>'
  type :unshift, '(*t) -> Array<t>'
  type :values_at, '(*Range or Fixnum) -> Array<t>'
  type :zip, '(*Array<u>) -> Array<Array<t or u>>'
  type :|, '(Array<u>) -> Array<t or u>'
end
