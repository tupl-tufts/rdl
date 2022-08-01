require 'csv'

module RDL::Reporting::CSV

  def meth_to_s(meth)
    RDL::Type::VarType.print_XXX!
    block_string = meth.block ? " { #{meth.block} }" : nil
    "(#{meth.args.join(', ')})#{block_string} -> #{meth.ret}"
  end

  def to_csv(path, open_file = nil)
    csv = open_file || CSV.open(path, 'wb')

    unless open_file
      csv << ['Class', 'Method', 'Inferred Type', 'Original Type',
              'Source Code', 'Comments']
    end

    @methods.each do |method|
      raise 'Error: unknown class' unless @full_name
      class_str = @full_name

      RDL::Logging.debug :inference, "Rendering #{RDL::Util.pp_klass_method(class_str, method.method_name)}"

      if method.type.solution.is_a?(RDL::Type::MethodType)
        meth = method.type.solution
        inf_type = meth_to_s meth
      else
        RDL::Logging.warning :inference, "Got a non-method type in type solutions: #{method.type.class}"

        RDL::Type::VarType.no_print_XXX!
        inf_type = method.type.solution.to_s # This would be weird
      end

      csv << [class_str, method.method_name, inf_type,
              method.orig_type, method.source_code]
    end

    @children.each_key do |key|
      @children[key].to_csv(path, csv)
    end

    csv.close unless open_file
    RDL::Logging.log :inference, :info, "File result is writed"
  end
end
