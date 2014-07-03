require 'test/unit'
require 'rdl'

class Typesig_test < Test::Unit::TestCase
    include RDL::Type
    
    def setup
        @x = "String"
        @y = ""
    end
    
    def method_overload
        assert_equal("S",@x[0])
        assert_equal("Str",@x[0..2])
        assert_equal("St",@x[0,2])
    end
    
    def undefined_typesig
        assert_raise(error) {RDLTests::undefined_typesig}
    end
    
end

class RDLTests
	extend RDL
	
	typesig :foo, " () -> asdfghjkl"
	def foo
		return "hello world"
	end
	
    def undefined_typesig
        p "String"+( foo() )
    end
	
end
