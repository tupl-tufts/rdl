module RDL::Reporting
  require_relative './csv.rb'
  require_relative './sorbet.rb'

  class InferenceReport
    include RDL::Reporting::CSV
    include RDL::Reporting::Sorbet

    class MethodInfo
      attr_accessor :klass, :method_name, :type, :orig_type, :source_code,
                    :comments
    end

    attr_reader :full_name

    def initialize(full_name = nil)
      RDL::Logging.debug :inference, "MK #{full_name}"
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
      meth = MethodInfo.new

      meth.klass       = input[:klass]
      meth.method_name = input[:method_name]
      meth.type        = input[:type]
      meth.orig_type   = input[:orig_type]
      meth.source_code = input[:source_code]
      meth.comments    = input[:comments]

      @methods << meth
    end

  end

end
