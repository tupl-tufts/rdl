module Benchmark
  rdl_nowrap

  type 'self.benchmark', '(String, ?Fixnum, ?String, *String) -> Array<Benchmark::Tms>'
  type 'self.bm', '(?Fixnum, *String) { (Benchmark::Process) -> nil} -> Array<Benchmark::Tms>'
  #type 'self.benchmark', '(Caption: String, Label_Width: ?Fixnum, Format: ?String, Labels: *String) -> Benchmark::Tms'
  #type 'self.bm', '(Label_Width: ?Fixnum, Labels: *String) { (Benchmark::Process) -> nil} -> Array<Benchmark::Tms>'
  type 'self.bmbm', '(?Fixnum label_width) { (Benchmark::Process) -> nil} -> Array<Benchmark::Tms>'
  type 'self.measure', '(?String label) -> Benchmark::Tms'
  type 'self.realtime', '() {(*%any) -> %any} -> Fixnum'
end
