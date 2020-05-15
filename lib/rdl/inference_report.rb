require 'csv'

class RDL::InferenceReport

  class Method
    attr_accessor :klass, :method, :inferred_type,
                  :original_type, :source_code, :comments
  end

  def initialize(name = nil)
    @name = name
    @children = {}
    @methods = []
  end

  def [](className)
    # TODO: We need to know whether or not each level is a module or class...
    part, parts = className.split '::', 2
    part = part.to_sym

    @children[part] = self.class.new(part) unless @children.key? part

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

  def to_csv(path, prefix = nil, open_file = nil)
    RDL::Logging.log :inference, :info, "Rendering #{prefix}"

    csv = open_file || CSV.open(path, 'wb')

    unless open_file
      csv << ['Class', 'Method', 'Inferred Type', 'Original Type',
              'Source Code', 'Comments']
    end

    unless @methods.empty?
      @methods.each do |method|
        class_str = prefix || '' + (@name || '::')

        csv << [class_str, method.method, method.inferred_type,
                method.original_type, method.source_code]
      end
    end

    unless @children.empty?
      @children.each_key do |key|
        nxt = prefix ? "#{prefix}::#{key}" : key
        @children[key].to_csv(path, nxt, csv)
      end
    end

    csv.close unless open_file
  end
end
