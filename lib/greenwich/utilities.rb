module Greenwich
  module Utilities
    def self.get_time_zone_field(name, columns)
      target_columns = ["#{name}_time_zone", "time_zone"]

      get_target_column(target_columns, columns)
    end

    def self.get_time_zone(object, time_zone_field_name)
      begin
        time_zone_name = object.send(time_zone_field_name.to_sym)
      rescue
        time_zone_name = ''
      end

      Greenwich::Utilities.coerce_to_time_zone(time_zone_name)
    end

    def self.coerce_to_time_zone(name)
      return nil  if name.nil?
      return name if name.is_a? ActiveSupport::TimeZone

      ActiveSupport::TimeZone.new(name)
    end

    def self.coerce_to_time_without_zone(value)
      return value if value.is_a?(Time)

      value.gsub! /\s[-+]\d{4}$/, '' if value.respond_to? :gsub!
      value.to_time                  if value.respond_to? :to_time
    rescue ArgumentError
      nil
    end

  private
    def self.get_target_column(target_columns, all_columns)
      target_columns.each {|col| return col if all_columns.include?(col) }

      nil
    end
  end
end
