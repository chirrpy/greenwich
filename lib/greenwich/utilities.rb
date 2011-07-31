module Greenwich
  module Utilities
    def self.get_time_zone_field(name, columns)
      target_columns = ["#{name}_time_zone", "time_zone"]

      get_target_column(target_columns, columns)
    end

    def self.get_time_field(name, columns)
      target_columns = ["#{name}_at", "#{name}_datetime", "#{name}_time"]

      get_target_column(target_columns, columns)
    end

    def self.get_time_zone_from(value)
      return nil if [nil, ''].include? value

      begin
        value = ActiveSupport::TimeZone.new(value) unless value.is_a? ActiveSupport::TimeZone
      rescue ArgumentError
        raise ArgumentError, "'#{value}' cannot be converted into a TimeZone."
      end

      value
    end

  private
    def self.get_target_column(target_columns, all_columns)
      target_columns.each {|col| return col if all_columns.include?(col) }

      nil
    end
  end
end
