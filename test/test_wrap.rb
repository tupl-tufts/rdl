require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestWrap < Minitest::Test
  extend RDL::Annotate
  class C
    def foo_public(x)
      foo(x)
    end

    private

    def foo(x)
      x + 1
    end
  end

  def test_private_wrap
    RDL.type C, :foo, '(Integer) -> Integer'
    c = C.new

    assert_raises RDL::Type::TypeError do
      c.foo_public("1")
    end
  end

  class D
    def foo_public(x)
      foo(x)
    end

    protected

    def foo(x)
      x + 1
    end
  end

  def test_protected_wrap
    RDL.type D, :foo, '(Integer) -> Integer'
    d = D.new

    assert_raises RDL::Type::TypeError do
      d.foo_public("1")
    end
  end
end
