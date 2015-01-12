require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class Typesig_test < Minitest::Test
    extend RDL
    
    ###################################################
    
    def test_overload
        x = "String"
        assert_equal("S", x[0], "ERR 1.1 Typesig overload error")
        assert_equal("Str", x[0..2], "ERR 1.2 Typesig overload error")
        assert_equal("St", x[0,2], "ERR 1.3 Typesig overload error")
    end
    
    ###################################################
    
    def foo1
        return "hello world"
    end
    
    def test_err
    
        assert_raises ArgumentError, "ERR 2.1 Typesig unable to reject nonexistent type" do
            typesig(:foo1, " () -> notatype ")
        end
        
        #assert_raises RuntimeError, "ERR 2.2" do p "String"+(foo()) end
        
    end
    
    ##################################################

    def foo2(x)
        if(x == 5) then
            return "hi"
        end
        return x;
    end
    typesig(:foo2, "(Fixnum)->Fixnum")

    def test_typesig
        assert_equal(foo2(4), 4, "ERR 3.1 Typesig success case failed")
        assert_raises RuntimeError, "ERR 3.2 Typesig error case failed" do
            foo2(5)
        end
    end
    
    ##################################################

    # TODO case for typesig before method definition

    ##################################################

    # TODO named variable
    
    ##################################################

    # TODO RDL status

    ##################################################


end

