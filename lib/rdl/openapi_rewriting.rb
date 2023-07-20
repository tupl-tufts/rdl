# This file is responsible for rewriting Ruby source code for
# REST API inference.
#
# Currently, we rewrite Ruby source code in 2 ways:
#
# 1. In Rails controller functions, we inject an optional
#    argument, `params`, that allows for per-endpoint parameter
#    inference.
#
# 2. In Rails controllers, we inject hidden class fields,
#    each named `@__{FUNCTION}_render{NUM}`. `{FUNCTION}` corresponds
#    to the name of the controller function. These are injected
#    for each call to `respond_to { format.json }`, and is used
#    to infer the actual JSON type that is being rendered at the
#    endpoint. The translation looks like this:
#
#        respond_to do |format|
#            format.json { render json: @theme.errors, status: :unprocessable_entity }
#        end
#
#        ~~>
#        
#        respond_to do |format|
#          @__create_render1 = render json: @theme.errors, status: :unprocessable_entity
#          format.json { render json: @theme.errors, status: :unprocessable_entity }
#        end
# 
#    We can then access the JSON type being rendered through this class field.

module RDL::Typecheck
  class ParamsInjector < Parser::TreeRewriter
    
    # On an function argument definition, inject the `params` argument.
    # This will only be called on controller methods.
    def on_args(node)
      #ap "on_args:"
      #ap node
      #ap "args.location"
      #ap node.location
      #print()

      ap "Number of args being defined: #{node.children.length}"

      ap "Args: #{node.location.expression.source}" unless node.location.expression == nil

      # If the source doesn't exist, then just add "(params)" and call it a day.
      if node.location.expression == nil
        #insert_after(node.location.expression, "(params={})")
        # ^ this doesn't work either
        ap "No params defined. Injected earlier."
        return
      elsif node.location.expression.source.start_with?("|") # lambda
        ap "Lambda. No injection."
        return
      elsif node.children.none? {|node| node.children[0] == :params}# regular function, with one or more arguments. Requires a comma to be added
        node.children.each {|n| ap "Processing arg:"; ap n.children[0]}
        replace(node.location.expression, node.location.expression.source.insert(-2, ", params=nil"))
        ap "Arguments defined but no params. Injected."
      else
        ap "Params already defined. No injection."
      end


      # If the source starts with "|", don't inject params (this is for a lambda)


      #return unless node.location.expression != nil

      #ap "Expression: #{node.location.expression.source}"


      #insert_after(node.location.expression, ", params: {}") unless node.location.expression == nil
      #replace(node.location.expression, ", params: {}")# unless node.location.expression == nil
      ap "Injection successful! @ #{node.location.expression}"# unless node.location.expression == nil
    end

    def on_def(node)
      name, args_node, body_node = *node

      args = *args_node
      #puts ""
      #puts ""
      #ap "on_def: #{name}(#{args})"
      #ap "node.location"
      #ap node.location
      #ap "node:"
      #ap node
      #ap node.children[0].location.source

      #ap "Checking args_node.location:"
      #ap args_node.location
      if args_node.location.expression == nil # no args
        insert_after(node.location.name, "(params=nil)")
      end

      #  begin
      #    ap args[0].inspect
      #  rescue e
      #  end
      #  print()

      #  # Create new AST node to include `params` in args.
      #  #params_node = AST::Node.new(:arg, [AST::Node.new(:params, [])])

      #  # Modify args to include params.
      #  #ap "args_node.location:"
      #  #ap args_node.location
      #  #ap "node.location"
      #  #ap node.location
      #  #ap "@offset:"
      #  #ap @offset
      #  #insert_before(node.children[1].location.expression, "TEST")#params_node)

      #  #align_replace(node.location.expression, @offset, "#{name}(#{args}, params: {}})")

      #  # Don't call super.on_def. Only top-level methods need params injected.
      super
    end

    def on_class(node)
      name, zuper, body = *node
      ap "on_class: #{name} < #{zuper}"

      if RDL::Typecheck.is_controller(node)
        #super.on_class(node)
        #ParamsInjector.rewrite body
        super
      end

    end


    def initialize(offset)
      @offset = offset
    end

    def self.rewrite(ast)
      rewriter = ParamsInjector.new(ast.location.expression.begin_pos)
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

      ap "Here lies the code and source location for each block call to render:"
      format_json_block_calls.each { |call_ast| 
          render_src = call_ast.children[2].location.expression.source
          ap call_ast.children[2].location.expression.source
          ap "@"
          ap call_ast.children[2].location.expression
          ap ""
          #exit(1)

          # Inject the following expression after the `respond_to` call:
          # return render ...

          ap "about to insert `;__RDL_rendered = #{render_src};`"
          insert_after(node.location.expression, ";__RDL_rendered = #{render_src};")
      }

    end

    #def on_send(node)
    #    ap "on_send: #{node}"

    #    receiver, args = *node
    #    if receiver == :format && args[0] == :json 
    #        super
    #    else
    #        return nil
    #    end
    #end

    #def on_class(node)
    #  name, zuper, body = *node
    #  ap "on_class: #{name} < #{zuper}"

    #  if RDL::Typecheck.is_controller(node)
    #    #super.on_class(node)
    #    #ParamsInjector.rewrite body
    #    super
    #  else
    #    return nil
    #  end

    #end


    def initialize(offset)
      @offset = offset
    end

    def self.rewrite(ast)
      rewriter = RespondToInjector.new(ast.location.expression.begin_pos)
      buffer = Parser::Source::Buffer.new("(ast)")
      buffer.source = ast.location.expression.source
      puts "Creating buffer of length: #{ast.location.expression.source.length}"
      rewriter.rewrite(buffer, ast)
    end

  end

  def self.is_controller(class_node)
    name_node, zuper, body = *class_node
    name_nodee = *name_node
    name = name_nodee[1]

    klass = RDL::Util.to_class(name)
    #ap "Klass: "
    #ap klass

    if klass < ApplicationController
    ap "#{name} is a controller"
    return true
    end
    return false
  end

end