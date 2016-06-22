require_relative 'range.rb'

class Random
  rdl_nowrap

  type 'self.new', '(?Integer seed) -> Random' # Floats can be passed also, but just truncated to int?
  type 'self.new_seed', '() -> Integer'
  type 'self.rand', '(?Integer max) -> Numeric'
  type 'self.srand', '(?Integer number) -> Numeric old_seed'

  type :==, '(%any) -> %bool'
  type :bytes, '(Fixnum size) -> String'
  type :rand, '(?(Integer or Range<Integer>) max) -> Integer'
  type :rand, '(?(Float or Range<Float>) max) -> Float'
  pre(:rand) { |max| max > 0 }
  type :seed, '() -> Integer'
end
