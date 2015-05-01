require 'rbconfig'
require 'shell'

rby = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
Shell.def_system_command :ruby, rby

def sandbox(fname)
    thisfile = File.dirname(File.expand_path(__FILE__))+"/#{fname}"
    process = Shell.new.transact do ruby(thisfile) end
    return process.to_s
end

log = File.new("dotest.log","w")
$stderr.reopen("dotest.log", "w")

line = "----------------------------------------------------------"

puts "#{line}\nUnit Testing RDL.\n#{line}"

Dir.foreach(Dir.pwd) { |fname|
    if fname =~ /^(test).*(.rb)$/ then
        rslt = sandbox(fname)
        pf = (rslt =~ /0 failures/)
        puts "#{pf ? '    ':'ERR '}\tTest %25s\t#{pf ? ' passed ':'<FAILED>'}\n\n" % "#{fname}"
        log.write("Test #{fname}\n\n\n"+rslt+"\n\n\n\n\n")
    end
}

log.close

puts "#{line}\nOutputting verbose results into dotest.log\n#{line}"
puts "Done.\n\n"

