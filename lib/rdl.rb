require 'set'
require 'require_all'
require_rel 'rdl/switch.rb'
require_rel 'rdl/types/*.rb'
require_rel 'rdl/contracts/*.rb'
require_rel 'rdl/wrap.rb'

$__rdl_contracts = Hash.new
$__rdl_to_wrap = Set.new

module RDL

end
