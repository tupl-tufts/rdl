require 'set'
require 'require_all'

module RDL
end

# Hash from class name to method name to :pre/:post/:type to array of contracts
# class names are strings (because they need to be manipulated in case they include ::)
# method names are symbols
$__rdl_contracts = Hash.new

# Set of [class, method] pairs to wrap.
# class is a string
# method is a symbol
$__rdl_to_wrap = Set.new

# List of contracts that should be applied to the next method definition
$__rdl_deferred = []

require_rel 'rdl/switch.rb'
require_rel 'rdl/types/*.rb'
require_rel 'rdl/contracts/*.rb'
require_rel 'rdl/util.rb'
require_rel 'rdl/wrap.rb'

$__rdl_parser = RDL::Type::Parser.new
