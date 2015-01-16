require 'minitest/autorun'
require_relative '../lib/rdl.rb'

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
        assert ctc.check(true), "ERR 1.2 FlatCtc.check failed truecase"
        
        # Test :apply() truecase
        assert ctc.apply(true), "ERR 1.3 FlatCtc.apply failed truecase"
        
        # Test :check() errorcase
        # assert_raises Error ctc.check(false)
        assert_raises(RuntimeError, "ERR 1.4 FlatCtc.check failed errorcase") do
           ctc.check(false)
        end
        
        # Test :apply() falsecase
        assert !ctc.apply(false), "ERR 1.5 FlatCtc.check failed falsecase"
    end
    
    # Test Contract and OrdNCtc class methods
    def test_combinator
        ctc = RDL::FlatCtc.new &Proc.new{ |x| x}
        ctcT = RDL::FlatCtc.new &Proc.new{ |x| true}
        ctcF = RDL::FlatCtc.new &Proc.new{ |x| false}
        
        # Test :OR()
        ctc = ctc.OR(ctcF)
        assert_instance_of(RDL::OrCtc, ctc, "ERR 2.1 Contract.OR failed")
        
        # Test :AND()
        ctc = ctc.AND(ctcT)
        assert_instance_of(RDL::AndCtc, ctc, "ERR 2.2 Contract.AND failed")
        
        # Test <(x OR F) AND T>
        assert ctc.check(true), "ERR 2.3 Combinator Contract.check failed"
        
        assert_raises(RuntimeError, "ERR 2.4 Contract.check error case failed") do
            ctc.check(false)
        end
        
        # Test errorcase
        assert !ctc.apply(false), "ERR 2.5 Contract.apply falsecase failed"
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
    
    # Test method contract (typesig) functionality
    def test_methodctc
        # TODO
    end
    
    # Test block contracts
    def test_blockctc
        # TODO
        # Not yet implemented
    end
    
end