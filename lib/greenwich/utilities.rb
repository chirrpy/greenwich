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

      Greenwich::Utilities.get_time_zone_from_name(time_zone_name)
    end

    def self.get_time_zone_from_name(name)
      return nil  if name.nil?
      return name if name.is_a? ActiveSupport::TimeZone

      ActiveSupport::TimeZone.new(name)
    end

    def self.coerce_to_time_without_zone(time)
      if time.respond_to? :gsub!
        time.gsub! /\s[-+]\d{4}$/, ''
      end

      if !time.is_a?(Time) && time.respond_to?(:to_time)
        time = time.to_time
      end

      time
    rescue
      time
    end

  private
    def self.get_target_column(target_columns, all_columns)
      target_columns.each {|col| return col if all_columns.include?(col) }

      nil
    end
  end
end
