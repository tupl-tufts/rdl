class Array
  rdl_nowrap

  type_params [:t], :all?

  type :<<, '(t) -> Array<t>'
  type :[], '(Range<%integer>) -> Array<t>'
  type :[], '(%integer or Float) -> t'
  type :[], '(%integer, %integer) -> Array<t>'
  type :&, '(Array<u>) -> Array<t>'
  type :*, '(%integer) -> Array<t>'
  type :*, '(String) -> String'
  type :+, '(Enumerable<u>) -> Array<u or t>'
  type :+, '(Array<u>) -> Array<u or t>'
  type :-, '(Array<u>) -> Array<u or t>'
  type :slice, '(Range<%integer>) -> Array<t>'
  type :slice, '(%integer) -> t'
  type :slice, '(%integer, %integer) -> Array<t>'
  type :[]=, '(%integer, t) -> t'
  type :[]=, '(%integer, %integer, t) -> t'
  #type :[]=, '(%integer, %integer, Array<t>) -> Array<t>'
  #type :[]=, '(Range, Array<t>) -> Array<t>'
  type :[]=, '(Range<%integer>, t) -> t'
  type :assoc, '(t) -> Array<t>'
  type :at, '(%integer) -> t'
  type :clear, '() -> Array<t>'
  type :map, '() {(t) -> u} -> Array<u>'
  type :map, '() -> Enumerator<t>'
  type :map!, '() {(t) -> u} -> Array<u>'
  type :map!, '() -> Enumerator<t>'
  type :collect, '() { (t) -> u } -> Array<u>'
  type :collect, '() -> Enumerator<t>'
  type :combination, '(%integer) { (Array<t>) -> %any } -> Array<t>'
  type :combination, '(%integer) -> Enumerator<t>'
  type :push, '(*t) -> Array<t>'
  type :compact, '() -> Array<t>'
  type :compact!, '() -> Array<t>'
  type :concat, '(Array<t>) -> Array<t>'
  type :count, '() -> %integer'
  type :count, '(t) -> %integer'
  type :count, '() { (t) -> %bool } -> %integer'
  type :cycle, '(?%integer) { (t) -> %any } -> %any'
  type :cycle, '(?%integer) -> Enumerator<t>'
  type :delete, '(u) -> t'
  type :delete, '(u) { () -> v } -> t or v'
  type :delete_at, '(%integer) -> Array<t>'
  type :delete_if, '() { (t) -> %bool } -> Array<t>'
  type :delete_if, '() -> Enumerator<t>'
  type :drop, '(%integer) -> Array<t>'
  type :drop_while, '() { (t) -> %bool } -> Array<t>'
  type :drop_while, '() -> Enumerator<t>'
  type :each, '() -> Enumerator<t>'
  type :each, '() { (t) -> %any } -> Array<t>'
  type :each_index, '() { (%integer) -> %any } -> Array<t>'
  type :each_index, '() -> Enumerator<t>'
  type :empty?, '() -> %bool'
  type :fetch, '(%integer) -> t'
  type :fetch, '(%integer, u) -> u'
  type :fetch, '(%integer) { (%integer) -> u } -> t or u'
  type :fill, '(t) -> Array<t>'
  type :fill, '(t, %integer, ?%integer) -> Array<t>'
  type :fill, '(t, Range<%integer>) -> Array<t>'
  type :fill, '() { (%integer) -> t } -> Array<t>'
  type :fill, '(%integer, ?%integer) { (%integer) -> t } -> Array<t>'
  type :fill, '(Range<%integer>) { (%integer) -> t } -> Array<t>'
  type :flatten, '() -> Array<%any>' # Can't give a more precise type
  type :index, '(u) -> %integer'
  type :index, '() { (t) -> %bool } -> %integer'
  type :index, '() -> Enumerator<t>'
  type :first, '() -> t'
  type :first, '(%integer) -> Array<t>'
  type :include?, '(u) -> %bool'
  type :initialize, '() -> self'
  type :initialize, '(%integer) -> self'
  type :initialize, '(%integer, t) -> self'
  type :insert, '(%integer, *t) -> Array<t>'
  type :inspect, '() -> String'
  type :join, '(?String) -> String'
  type :keep_if, '() { (t) -> %bool } -> Array<t>'
  type :last, '() -> t'
  type :last, '(%integer) -> Array<t>'
  type :member, '(u) -> %bool'
  type :length, '() -> Fixnum'
  type :permutation, '(?%integer) -> Enumerator<t>'
  type :permutation, '(?%integer) { (Array<t>) -> %any } -> Array<t>'
  type :pop, '(%integer) -> Array<t>'
  type :pop, '() -> t'
  type :product, '(*Array<u>) -> Array<Array<t or u>>'
  type :rassoc, '(u) -> t'
  type :reject, '() { (t) -> %bool } -> Array<t>'
  type :reject, '() -> Enumerator<t>'
  type :reject!, '() { (t) -> %bool } -> Array<t>'
  type :reject!, '() -> Enumerator<t>'
  type :repeated_combination, '(%integer) { (Array<t>) -> %any } -> Array<t>'
  type :repeated_combination, '(%integer) -> Enumerator<t>'
  type :repeated_permutation, '(%integer) { (Array<t>) -> %any } -> Array<t>'
  type :repeated_permutation, '(%integer) -> Enumerator<t>'
  type :reverse, '() -> Array<t>'
  type :reverse!, '() -> Array<t>'
  type :reverse_each, '() { (t) -> %any } -> Array<t>'
  type :reverse_each, '() -> Enumerator<t>'
  type :rindex, '(u) -> t'
  type :rindex, '() { (t) -> %bool } -> %integer'
  type :rindex, '() -> Enumerator<t>'
  type :rotate, '(?%integer) -> Array<t>'
  type :rotate!, '(?%integer) -> Array<t>'
  type :sample, '() -> t'
  type :sample, '(%integer) -> Array<t>'
  type :select, '() { (t) -> %bool } -> Array<t>'
  type :select, '() -> Enumerator<t>'
  type :select!, '() { (t) -> %bool } -> Array<t>'
  type :select!, '() -> Enumerator<t>'
  type :shift, '() -> t'
  type :shift, '(%integer) -> Array<t>'
  type :shuffle, '() -> Array<t>'
  type :shuffle!, '() -> Array<t>'
  rdl_alias :size, :length
  rdl_alias :slice, :[]
  type :slice!, '(Range<%integer>) -> Array<t>'
  type :slice!, '(%integer, %integer) -> Array<t>'
  type :slice!, '(%integer or Float) -> t'
  type :sort, '() -> Array<t>'
  type :sort, '() { (t,t) -> %integer } -> Array<t>'
  type :sort!, '() -> Array<t>'
  type :sort!, '() { (t,t) -> %integer } -> Array<t>'
  type :sort_by!, '() { (t) -> u } -> Array<t>'
  type :sort_by!, '() -> Enumerator<t>'
  type :take, '(%integer) -> Array<t>'
  type :take_while, '() { (t) ->%bool } -> Array<t>'
  type :take_while, '() -> Enumerator<t>'
  type :to_a, '() -> Array<t>'
  type :to_ary, '() -> Array<t>'
  rdl_alias :to_s, :inspect
  type :transpose, '() -> Array<t>'
  type :uniq, '() -> Array<t>'
  type :uniq!, '() -> Array<t>'
  type :unshift, '(*t) -> Array<t>'
  type :values_at, '(*Range<%integer> or %integer) -> Array<t>'
  type :zip, '(*Array<u>) -> Array<Array<t or u>>'
  type :|, '(Array<u>) -> Array<t or u>'
end