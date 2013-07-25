require 'whenever'
require 'rdl'

module Kernel
  def implies(test)
    test ? yield : true
  end
end

class Whenever::JobList
  extend RDL

  spec :job_type do
    post_cond do |ret, name, str|
      args = str.gsub(/:\w+/).to_a
      args.include? ":task" and
        (class_eval do
           spec name do
             pre_cond do |task, options|
               options.keys.all? { |k| args.include? k }
             end
           end
         end; true)
    end
  end
end

a = Whenever::JobList.new ""
a.job_type :awesome, '/usr/local/bin/awesome :task :fun_level'

# fails because option not in string given to job_type
a.awesome "foo", :bar => "baz"

# fails because no :task option in string
a.job_type :futz, ''
