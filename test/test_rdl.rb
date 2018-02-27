require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestRDL < Minitest::Test
  extend RDL::Annotate

  def setup
    RDL.reset
  end

  # Test wrapping with no types or contracts
  def test_wrap
    def m1(x) return x; end
    def m2(x) return x; end
    def m3(x) return x; end
    def m4(x) return x; end
    assert(not(RDL::Wrap.wrapped?(TestRDL, :m1)))
    assert(not(RDL::Wrap.wrapped?(TestRDL, :m2)))
    assert(not(RDL::Wrap.wrapped?(TestRDL, :m3)))
    assert(not(RDL::Wrap.wrapped?(TestRDL, :m4)))
    RDL::Wrap.wrap(TestRDL, :m1)
    RDL::Wrap.wrap("TestRDL", :m2)
    RDL::Wrap.wrap(:TestRDL, :m3)
    RDL::Wrap.wrap(TestRDL, "m4")
    assert(RDL::Wrap.wrapped?(TestRDL, :m1))
    assert(RDL::Wrap.wrapped?(TestRDL, :m2))
    assert(RDL::Wrap.wrapped?(TestRDL, :m3))
    assert(RDL::Wrap.wrapped?(TestRDL, :m4))
    assert_equal 3, m1(3)
    assert_equal 3, m2(3)
    assert_equal 3, m3(3)
    assert_equal 3, m4(3)
  end

  def test_process_pre_post_args
    ppos = RDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    assert_equal ["TestRDL", :m1, ppos], RDL::Wrap.process_pre_post_args(self.class, "C", TestRDL, :m1, ppos)
    assert_equal ["TestRDL", :m1, ppos], RDL::Wrap.process_pre_post_args(self.class, "C", TestRDL, "m1", ppos)
    assert_equal ["#{RDL::Util::SINGLETON_MARKER}TestRDL", :m1, ppos], RDL::Wrap.process_pre_post_args(self.class, "C", TestRDL, "self.m1", ppos)
    assert_equal ["TestRDL", :m1, ppos], RDL::Wrap.process_pre_post_args(self.class, "C", :m1, ppos)
    assert_equal ["TestRDL", nil, ppos], RDL::Wrap.process_pre_post_args(self.class, "C", ppos)
    klass1, meth1, c1 = RDL::Wrap.process_pre_post_args(self.class, "C", TestRDL, :m1) { |x| x > 0 }
    assert_equal ["TestRDL", :m1], [klass1, meth1]
    assert (c1.is_a? RDL::Contract::FlatContract)

    klass2, meth2, c2 = RDL::Wrap.process_pre_post_args(self.class, "C", :m1) { |x| x > 0 }
    assert_equal ["TestRDL", :m1], [klass2, meth2]
    assert (c2.is_a? RDL::Contract::FlatContract)

    klass3, meth3, c3 = RDL::Wrap.process_pre_post_args(self.class, "C") { |x| x > 0 }
    assert_equal ["TestRDL", nil], [klass3, meth3]
    assert (c3.is_a? RDL::Contract::FlatContract)

    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, "C") }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, "C", 42) }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, "C", 42) { |x| x > 0} }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, "C", ppos) { |x| x > 0 } }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, "C", :m1) }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, "C", TestRDL) }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, "C", TestRDL) { |x| x > 0 } }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, "C", TestRDL, ppos) }
    assert_raises(ArgumentError) { RDL::Wrap.process_pre_post_args(self.class, "C", TestRDL, :m1, ppos, 42) }
  end

  def test_pre_contract
    pos = RDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    def m5(x) return x; end
    RDL.pre TestRDL, :m5, pos
    assert_equal 3, m5(3)
    assert_raises(RDL::Contract::ContractError) { m5(-1) }
  end

  def test_post_contract
    neg = RDL::Contract::FlatContract.new("Negative") { |x| x < 0 }
    def m6(x) return 3; end
    RDL.post TestRDL, :m6, neg
    assert_raises(RDL::Contract::ContractError) { m6(42) }
  end

  def test_pre_post_contract
    pos = RDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    ppos = RDL::Contract::FlatContract.new("Positive") { |r, x| r > 0 }
    def m7(x) return x; end
    RDL.pre TestRDL, :m7, pos
    RDL.post TestRDL, :m7, ppos
    assert_equal 3, m7(3)
  end

  def test_and_contract
    pos = RDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    five = RDL::Contract::FlatContract.new("Five") { |x| x == 5 }
    gt = RDL::Contract::FlatContract.new("Greater Than 3") { |x| x > 3 }
    def m8(x) return x; end
    RDL.pre TestRDL, :m8, pos
    RDL.pre TestRDL, :m8, gt
    assert_equal 5, m8(5)
    assert_equal 4, m8(4)
    assert_raises(RDL::Contract::ContractError) { m8 3 }
    def m9(x) return x; end
    RDL.pre TestRDL, :m9, pos
    RDL.pre TestRDL, :m9, gt
    RDL.pre TestRDL, :m9, five
    assert_equal 5, m9(5)
    assert_raises(RDL::Contract::ContractError) { m9 4 }
    assert_raises(RDL::Contract::ContractError) { m9 3 }

    ppos = RDL::Contract::FlatContract.new("Positive") { |r, x| r > 0 }
    pfive = RDL::Contract::FlatContract.new("Five") { |r, x| r == 5 }
    pgt = RDL::Contract::FlatContract.new("Greater Than 3") { |r, x| r > 3 }
    def m10(x) return x; end
    RDL.post TestRDL, :m10, ppos
    RDL.post TestRDL, :m10, pgt
    assert_equal 5, m10(5)
    assert_equal 4, m10(4)
    assert_raises(RDL::Contract::ContractError) { m10 3 }
    def m11(x) return x; end
    RDL.post TestRDL, :m11, ppos
    RDL.post TestRDL, :m11, pgt
    RDL.post TestRDL, :m11, pfive
    assert_equal 5, m11(5)
    assert_raises(RDL::Contract::ContractError) { m11 4 }
    assert_raises(RDL::Contract::ContractError) { m11 3 }
  end

  def test_deferred_wrap
    pos = RDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    RDL.pre TestRDL, :m12, pos
    def m12(x) return x; end
    assert_equal 3, m12(3)
    assert_raises(RDL::Contract::ContractError) { m12(-1) }

    ppos = RDL::Contract::FlatContract.new("Positive") { |r, x| r > 0 }
    RDL.post TestRDL, :m13, ppos
    def m13(x) return x; end
    assert_equal 3, m13(3)
    assert_raises(RDL::Contract::ContractError) { m13(-1) }

    self.class.class_eval {
      pre(pos)
      def m14(x) return x; end
    }
    assert_equal 3, m14(3)
    assert_raises(RDL::Contract::ContractError) { m14(-1) }

    self.class.class_eval {
      pre { |x| x > 0 }
      def m15(x) return x; end
    }
    assert_equal 3, m15(3)
    assert_raises(RDL::Contract::ContractError) { m15(-1) }

    self.class.class_eval {
      pre { |x| x > 0 }
      post { |r, x| x > 0 }
      def m17(x) return x; end
    }
    assert_equal 3, m17(3)
    assert_raises(RDL::Contract::ContractError) { m17(-1) }

    self.class.class_eval {
      pre { |x| x > 0 }
      post { |r, x| x < 0 }
      def m18(x) return x; end
    }
    assert_raises(RDL::Contract::ContractError) { m18(-1) }

    self.class.class_eval {
      pre { |x| x > 0 }
      pre { |x| x < 5 }
      def m19(x) return x; end
    }
    assert_equal 3, m19(3)
    assert_raises(RDL::Contract::ContractError) { m19(6) }
    assert_raises(RDL::Contract::ContractError) { m19(-1) }

    assert_raises(RuntimeError) {
      self.class.class_eval <<-RUBY, __FILE__, __LINE__
  pre { |x| x > 0 }
  class Inner
    def m20(x)
      return x
    end
  end
RUBY
    }
  end

  def test_special_method_names
    self.class.class_eval {
      pre { |x| x > 0 }
      def [](x) return x end
    }
    assert_equal 3, self[3]
    assert_raises(RDL::Contract::ContractError) { self[-1] }
    self.class.class_eval {
      pre { |x| x > 0 }
      def foo?(x) return x end
    }
    assert_equal 3, foo?(3)
    assert_raises(RDL::Contract::ContractError) { foo?(-1) }
    self.class.class_eval {
      pre(:"bar!") { |x| x > 0 }
      def bar!(x) return x end
    }
    assert_equal 3, bar!(3)
    assert_raises(RDL::Contract::ContractError) { bar!(-1) }
  end

  def test_wrap_access_control
    def m20(x) return x; end
    def m21(x) return x; end
    def m22(x) return x; end
    self.class.class_eval { public(:m20) }
    self.class.class_eval { protected(:m21) }
    self.class.class_eval { private(:m22) }
    RDL::Wrap.wrap(TestRDL, :m20)
    RDL::Wrap.wrap(TestRDL, :m21)
    RDL::Wrap.wrap(TestRDL, :m22)
    assert (self.class.class_eval { public_method_defined? :m20 })
    assert (self.class.class_eval { protected_method_defined? :m21 })
    assert (self.class.class_eval { private_method_defined? :m22 })
  end

  def test_type_params
    self.class.class_eval "class TP1; extend RDL::Annotate; type_params [:t], :all? end"
    assert_equal [[:t], [:~], :all?], RDL::Wrap.get_type_params(TestRDL::TP1)
    self.class.class_eval "class TP2; extend RDL::Annotate; type_params([:t], nil) { |t| true } end"
    tp2 = RDL::Wrap.get_type_params(TestRDL::TP2)
    assert_equal [:t], tp2[0]
    assert_equal [:~], tp2[1]
    assert_raises(RuntimeError) { self.class.class_eval "class TP1; extend RDL::Annotate; type_params [:t], :all? end" }
    self.class.class_eval "class TP3; extend RDL::Annotate; type_params [:t, :u], :all? end"
    assert_equal [[:t, :u], [:~, :~], :all?], RDL::Wrap.get_type_params(TestRDL::TP3)

    self.class.class_eval "class TP4; extend RDL::Annotate; type_params [:t, :u, :v], :all?, variance: [:+, :-, :~] end"
    assert_equal [[:t, :u, :v], [:+, :-, :~], :all?], RDL::Wrap.get_type_params(TestRDL::TP4)
    assert_raises(RuntimeError) { self.class.class_eval "class TP5; extend RDL::Annotate; type_params([], :all?) { true } end" }
    assert_raises(RuntimeError) { self.class.class_eval "class TP6; extend RDL::Annotate; type_params [:t, :u], :all?, variance: [:+] end" }
    assert_raises(RuntimeError) { self.class.class_eval "class TP7; extend RDL::Annotate; type_params [:t, :u], :all?, variance: [:a, :b] end" }
    assert_raises(RuntimeError) { self.class.class_eval "class TP8; extend RDL::Annotate; type_params([:t], :all?) { |t| true } end" }
    assert_raises(RuntimeError) { self.class.class_eval "class TP8; extend RDL::Annotate; type_params [:t], 42 end" }
  end

  def test_wrap_new
    self.class.class_eval "class B; def initialize(x); @x = x end; def get(); return @x end end"
    RDL.pre("TestRDL::B", "self.new") { |x| x > 0 }
    assert_equal 3, TestRDL::B.new(3).get
    assert_raises(RDL::Contract::ContractError) { TestRDL::B.new(-3) }

    self.class.class_eval "class C; extend RDL::Annotate; pre { |x| x > 0 }; def initialize(x); @x = x end; def get(); return @x end end"
    assert_equal 3, TestRDL::C.new(3).get
    assert_raises(RDL::Contract::ContractError) { TestRDL::C.new(-3) }

    self.class.class_eval "class D; def get(); return @x end end"
    RDL.pre("TestRDL::D", "self.new") { |x| x > 0 }
    self.class.class_eval "class D; def initialize(x); @x = x end end"
    assert_equal 3, TestRDL::D.new(3).get
    assert_raises(RDL::Contract::ContractError) { TestRDL::D.new(-3) }

    skip "Can't defer contracts on new yet"
    RDL.
    pre("TestRDL::E", "self.new") { |x| x > 0 }
    self.class.class_eval "class E; def initialize(x); @x = x end end"
    assert (TestRDL::E.new(3))
    assert_raises(RDL::Contract::ContractError) { TestRDL::E.new(-3) }
  end

  def test_class_method
    pos = RDL::Contract::FlatContract.new("Positive") { |x| x > 0 }
    self.class.class_eval { def self.cm1(x) return x; end }
    RDL.pre TestRDL, "self.cm1", pos
    assert_equal 3, TestRDL.cm1(3)
    assert_raises(RDL::Contract::ContractError) { TestRDL.cm1(-1) }

    assert_raises(RuntimeError) { RDL.pre TestRDL, "TestRDL.cm1", pos }

    RDL.pre TestRDL, "self.cm2", pos
    self.class.class_eval { def self.cm2(x) return x; end }
    assert_equal 3, TestRDL.cm2(3)
    assert_raises(RDL::Contract::ContractError) { TestRDL.cm2(-1) }

    self.class.class_eval {
      pre { |x| x > 0 }
      def self.cm3(x) return x; end
    }
    assert_equal 3, TestRDL.cm3(3)
    assert_raises(RDL::Contract::ContractError) { TestRDL.cm3(-1) }
  end

  def test_cast
    obj1 = RDL.type_cast(3, RDL::Globals.types[:nil], force: true)
    assert (RDL::Globals.types[:nil].member? obj1)
    obj2 = RDL.type_cast(3, 'nil', force: true)
    assert (RDL::Globals.types[:nil].member? obj2)
    assert_raises(RuntimeError) { RDL.type_cast(3, RDL::Globals.types[:nil]) }
  end

  def test_pre_post_self
    self.class.class_eval {
      pre { |x| self.instance_of? TestRDL }
      post { |r, x| self.instance_of? TestRDL }
      def m23(x) return x; end
    }
    assert_equal 3, m23(3)
  end

  def test_nowrap
    RDL.pre(TestRDL, :nwrap1) { true }
    def nwrap1(x) return x; end
    assert(RDL::Wrap.wrapped?(TestRDL, :nwrap1))
    RDL.pre(TestRDL, :nwrap2, wrap: false) { true }
    def nwrap2(x) return x; end
    assert(not(RDL::Wrap.wrapped?(TestRDL, :nwrap2)))

    RDL.post(TestRDL, :nwrap3) { true }
    def nwrap3(x) return x; end
    assert(RDL::Wrap.wrapped?(TestRDL, :nwrap3))
    RDL.post(TestRDL, :nwrap4, wrap: false) { true }
    def nwrap4(x) return x; end
    assert(not(RDL::Wrap.wrapped?(TestRDL, :nwrap4)))

    RDL.type TestRDL, :nwrap5, "(Integer) -> Integer"
    def nwrap5(x) return x; end
    assert(RDL::Wrap.wrapped?(TestRDL, :nwrap5))
    RDL.type TestRDL, :nwrap6, "(Integer) -> Integer", wrap: false
    def nwrap6(x) return x; end
    assert(not(RDL::Wrap.wrapped?(TestRDL, :nwrap6)))

    self.class.class_eval {
      type "(Integer) -> Integer"
      def nwrap7(x) return x; end
    }
    assert(RDL::Wrap.wrapped?(TestRDL, :nwrap7))
    self.class.class_eval {
      type "(Integer) -> Integer", wrap: false
      def nwrap8(x) return x; end
    }
    assert(not(RDL::Wrap.wrapped?(TestRDL, :nwrap8)))
  end

  def test_var_type
    self.class.class_eval {
      var_type :@foo, "Integer"
      var_type :@@foo, "String"
      var_type :$foo, "Symbol"
    }
    assert_equal RDL::Globals.types[:integer], RDL::Globals.info.get(TestRDL, :@foo, :type)
    assert_equal RDL::Globals.types[:string], RDL::Globals.info.get(TestRDL, :@@foo, :type)
    assert_equal RDL::Globals.types[:symbol], RDL::Globals.info.get(RDL::Util::GLOBAL_NAME, :$foo, :type)
    assert_raises(RuntimeError) {
      self.class.class_eval { var_type :@foo, "String" }
    }
    assert_raises(RuntimeError) {
      self.class.class_eval { var_type :@@foo, "Integer" }
    }
    assert_raises(RuntimeError) {
      self.class.class_eval { var_type :Foo, "String" }
    }
    assert_raises(RuntimeError) {
      self.class.class_eval { var_type :$foo, "String" }
    }
  end

  def test_inconsistent
    self.class.class_eval {
      type "(Integer) -> Integer"
      pre { |x| true }
      def inconsistent1(y) return y; end
    }
  end

  def test_rdl_remove_type
    self.class.class_eval {
      type "() -> nil"
      def remove1() return 42; end
    }
    assert_raises(RDL::Type::TypeError) { remove1 }
    RDL.remove_type(self.class, :remove1)
    assert_equal 42, remove1 # shouldn't raise type error with contract removed
  end

  def test_version
    RDL.pre("TestRDL::TestVersion", "m1", version: Gem.ruby_version.to_s) { true }
    assert (RDL::Globals.info.has? "TestRDL::TestVersion", "m1", :pre)
    RDL.pre("TestRDL::TestVersion", "m2", version: Gem.ruby_version.bump.to_s) { true }
    assert !(RDL::Globals.info.has? "TestRDL::TestVersion", "m2", :pre)
    RDL.post("TestRDL::TestVersion", "m3", version: Gem.ruby_version.to_s) { true }
    assert (RDL::Globals.info.has? "TestRDL::TestVersion", "m3", :post)
    RDL.
    pre("TestRDL::TestVersion", "m4", version: Gem.ruby_version.bump.to_s) { true }
    assert !(RDL::Globals.info.has? "TestRDL::TestVersion", "m4", :post)
  end

  def test_pre_rdl_annotate_contract
    self.class.class_eval <<-RUBY, __FILE__, __LINE__
      class TestRDLAnnotate
        extend RDL::RDLAnnotate

        rdl_pre { |x| x > 0 }
        def m1(x) return x; end

        rdl_post { |x| x < 0 }
        def m2(x) return 3; end

        rdl_type '(Integer) -> Integer'
        def m3(x) return x; end
    end
RUBY
    assert_equal 3, TestRDLAnnotate.new.m1(3)
    assert_raises(RDL::Contract::ContractError) { TestRDLAnnotate.new.m1(-1) }
    assert_raises(RDL::Contract::ContractError) { TestRDLAnnotate.new.m2(42) }
    assert_raises(RDL::Type::TypeError) { TestRDLAnnotate.new.m3('one') }
  end

  class TC0
    def foo
      's'
    end

    def bar
      0
    end
  end

  class TC1 < TC0
    def foo
      's'
    end

    def bar
      0
    end
  end

  def test_wrap_inheritance
    RDL.type TC0, :foo, '() -> Integer', typecheck: :call
    RDL.type TC0, :bar, '() -> Integer', typecheck: :call
    RDL.type TC1, :foo, '() -> String', typecheck: :call
    RDL.type TC1, :bar, '() -> String', typecheck: :call
    assert_raises(RDL::Typecheck::StaticTypeError) { TC0.new.foo }
    assert_equal 0, TC0.new.bar
    assert_equal 's', TC1.new.foo
    assert_raises(RDL::Typecheck::StaticTypeError) { TC1.new.bar }
  end

end
