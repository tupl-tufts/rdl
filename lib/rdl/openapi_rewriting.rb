# This file is responsible for rewriting Ruby source code for
# REST API inference.
#
# Currently, we rewrite Ruby source code in 2 ways:
#
# 1. In Rails controller functions, we inject an optional
#    argument, `params`, that allows for per-endpoint parameter
#    inference.
#
# 2. In Rails controllers, all calls to `render` are rewritten.
#    The original call remains, but we also inject another identical
#    call, whose result is written to the local variable `__RDL_rendered`.
#    At the end of every Rails action, we inject `return __RDL_rendered`.
#    The translation looks like this:
#
#        respond_to do |format|
#            format.json { render json: @theme.errors, status: :unprocessable_entity }
#        end
#
#        ~~>
#        
#        respond_to do |format|
#          format.json { render json: @theme.errors, status: :unprocessable_entity }
#        end
#  *NEW* __RDL_rendered = render json: @theme.errors, status: :unprocessable_entity
#  *NEW* return __RDL_rendered
# 
#    
# The result of these two rewriting passes on Rails controllers leads to a 
# nice property: want to infer the input and output of a Rails controller?
# Simply infer its type normally. The `params` will be its input type,
# and the `render`'d output will be its return type.

module RDL::Typecheck
  class ParamsInjector < Parser::TreeRewriter

    def on_def(node)

      if @klass
        name, args_node, body_node = *node
        args = *args_node
        ap "ParamsInjector :: on_def -> #{name}(#{args_node})"

        rewritten_args = ""
        body_code = (body_node && body_node.location.expression.source) || ""

        if !RDL::Typecheck.is_controller_method(@klass, name) # not an endpoint
          ap "Not a controller method. No injection."
          if args_node.location.expression
            # If there were args defined, use them.
            rewritten_args = args_node.location.expression.source
          else
            # Otherwise, no args.
            rewritten_args = ""
          end
        elsif args_node.location.expression == nil # no args
          rewritten_args = "(params)"
        elsif args_node.location.expression.source.start_with?("|") # lambda
          ap "Lambda. No injection."
          rewritten_args = args_node.location.expression.source
        elsif args_node.children.none? {|node| node.children[0] == :params}# regular function (with parentheses). If it has at least one argument, it requires a comma to be added.
          args_node.children.each {|n| ap "Processing arg:"; ap n.children[0]}
          to_insert = if args_node.children.length > 0 then ", params" else "params" end
          rewritten_args = args_node.location.expression.source.insert(-2, to_insert)
          ap "Arguments defined but no params. Injected."
        else
          ap "Params already defined. No injection."
          rewritten_args = args_node.location.expression.source
        end

        # `rewritten_args` now contains the source code for args /with/ params.

        # Replace the class definition.
        align_replace(node.location.expression, @offset,
          "def #{name}#{rewritten_args} \n#{body_code}\nend")
      end
    end

    def on_class(node)
      name_ast, super_ast, body_ast = *node
      name_code = name_ast.location.expression.source
      super_code = (super_ast && super_ast.location.expression.source) || "Object"
      ap "on_class: #{name_ast} < #{super_ast}"

      klass = RDL::Typecheck.get_class_from_node(node)

      if RDL::Typecheck.is_controller(klass)
        # Rewrite the body
        body_code = ParamsInjector.rewrite(body_ast, klass=klass)
        align_replace(node.location.expression, @offset, "class #{name_code} < #{super_code}\n\n#{body_code}\nend")
      end

    end


    def initialize(offset, klass=nil)
      @offset = offset
      @klass = klass
    end

    def self.rewrite(ast, klass=nil)
      return unless ast != nil
      rewriter = ParamsInjector.new(ast.location.expression.begin_pos, klass)
      buffer = Parser::Source::Buffer.new("(ast)")
      buffer.source = ast.location.expression.source
      puts "Creating buffer of length: #{ast.location.expression.source.length}"
      rewriter.rewrite(buffer, ast)
    end
  end

  class RespondToInjector < Parser::TreeRewriter

    def on_block(node)
      ap "on_block: #{node}"
      
      # E.g. (send nil :respond_to)
      send_ast = node.children[0]
      return unless send_ast.children[1] == :respond_to

      # E.g. (args (arg :format))
      args_ast = node.children[1]
      return unless args_ast.children[0].children[0] == :format

      ap "We are definitely in a `respond_to` block."

      # E.g. (begin (send (lvar :format) :html) 
      #             (block (send (lvar :format) :json)
      #                    (args)
      #                    (send nil :render (hash (pair (sym :json) (ivar :@talk))))))
      body_ast = node.children[2]

      possible_calls = body_ast.children
      possible_calls = [body_ast] unless body_ast.type == :begin
      # Find calls that look like `format.json { ... }`
      format_json_block_calls = possible_calls.filter { |node|
          node.type == :block &&
          node.children[0].type == :send &&
          node.children[0].children[0].children[0] == :format &&
          node.children[0].children[1] == :json
      }

      # Find calls that look like `format.json`
      format_json_empty_calls = possible_calls.filter { |node|
          node.type == :send &&
          node.children[0].children[0] == :format &&
          node.children[1] == :json
      }

      ap "Identified #{format_json_block_calls.length} block calls to format.json:"
      ap format_json_block_calls

      ap ""
      ap "Identified #{format_json_empty_calls.length} empty calls to format.json:"
      ap format_json_empty_calls
      #return unless body_ast.children.

      to_inject = ""
      ap "Here lies the code and source location for each block call to render:"
      format_json_block_calls.each { |call_ast| 
          render_src = call_ast.children[2].location.expression.source
          ap call_ast.children[2].location.expression.source
          ap "@"
          ap call_ast.children[2].location.expression
          ap ""

          # Inject the following expression after the `respond_to` call:
          # return render ...

          #ap "about to insert `;__RDL_rendered = #{render_src};`"
          to_inject += ";__RDL_rendered = #{render_src};"
          #insert_after(node.location.expression, ";__RDL_rendered = #{render_src};")
          
      }

      # Rewrite the block.
      #block_code = RespondToInjector.rewrite(node)
      block_code = node.location.expression.source
      # Replace the block => block + `__RDL_rendered = ...`

      ap "about to replace block => #{block_code + to_inject}"
      align_replace(node.location.expression, @offset, block_code + to_inject)

    end

    def on_send(node)
        ap "on_send: #{node}"

        # Don't rewrite unless we're in a Rails controller
        return unless @klass

        #receiver, args = *node
        method_name = node.children[1]
        args = node.children[2]

        if method_name == :render #&& args[] receiver == :format && args[0] == :json 
            ap "on_send: Identified a call to format.json: #{node}"

            # Assign the result of this call to `__RDL_rendered`
            to_inject = "__RDL_rendered = "
            align_replace(node.location.expression, @offset, to_inject + node.location.expression.source)
        end
    end

    def on_def(node)
      ap "respond_to on_def: #{node.children[1]}"

      # Are we in a Rails controller class?
      if @klass
        ap "respond_to on_def: we are in Rails controller #{@klass}"

        
        # If so, rewrite the def.
        #def_keyword_ast = node.children[0]
        def_name_ast = node.children[0]
        def_args_ast = node.children[1]
        def_body_ast = node.children[2]

        ap "respond_to on_def: #{def_name_ast}(#{def_args_ast})"
        puts
        return if def_body_ast == nil

        
        # This will add the `__RDL_rendered = ...` # assignments.
        def_body_code = RespondToInjector.rewrite(def_body_ast, klass=@klass)

        # Determine the argument source code.
        def_args_code = (def_args_ast.location.expression && def_args_ast.location.expression.source) || ""

        # Then, inject `return __RDL_rendered` at the end of the 
        # method body.
        #insert_after(def_body_ast.location.expression, ";return __RDL_rendered;")
        align_replace(node.location.expression, @offset, 
          "def #{def_name_ast} #{def_args_code};__RDL_rendered = nil\n    #{def_body_code};return __RDL_rendered;\n  end\n\n")
          #def_code + ";return __RDL_rendered;")
      end
    end

    def on_return(node)
      # If we aren't returning a value,
      # we need to `return __RDL_rendered` to create a data flow
      # between any renders on this path and the function return.
      if node.children.length == 0
        align_replace(node.location.expression, @offset,
          ";return __RDL_rendered;")
      end
    end

    def on_class(node)
      name_ast, super_ast, body_ast = *node
      name_code = name_ast.location.expression.source
      super_code = (super_ast && super_ast.location.expression.source) || "Object"
      ap "on_class: #{name_ast} < #{super_ast}"

      klass = RDL::Typecheck.get_class_from_node(node)

      if RDL::Typecheck.is_controller(klass)
        # Rewrite the body
        body_code = RespondToInjector.rewrite(body_ast, klass=klass)
        align_replace(node.location.expression, @offset, "class #{name_code} < #{super_code}\n\n#{body_code}\nend")
      end

    end


    def initialize(offset, klass=nil)
      @offset = offset
      @klass = klass
    end

    def self.rewrite(ast, klass=nil)
      return unless ast != nil
      rewriter = RespondToInjector.new(ast.location.expression.begin_pos, klass)
      buffer = Parser::Source::Buffer.new("(ast)")
      buffer.source = ast.location.expression.source
      puts "Creating buffer of length: #{ast.location.expression.source.length}"
      rewriter.rewrite(buffer, ast)
    end

  end

  # Get the actual Ruby class from a class definition AST node.
  def self.get_class_from_node(class_node)
    name_node, zuper, body = *class_node
    name_nodee = *name_node
    name = name_nodee[1]

    begin
      return RDL::Util.to_class(name)
    rescue NameError
      return nil
    end
  end

  # Is the given Ruby class a Rails controller?
  def self.is_controller(klass)
    #ap "Klass: "
    #ap klass

    klass = klass.constantize if klass.is_a? String

    if klass && defined?(Rails) && (klass.respond_to? :superclass) && (klass.superclass.to_s == "ApplicationController")
      ap "#{klass.name} is a Rails controller"
      return true
    end
    return false
  end

  def self.is_controller_method(klass, meth)
    RDL::Typecheck.is_controller(klass) && klass.action_methods.include?(meth.to_s)
  end

end