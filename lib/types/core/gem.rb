RDL.nowrap :Gem

RDL.type :Gem, 'self.bin_path', '(String name, ?String exec_name, *Gem::Requirement requirements) -> String'
RDL.type :Gem, 'self.binary_mode', '() -> String'
RDL.type :Gem, 'self.bindir', '(?String install_dir) -> String'
RDL.type :Gem, 'self.clear_default_specs', '() -> Hash'
RDL.type :Gem, 'self.clear_paths', '() -> nil'
RDL.type :Gem, 'self.config_file', '() -> String'
RDL.type :Gem, 'self.configuration', '() -> Gem::ConfigFile'
RDL.type :Gem, 'self.configuration=', '(%any) -> %any' #returns param
RDL.type :Gem, 'self.datadir', '(String gem_name) -> String or nil'
RDL.type :Gem, 'self.default_bindir', '() -> String or nil'
RDL.type :Gem, 'self.default_cert_path', '() -> String or nil'
RDL.type :Gem, 'self.default_dir', '() -> String or nil'
RDL.type :Gem, 'self.default_exec_format', '() -> String or nil'
RDL.type :Gem, 'self.default_key_path', '() -> String or nil'
RDL.type :Gem, 'self.default_path', '() -> String or nil'
RDL.type :Gem, 'self.default_rubygems_dirs', '() -> Array<String> or nil'
RDL.type :Gem, 'self.default_sources', '() -> Array<String> or nil'
