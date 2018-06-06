require 'delegate'
require 'digest'
require 'set'
require 'parser/current'
require 'bigdecimal' ## needed for now to avoid "undefined constant" errors

module RDL
end

require 'rdl/config.rb'
def RDL.config
  yield(RDL::Config.instance)
end
require 'rdl/info.rb'

module RDL::Globals
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
  @info = RDL::Info.new

  # Map from full_method_name to number of times called when wrapped
  @wrapped_calls = Hash.new 0

  # Hash from class name to array of symbols that are the class's type parameters
  @type_params = Hash.new

  # Hash from class name to method name to its alias method name
  # class names are strings
  # method names are symbols
  @aliases = Hash.new

  # Set of [class, method] pairs to wrap.
  # class is a string
  # method is a symbol
  @to_wrap = Set.new

  # Map from symbols to set of [class, method] pairs to type check when those symbols are rdl_do_typecheck'd
  # (or the methods are defined, for the symbol :now)
  @to_typecheck = Hash.new
  @to_typecheck[:now] = Set.new

  # Map from symbols to Array<Proc> where the Procs are called when those symbols are rdl_do_typecheck'd
  @to_do_at = Hash.new

  # List of contracts that should be applied to the next method definition
  @deferred = []

  # List of method types that have a dependent type. Used to type check type-level code.
  @dep_types = []
end

class << RDL::Globals # add accessors and readers for module variables
  attr_accessor :info
  attr_accessor :wrapped_calls
  attr_accessor :type_params
  attr_reader :aliases
  attr_accessor :to_wrap
  attr_accessor :to_typecheck
  attr_accessor :to_do_at
  attr_accessor :deferred
  attr_accessor :dep_types
end

# Create switches to control whether wrapping happens and whether
# contracts are checked. These need to be created before rdl/wrap.rb
# is loaded.
require 'rdl/switch.rb'
module RDL::Globals
  @wrap_switch = RDL::Switch.new
  @contract_switch = RDL::Switch.new
end

class << RDL::Globals
  attr_reader :wrap_switch
  attr_reader :contract_switch
end

require 'rdl/types/type.rb'
require 'rdl/types/annotated_arg.rb'
require 'rdl/types/bot.rb'
require 'rdl/types/computed.rb'
require 'rdl/types/dependent_arg.rb'
require 'rdl/types/dots_query.rb'
require 'rdl/types/finite_hash.rb'
require 'rdl/types/generic.rb'
require 'rdl/types/intersection.rb'
require 'rdl/types/lexer.rex.rb'
require	'rdl/types/method.rb'
require 'rdl/types/singleton.rb'
require 'rdl/types/ast_node.rb'
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

module RDL::Globals
  FIXBIG_VERSIONS = ['>= 2.0.0', '< 2.4.0']
  # INTEGER_VERSIONS = '>= 2.4.0'

  @parser = RDL::Type::Parser.new

  # Map from file names to [digest, cache] where 2nd elt maps
  #  :ast to the AST
  #  :line_defs maps linenumber to AST for def at that line
  @parser_cache = Hash.new

  # Some generally useful types; not really a big deal to do this since
  # NominalTypes are cached, but these names are shorter to type
  @types = Hash.new
  @types[:nil] = RDL::Type::NominalType.new NilClass # actually creates singleton type
  @types[:top] = RDL::Type::TopType.new
  @types[:bot] = RDL::Type::BotType.new
  @types[:object] = RDL::Type::NominalType.new Object
  @types[:true] = RDL::Type::NominalType.new TrueClass # actually creates singleton type
  @types[:false] = RDL::Type::NominalType.new FalseClass # also singleton type
  @types[:bool] = RDL::Type::UnionType.new(@types[:true], @types[:false])
  @types[:float] = RDL::Type::NominalType.new Float
  @types[:complex] = RDL::Type::NominalType.new Complex
  @types[:rational] = RDL::Type::NominalType.new Rational
  @types[:integer] = RDL::Type::NominalType.new Integer
  @types[:numeric] = RDL::Type::NominalType.new Numeric
  @types[:string] = RDL::Type::NominalType.new String
  @types[:array] = RDL::Type::NominalType.new Array
  @types[:hash] = RDL::Type::NominalType.new Hash
  @types[:symbol] = RDL::Type::NominalType.new Symbol
  @types[:range] = RDL::Type::NominalType.new Range
  @types[:regexp] = RDL::Type::NominalType.new Regexp
  @types[:standard_error] = RDL::Type::NominalType.new StandardError
  @types[:proc] = RDL::Type::NominalType.new Proc

  # Hash from special type names to their values
  @special_types = {'%any' => @types[:top],
                    '%bot' => @types[:bot],
                    '%bool' => @types[:bool]}
end

class << RDL::Globals
  attr_reader :parser
  attr_accessor :parser_cache
  attr_reader :types
  attr_reader :special_types
end

require 'rdl/types/rdl_types.rb'
