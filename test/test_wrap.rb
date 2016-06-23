require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'

class TestWrap < Minitest::Test
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
    type C, :foo, '(Fixnum) -> Fixnum'
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
    type D, :foo, '(Fixnum) -> Fixnum'
    d = D.new

    assert_raises RDL::Type::TypeError do
      d.foo_public("1")
    end
  end
end
