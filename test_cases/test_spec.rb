require 'minitest/autorun'
require_relative '../lib/rdl.rb'

# Tests Spec class and pre/post condition specification
class RDLTest < Minitest::Test
    
    # Test spec shortcut methods
    class Spec_A
        extend RDL
        
        # String or Fixnum -> Bool or String
        def foo( x )
            if(x.class == String) then
                return x
            end
            if(x == 101) then
                return nil
            end
            x.class == Fixnum
        end
        
        # Set up spec wrapper
        spec :foo do
        
            # Nonmutating case
            pre_cond("Pre2") { |x| (x.class == String || x.class == Fixnum) }
            # Mutating case TODO pre_task
            pre_cond("Pre1") { |x| if (x == 9001) then x = "Hello World!" end; true }
    
            # Nonmutating case
            post_cond("Post2") { |y, x| x.class == String || x.class == FalseClass || x.class == TrueClass }
            # Mutating case
            post_cond("Post1") { |y, x| if (x == "Hello World!") then x = 42 end; true }

            puts store_get_contract().rdoc_gen

        end

    end

    # Tests Preconditions and Postconditions added by Spec
    # Tests MethodCtc see test_ctc.rb and/or rdl_ctc.rb
    def test_prepost
        dsl = Spec_A.new
    
        # Test nonmutating truecase
        assert dsl.foo(5), "ERR 1.1 Precondition nonmutating truecase error"
    
        # Test nonmutating truecase
        assert dsl.foo("hi") == "hi", "ERR 1.2 Precondition nonmutating truecase error"
    
        # Test nonmutating pre_cond falsecase
        assert_raises RDL::ContractViolationException, "ERR 1.3 Precondition nonmutating falsecase error" do
            dsl.foo(dsl)
        end
    
        # Test nonmutating post_cond falsecase
        assert_raises RDL::ContractViolationException, "ERR 1.4 Postcondition nonmutating falsecase error" do
            dsl.foo(101)
        end
    
        # TODO add this feature
        # Test mutating pre_cond and post_cond
        # assert (dsl.foo(9001) == 42)
    
    end

    # TODO test other Spec features

end