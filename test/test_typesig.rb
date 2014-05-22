require 'test/unit'
require 'rdl'

class Test1
	extend RDL
	
	"String".byteslice(5,5)
	"String".byteslice(6)
	"String".byteslice(1..2)
	#"String".byteslice(String)
end