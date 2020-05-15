require 'csv'
require 'parlour'

class RDL::InferenceReport

  class Method
    attr_accessor :klass, :method, :inferred_type,
                  :original_type, :source_code, :comments
  end

  attr_reader :full_name

  def initialize(full_name = nil)
    RDL::Logging.log :inference, :info, "MK #{full_name}"
    @full_name = full_name
    @children = {}
    @methods = []
  end

  def [](className)
    # TODO: We need to know whether or not each level is a module or class...
    part, parts = className.split '::', 2
    part = part.to_sym

    unless @children.key? part
      child_full_name = @full_name ? "#{@full_name}::" : ''
      child_full_name += part.to_s
      @children[part] = self.class.new(child_full_name)
    end

    return @children[part][parts] if parts

    @children[part]
  end

  def <<(input)
    meth = Method.new

    meth.klass         = input[:klass]
    meth.method        = input[:method]
    meth.inferred_type = input[:inferred_type]
    meth.original_type = input[:original_type]
    meth.source_code   = input[:source_code]
    meth.comments      = input[:comments]

    @methods << meth
  end

  def to_csv(path, open_file = nil)
    csv = open_file || CSV.open(path, 'wb')

    unless open_file
      csv << ['Class', 'Method', 'Inferred Type', 'Original Type',
              'Source Code', 'Comments']
    end

    @methods.each do |method|
      class_str = @full_name || 'ERROR: UNKNOWN'

      RDL::Logging.log :inference, :info, "Rendering #{class_str} / #{method.method}"

      if method.inferred_type.is_a? RDL::Type::MethodType
        meth = method.inferred_type

        RDL::Type::VarType.print_XXX!
        inf_type = "(#{meth.args.join(', ')})#{meth.block} -> #{meth.ret}"
      else
        RDL::Logging.log :inference, :warning, "Got a non-method type in type solutions"

        RDL::Type::VarType.print_XXX!
        inf_type = method.inferred_type.to_s # This would be weird
      end

      csv << [class_str, method.method, inf_type,
              method.original_type, method.source_code]
    end

    @children.each_key do |key|
      @children[key].to_csv(path, csv)
    end

    csv.close unless open_file
  end

  def gen_sorbet(generator)
    @methods.each do |method|
      generator.create_method(method.method.to_s, parameters: [
                                Parlour::RbiGenerator::Parameter.new('a', type: 'Integer'),
                                Parlour::RbiGenerator::Parameter.new('b', type: 'Integer')
                              ],
                              return_type: method.inferred_type.ret.to_s)
    end

    @children.each_key do |key|
      child = @children[key]
      klass = RDL::Util.to_class(child.full_name)
      is_mod = !klass.is_a?(Class)

      klass_name = child.full_name.split('::').last

      if is_mod
        generator.create_module(klass_name) do |mod|
          child.gen_sorbet(mod)
        end
      else
        generator.create_class(klass_name) do |klass|
          child.gen_sorbet(klass)
        end
      end
    end

  end

  def to_sorbet(path)
    generator = Parlour::RbiGenerator.new

    gen_sorbet(generator.root)

    puts generator.rbi
  end
end
