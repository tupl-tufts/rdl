require_relative '../../../../../lib/rdl.rb'
require 'set'

class Set
  extend RDL
  
  typesig(:add, "(Object)->Set")
end

a = Set.new(1..10)
a.add(12)
