require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestTypecheck < Minitest::Test

  def test_fixnum_id
    self.class.class_eval {
      type "(Fixnum) -> Fixnum", typecheck_now: true
      def id_ff(x) x; end
    }
    assert_equal 42, id_ff(42)

    assert_raises(RDL::Typecheck::StaticTypeError) {
      self.class.class_eval {
        type "(Fixnum) -> Fixnum", typecheck_now: true
        def id_fs(x) "42"; end
      }
    }

    skip "not implemented yet"
    self.class.class_eval {
      type "(Fixnum) -> Fixnum", typecheck_now: true
      def id_fs(x) "42"; end
    }
    assert_raises(RDL::Typecheck::StaticTypeError) { id_fs(42) }

    self.class.class_eval {
      type "(Fixnum, Fixnum) -> Fixnum", typecheck_now: true
      def add(x, y) x+y; end
    }
    assert_equal 42, id_ff(42)
  end
end
