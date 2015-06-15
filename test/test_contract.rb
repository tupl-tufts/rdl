require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class ContractTest < Minitest::Test
  include RDL::Contract
  
  def test_flat
    pos = FlatContract.new("Positive") { |x| x > 0 }
    assert_equal pos.to_s, "Positive"
  end
end