class Dir

  rdl_alias :[], :glob
  type 'self.chdir', '(?String) -> Fixnum' # TODO 0
  type 'self.chdir', '(?String) { (String) -> u } -> u'
  type 'self.chroot', '(String) -> Fixnum' # TODO 0
  type 'self.delete', '(String) -> Fixnum' # TODO 0
  type 'self.entries', '(String, ?Encoding) -> Array<String>'
  type 'self.exist?', '(file: String) -> %bool'
  # exists? deprecated
  type 'self.foreach', '(dir: String, ?Encoding) { (String) -> %any } -> nil'
  type 'self.foreach', '(dir: String, ?Encoding) -> Enumerator<String>'
  type 'self.getwd', '() -> String'
  type 'self.glob', '(pattern: String or Array<String>, flags: Fixum) -> Array<String>'
  type 'self.glob', '(pattern: String or Array<String>, flags: Fixum) { (String) -> %any} -> nil'
  type 'self.home', '(?String) -> String'
  type 'self.mkdir', '(String, ?Fixnum) -> Fixnum' # TODO 0
  type 'self.new', '(String, ?Encoding) -> Dir'
  type 'self.open', '(String, ?Encoding) -> Dir'
  type 'self.open', '(String, ?Encoding) { (Dir) -> u } -> u'
  type 'self.pwd', '() -> String'
  type 'self.rmdir', '(String) -> Fixnum' # TODO 0
  type 'self.unlink', '(String) -> Fixnum' # TODO 0
  type :close, '() -> nil'
  type :each, '() { (String) -> %any } -> self'
  type :each, '() -> Enumerator<String>'
  type :fileno, '() -> Fixnum'
  type :inspect, '() -> String'
  type :path, '() -> String or nil'
  type :pos, '() -> Fixnum'
  type :pos=, '(Fixnum) -> Fixnum'
  type :read, '() -> String or nil'
  type :rewind, '() -> self'
  type :seek, '(Fixnum) -> self'
  type :tell, '() -> Fixnum'
  type :to_path, '() -> String or nil'
end