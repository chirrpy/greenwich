module Greenwich
  module Utilities
    def self.get_time_zone_field(name, columns)
      target_columns = ["#{name}_time_zone", "time_zone"]

      get_target_column(target_columns, columns)
    end

    def self.get_time_zone_from_name(name)
      return nil  if name.nil?
      return name if name.is_a? ActiveSupport::TimeZone

      ActiveSupport::TimeZone.new(name)
    end

  private
    def self.get_target_column(target_columns, all_columns)
      target_columns.each {|col| return col if all_columns.include?(col) }

      nil
    end
  end
end
