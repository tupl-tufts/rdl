require 'minitest/autorun'
require_relative '../lib/rdl.rb'

class LeTest < Minitest::Test
  include RDL::Type

  def setup
    @tnil = NilType.new
    @ttop = TopType.new
    @tstring = NominalType.new "String"
    @tobject = NominalType.new "Object"
    @tbasicobject = NominalType.new "BasicObject"
    @tsymfoo = SymbolType.new :foo
    @tsym = NominalType.new Symbol
    @tarray = NominalType.new Array
    @tarraystring = GenericType.new(@tarray, @tstring)
    @tarrayobject = GenericType.new(@tarray, @tobject)
    @tarrayarraystring = GenericType.new(@tarray, @tarraystring)
    @tarrayarrayobject = GenericType.new(@tarray, @tarrayobject)
    @thash = NominalType.new Hash
    @thashstringstring = GenericType.new(@thash, @tstring, @tstring)
    @thashobjectobject = GenericType.new(@thash, @tobject, @tobject)
    @tstring_or_sym = UnionType.new(@tstring, @tsym)
    @tobject_and_basicobject = IntersectionType.new(@tobject, @tbasicobject)
  end
  
  def test_nil
    assert (@tnil <= @ttop)
    assert (@tnil <= @tstring)
    assert (@tnil <= @tobject)
    assert (@tnil <= @tbasicobject)
    assert (@tnil <= @tsymfoo)
    assert (not (@ttop <= @tnil))
    assert (not (@tstring <= @tnil))
    assert (not (@tobject <= @tnil))
    assert (not (@tbasicobject <= @tnil))
    assert (not (@tsymfoo <= @tnil))
  end

  def test_top
    assert (not (@ttop <= @tnil))
    assert (not (@ttop <= @tstring))
    assert (not (@ttop <= @tobject))
    assert (not (@ttop <= @tbasicobject))
    assert (not (@ttop <= @tsymfoo))
    assert (@ttop <= @ttop)
    assert (@tstring <= @ttop)
    assert (@tobject <= @ttop)
    assert (@tbasicobject <= @ttop)
    assert (@tsymfoo <= @ttop)
  end

  def test_sym
    assert (@tsym <= @tsym)
    assert (@tsymfoo <= @tsymfoo)
    assert (@tsymfoo <= @tsym)
    assert (not (@tsym <= @tsymfoo))
  end

  def test_nominal
    assert (@tstring <= @tstring)
    assert (@tsym <= @tsym)
    assert (not (@tstring <= @tsym))
    assert (not (@tsym <= @tstring))
    assert (@tstring <= @tobject)
    assert (@tstring <= @tbasicobject)
    assert (@tobject <= @tbasicobject)
    assert (not (@tobject <= @tstring))
    assert (not (@tbasicobject <= @tstring))
    assert (not (@tbasicobject <= @tobject))
  end

  def test_generic
    assert (@tarraystring <= @tarraystring)
    assert (@tarrayobject <= @tarrayobject)
    assert (@tarrayarraystring <= @tarrayarraystring)
    assert (@thashstringstring <= @thashstringstring)
    assert (@thashobjectobject <= @thashobjectobject)
    assert (not (@tarraystring <= @tarrayobject))
    assert (not (@tarrayobject <= @tarraystring))
    assert (not (@thashstringstring <= @thashobjectobject))
    assert (not (@thashobjectobject <= @thashstringstring))
  end

  def test_union
    assert (@tstring_or_sym <= @tobject)
    assert (not (@tobject <= @tstring_or_sym))
    assert (not (@tobject_and_basicobject <= @tobject))
    assert (@tobject <= @tobject_and_basicobject)
  end
  
end
