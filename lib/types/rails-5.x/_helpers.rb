# :integer, :bigint, :float, :decimal, :numeric, :datetime, :time, :date, :binary, :boolean.
# null allowed

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
  end
end
