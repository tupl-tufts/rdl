rdl_nowrap :StringScanner

type :StringScanner, 'self.new', '(String, ?%bool) -> StringScanner'
type :StringScanner, :eos?, '() -> %bool'
type :StringScanner, :scan, '(Regexp) -> String'
type :StringScanner, :getch, '() -> String'
