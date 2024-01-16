# frozen_string_literal: true

require 'colorize'
require 'coderay'

require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'rdl'
require 'types/core'

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
      #response[:fetched] = Date.now
      #response[:created] = Date.new(2023, 11, 13)
      response[:fetched] = 1
      response[:created] = 1
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

  #############################################################################
  # Integration tests.                                                        #
  # These are for complex type system features in RDL that had to be modified  #
  # to work with path sensitivity.                                            #
  #############################################################################
  # Precise Strings.
  def MP_precise_str_1(x)
    if x.is_a? String
      x + " World"
    else
      x
    end
  end
  should_have_type :MP_precise_str_1, '("Hello" or Integer) -> Path{$0.is_a? String, True => "Hello World", False => Integer}'

  # Array splat.
  def MP_array_splat_1(array)
    if array[0].is_a? Integer
      [0, *array, 10]
    else
      ["hello", *array, "world"]
    end
  end
  should_have_type :MP_array_splat_1, '() -> nil'

  # irange. (e.g. 1..3)
  def MP_irange_1(int_or_string)
    if int_or_string.is_a? Integer
      [0..int_or_string]
    else
      ["a"..int_or_string]
    end
    
  end
  should_have_type :MP_irange_1, '(Integer or String) -> Path<$0.is_a? Integer, True => IRange<Integer>, False => IRange<String>>'

  # erange. (e.g. 1...3)
  def MP_erange_1(int_or_string)
    if int_or_string.is_a? Integer
      [0...int_or_string]
    else
      ["a"...int_or_string]
    end
    
  end
  should_have_type :MP_erange_1, '(Integer or String) -> Path<$0.is_a? Integer, True => ERange<Integer>, False => ERange<String>>'

  # Array assign. From test_array_types.rb:assign_test4
  def MP_array_assign_1(flag)
    array = [1, "hello", 2, "world"]
    if flag
      array[0] = 1
    else
      array[1] = "hello"
    end
  end
  should_have_type :MP_array_assign_1, '(%bool) -> Path<$0, True => 1, False => "hello">'

  def MP_case_stmt_type_test_1(x)
    case x
    when Integer
      1
    when String
      "Hello World"
    else
      []
    end
  end
  should_have_type :MP_case_stmt_type_test_1, '(%any) -> %any'

  # Case statements skip typechecking on impossible branches of typetests.
  def MP_case_stmt_type_test_2(x)
    # y :: Path<x.is_a? Integer, True => Integer, False => String>
    y = if x.is_a? Integer
      x + 1
    else 
      "Hello World"
    end

    # This should NEVER return "Error!" because Hash !<=_p y for any p
    case y
    when Hash
      "Error!"
    else
      true
    end
  end
  should_have_type :MP_case_stmt_type_test_2, '(%any) -> true'

  # This should have the same effect if the type test in question
  # came from an assignment.
  def MP_case_stmt_type_test_3(x)
    # y :: Path<x.is_a? Integer, True => Integer, False => String>
    y = "Hello World"
    if x.is_a? Integer
      y = x + 1
    end

    # This should NEVER return "Error!" because Hash !<=_p y for any p
    case y
    when Hash
      "Error!"
    else
      true
    end
  end
  should_have_type :MP_case_stmt_type_test_3, '(%any) -> true'


  # Refining the type of a generic.
  def MP_case_generic(bool)
    # Start with Array<String>
    obj = Array.new

    # Possibly turn it into Hash<String, String>
    if bool == true
      obj = Hash.new
    end

    case obj
    when Integer
      'Integer'
    when Hash
      'Hash'
    when Array
      'Array'
    end
  end
  #should_have_type :MP_case_generic, '() -> Path<$0, TrueClass => "Array", Else => "Hash">'
  should_have_type :MP_case_generic, '() -> Integer'

  # Side effects inside case statements.
  # (This is necessary to detect a bug that arose from 
  #  Talks user.rb#subscribed_talks)
  def MP_case_side_effect_1(x)
    ret = nil
    case x
    when "t1"
      ret = 1
    when "t2"
      ret = 2
    end

    ret
  end
  should_have_type :MP_case_side_effect_1, '() -> %any'

  def MP_case_side_effect_2(x)
    ret = nil

    # Returns Integer or String or Array
    case x
    when Integer
      ret = 1
    when String
      ret = "test"
    else
      ret = []
    end

    ret
  end
  should_have_type :MP_case_side_effect_2, '() -> %any'


  # Nested path conditions.
  def MP_nested_1(x, y)
    if x
      if y
        true
      else
        false
      end
    else
      if y
        false
      else
        true
      end
    end
  end
  should_have_type :MP_nested_1, '(%any, %any) -> %any'

  # Nested path conditions.
  def MP_nested_2(x, y)
    ret = nil
    if x
      ret = 42 if y
    end

    ret
  end
  should_have_type :MP_nested_2, '(%any, %any) -> %any'

  # Path conditions across blocks.
  def MP_block_1
    ret = nil

    arr = [1, 2, 3, 4, 5]
    arr.each do |n|
      ret = 5 if n == 5
    end

    ret
  end
  should_have_type :MP_block_1, '() -> %any'

  #############################################################################
  # Pattern tests.                                                            #
  # These are path-sensitive patterns I found in Ruby on Rails REST APIs.     #
  #############################################################################

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
  should_have_type :MP_pattern_1, '() -> nil'

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
  should_have_type :MP_pattern_2, '() -> nil'

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
  should_have_type :MP_pattern_3, '() -> nil'

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
  should_have_type :MP_pattern_4, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #5: Param existence.
  # ---------------------------------------------------------------------------
  def MP_pattern_5(params)
    if params[:name]
      return {success: "Success"}
    else
      return {failure: "Name required"}
    end
  end
  should_have_type :MP_pattern_5, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #6: Complex input validation.
  # ---------------------------------------------------------------------------
  def MP_pattern_6(params)
    if params[:student_ids].split(',').map(to_i).nil?
      return {failure: "Comma-separated list of IDs expected"}
    else
      return {success: "Success"}
    end
  end
  should_have_type :MP_pattern_6, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #7: Comparison between two params.
  # ---------------------------------------------------------------------------
  def MP_pattern_7(params)
    if params[:new_section_code] == params[:current_section_code]
      return {failure: "Section codes must be different"}
    else
      return {success: "Success"}
    end
  end
  should_have_type :MP_pattern_7, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #8: Ruby exception handling.
  # ---------------------------------------------------------------------------
  def MP_pattern_8
    return {success: "1 / 0 = #{1 / 0}"}
  rescue ZeroDivisionError => e
    return {failure: "Why would I expect this to work..."}
  end
  should_have_type :MP_pattern_8, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #9: Conditional status code.
  # ---------------------------------------------------------------------------
  def MP_pattern_9(success)
    return {message: "Message", status: (!!success)? 200 : 422}
  end
  should_have_type :MP_pattern_9, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #10: Site configuration.
  # Here, a property on a database object is used to determine the type of 
  # response. We will mock this by using an unknown class variable.
  # ---------------------------------------------------------------------------
  def MP_pattern_10
    raise ZeroDivisionError.new if !@level.enabled

    return {success: "Success"}
  end
  should_have_type :MP_pattern_10, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #11: Email verification.
  # We will not be mocking this here. We will leave it uninterpreted.
  # ---------------------------------------------------------------------------
  def MP_pattern_11(params)
    if EmailToken.confirm(params[:token])
      return {success: "Success"}
    else
      return {failure: "Failure"}
    end
  end
  should_have_type :MP_pattern_11, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #12: Request type.
  # We will leave this uninterpreted as well.
  # ---------------------------------------------------------------------------
  def MP_pattern_12
    if request.put?
      {status: 200}
    else
      {status: 500}
    end
  end
  should_have_type :MP_pattern_12, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #13: JSON merging.
  # ---------------------------------------------------------------------------
  def MP_pattern_13(params)
    json = {title: "Hello world",
            content: "This is a blog post"}

    new_json = if params[:include_time]
      json.merge({datetime: "2023-11-14 @ 11:47AM EST"})
    else
      json.merge({date: "2023-11-14"})
    end

    new_json
  end
  should_have_type :MP_pattern_13, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #14: At least one param must be present.
  # ---------------------------------------------------------------------------
  def MP_pattern_14(params)
    if params.select { |_, v| v.present? }.present?
      {success: "Success"}
    else 
      {failure: "At least one param is required"}
    end
  end
  should_have_type :MP_pattern_14, '() -> nil'

  # ---------------------------------------------------------------------------
  # Pattern #1: Session state.
  # ---------------------------------------------------------------------------
  #def MP_pattern_1
  #end
  #should_have_type :MP_pattern_1, '() -> nil'

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

  # NOTE(Mark): I tried for hours to write a test that covers "TEST_MARKER_3"
  #             in `typecheck.rb`. This is what ended up working. I'm not sure
  #             what this test does, but it seems to trigger an edge case
  #             in the typechecking logic that involves the combination
  #             of optional parameters with named parameters.
  def SP_tc_arg_types_fht_test(a1, a2 = 2, a3: 3, a4: 4)
    a1
  end
  def SP_tc_arg_types_fht
    SP_tc_arg_types_fht_test(1, a3: 1, a4: 2)
  end
  should_have_type :SP_tc_arg_types_fht, '() -> Integer', depends_on: [:SP_tc_arg_types_fht_test]

  # NOTE(Mark): Similar to tc_arg_types_fht, but includes a comp type.
  #             Activates "TEST_MARKER_4" in `typecheck.rb`.
  #             I Couldn't get this to work, so I'm commenting this out 
  #             for now (forever).
  # def SP_tc_bind_arg_types_fht_test(a1, a2 = 2, a3: 3, a4: 4)
  #   1
  # end
  # def self.tc_bind_arg_types_fht_test_output
  #   RDL::Globals.types[:integer]
  # end
  # RDL.type TestPathInfer, :SP_tc_bind_arg_types_fht_test, "(Integer, ?%any, a3: Integer, a4: Integer) -> ``tc_bind_arg_types_fht_test_output()``"
  # def SP_tc_bind_arg_types_fht
  #   SP_tc_bind_arg_types_fht_test(1, a3: 3, a4: 4)
  # end
  # should_have_type :SP_tc_bind_arg_types_fht, '() -> Integer'
  
end
