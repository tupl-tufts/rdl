require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class Typesig_test < Minitest::Test

  class Foo
  end
  
  def test_undefined_class
    skip "FAILING TEST"
    assert_raises(Object) do
      typesig(Foo, :foo, "() -> asdfghjkl")
    end
  end
end

