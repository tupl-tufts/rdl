require 'minitest/autorun'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rdl'
RDL.reset

class ActionController
end

class PostsController < ActionController
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
                            {"/posts.json" => {controller: PostsController,
                                             action: :index},
                             "/posts/{id}.json" => {controller: PostsController,
                                                  action: :show},
                             "/latest.json" => {controller: PostsController,
                                              action: :latest},
                             "/oldest.json" => {controller: PostsController,
                                              action: :oldest},
                             "" => {}}[path]
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

class TestOpenAPI < Minitest::Test
    extend RDL::Annotate

    def setup
        RDL.reset
        RDL::Config.instance.number_mode = true
        RDL::Config.instance.use_precise_string = false
        RDL::Config.instance.promote_widen = true
        RDL::Config.instance.strict_field_inference = true

        RDL.readd_comp_types

        define_rails()
        #Rails = 

    end

    def teardown
        undefine_rails()
    end
end