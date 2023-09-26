## Testing the machinery involved with OpenAPI typechecking. This means:
## - we should be able to infer Ruby on Rails code
## - we should be able to typecheck those Rails actions against an OpenAPI spec
##
##
## What's in scope for this test:
## - OpenAPI rewriting: Rails controllers are rewritten in a couple ways to
##                      make inference on them easier. The inference in this
##                      file relies on:
##                      1. Rails actions having a function argument injected:
##                         `params`.
##                      2. All calls to `render` (in `format` or outside of 
##                         `format`) are written to a local variable:
##                         `__RDL_rendered`. The end of the function body
##                         is then rewritten to `return __RDL_rendered`.
##                    
## - OpenAPI typechecking: This involves parsing an OpenAPI spec, converting
##                         the specified types into RDL types, resolving the
##                         endpoints in the OpenAPI spec to methods in Ruby,
##                         then actually calling `typecheck` on them.
##
## What's *out of scope* for this test:
## - Rails comp types: This means that all types in this file that would
##                     normally come from Rails comp types are manually
##                     specified here. Loading in Rails for this test would
##                     add too much complexity.
##
## - Rails routes: The OpenAPI typechecking code will call into Rails to
##                 resolve paths given in the OpenAPI spec. In this file
##                 we do not rely on Rails, and instead define a mocked `Rails`
##                 object that does exactly what we need it to do.


require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'
require 'types/core'
require 'coderay'

## String methods we need from Rails.
class String
    # Taken from Rails: 
    # activesupport/lib/active_support/inflector/methods.rb, line 68
    def camelize(uppercase_first_letter = true)
      string = self
      if uppercase_first_letter
        string = string.sub(/^[a-z\d]*/) { |match| match.capitalize }
      else
        string = string.sub(/^(?:(?=\b|[A-Z_])|\w)/) { |match| match.downcase }
      end
      string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub("/", "::")
    end

    # Taken from Rails:
    # activesupport/lib/active_support/inflector/methods.rb, line 277
    def constantize
        Object.const_get(self)
    end
end


# A mock class to house the types for `format.json` and `format.html`.
class Formatter
    def json(s)
        s
    end

    def html(s)
        s
    end
end

## A mock class to act as the superclass of `PostsController`.
class ApplicationController
end

## Mock
class Post
end

## Mock
class Comment
end

# These 2 functions will dynamically (un)define the `Rails` constant to mock
# it specifically for this test case.
def define_rails
    eval('
    module Rails
        def self.application
            Class.new do
                def routes
                    Class.new do
                        def recognize_path(path)
                            {"/posts.json" => {controller: "Posts",
                                             action: :index},
                             "/posts/id.json" => {controller: "Posts",
                                                  action: :show},
                             "/latest.json" => {controller: "Posts",
                                              action: :latest},
                             "/oldest.json" => {controller: "Posts",
                                              action: :oldest},
                             "/chronological.json" => {controller: "Posts",
                                                       action: :chronological},
                             "/search.json" => {controller: "Posts",
                                                action: :search}
                                                    
                            }[path]

                        end
                    end.new
                end
            end.new
        end
    end
    ', TOPLEVEL_BINDING)
end
def undefine_rails
    # ...
    Object.send(:remove_const, :Rails)
end


# This is a test controller for viewing blog posts.
# Each controller method renders json in a different way.
# The aim is to exercise the variety of options controllers
# have to render json, including using `format.json`,
# `render json: @var.as_json`, 
# `render json: @var.as_json(include: comments, except: [...])`,
# or just `render json: {k1: v1, k2: v2, ...}`.
class PostsController < ApplicationController

    # Type params for `render`.
    RDL.type_params :PostsController, [:t], :all? unless RDL::Globals::type_params['PostsController']

    # Simple type signature for `render`.
    # `render json: o  ~~>  o`
    RDL.type PostsController, 'render', '({ json: t, except: ?%any, include: ?%any }) -> t'
    def render(o)
        o.json
    end

    # Get list of all posts.
    # () -> Array<SlimPost>
    def index
        @posts = Post.all

        respond_to do |format|
            format.html
            format.json { 
                render json: RDL.type_cast(@posts.as_json(except: [:id, :created_at, :updated_at]),
                                           "Array<JSON<{ title: String, views: Integer, content: String }>>",
                                           force: true)
            }
        end
    end

    # Get a specific post with its comments.
    # (id: Integer) -> SlimPostWithComments
    def show
        @post = Post.find(params[:id])
        render json: RDL.type_cast(@post.as_json(include: {
                                       comments: {
                                           except: [:id, :created_at, :updated_at]
                                       }
                                   }),
                     "JSON<{title: String, views: Integer, content: String, comments: Array<JSON<{content: String }>> }>")

    end

    # Get the latest post.
    # () -> PostWithComments
    def latest
        @post = Post.last
        render json: 
            RDL.type_cast(@post.as_json(except: [:created_at, :updated_at], include: {comments: {except: [:created_at, :updated_at]}}),
                          "JSON<{id: Integer, title: String, views: Integer, content: String, comments: Array<JSON<{ id: Integer, content: String }>> }>")
    end

    # Get the oldest post.
    # () -> PostWithComments
    def oldest
        render json: 
            RDL.type_cast(Post.first.as_json(except: [:created_at, :updated_at], include: {comments: {except: [:created_at, :updated_at]}}),
                          "JSON<{ id: Integer, title: String, views: Integer, content: String, comments: Array<JSON<{ id: Integer, content: String }>> }>")
    end

    # Get list of all posts in chronological order.
    # () -> Array<Post>
    def chronological
        render json: RDL.type_cast(Post.all.as_json(except: [:created_at, :updated_at]),
                                   "Array<JSON<{ id: Integer, title: String, views: Integer, content: String }>>")
    end

    # Search for a specific post by title.
    # (title: string) -> {error: string} or {numFound: integer, posts: Array<Post>}
    def search
        @posts = Post.where title: params[:title]

        numFound = @posts.size

        if numFound == 0
            render json: RDL.type_cast({ error: "No matching blog posts found." }, "JSON<{ error: String }>")
        else
            render json: RDL.type_cast({ 
                numFound: numFound, 
                posts: @posts.as_json(except: [:created_at, :updated_at])
            }, "JSON<{ numFound: Integer, posts: Array<JSON<{ id: Integer, title: String, views: Integer, content: String }>> }>")
        end
    end

end


## Actually do the testing
class TestOpenAPI < Minitest::Test
    extend RDL::Annotate

    def setup
        RDL.reset
        RDL::Config.reset
        RDL::Config.instance.number_mode = true
        RDL::Config.instance.use_precise_string = false
        RDL::Config.instance.promote_widen = true
        RDL::Config.instance.strict_field_inference = true

        RDL.readd_comp_types
        RDL.type_params :Hash, [:k, :v], :all? unless RDL::Globals.type_params['Hash']
        RDL.type_params :Array, [:t], :all? unless RDL::Globals.type_params['Array']
        RDL.type_params :JSON, [:t], :all? unless RDL::Globals.type_params['JSON']

        define_rails()

        ##################################################################
        #                             Types                              #
        ##################################################################
        #RDL.type_params Post, []
        RDL.type Post, "self.all", "() -> Post"
        RDL.type Post, "self.find", "(Integer) -> Post"
        RDL.type Post, "self.first", "() -> Post"
        RDL.type Post, "self.last", "() -> Post"
        RDL.type Post, "self.where", "({ title: String }) -> Post"
        RDL.type Post, :as_json, "(?%any) -> String"
        RDL.type Post, :size, "() -> Integer"
        RDL.type PostsController, :respond_to, "() { (Formatter) -> %any } -> String"
        RDL.type Formatter, :html, "(?%any) -> %any"
        RDL.type Formatter, :json, "(%any)  -> %any"
        RDL.type Formatter, :json, "() { () -> %any } -> %any"



        ## Uncomment below to see test names. Useful for hanging tests.
        #puts "Start #{@NAME}"

    end

    def teardown
        undefine_rails()
        RDL.reset
    end

    # convert a string to a method type
    def tm(typ)
        RDL::Globals.parser.scan_str('#Q ' + typ)
    end

    def infer_method_type(klass, method, depends_on: [])
        depends_on.each { |m| RDL.infer klass, m, time: :test }

        RDL.infer klass, method, time: :test
        RDL.do_infer :test, render_report: false

        types = RDL::Globals.info.get klass.name.to_s, method, :type
        assert types, msg: 'No type found after inference'
        assert types.length == 1, msg: 'Expected one solution for type'

        types[0]
    end

    def assert_return_type_equal(klass, meth, expected_type, depends_on: [])
        typ = infer_method_type klass, meth, depends_on: depends_on
        RDL::Type::VarType.no_print_XXX!

        #require 'debug/open'
        if expected_type.ret != typ.solution.ret
            ast  = RDL::Typecheck.get_ast(klass, meth)
            code = CodeRay.scan(ast.loc.expression.source, :ruby).term

            error_str  = 'Given'.yellow + ":\n  #{code}\n\n"
            error_str += 'Expected type '.green + expected_type.ret.to_s + "\n"
            error_str += 'Got type      '.red + typ.solution.ret.to_s
        end

        assert expected_type.ret.match(typ.solution.ret), error_str
    end

    def self.should_have_type(klass, meth, typ, depends_on: [], shouldSkip: false)
        #require 'debug/open'
        define_method "test_#{meth}" do
        if shouldSkip
            skip
        end
        assert_return_type_equal klass, meth, tm(typ), depends_on: depends_on
        end
    end

    # ----------------------------------------------------------------------------



    # Test that Rails inference works.
    should_have_type PostsController, :index, "(nil) -> Array<JSON<{title: String, views: Integer, content: String}>>"
    should_have_type PostsController, :show, "({id: Integer}) -> JSON<{title: String, views: Integer, content: String, comments: Array<JSON<{content: String}>>}>"
    should_have_type PostsController, :latest, "(nil) -> JSON<{id: Integer, title: String, views: Integer, content: String, comments: Array<JSON<{ id: Integer, content: String }>> }>"
    should_have_type PostsController, :oldest, "(nil) -> JSON<{id: Integer, title: String, views: Integer, content: String, comments: Array<JSON<{ id: Integer, content: String }>> }>"
    should_have_type PostsController, :chronological, "(nil) -> Array<JSON<{ id: Integer, title: String, views: Integer, content: String }>>"
    should_have_type PostsController, :search, "(nil) -> JSON<{ numFound: Integer, posts: Array<JSON<{ id: Integer, title: String, views: Integer, content: String }>> }> or JSON<{ error: String }>"



    # Test that OpenAPI typechecking works.
    def test_openapi_tc
        # Step 1. Infer all the Rails actions
        RDL.infer PostsController, :index, time: :test
        RDL.infer PostsController, :show, time: :test
        RDL.infer PostsController, :latest, time: :test
        RDL.infer PostsController, :oldest, time: :test
        RDL.infer PostsController, :chronological, time: :test
        RDL.infer PostsController, :search, time: :test
        RDL.do_infer :test, render_report: false

        # Step 2. Typecheck against OpenAPI spec
        RDL.openapi('./test/test_openapi.json')
    end
end

