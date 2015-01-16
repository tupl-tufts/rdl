require 'rdoc'
require 'erb'
require 'fileutils'
require 'pathname'
require 'pp'
require 'tempfile'
require 'tmpdir'

require 'rdoc'
require_relative '../lib/rdl.rb'

=begin
class String
    extend RDL
    
    typesig :size, "()->Fixnum"
    typesig :bytesize, "()->Fixnum"
    
    rdocTypesigFor(String);
end
=end

require_relative '../types/ruby-2.1/core/string.rb'
class TestRDLRDoc
    extend RDL
    rdocTypesigFor(String)
end
