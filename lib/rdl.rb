require 'delegate'
require 'digest'
require 'set'
require 'parser/current'

module RDL
end

require 'rdl/config.rb'
def RDL.config
  yield(RDL::Config.instance)
end
require 'rdl/info.rb'

# Method/variable info table with kinds:
# For methods
#   :pre to array of precondition contracts
#   :post to array of postcondition contracts
#   :type to array of types
#   :source_location to [filename, linenumber] location of most recent definition
#   :typecheck - boolean that is true if method should be statically type checked
#   :otype to set of types that were observed at run time, where a type is a finite hash {:args => Array<Class>, :ret => Class, :block => %bool}
#   :context_types to array of [klass, meth, Type] - method types that exist only within this method. An icky hack to deal with Rails `params`.
# For variables
#   :type to type
$__rdl_info = RDL::Info.new

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

# Map from symbols to set of [class, method] pairs to type check when those symbols are rdl_do_typecheck'd
# (or the methods are defined, for the symbol :now)
$__rdl_to_typecheck = Hash.new
$__rdl_to_typecheck[:now] = Set.new

# List of contracts that should be applied to the next method definition
$__rdl_deferred = []

# Create switches to control whether wrapping happens and whether
# contracts are checked. These need to be created before rdl/wrap.rb
# is loaded.
require 'rdl/switch.rb'
$__rdl_wrap_switch = RDL::Switch.new
$__rdl_contract_switch = RDL::Switch.new

require 'rdl/types/type.rb'
require 'rdl/types/annotated_arg.rb'
require 'rdl/types/bot.rb'
require 'rdl/types/dependent_arg.rb'
require 'rdl/types/dots_query.rb'
require 'rdl/types/finite_hash.rb'
require 'rdl/types/generic.rb'
require 'rdl/types/intersection.rb'
require 'rdl/types/lexer.rex.rb'
require	'rdl/types/method.rb'
require 'rdl/types/singleton.rb'
require 'rdl/types/nominal.rb'
require	'rdl/types/non_null.rb'
require 'rdl/types/optional.rb'
require 'rdl/types/parser.tab.rb'
require 'rdl/types/structural.rb'
require 'rdl/types/top.rb'
require 'rdl/types/tuple.rb'
require 'rdl/types/type_query.rb'
require 'rdl/types/union.rb'
require 'rdl/types/var.rb'
require	'rdl/types/vararg.rb'
require 'rdl/types/wild_query.rb'

require 'rdl/contracts/contract.rb'
require 'rdl/contracts/and.rb'
require 'rdl/contracts/flat.rb'
require 'rdl/contracts/or.rb'
require 'rdl/contracts/proc.rb'

require 'rdl/util.rb'
require 'rdl/wrap.rb'
require 'rdl/query.rb'
require 'rdl/typecheck.rb'
#require_relative 'rdl/stats.rb'

$__rdl_parser = RDL::Type::Parser.new

# Map from file names to [digest, cache] where 2nd elt maps
#  :ast to the AST
#  :line_defs maps linenumber to AST for def at that line
$__rdl_ruby_parser_cache = Hash.new

# Some generally useful types; not really a big deal to do this since
# NominalTypes are cached, but these names are shorter to type
$__rdl_nil_type = RDL::Type::NominalType.new NilClass # actually creates singleton type
$__rdl_top_type = RDL::Type::TopType.new
$__rdl_bot_type = RDL::Type::BotType.new
$__rdl_object_type = RDL::Type::NominalType.new Object
$__rdl_true_type = RDL::Type::NominalType.new TrueClass # actually creates singleton type
$__rdl_false_type = RDL::Type::NominalType.new FalseClass # also singleton type
$__rdl_bool_type = RDL::Type::UnionType.new($__rdl_true_type, $__rdl_false_type)
$__rdl_fixnum_type = RDL::Type::NominalType.new Fixnum
$__rdl_bignum_type = RDL::Type::NominalType.new Bignum
$__rdl_float_type = RDL::Type::NominalType.new Float
$__rdl_complex_type = RDL::Type::NominalType.new Complex
$__rdl_rational_type = RDL::Type::NominalType.new Rational
$__rdl_integer_type = RDL::Type::UnionType.new($__rdl_fixnum_type, $__rdl_bignum_type)
$__rdl_numeric_type = RDL::Type::NominalType.new Numeric
$__rdl_string_type = RDL::Type::NominalType.new String
$__rdl_array_type = RDL::Type::NominalType.new Array
$__rdl_hash_type = RDL::Type::NominalType.new Hash
$__rdl_symbol_type = RDL::Type::NominalType.new Symbol
$__rdl_range_type = RDL::Type::NominalType.new Range
$__rdl_regexp_type = RDL::Type::NominalType.new Regexp
$__rdl_standard_error_type = RDL::Type::NominalType.new StandardError

# Hash from special type names to their values
$__rdl_special_types = {'%any' => $__rdl_top_type,
                        '%bot' => $__rdl_bot_type,
                        '%bool' => $__rdl_bool_type}
