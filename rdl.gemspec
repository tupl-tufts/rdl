# In the top directory
# gem build rdl.gemspec
# gem install rdl-1.0.0.beta.1.gem

Gem::Specification.new do |s|
  s.name        = 'rdl'
  s.version     = '1.0.0.beta.1'
  s.date        = '2015-12-15'
  s.summary     = "Ruby type and contract system"
  s.description = "Add preconditions, postconditions, and type annotations to your Ruby program"
  s.authors     = ['University of Maryland, College Park']
  s.email       = ['rdl-devel@googlegroups.com']
  s.files       = Dir["lib/**/*", "types/**/*"]
  s.homepage    = 'https://github.com/plum-umd/rdl'
  s.license     = "BSD-3-Clause"
end
