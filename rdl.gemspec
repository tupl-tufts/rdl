# In the top directory 
# gem build rdl.gemspec
# gem install rdl-0.0.0.gem

Gem::Specification.new do |s|
  s.name        = 'rdl'
  s.version     = '0.0.0'
  s.date        = '2013-07-25'
  s.summary     = "Ruby DSL Library"
  s.description = "Ruby DSL Library"
  s.authors     = ['Stevie Strickland', 'Brianna Ren']
  s.email       = ['sstrickl@cs.umd.edu', 'bren@cs.umd.edu']
  s.files       = ["lib/rdl.rb", "lib/rdl/inspect.rb", "lib/rdl/infer.rb",
                   "lib/rdl/structure.rb"]
  s.files      += Dir['lib/type/*']
  s.homepage    =
    'https://github.com/plum-umd/rdl'
end
