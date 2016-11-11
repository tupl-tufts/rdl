# In the top directory
# gem build rdl.gemspec
# gem install rdl-1.0.0.beta.1.gem

Gem::Specification.new do |s|
  s.name        = 'rdl'
  s.version     = '2.0.1'
  s.date        = '2016-11-11'
  s.summary     = 'Ruby type and contract system'
  s.description = <<-EOF
RDL is a gem that adds types and contracts to Ruby. RDL includes extensive
support for specifying method types, which can either be enforced as
contracts or statically checked.
EOF
  s.authors     = ['Jeffrey S. Foster', 'Brianna M. Ren', 'T. Stephen Strickland', 'Alexander T. Yu', 'Milod Kazerounian']
  s.email       = ['rdl-users@googlegroups.com']
  s.files       = `git ls-files`.split($/)
  s.executables << 'rdl_query'
  s.homepage    = 'https://github.com/plum-umd/rdl'
  s.license     = 'BSD-3-Clause'
  s.add_runtime_dependency 'parser', '~>2.3', '>= 2.3.1.4'
end
