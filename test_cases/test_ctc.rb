require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class Dummy
    def +(x)
        return false
    end
end

class MyError < Exception
end

# Tests RDL Contract System defined in rdl_ctc.rb
class Test_Ctc < Minitest::Test
    extend RDL

    # Test basic contract functionality of FlatCtc
    def test_flatctc
        prc = Proc.new{ |x| x}
        ctc = RDL::FlatCtc.new &prc
        
        # Test constructor
        assert_equal(prc, ctc.instance_variable_get(:@pred),
                     "ERR 1.1 FlatCtc failed to assign @pred")
        
        # Test :check() truecase
        assert ctc.check(true).nil?, "ERR 1.2 FlatCtc.check failed truecase"
        
        
        # Test :check() errorcase
        # assert_raises Error ctc.check(false)
        assert_raises(RDL::ContractViolationException, "ERR 1.3 FlatCtc.check failed errorcase") do
           ctc.check(false)
        end
        
    end
    
    # Test Contract and OrdNCtc class methods
    def test_combinator
        ctc = RDL::FlatCtc.new "Stub", &Proc.new{ |x| next x}
        ctcT = RDL::FlatCtc.new "TRUE", &Proc.new{ |x| next true}
        ctcF = RDL::FlatCtc.new "FALSE", &Proc.new{ |x| next false}
        
        # Test :OR()
        ctc = ctc.OR(ctcF)
        assert_instance_of(RDL::OrCtc, ctc, "ERR 2.1 Contract.OR failed")
        
        # Test :AND()
        ctc = ctc.AND(ctcT)
        assert_instance_of(RDL::AndCtc, ctc, "ERR 2.2 Contract.AND failed")
        
        # Test <(x OR F) AND T>
        assert ctc.check(true).nil?, "ERR 2.3 Combinator Contract.check failed"
        
        assert_raises(RDL::ContractViolationException, "ERR 2.4 Contract.check error case failed") do
            ctc.check(false)
        end
        
    end
    
    # Test contract label functionality
    def test_label
        ctc = RDL::FlatCtc.new &Proc.new{ |x| x}
        ctclbl1 = RDL::PreCtc.new ctc
        ctclbl2 = RDL::PostCtc.new ctclbl1
        
        # Test label recognition
        assert ctclbl2.is_a?(RDL::PostCtc), "ERR 3.1 PostCtc failed"
        assert ctclbl2.is_a?(RDL::PreCtc), "ERR 3.2 PreCtc failed"
        assert ctclbl2.is_a?(RDL::FlatCtc), "ERR 3.3 ContractLabel failed"
    end
    
    def rdl_foo(x)
        return x+1
    end
    
    # Test method contract (typesig) functionality
    def test_methodctc
        ctc = RDL::MethodCtc.new("rdl_foo", RDL::FlatCtc.new("MCtcPre") {|*args, &blk| !args[0].nil?}, RDL::FlatCtc.new("MCtcPost") {|*args, ret, &blk| args[0].class==ret.class})
        
        assert_equal(ctc.check(self, 2, prev:"", blame:0), 3, "ERR 4.1 MethodCtc truecase failed") # Tests 2+1
        assert_raises(RDL::ContractViolationException, "ERR 4.2 MethodCtc precondition check failed") do # Tests nil+1
            ctc.check(self, nil, prev:"", blame:0)
        end
        assert_raises(RDL::ContractViolationException, "ERR 4.3 MethodCtc postcondition check failed") do # Tests Dummy+1
            ctc.check(self, Dummy.new, prev:"", blame:0)
        end
    end
    
    def rdl_foobar(x, y, &blk)
        boo = Proc.new {|*args, &blk| p "BOO"; blk.call(y)}
        blk.call(x, &boo) # Calls the received block, which then calls boo, which then calls the block it receives
    end
    
    # Test block contracts
    #########################
    # SAMPLE CODE
    # def foo(*args, &blk)
    #   blk.call {|*argz, &blok| p "hi"; blok.call(5)}
    # end
    #
    # foo(){|*args, &blk| p "hello"; blk.call(){|*args| p args}}
    #########################
    # EXPECTED OUTPUT
    # > "hello"
    # > "hi"
    # > [5]
    #########################
    def test_blockctc
        bctc1 = RDL::RDLProc.new {|*args, ret, &blk| args[0].class==String} # the first arg &blk receives (x) must be a String
        bctc2 = RDL::RDLProc.new {|*args, ret, &blk| ret==Fixnum} # boo must return Fixnum
        bctc3 = RDL::RDLProc.new {|*args, ret, &blk| args[0].class==Fixnum} # the block boo receives has a first argument of type Fixnum (y must be Fixnum)
        bctc2.blkctc.add_blkctc(bctc3)
        bctc1.blkctc.add_blkctc(bctc2)
        
        ctc = RDL::MethodCtc.new("rdl_foobar", RDL::FlatCtc.new("BCtcPreStud") {|*args, &blk| !args[0].nil?}, RDL::FlatCtc.new("BCtcPostStud") {|*args, ret, &blk| true})
        ctc.add_blkctc(bctc1) # Comment out this line and everything works
        
        assert_raises(RDL::ContractViolationException, "ERR 5.1 BlockCtc one level failed") do
            ctc.check(self, 5, 5, prev:"", blame:0) {|x, &blk| blk.call(){|*args| Fixnum} }
        end
        
        assert_raises(RDL::ContractViolationException, "ERR 5.2 BlockCtc two levels failed") do
            ctc.check(self, "err", "err", prev:"", blame:0) {|x, &blok| blok.call(){|*args| "Hello World"}}
        end
        
        rslt = ctc.check(self, "err", 5, prev:"", blame:0) {|x, &blk| blk.call(){|*args| Fixnum} }
        assert(rslt,"ERR 5.3 BlockCtc truecase failed")
    end
    
end