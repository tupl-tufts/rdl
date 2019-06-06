require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'
require 'types/core'

class TestDynChecks < Minitest::Test
  extend RDL::Annotate

  RDL::Config.instance.check_comp_types = true
  RDL::Config.instance.rerun_comp_types = true

  type :bar1, "(Integer) -> ``RDL::Type::SingletonType.new(2)``", wrap: false
  
  type "(Integer) -> Integer", typecheck: :now, wrap: false
  def foo1(x)
    bar1(x)
  end

  ## First, a silly example. `bar1` (defined below) always returns 1, but its comp type says it always returns 2.
  ## `foo1` will type check properly, but the `bar1` error won't be caught until `foo` is called after type checking.
  def test_foo1_fail
    RDL::Util.silent_warnings { self.class.class_eval("def bar1(x) 1; end") } 
    assert_raises(RDL::Type::TypeError) { self.class.new(nil).foo1(1) }
  end

  ## If we redefine `bar1`, it should work.

  def test_foo1_pass
    RDL::Util.silent_warnings { self.class.class_eval("def bar1(x) 2; end") }
    assert self.class.new(nil).foo1(1)
  end


  ## Let's try again, with arrays.

  type :return_array, "() -> ``RDL::Type::TupleType.new(RDL::Type::SingletonType.new(0), RDL::Type::SingletonType.new(0), RDL::Type::SingletonType.new(0))``", wrap: false

  type "() -> Integer", typecheck: :now ## this type check should pass
  def calls_array
    a = return_array
    a[1]
  end

  def test_array_fail
    RDL::Util.silent_warnings{ self.class.class_eval("def return_array() [1,2,3]; end") }
    assert_raises(RDL::Type::TypeError) { self.class.new(nil).calls_array }
  end

  def test_array_pass
    RDL::Util.silent_warnings { self.class.class_eval("def return_array() [0,0,0]; end") }
    assert self.class.new(nil).calls_array
  end

  # Now for a slightly-but-not-really more realistic example, with a mock (very small) DB schema.

  class People
    extend RDL::Annotate
    @people_schema = RDL::Globals.parser.scan_str "#T { name: String, age: Integer }"
    type 'self.where', "(``raise 'Expected schema' unless @people_schema; @people_schema``) -> Integer", wrap: false
    def self.where(record)
      1 ## not actually looking anything up, so just return a dummy int
    end

    type :person_to_look_up, '() -> {name: String, age: 30}', wrap: false
    
    type "() -> Integer", wrap: false, typecheck: :now ## type checking will succeed the first time
    def calls_where
      self.class.where(person_to_look_up)
    end

    
  end

  def test_where_fail
    RDL::Util.silent_warnings{ People.class_eval("def person_to_look_up() {name: 'alice', age: '30'}; end") }
    assert_raises(RDL::Type::TypeError) { People.new.calls_where }
  end
    
  def test_where_pass
    RDL::Util.silent_warnings { People.class_eval("def person_to_look_up() {name: 'alice', age: 30}; end") }
    assert People.new.calls_where
  end


  # A test where the same method returns different types in different calls:

  def self.called_thrice_output(trec, targs)
    if targs[0].is_a?(RDL::Type::NominalType)
      RDL::Globals.types[:integer]
    elsif targs[0].is_a?(RDL::Type::SingletonType)
      RDL::Type::SingletonType.new(targs[0].val + 1)
    end
  end
  
  type :called_thrice, "(Integer) -> ``called_thrice_output(trec, targs)``", wrap: false


  type "(Integer) -> Integer", wrap: false, typecheck: :now
  def multi_caller(x)
    called_thrice(x) ## should have type Integer
    called_thrice(1) ## Should have type 2
    called_thrice(2) ## Should have type 3
  end

  def test_multi_pass
    RDL::Util.silent_warnings { self.class.class_eval "def called_thrice(x) x+1; end" } ## this will satisfy all call return types
    assert self.class.new(nil).multi_caller(0)
  end

  def test_multi_fail
    RDL::Util.silent_warnings { self.class.class_eval "def called_thrice(x) if (x==2) then x+2 else x+1 end; end" } ## silly
    assert_raises(RDL::Type::TypeError) { multi_caller(0) }
  end


  # Now to test op_asgn.

  type "(Integer) -> Integer", typecheck: :now, wrap: false
  def op_asgn_test(x)
    x += 1
  end

  def test_op_asgn
    assert self.class.new(nil).op_asgn_test(1)
    assert_raises(RDL::Type::TypeError) { self.class.new(nil).op_asgn_test(1.5) } ## Because `op_asgn_test` isn't wrapped, this should only raise error once :+ is called    
  end

  type "([1,2,3]) -> Integer", typecheck: :now, wrap: false
  def op_asgn_arr(arr)
    arr[1] += 1
  end

  def test_op_asgn_arr
    assert self.class.new(nil).op_asgn_arr([1,2,3])
    assert_raises(RDL::Type::TypeError) { self.class.new(nil).op_asgn_arr([1,42, 3]) } ## same issue as above
  end


  # Now, we'll test the re-running of computed types; this has been tested in all the examples above, but here we'll test that it fails correctly.

  class CompFail
    extend RDL::Annotate
    #@@compfail = 1
=begin
    def self.get_val()
      @@compfail
    end

    def self.set_val(v)
      @@compfail = v
    end

    type "(``if (get_val == 1) then RDL::Globals.types[:integer] else RDL::Type::UnionType.new(RDL::Globals.types[:integer], RDL::Globals.types[:string]) end``) -> Integer", wrap: false ## pathological type depending on @@compfail
    def bar(x)
      x
    end

    type "(Integer) -> Integer", typecheck: :now, wrap: false ## will type check fine
    def foo(x)
      bar(x)
    end
=end
  end

  def test_rerun_comp_type
    CompFail.class_eval {
      #RDL::Config.instance.check_comp_types = true
      #RDL::Config.instance.rerun_comp_types = true

      @@compfail = 1
      def self.get_val()
        @@compfail
      end

      def self.set_val(v)
        @@compfail = v
      end

      type "(``if (get_val == 1) then RDL::Globals.types[:integer] else RDL::Type::UnionType.new(RDL::Globals.types[:integer], RDL::Globals.types[:string]) end``) -> Integer", wrap: false ## pathological type depending on @@compfail
      def bar(x)
        x
      end

      RDL::Config.instance.check_comp_types = true
      RDL::Config.instance.rerun_comp_types = true
      
      type "(Integer) -> Integer", typecheck: :now, wrap: false ## will type check fine
      def foo2(x)
        bar(x)
      end
    }

    ## These are needed out here too due to weird orderings involving RDL.reset.
    assert CompFail.new.foo2(1) ## will run fine
    CompFail.set_val(2) ## change heap
    assert_raises(RDL::Type::TypeError) { CompFail.new.foo2(1) }

    RDL::Config.instance.check_comp_types = false
    RDL::Config.instance.rerun_comp_types = false
  end

  RDL::Config.instance.check_comp_types = false
  RDL::Config.instance.rerun_comp_types = false
  
  
end
