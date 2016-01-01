# In the top directory
# gem build rdl.gemspec
# gem install rdl-1.0.0.beta.1.gem

Gem::Specification.new do |s|
  s.name        = 'rdl'
  s.version     = '1.0.1.rc1'
  s.date        = '2016-01-01'
  s.summary     = 'Ruby type and contract system'
  s.description = <<-EOF
RDL is a gem that allows contracts (pre- and postconditions) to be added to methods.
Preconditions are checked at run time when the method is called, and
postconditions are checked at run time when the method returns.
RDL also includes extensive support for type contracts, which check the types of arguments and returns
when the method is called and when it returns, respectively.
EOF
  s.authors     = ['Jeffrey S. Foster', 'Brianna M. Ren', 'T. Stephen Strickland', 'Alexander T. Yu']
  s.email       = ['rdl-users@googlegroups.com']
  s.files       = `git ls-files`.split($/)
  s.executables << 'rdl_query'
  s.homepage    = 'https://github.com/plum-umd/rdl'
  s.license     = 'BSD-3-Clause'
  s.add_runtime_dependency 'require_all', '~> 1.3', '>= 1.3.3'
end
