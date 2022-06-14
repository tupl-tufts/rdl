RDL.nowrap :Pathname

RDL.type :Pathname, 'self.getwd', '() -> Pathname'
RDL.type :Pathname, 'self.glob', '(String p1, ?String p2) -> Array<Pathname>'
RDL.type :Pathname, 'self.glob', '(String p1, ?String p2) { (String) -> %any } -> Array<Pathname>'
RDL.rdl_alias :Pathname, 'self.pwd', 'self.getwd'
RDL.type :Pathname, :+, '(String or Pathname other) -> Pathname'
RDL.rdl_alias :Pathname, :/, :+
RDL.type :Pathname, :<=>, '(%any p1) -> -1 or 0 or 1 or nil'
RDL.type :Pathname, :==, '(%any p1) -> %bool'
RDL.type :Pathname, :===, '(%any p1) -> %bool'
RDL.type :Pathname, :absolute?, '() -> %bool'
RDL.type :Pathname, :ascend, '() { (Pathname) -> %any } -> %any'
RDL.type :Pathname, :atime, '() -> Time'
RDL.type :Pathname, :basename, '(?String p1) -> Pathname' # guessing about arg RDL.type
RDL.type :Pathname, :binread, '(?Integer length, ?Integer offset) -> String'
RDL.type :Pathname, :binwrite, '(String, ?Integer offset) -> Integer' # TODO open_args
RDL.type :Pathname, :birthtime, '() -> Time'
RDL.type :Pathname, :blockdev?, '() -> %bool'
RDL.type :Pathname, :chardev?, '() -> %bool'
RDL.type :Pathname, :children, '(%bool with_directory) -> Array<Pathname>'
RDL.type :Pathname, :chmod, '(Integer mode) -> Integer'
RDL.type :Pathname, :chown, '(Integer owner, Integer group) -> Integer'
RDL.type :Pathname, :cleanpath, '(?%bool consider_symlink) -> %any'
RDL.type :Pathname, :ctime, '() -> Time'
RDL.type :Pathname, :delete, '() -> %any'
RDL.type :Pathname, :descend, '() { (Pathname) -> %any } -> %any'
RDL.type :Pathname, :directory?, '() -> %bool'
RDL.type :Pathname, :dirname, '() -> Pathname'
RDL.type :Pathname, :each_child, '(%bool with_directory) { (Pathname) -> %any } -> %any'
RDL.type :Pathname, :each_entry, '() { (Pathname) -> %any } -> %any'
RDL.type :Pathname, :each_filename, '() { (String) -> %any } -> %any'
RDL.type :Pathname, :each_filename, '() -> Enumerator<String>'
RDL.type :Pathname, :each_line, '(?String sep, ?Integer limit) { (String) -> %any } -> %any' # TODO open_args
RDL.type :Pathname, :each_line, '(?String sep, ?Integer limit) -> Enumerator<String>'
RDL.type :Pathname, :entries, '() -> Array<Pathname>'
RDL.type :Pathname, :eql?, '(%any) -> %bool'
RDL.type :Pathname, :executable?, '() -> %bool'
RDL.type :Pathname, :executable_real?, '() -> %bool'
RDL.type :Pathname, :exist?, '() -> %bool'
RDL.type :Pathname, :expand_path, '(?(String or Pathname) p1) -> Pathname'
RDL.type :Pathname, :extname, '() -> String'
RDL.type :Pathname, :file?, '() -> %bool'
RDL.type :Pathname, :find, '(%bool ignore_error) { (Pathname) -> %any } -> %any'
RDL.type :Pathname, :find, '(%bool ignore_error) -> Enumerator<Pathname>'
RDL.type :Pathname, :fnmatch, '(String pattern, ?Integer flags) -> %bool'
RDL.type :Pathname, :freeze, '() -> self' # TODO return RDL.type?
RDL.type :Pathname, :ftype, '() -> String'
RDL.type :Pathname, :grpowned?, '() -> %bool'
#RDL.type :Pathname, :initialize, '(%string or Pathname p1) -> self' # p1 can be String-like
RDL.type :Pathname, :join, '(*(String or Pathname) args) -> Pathname'
RDL.type :Pathname, :lchmod, '(Integer mode) -> Integer'
RDL.type :Pathname, :lchown, '(Integer owner, Integer group) -> Integer'
RDL.type :Pathname, :lstat, '() -> File::Stat'
RDL.type :Pathname, :make_link, '(String old) -> 0'
RDL.type :Pathname, :symlink?, '(String old) -> 0'
RDL.type :Pathname, :mkdir, '(String p1) -> 0'
RDL.type :Pathname, :mkpath, '() -> %any' # TODO return?
RDL.type :Pathname, :mountpoint?, '() -> %bool'
RDL.type :Pathname, :mtime, '() -> Time'
RDL.type :Pathname, :open, '(?String mode, ?String perm, ?Integer opt) -> File'
RDL.type :Pathname, :open, '(?String mode, ?String perm, ?Integer opt) { (File) -> t } -> t'
RDL.type :Pathname, :opendir, '(?Encoding) -> Dir'
RDL.type :Pathname, :opendir, '(?Encoding) { (Dir) -> u } -> u'
RDL.type :Pathname, :owned?, '() -> %bool'
RDL.type :Pathname, :parent, '() -> Pathname'
RDL.type :Pathname, :pipe?, '() -> %bool'
RDL.type :Pathname, :read, '(?Integer length, ?Integer offset, ?Integer open_args) -> String'
RDL.type :Pathname, :readable?, '() -> %bool'
RDL.type :Pathname, :readable_real?, '() -> %bool'
RDL.type :Pathname, :readlines, '(?String sep, ?Integer limit, ?Integer open_args) -> Array<String>'
RDL.type :Pathname, :readlink, '() -> String file'
RDL.type :Pathname, :realdirpath, '(?String p1) -> String'
RDL.type :Pathname, :realpath, '(?String p1) -> String'
RDL.type :Pathname, :relative?, '() -> %bool'
RDL.type :Pathname, :relative_path_from, '(String or Pathname base_directory) -> Pathname'
RDL.type :Pathname, :rename, '(String p1) -> 0'
RDL.type :Pathname, :rmdir, '() -> 0'
RDL.type :Pathname, :rmtree, '() -> 0'
RDL.type :Pathname, :root?, '() -> %bool'
RDL.type :Pathname, :setgid?, '() -> %bool'
RDL.type :Pathname, :setuid?, '() -> %bool'
RDL.type :Pathname, :size, '() -> Integer'
RDL.type :Pathname, :size?, '() -> %bool'
RDL.type :Pathname, :socket?, '() -> %bool'
RDL.type :Pathname, :split, '() -> [Pathname, Pathname]'
RDL.type :Pathname, :stat, '() -> File::Stat'
RDL.type :Pathname, :sticky?, '() -> %bool'
RDL.type :Pathname, :sub, '(*String args) -> Pathname'
RDL.type :Pathname, :sub_ext, '(String p1) -> Pathname'
RDL.type :Pathname, :symlink?, '() -> %bool'
RDL.type :Pathname, :sysopen, '(?Integer mode, ?Integer perm) -> Integer'
RDL.type :Pathname, :taint, '() -> self'
RDL.type :Pathname, :to_path, '() -> String'
RDL.rdl_alias :Pathname, :to_s, :to_path
RDL.type :Pathname, :truncate, '(Integer length) -> 0'
RDL.type :Pathname, :unlink, '() -> Integer'
RDL.type :Pathname, :untaint, '() -> self'
RDL.type :Pathname, :utime, '(Time atime, Time mtime) -> Integer'
RDL.type :Pathname, :world_readable?, '() -> %bool'
RDL.type :Pathname, :world_writable?, '() -> %bool'
RDL.type :Pathname, :writable?, '() -> %bool'
RDL.type :Pathname, :writable_real?, '() -> %bool'
RDL.type :Pathname, :write, '(String, ?Integer offset, ?Integer open_args) -> Integer'
RDL.type :Pathname, :zero?, '() -> %bool'
