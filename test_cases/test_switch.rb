require 'minitest/autorun'
require_relative '../lib/rdl.rb'

# Tests Master Switch recursion protection
# See master_switch.rb
class MasterSwitchTest < Minitest::Test
    include RDL
    
    def test_switch
        
        assert(@@master_switch, "ERR 1.1 Default switch error")
        assert(RDL.on?, "ERR 1.2 :on? error")
        RDL.turn_on
        assert(RDL.on?, "ERR 1.3 :turn_on oncase error")
        RDL.turn_off
        assert(!RDL.on?, "ERR 1.4 :turn_off oncase error")
        RDL.turn_off
        assert(!RDL.on?, "ERR 1.5 :turn_off offcase error")
        RDL.set_to(false)
        assert(!RDL.on?, "ERR 1.6 :set_to offcase error")
        RDL.ensure_off
        assert(!RDL.on?, "ERR 1.7 :ensure_off offcase error")
        RDL.turn_on
        assert(RDL.on?, "ERR 1.8 :turn_on offcase error")
        
    end

end