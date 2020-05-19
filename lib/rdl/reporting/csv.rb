require 'csv'

module RDL::Reporting::CSV
  def to_csv(path, open_file = nil)
    csv = open_file || CSV.open(path, 'wb')

    unless open_file
      csv << ['Class', 'Method', 'Inferred Type', 'Original Type',
              'Source Code', 'Comments']
    end

    @methods.each do |method|
      class_str = @full_name || 'ERROR: UNKNOWN'

      RDL::Logging.log :inference, :info, "Rendering #{class_str} / #{method.method}"

      if method.type.solution.is_a? RDL::Type::MethodType
        meth = method.type.solution

        RDL::Type::VarType.print_XXX!
        inf_type = "(#{meth.args.join(', ')})#{meth.block} -> #{meth.ret}"
      else
        RDL::Logging.log :inference, :warning, "Got a non-method type in type solutions"

        RDL::Type::VarType.print_XXX!
        inf_type = method.type.solution.to_s # This would be weird
      end

      csv << [class_str, method.method_name, inf_type,
              method.type.to_s, method.source_code]
    end

    @children.each_key do |key|
      @children[key].to_csv(path, csv)
    end

    csv.close unless open_file
  end
end
