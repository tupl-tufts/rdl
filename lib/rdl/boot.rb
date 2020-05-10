require 'delegate'
require 'digest'
require 'set'
require 'parser/current'
#require 'method_source'
require 'colorize'

module RDL
end

require 'rdl/config.rb'
require 'rdl/logging.rb'
def RDL.config
  yield(RDL::Config.instance)
end
require 'rdl/info.rb'

module RDL::Globals
  FIXBIG_VERSIONS = ['>= 2.0.0', '< 2.4.0']

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

  # Map from symbols to set of [class, method] pairs to infer when those symbols are rdl_do_infer'd
  # (or the methods are defined, for the symbol :now)
  @to_infer = Hash.new
  @to_infer[:now] = Set.new

  ## List of [klass, method] pairs for which we have generated constraints.
  ## That is, if we look up RDL::Globals.info.get(klass, meth, :type), we will get a single MethodType
  ## composed of VarTypes with constraints.
  ## TODO: add inst/class vars to this list?
  @constrained_types = []

  # Map from symbols to Array<Proc> where the Procs are called when those symbols are rdl_do_typecheck'd
  @to_do_at = Hash.new

  # List of contracts that should be applied to the next method definition
  @deferred = []

  # List of method types that have a dependent type. Used to type check type-level code.
  @dep_types = []

  ## Hash mapping node object IDs (integers) to a list [tmeth, tmeth_old, tmeth_res, self_klass, trecv_old, targs_old], where: tmeth is a MethodType that is fully evaluated (i.e., no ComputedTypes) *and instantiated*, tmeth_old is the unevaluated method type (i.e., with ComputedTypes), tmeth_res is the result of evaluating tmeth_old *but not instantiating it*, self_klass is the class where the MethodType is defined, trecv_old was the receiver type used to evaluate tmeth_old, and targs_old is an Array of the argument types used to evaluate tmeth_old.
  @comp_type_map = Hash.new

  # Map from ActiveRecord table names (symbols) to their schema types, which should be a Table type
  @ar_db_schema = Hash.new

  # Map from Sequel table names (symbols) to their schema types, which should be a Table type
  @seq_db_schema = Hash.new

  # Array<[String, String]>, where each first string is a class name and each second one is a method name.
  # klass/method pairs here should not be inferred.
  @no_infer_meths = []

  # Array<String> of absolute file paths for files that should not be inferred.
  @no_infer_files = []

  # If non-nil, should be a symbol. Added, untyped methods will be tagged
  # with that symbol
  @infer_added = nil
end

class << RDL::Globals # add accessors and readers for module variables
  attr_accessor :info
  attr_accessor :wrapped_calls
  attr_accessor :type_params
  attr_reader :aliases
  attr_accessor :to_wrap
  attr_accessor :to_typecheck
  attr_accessor :to_infer
  attr_accessor :constrained_types
  attr_accessor :to_do_at
  attr_accessor :deferred
  attr_accessor :dep_types
  attr_accessor :comp_type_map
  attr_accessor :ar_db_schema
  attr_accessor :seq_db_schema
  attr_accessor :no_infer_meths
  attr_accessor :no_infer_files
  attr_accessor :infer_added
  attr_accessor :infer_added_filter
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
require 'rdl/types/bound_arg.rb'
require 'rdl/types/bot.rb'
require 'rdl/types/computed.rb'
require 'rdl/types/dependent_arg.rb'
require 'rdl/types/dots_query.rb'
require 'rdl/types/dynamic.rb'
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
require 'rdl/types/choice.rb' ## depends on var.rb
require	'rdl/types/vararg.rb'
require 'rdl/types/wild_query.rb'
require	'rdl/types/string.rb'

require 'rdl/contracts/contract.rb'
require 'rdl/contracts/and.rb'
require 'rdl/contracts/flat.rb'
require 'rdl/contracts/or.rb'
require 'rdl/contracts/proc.rb'

require 'rdl/util.rb'
require 'rdl/class_indexer.rb'
require 'rdl/wrap.rb'
require 'rdl/query.rb'
require 'rdl/typecheck.rb'
require 'rdl/constraint.rb'
require 'rdl/heuristics.rb'
#require_relative 'rdl/stats.rb'

class << RDL::Globals
  attr_reader :parser
  attr_accessor :parser_cache
  attr_reader :types
  attr_reader :special_types
end

module RDL
  def self.reset
    RDL::Globals.module_eval {
      RDL::Config.reset
      @info = RDL::Info.new
      @wrapped_calls = Hash.new 0
      @type_params = Hash.new
      @aliases = Hash.new
      @to_wrap = Set.new
      @to_typecheck = Hash.new
      @to_typecheck[:now] = Set.new
      @to_infer = Hash.new
      @to_infer[:now] = Set.new
      @constrained_types = []
      @to_do_at = Hash.new
      @deferred = []
      # @dep_types = []
      # @comp_type_map = Hash.new
      @ar_db_schema = Hash.new
      @seq_db_schema = Hash.new
      @no_infer_meths = []
      @no_infer_files = []
      @infer_added = nil

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
      @types[:dyn] = RDL::Type::DynamicType.new
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
                        '%bool' => @types[:bool],
                        '%dyn' => @types[:dyn]}
    }
  end
end

RDL.reset
require 'rdl/types/rdl_types.rb'
