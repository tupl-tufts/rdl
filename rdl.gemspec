# In the top directory
# gem build rdl.gemspec
# gem install rdl-1.0.0.beta.1.gem

Gem::Specification.new do |s|
  s.name        = 'rdl'
  s.version     = '2.2.0'
  s.date        = '2019-06-09'
  s.summary     = 'Ruby type and contract system'
  s.description = <<-EOF
RDL is a gem that adds types and contracts to Ruby. RDL includes extensive
support for specifying method types, which can either be enforced as
contracts or statically checked.
EOF
  s.authors     = ['Jeffrey S. Foster', 'Brianna M. Ren', 'T. Stephen Strickland', 'Alexander T. Yu', 'Milod Kazerounian', 'Sankha Narayan Guria']
  s.email       = ['rdl-users@googlegroups.com']
  s.files       = `git ls-files`.split($/)
  s.executables << 'rdl_query'
  s.homepage    = 'https://github.com/tupl-tufts/rdl'
  s.license     = 'BSD-3-Clause'
  s.add_runtime_dependency 'parser', '~>2.3', '>= 2.3.1.4'
  s.add_runtime_dependency 'sql-parser', '~>0.0.2'
  s.add_runtime_dependency 'method_source'
  s.add_runtime_dependency 'colorize', '~>0.8', '>= 0.8.1'
  s.add_development_dependency 'coderay', '~>1.2', '>= 1.1.2'
end
