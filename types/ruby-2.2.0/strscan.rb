class StringScanner
  nowrap
  
  type :eos?, '() -> %bool'
  type :scan, '(Regexp) -> String'
  type :getch, '() -> String'
end