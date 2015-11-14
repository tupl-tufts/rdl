require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

task :skel, [:cname,:prettyname] do |skel, varhash|
  kls = eval "#{varhash[:cname]}.new"
  mthds = kls.public_methods(false) + kls.private_methods(false) + kls.protected_methods(false)
  mname = "types/ruby-2.2.3/#{varhash[:prettyname]}.rb"
  touch mname
  mthds.sort.each{ |m|
    sh "echo \"  type '#{m}', '() -> '\" >> #{mname}"
  }
  sh "echo \"end\" >> #{mname}"
end

task :stat, [:fname,:outpath] do |stat,varhash|
  ruby "extras/rdlstat.rb #{varhash[:fname]} #{varhash[:outpath]}"
end

task :statrun, [:fname] do |statrun,varhash|
  ruby "#{varhash[:fname]}"
end