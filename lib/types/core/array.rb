rdl_nowrap :Array

class Array
  type_params [:t], :all?
end

type :Array, :<<, '(t) -> Array<t>'
type :Array, :[], '(Range<%integer>) -> Array<t>'
type :Array, :[], '(%integer or Float) -> t'
type :Array, :[], '(%integer, %integer) -> Array<t>'
type :Array, :&, '(Array<u>) -> Array<t>'
type :Array, :*, '(%integer) -> Array<t>'
type :Array, :*, '(String) -> String'
type :Array, :+, '(Enumerable<u>) -> Array<u or t>'
type :Array, :+, '(Array<u>) -> Array<u or t>'
type :Array, :-, '(Array<u>) -> Array<u or t>'
type :Array, :slice, '(Range<%integer>) -> Array<t>'
type :Array, :slice, '(%integer) -> t'
type :Array, :slice, '(%integer, %integer) -> Array<t>'
type :Array, :[]=, '(%integer, t) -> t'
type :Array, :[]=, '(%integer, %integer, t) -> t'
# type :Array, :[]=, '(%integer, %integer, Array<t>) -> Array<t>'
# type :Array, :[]=, '(Range, Array<t>) -> Array<t>'
type :Array, :[]=, '(Range<%integer>, t) -> t'
type :Array, :assoc, '(t) -> Array<t>'
type :Array, :at, '(%integer) -> t'
type :Array, :clear, '() -> Array<t>'
type :Array, :map, '() {(t) -> u} -> Array<u>'
type :Array, :map, '() -> Enumerator<t>'
type :Array, :map!, '() {(t) -> u} -> Array<u>'
type :Array, :map!, '() -> Enumerator<t>'
type :Array, :collect, '() { (t) -> u } -> Array<u>'
type :Array, :collect, '() -> Enumerator<t>'
type :Array, :combination, '(%integer) { (Array<t>) -> %any } -> Array<t>'
type :Array, :combination, '(%integer) -> Enumerator<t>'
type :Array, :push, '(*t) -> Array<t>'
type :Array, :compact, '() -> Array<t>'
type :Array, :compact!, '() -> Array<t>'
type :Array, :concat, '(Array<t>) -> Array<t>'
type :Array, :count, '() -> %integer'
type :Array, :count, '(t) -> %integer'
type :Array, :count, '() { (t) -> %bool } -> %integer'
type :Array, :cycle, '(?%integer) { (t) -> %any } -> %any'
type :Array, :cycle, '(?%integer) -> Enumerator<t>'
type :Array, :delete, '(u) -> t'
type :Array, :delete, '(u) { () -> v } -> t or v'
type :Array, :delete_at, '(%integer) -> Array<t>'
type :Array, :delete_if, '() { (t) -> %bool } -> Array<t>'
type :Array, :delete_if, '() -> Enumerator<t>'
type :Array, :drop, '(%integer) -> Array<t>'
type :Array, :drop_while, '() { (t) -> %bool } -> Array<t>'
type :Array, :drop_while, '() -> Enumerator<t>'
type :Array, :each, '() -> Enumerator<t>'
type :Array, :each, '() { (t) -> %any } -> Array<t>'
type :Array, :each_index, '() { (%integer) -> %any } -> Array<t>'
type :Array, :each_index, '() -> Enumerator<t>'
type :Array, :empty?, '() -> %bool'
type :Array, :fetch, '(%integer) -> t'
type :Array, :fetch, '(%integer, u) -> u'
type :Array, :fetch, '(%integer) { (%integer) -> u } -> t or u'
type :Array, :fill, '(t) -> Array<t>'
type :Array, :fill, '(t, %integer, ?%integer) -> Array<t>'
type :Array, :fill, '(t, Range<%integer>) -> Array<t>'
type :Array, :fill, '() { (%integer) -> t } -> Array<t>'
type :Array, :fill, '(%integer, ?%integer) { (%integer) -> t } -> Array<t>'
type :Array, :fill, '(Range<%integer>) { (%integer) -> t } -> Array<t>'
type :Array, :flatten, '() -> Array<%any>' # Can't give a more precise type
type :Array, :index, '(u) -> %integer'
type :Array, :index, '() { (t) -> %bool } -> %integer'
type :Array, :index, '() -> Enumerator<t>'
type :Array, :first, '() -> t'
type :Array, :first, '(%integer) -> Array<t>'
type :Array, :include?, '(u) -> %bool'
type :Array, :initialize, '() -> self'
type :Array, :initialize, '(%integer) -> self'
type :Array, :initialize, '(%integer, t) -> self'
type :Array, :insert, '(%integer, *t) -> Array<t>'
type :Array, :inspect, '() -> String'
type :Array, :join, '(?String) -> String'
type :Array, :keep_if, '() { (t) -> %bool } -> Array<t>'
type :Array, :last, '() -> t'
type :Array, :last, '(%integer) -> Array<t>'
type :Array, :member, '(u) -> %bool'
type :Array, :length, '() -> Fixnum'
type :Array, :permutation, '(?%integer) -> Enumerator<t>'
type :Array, :permutation, '(?%integer) { (Array<t>) -> %any } -> Array<t>'
type :Array, :pop, '(%integer) -> Array<t>'
type :Array, :pop, '() -> t'
type :Array, :product, '(*Array<u>) -> Array<Array<t or u>>'
type :Array, :rassoc, '(u) -> t'
type :Array, :reject, '() { (t) -> %bool } -> Array<t>'
type :Array, :reject, '() -> Enumerator<t>'
type :Array, :reject!, '() { (t) -> %bool } -> Array<t>'
type :Array, :reject!, '() -> Enumerator<t>'
type :Array, :repeated_combination, '(%integer) { (Array<t>) -> %any } -> Array<t>'
type :Array, :repeated_combination, '(%integer) -> Enumerator<t>'
type :Array, :repeated_permutation, '(%integer) { (Array<t>) -> %any } -> Array<t>'
type :Array, :repeated_permutation, '(%integer) -> Enumerator<t>'
type :Array, :reverse, '() -> Array<t>'
type :Array, :reverse!, '() -> Array<t>'
type :Array, :reverse_each, '() { (t) -> %any } -> Array<t>'
type :Array, :reverse_each, '() -> Enumerator<t>'
type :Array, :rindex, '(u) -> t'
type :Array, :rindex, '() { (t) -> %bool } -> %integer'
type :Array, :rindex, '() -> Enumerator<t>'
type :Array, :rotate, '(?%integer) -> Array<t>'
type :Array, :rotate!, '(?%integer) -> Array<t>'
type :Array, :sample, '() -> t'
type :Array, :sample, '(%integer) -> Array<t>'
type :Array, :select, '() { (t) -> %bool } -> Array<t>'
type :Array, :select, '() -> Enumerator<t>'
type :Array, :select!, '() { (t) -> %bool } -> Array<t>'
type :Array, :select!, '() -> Enumerator<t>'
type :Array, :shift, '() -> t'
type :Array, :shift, '(%integer) -> Array<t>'
type :Array, :shuffle, '() -> Array<t>'
type :Array, :shuffle!, '() -> Array<t>'
rdl_alias :Array, :size, :length
rdl_alias :Array, :slice, :[]
type :Array, :slice!, '(Range<%integer>) -> Array<t>'
type :Array, :slice!, '(%integer, %integer) -> Array<t>'
type :Array, :slice!, '(%integer or Float) -> t'
type :Array, :sort, '() -> Array<t>'
type :Array, :sort, '() { (t,t) -> %integer } -> Array<t>'
type :Array, :sort!, '() -> Array<t>'
type :Array, :sort!, '() { (t,t) -> %integer } -> Array<t>'
type :Array, :sort_by!, '() { (t) -> u } -> Array<t>'
type :Array, :sort_by!, '() -> Enumerator<t>'
type :Array, :take, '(%integer) -> Array<t>'
type :Array, :take_while, '() { (t) ->%bool } -> Array<t>'
type :Array, :take_while, '() -> Enumerator<t>'
type :Array, :to_a, '() -> Array<t>'
type :Array, :to_ary, '() -> Array<t>'
rdl_alias :Array, :to_s, :inspect
type :Array, :transpose, '() -> Array<t>'
type :Array, :uniq, '() -> Array<t>'
type :Array, :uniq!, '() -> Array<t>'
type :Array, :unshift, '(*t) -> Array<t>'
type :Array, :values_at, '(*Range<%integer> or %integer) -> Array<t>'
type :Array, :zip, '(*Array<u>) -> Array<Array<t or u>>'
type :Array, :|, '(Array<u>) -> Array<t or u>'