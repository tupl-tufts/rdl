rdl_nowrap :Benchmark

type :Benchmark, 'self.benchmark', '(String, ?Fixnum, ?String, *String) -> Array<Benchmark::Tms>'
type :Benchmark, 'self.bm', '(?Fixnum, *String) { (Benchmark::Process) -> nil} -> Array<Benchmark::Tms>'
# type :Benchmark, 'self.benchmark', '(Caption: String, Label_Width: ?Fixnum, Format: ?String, Labels: *String) -> Benchmark::Tms'
# type :Benchmark, 'self.bm', '(Label_Width: ?Fixnum, Labels: *String) { (Benchmark::Process) -> nil} -> Array<Benchmark::Tms>'
type :Benchmark, 'self.bmbm', '(?Fixnum label_width) { (Benchmark::Process) -> nil} -> Array<Benchmark::Tms>'
type :Benchmark, 'self.measure', '(?String label) -> Benchmark::Tms'
type :Benchmark, 'self.realtime', '() {(*%any) -> %any} -> Fixnum'
