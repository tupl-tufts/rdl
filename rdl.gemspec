# In the top directory 
# gem build rdl.gemspec
# gem install rdl-0.0.0.gem

Gem::Specification.new do |s|
  s.name        = 'rdl'
  s.version     = '1.0.0.beta.1'
  s.date        = '2015-07-08'
  s.summary     = "Ruby type and contract system"
  s.description = "Add longer description..."
  s.authors     = ['University of Maryland, College Park'Jeff Foster', 'Stevie Strickland', 'Brianna Ren']
  s.email       = ['rdl-devel@googlegroups.com']
  s.files       = Dir["lib/**/*"]
  s.homepage    =
    'https://github.com/plum-umd/rdl'
  s.license     = "BSD-3-Clause"
end
