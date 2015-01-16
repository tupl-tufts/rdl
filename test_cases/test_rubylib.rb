require 'minitest/autorun'

# Tests basic Ruby library functions as used in RDL
class LibTest < Minitest::Test
    
    def foo1 (obj)
        return obj unless block_given?
    end
    
    def foo2 (&blk)
        return block_given?
    end
    
    def foo3()
        return block_given?
    end
    
    # Tests unparenthesized block passing
    def test_block_order()
        assert((foo1 foo2 {p "hi"}), "ERR 1.1 Unparenthesized block passing error")
        assert((foo1 foo3 {p "hi"}), "ERR 1.2 Unparenthesized block (expecting block arg) passing error")
    end

end