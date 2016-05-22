require 'set'
require 'delegate'
require 'require_all'

module RDL
end

require_relative 'rdl/config.rb'
def RDL.config
  yield(RDL::Config.instance)
end

# Hash from class name to method name to :pre/:post/:type to array of contracts
# class names are strings (because they need to be manipulated in case they include ::)
#  (class names may have Util.add_singleton_marker applied to them to indicate they're singleton classes.)
# method names are symbols
$__rdl_contracts = Hash.new

# Map from full_method_name to number of times called when wrapped
$__rdl_wrapped_calls = Hash.new 0

# Hash from class name to array of symbols that are the class's type parameters
$__rdl_type_params = Hash.new

# Hash from class name to method name to its alias method name
# class names are strings
# method names are symbols
$__rdl_aliases = Hash.new

# Set of [class, method] pairs to wrap.
# class is a string
# method is a symbol
$__rdl_to_wrap = Set.new

# Same as $__rdl_to_wrap, but records [class, method] pairs to type check
$__rdl_to_typecheck = Set.new

# List of contracts that should be applied to the next method definition
$__rdl_deferred = []

# Create switches to control whether wrapping happens and whether
# contracts are checked. These need to be created before rdl/wrap.rb
# is loaded.
require_rel 'rdl/switch.rb'
$__rdl_wrap_switch = RDL::Switch.new
$__rdl_contract_switch = RDL::Switch.new

require_rel 'rdl/types/*.rb'
require_rel 'rdl/contracts/*.rb'
require_rel 'rdl/util.rb'
require_rel 'rdl/wrap.rb'
require_rel 'rdl/query.rb'
require_rel 'rdl/typecheck.rb'
#require_rel 'rdl/stats.rb'

$__rdl_parser = RDL::Type::Parser.new

# Hash from special type names to their values
$__rdl_special_types = {'%any' => RDL::Type::TopType.new,
                        '%bool' => RDL::Type::UnionType.new(RDL::Type::NominalType.new(TrueClass),
                                                            RDL::Type::NominalType.new(FalseClass)) }
