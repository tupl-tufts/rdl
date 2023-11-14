# frozen_string_literal: true

require 'colorize'
require 'coderay'

require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'rdl'
require 'types/core'
#require 'debug/open'

# Testing Inference (constraint.rb)
class TestPathInfer < Minitest::Test
  extend RDL::Annotate

  def setup
    RDL.reset
    RDL::Config.instance.path_sensitive = :all
    RDL::Config.instance.number_mode = true
    RDL::Config.instance.use_precise_string = true

    # TODO: this will go away after config/reset
    RDL::Config.instance.use_precise_string = false
    RDL::Config.instance.log_levels[:inference] = :error
    # RDL::Config.instance.log_levels[:inference] = :debug

    RDL.readd_comp_types
    RDL.type_params :Hash, [:k, :v], :all? unless RDL::Globals.type_params['Hash']
    RDL.type_params :Array, [:t], :all? unless RDL::Globals.type_params['Array']
    # RDL.rdl_alias :Array, :size, :length
    RDL.nowrap :Range
    RDL.type_params 'RDL::Type::SingletonType', [:t], :satisfies? unless RDL::Globals.type_params['RDL::Type::SingletonType']
    RDL.type_params(:Range, [:t], nil, variance: [:+]) { |t| t.member?(self.begin) && t.member?(self.end) } unless RDL::Globals.type_params['Range']
    RDL.type :Range, :each, '() { (t) -> %any } -> self'
    RDL.type :Range, :each, '() -> Enumerator<t>'
    RDL.type :Integer, :to_s, '() -> String', wrap: false
    RDL.type :Kernel, 'self.puts', '(*[to_s : () -> String]) -> nil', wrap: false
    RDL.type :Kernel, :raise, '() -> %bot', wrap: false
    RDL.type :Kernel, :raise, '(String) -> %bot', wrap: false
    RDL.type :Kernel, :raise, '(Class, ?String, ?Array<String>) -> %bot', wrap: false
    RDL.type :Kernel, :raise, '(Exception, ?String, ?Array<String>) -> %bot', wrap: false
    RDL.type :Object, :===, '(%any other) -> %bool', wrap: false
    RDL.type :Object, :clone, '() -> self', wrap: false
    RDL.type :NilClass, :&, '(%any obj) -> false', wrap: false
    RDL.type :Hash, :merge, '(Hash<a, b>) -> Hash<k or a, b or v>', wrap: false

    ### Uncomment below to see test names. Useful for hanging tests.
    # puts "Start #{@NAME}"
  end

  # TODO: this will go away after config/reset
  def teardown
    RDL::Config.instance.number_mode = false
    RDL::Config.instance.use_unknown_types = false # set in do_infer
  end

  # convert a string to a method type
  def tm(typ)
    RDL::Globals.parser.scan_str('#Q ' + typ)
  end

  def infer_method_type(method, depends_on: [])
    depends_on.each { |m| RDL.infer self.class, m, time: :test }

    RDL.infer self.class, method, time: :test
    RDL.do_infer :test, render_report: false

    types = RDL::Globals.info.get 'TestPathInfer', method, :type
    assert types.length == 1, msg: 'Expected one solution for type'

    types[0]
  end

  def assert_type_equal(meth, expected_type, depends_on: [])
    typ = infer_method_type meth, depends_on: depends_on
    RDL::Type::VarType.no_print_XXX!

    if expected_type != typ.solution
      ast  = RDL::Typecheck.get_ast(self.class, meth)
      code = CodeRay.scan(ast.loc.expression.source, :ruby).term

      error_str  = 'Given'.yellow + ":\n  #{code}\n\n"
      error_str += 'Expected '.green + expected_type.to_s + "\n"
      error_str += 'Got      '.red + typ.solution.to_s
    end

    assert expected_type.match(typ.solution), error_str
  end

  def self.should_have_type(meth, typ, depends_on: [], shouldSkip: false)
    define_method "test_#{meth}" do
      if shouldSkip
        skip
      end
      assert_type_equal meth, tm(typ), depends_on: depends_on
    end
  end

  # SP = single path
  # MP = multiple paths

  # ----------------------------------------------------------------------------
  def MP_if1
    if true
      1
    else
      "Nope"
    end
  end
  should_have_type :MP_if1, '() -> Integer' # NOTE(Mark): how should we parse path types?

  def MP_if2
    if true || false
      1
    else
      "error"
    end
  end
  should_have_type :MP_if2, '() -> Integer'

  def MP_if3 # fix in _tc:when :and, :or
    if true && false
      1
    else
      "error"
    end
  end
  should_have_type :MP_if3, '() -> String'

  #def MP_if4(params)
  #  if params[:test]
  #    1
  #  else
  #    "error"
  #  end
  #end
  #should_have_type :MP_if4, '() -> Integer or String' # NOTE(Mark): how should we parse path types?

  def MP_if5
    x = 1
    if x + x + x == 3
      1
    else
      "error"
    end
  end
  should_have_type :MP_if5, '() -> Integer or String'

  def MP_if6
    x = 1
    if x + x + x == 3
      x = 1
    else
      x = "error"
    end

    return x
  end
  should_have_type :MP_if6, '() -> String'

  def MP_if7(x)
    response = {
      title: "Hello world",
      description: "This is a story"
    }

    if x + x = x == 3
      response[:fetched] = Date.now
      response[:created] = Date.new(2023, 11, 13)
    end

    return response
  end
  should_have_type :MP_if7, '(Integer) -> JSON<{}>'

  def MP_typetest_0(x)
    case x
    when Integer then true
    when String then false
    end
  end
  should_have_type :MP_typetest_0, '(%any) -> Integer or String'

  def MP_typetest_1(x)
    if x.is_a? Integer
      return x + x
    else
      return false
    end
  end
  should_have_type :MP_typetest_1, '(%any) -> Integer or String'

  def MP_typetest_2(x)
    y = 1
    if x.is_a? Integer
      y = "Hello world"
    end

    y
  end
  should_have_type :MP_typetest_2, '(%any) -> Integer or String'

  def MP_typetest_3(x)
    y = 1
    if x.is_a? Integer
      y = "Hello world"
    end

    if x.is_a? Integer # re-using path context
      y = y.upcase
    end

    y
  end
  should_have_type :MP_typetest_3, '(%any) -> Integer or String'

  def MP_flow1
    x = 1
    if x + x + x == 3
      x = "Hello world"
    end

    x = true

    return x
  end
  should_have_type :MP_flow1, '() -> true'


  # A variable *maybe* has a value
  #def MP_one_plus_one(x)
  #  if x
  #    y = 1 + 1
  #  end

  #  y
  #end

  #def MP_ret1(x)
  #  if x
  #    return 1
  #  end
  #end
  #should_have_type :MP_ret1, '() -> Integer or nil'

  #def MP_ret2(x)
  #  if x
  #    return 1
  #  else
  #    return "hello world"
  #  end
  #end
  #should_have_type :MP_ret2, '%any -> Integer or String'

  # ---------------------------------------------------------------------------
  # Pattern #1: Session state.
  # ---------------------------------------------------------------------------
  # Uses a `current_user` method defined by ActionController::Base.
  # We will mock it here.
  def current_user
    if x + x + x == 3
      5
    else
      nil
    end
  end
  def MP_pattern_1
    unless current_user
      return {}
    end

    return {status: "Success"}
  end
  should_have_type: MP_pattern_1, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #2: Database Error Propagation.
  # Here, we'll be mocking this with `Hash.has_value?`, since it has the same
  # type signature as `ActiveModel.save`.
  # ---------------------------------------------------------------------------
  def MP_pattern_2
    @obj = {}
    if @obj.has_value? 1
      return {failure: "fail"}
    else
      return {success: "success"}
    end
  end
  should_have_type: MP_pattern_2, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #3: Parameter size.
  # ---------------------------------------------------------------------------
  def MP_pattern_3(params)
    if params[:file].size > 1048576
      return {failure: "Asset too large"}
    else
      return {success: "Success"}
    end
  end
  should_have_type: MP_pattern_3, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #4: Param compared to database state.
  # ---------------------------------------------------------------------------
  def MP_pattern_4(params)
    if @level.name.downcase == params[:name].downcase
      return {failure: "Cannot change only the capitalization of the name"}
    else
      return {success: "Success"}
    end
  end
  should_have_type: MP_pattern_4, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #1: Session state.
  # ---------------------------------------------------------------------------
  #def MP_pattern_1
  #end
  #should_have_type: MP_pattern_1, '() -> nil'

  # ----------------------------------------------------------------------------

  def SP_return_two
    2
  end
  should_have_type :SP_return_two, '() -> Integer'

  def SP_return_two_plus_two
    2 + 2
  end
  should_have_type :SP_return_two_plus_two, '() -> Integer'

  def SP_plus_two(val)
    val + 2
  end
  should_have_type :SP_plus_two, '([ +: (Integer) -> a ]) -> b'

  def SP_print_it(val)
    puts val
  end
  should_have_type :SP_print_it, '([ to_s: () -> String ]) -> nil'

  def SP_return_hash
    { a: 1, b: 2, c: 3 }
  end
  should_have_type :SP_return_hash, '() -> { a: Integer, b: Integer, c: Integer }'

  def SP_return_hash_1
    { a: 1, b: 'b', c: :c }
  end
  should_have_type :SP_return_hash_1, '() -> { a: Integer, b: String, c: :c }'

  def SP_return_hash_val(val)
    { a: 1, b: 'b', c: val }
  end
  should_have_type :SP_return_hash_val, '(a) -> { a: Integer, b: String, c: a }'

  def SP_concatenate
    'Hello' + ' World!'
  end
  should_have_type :SP_concatenate, '() -> String'

  def SP_concatenate_1(val)
    'Hello, ' + val
  end
  should_have_type :SP_concatenate_1, '(String) -> String'

  def SP_repeat
    'a' * 5
  end
  should_have_type :SP_repeat, '() -> String'

  def SP_repeat_n(n)
    'a' * n
  end
  should_have_type :SP_repeat_n, '(Numeric) -> String', shouldSkip: true
  # skipped because of `number_mode`.

  # Note: The last type in the unions below comes from requiring `sorbet` (via
  #       requiring `parlour`) to render RBI files. The Structural -> Nominal
  #       heuristic picks up that this might be a valid type this case.
  def SP_note(reason, args, ast)
    Diagnostic.new :SP_note, reason, args, ast.loc.expression
  end
  should_have_type :SP_note, '(a, b, Parser::AST::Node or Parser::Source::Comment or T::Private::Methods::DeclarationBlock) -> Diagnostic'

  def SP_print_note(reason, args, ast)
    puts SP_note(reason, args, ast).render
  end
  should_have_type :SP_print_note, '(a, b, Parser::AST::Node or Parser::Source::Comment or T::Private::Methods::DeclarationBlock) -> nil',
                   depends_on: [:SP_note]

  def SP_compares_struct_with_parametric_method(options = {})
    options.merge({ "test" => 42 })
    42
  end
  should_have_type :SP_compares_struct_with_parametric_method, "(?[ merge: (Hash<String, Integer>) -> a]) -> Integer"
  # Not concerned with specific inferred types here.
  # Want to test that constraint resolution does not fail when using Hash#merge's type,
  # which includes type variables
  
end
