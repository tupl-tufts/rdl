# :integer, :bigint, :float, :decimal, :numeric, :datetime, :time, :date, :binary, :boolean.
# null allowed

type_alias '%symstr', 'Symbol or String'

module RDL
  class Rails

    # [+ rails_type +] is a Rails column type (:string, :integer, etc)
    # returns a String containing an RDL type
    def self.column_to_rdl(rails_type)
      case rails_type
      when :string, :text, :binary
        return 'String'
      when :integer
        return 'Fixnum'
      when :float
        return 'Float'
      when :decimal
        return 'BigDecimal'
      when :boolean
        return '%bool'
      when :date
        return 'Date'
      when :time
        return 'Time'
      when :datetime
        return 'DateTime'
      else
        raise RuntimeError, "Unrecoganized column type #{rails_type}"
      end
    end

    # [+ model +] is an ActiveRecord::Base subclass that has been loaded.
    # Gets the columns_hash of the model and returns a String that can
    # serve as the paramter list to a method that accepts any number
    # of the model's attributes keyed by the attribute names.
    def self.attribute_types(model)
      args = []

      model.columns_hash.each { |name, col|
        t = column_to_rdl(col.type)
        if col.null
          args << "#{name}: ?#{t}"
        else
          args << "#{name}: ?!#{t}"
        end
      }
      return args.join ','
    end
  end
end
