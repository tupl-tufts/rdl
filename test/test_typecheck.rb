require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TestTypecheck < Minitest::Test

  def test_fixnum_id
    self.class.class_eval {
      type "(Fixnum) -> Fixnum", typecheck_now: true
      def id_ff(x) return x; end
    }
    assert_equal 42, id_ff(42)

    skip "not implemented yet"
    self.class.class_eval {
      type "(Fixnum) -> Fixnum", typecheck_now: true
      def id_fs(x) return "42"; end
    }
    assert_raises(RDL::Typecheck::StaticTypeError) { id_fs(42) }
  end
end
