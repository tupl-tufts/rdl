rdl_nowrap :Random

type :Random, 'self.new', '(?Integer seed) -> Random' # Floats can be passed also, but just truncated to int?
type :Random, 'self.new_seed', '() -> Integer'
type :Random, 'self.rand', '(?Integer max) -> Numeric'
type :Random, 'self.srand', '(?Integer number) -> Numeric old_seed'

type :Random, :==, '(%any) -> %bool'
type :Random, :bytes, '(Integer size) -> String'
type :Random, :rand, '(?(Integer or Range<Integer>) max) -> Integer'
type :Random, :rand, '(?(Float or Range<Float>) max) -> Float'
pre(:Random, :rand) { |max| max > 0 }
type :Random, :seed, '() -> Integer'
