RDL.nowrap :Random

RDL.type :Random, :initialize, '(?Integer seed) -> self' # Floats can be passed also, but just truncated to int?
RDL.type :Random, 'self.new_seed', '() -> Integer'
RDL.type :Random, 'self.rand', '(?Integer max) -> Numeric'
RDL.type :Random, 'self.srand', '(?Integer number) -> Numeric old_seed'

RDL.type :Random, :==, '(%any) -> %bool'
RDL.type :Random, :bytes, '(Integer size) -> String'
RDL.type :Random, :rand, '(?(Integer or Range<Integer>) max) -> Integer'
RDL.type :Random, :rand, '(?(Float or Range<Float>) max) -> Float'
RDL.pre(:Random, :rand) { |max| max > 0 }
RDL.type :Random, :seed, '() -> Integer'
