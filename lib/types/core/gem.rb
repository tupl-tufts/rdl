rdl_nowrap :Gem

type :Gem, 'self.bin_path', '(String name, ?String exec_name, *Gem::Requirement requirements) -> String'
type :Gem, 'self.binary_mode', '() -> String'
type :Gem, 'self.bindir', '(?String install_dir) -> String'
type :Gem, 'self.clear_default_specs', '() -> Hash'
type :Gem, 'self.clear_paths', '() -> nil'
type :Gem, 'self.config_file', '() -> String'
type :Gem, 'self.configuration', '() -> Gem::ConfigFile'
type :Gem, 'self.configuration=', '(%any) -> %any' #returns param
type :Gem, 'self.datadir', '(String gem_name) -> String or nil'
type :Gem, 'self.default_bindir', '() -> String or nil'
type :Gem, 'self.default_cert_path', '() -> String or nil'
type :Gem, 'self.default_dir', '() -> String or nil'
type :Gem, 'self.default_exec_format', '() -> String or nil'
type :Gem, 'self.default_key_path', '() -> String or nil'
type :Gem, 'self.default_path', '() -> String or nil'
type :Gem, 'self.default_rubygems_dirs', '() -> Array<String> or nil'
type :Gem, 'self.default_sources', '() -> Array<String> or nil'
