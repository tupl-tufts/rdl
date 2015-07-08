class Random
  type 'self.new', '(seed: ?Integer) -> Random' # Floats can be passed also, but just truncated to int?
  type 'self.new_seed', '() -> Integer'
  type 'self.rand', '(max: ?Integer) -> Numeric'
  type 'self.srand', '(number: ?Integer) -> old_ssed: Numeric'

  type :==, '(%any) -> %bool'
  type :bytes, '(size: Fixnum) -> String'
  type :rand, '(max: ?(Integer or Range<Integer>)) -> Integer'
  type :rand, '(max: ?(Float or Range<Float>)) -> Float'
  pre(:rand) { |max| max > 0 }
  type :seed, '() -> Integer'
end