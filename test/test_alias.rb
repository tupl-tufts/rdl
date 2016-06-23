require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestAlias < Minitest::Test

  def test_alias_lookup
    self.class.class_eval {
      rdl_alias :foobar1, :foobar
      rdl_alias :foobar2, :foobar
      rdl_alias :foobar3, :foobar2
      rdl_alias :foobar4, :foobar3
      rdl_alias :foobar5, :foobar2
    }
    assert_equal :foobar, RDL::Wrap.resolve_alias(TestAlias, :foobar)
    assert_equal :foobar, RDL::Wrap.resolve_alias(TestAlias, :foobar1)
    assert_equal :foobar, RDL::Wrap.resolve_alias(TestAlias, :foobar2)
    assert_equal :foobar, RDL::Wrap.resolve_alias(TestAlias, :foobar3)
    assert_equal :foobar, RDL::Wrap.resolve_alias(TestAlias, :foobar4)
    assert_equal :foobar, RDL::Wrap.resolve_alias(TestAlias, :foobar5)
  end

  def test_basic_alias_contract
    self.class.class_eval {
      pre { |x| x > 0 }
      def m1(x) return x; end
      alias_method :m2, :m1
    }
    assert_equal 3, m2(3)
    assert_raises(RDL::Contract::ContractError) { m2(-1) }
    self.class.class_eval { alias m3 m1 }
    assert_equal 3, m3(3)
    assert_raises(RDL::Contract::ContractError) { m3(-1) }
  end

  def test_existing_alias_contract
    self.class.class_eval {
      def m4(x) return x; end
      alias_method :m5, :m4
      rdl_alias :m5, :m4
      pre(:m4) { |x| x > 0 }
    }
    assert_equal 3, m5(3)
    assert_raises(RDL::Contract::ContractError) { m5(-1) }

    def m6(x) return x; end
    self.class.class_eval {
      alias m7 m6
      rdl_alias :m7, :m6
      pre(:m6) { |x| x > 0 }
    }
    assert_equal 3, m7(3)
    assert_raises(RDL::Contract::ContractError) { m7(-1) }

    def m8(x) return x; end
    self.class.class_eval {
      alias_method :m9, :m8
      rdl_alias :m9, :m8
      alias_method :m10, :m9
      rdl_alias :m10, :m9
      pre(:m8) { |x| x > 0 }
    }
    assert_equal 3, m10(3)
    assert_raises(RDL::Contract::ContractError) { m10(-1) }
  end

end
