require 'test/unit'
require_relative '../lib/rdl.rb'

class Test1
	extend RDL
	
	x = "String"
	#x.byteslice(5,5)
	#x.byteslice(6)
	#x.byteslice(1..2)
	#x.byteslice(String)
	
end

class Test2
	extend RDL
	
	typesig :foo, " () -> asdfghjkl"
	def foo
		return "hello world"
	end
	
	p "String"+( foo() )
	
end
