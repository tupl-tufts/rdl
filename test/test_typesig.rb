require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class Typesig_test < Minitest::Test
    
    #####################################################
    
    class Overload_Tests
        extend RDL
        
        def initialize
            @x = "String"
            @y = ""
        end
        
        def method_overload
            assert_equal("S",@x[0])
            assert_equal("Str",@x[0..2])
            assert_equal("St",@x[0,2])
        end
        
        
        
    end
    
    ###################################################
    
    class Err_Tests
        extend RDL

        typesig( :foo, " () -> asdfghjkl ") {}
        def foo
            return "hello world"
        end
        
        def undefined_typesig
            #assert_raise(error) {p "String"+( foo() )}
        end
        
    end
    
    ###################################################
    
end

