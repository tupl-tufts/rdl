require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class TypeContractTest < Minitest::Test
  include RDL::Type
  include RDL::Contract
  
  def test_flat
    tnil = NilType.new
    cnil = tnil.to_contract
    assert (cnil.check nil)
    assert_raises(TypeException) { cnil.check true }
    tfixnum = NominalType.new :Fixnum
    cfixnum = tfixnum.to_contract
    assert (cfixnum.check 42)
    assert (cfixnum.check nil)
    assert_raises(TypeException) { cfixnum.check "42" }
  end
end