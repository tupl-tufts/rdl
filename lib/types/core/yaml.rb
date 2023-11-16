RDL.nowrap :YAML
RDL.nowrap :Psych

RDL.type :YAML, 'self.load_file', '(String) -> Array<String> or Hash<Symbol, String>'
RDL.type :YAML, 'self.load', '(String) -> Array<String> or Hash<Symbol, String>'

RDL.type :Psych, 'self.load_file', '(String) -> Array<String>'
RDL.type :Psych, 'self.load', '(String) -> Array<String>'
