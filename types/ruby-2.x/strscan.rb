class StringScanner
  rdl_nowrap

  type :eos?, '() -> %bool'
  type :scan, '(Regexp) -> String'
  type :getch, '() -> String'
end
