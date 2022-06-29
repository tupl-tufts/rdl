## This is inspired by the class_indexer gem, found at:
## https://github.com/matugm/class_indexer

module ClassIndexer
  class Processor < AST::Processor
    attr_reader :class_list

    def initialize
      reset_class

      @class_list = Hash.new { |h,k| h[k] = [] }
    end

    def get_const_name(ast)
      if ast.nil?
        ast
      elsif ast.type == :const
        inner = ast.children[1].to_s
        outer = get_const_name(ast.children[0])
        outer.nil? ? inner : outer + "::" + inner
      else
        raise "unexpected const ast #{ast}"
      end
    end

    def reset_class
      @current_class = "main"
    end

    def add_method(method_name, line_num)
      @class_list[@current_class] << { name: method_name.to_s, line: line_num }
    end

    def on_class(node)
      class_name = get_const_name(node.children[0])#node.children[0].children[1].to_s
      if @current_class == "main"
        @current_class = class_name
        entered_class = class_name
      else
        @current_class << "::" + class_name
        entered_class = "::" + class_name
      end
      node.children.each { |c| process(c) }

      @current_class.delete_suffix!(entered_class)
      reset_class if @current_class.empty?

=begin
      if @current_class.include?("::")
        @current_class.sub!("::" + class_name, "")
      else
        reset_class
      end
=end
    end

    def on_module(node)
      module_name = get_const_name(node.children[0])#node.children[0].children[1].to_s
      
      if @current_class == "main"
        @current_class = module_name
        entered_class = module_name
      else
        #@current_class.prepend(module_name + "::")
        @current_class << "::" + module_name
        entered_class = "::" + module_name
      end
      node.children.each { |c| process(c) }

      @current_class.delete_suffix!(entered_class)
      reset_class if @current_class.empty?
=begin
      if @current_class.include?("::")
        @current_class.sub!("::"+module_name, "")
      else
        reset_class
      end
=end
    end

    def on_sclass(node)
      #raise "Not currently supported." unless (node.children[0].type == :self) || (node.children[0].loc.expression.source == @current_class)
=begin
      @current_class.prepend("[s]")

      node.children.each { |c| process(c) }

      @current_class.sub!("[s]", "")
=end
      if node.children[0].type == :self
        @current_class.prepend("[s]")
        node.children.each { |c| process(c) }
        @current_class.sub!("[s]", "")
      else
        old_class = @current_class
        @current_class = "[s]" + node.children[0].loc.expression.source
        node.children.each { |c| process(c) }
        @current_class = old_class
      end
    end

    # Instance methods
    def on_def(node)
      line_num    = node.loc.line
      method_name = node.children[0]

      add_method(method_name, line_num)
    end

    # Class methods
    def on_defs(node)
      line_num    = node.loc.line
      method_name = "self.#{node.children[1]}"

      add_method(method_name, line_num)
    end

    def on_begin(node)
      node.children.each { |c| process(c) }
    end
  end

  def self.process_file(file)
    exp = Parser::CurrentRuby.parse(File.read(file))
    ast = Processor.new
    ast.process(exp)
    ast.class_list
  rescue Parser::SyntaxError
    warn "Syntax Error found while parsing #{file}"
  end

end
