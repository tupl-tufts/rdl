require 'minitest/autorun'

class LibTest < Minitest::Test

    def setup
        
    end
    
    def foo1 (obj)
        return obj unless block_given?
    end
    
    def foo2 (&blk)
        return block_given?
    end
    
    def foo3()
        return block_given?
    end
    
    def test_block_order()
        assert(foo1 foo2 {p "hi"})
        assert(foo1 foo3 {p "hi"})
    end

end