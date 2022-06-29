RDL.nowrap :StringScanner

RDL.type :StringScanner, 'self.new', '(String, ?%bool) -> StringScanner'
RDL.type :StringScanner, :eos?, '() -> %bool'
RDL.type :StringScanner, :scan, '(Regexp) -> String'
RDL.type :StringScanner, :getch, '() -> String'
