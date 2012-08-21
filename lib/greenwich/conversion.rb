module Greenwich
  module Conversion
    extend ActiveSupport::Concern

    module ClassMethods
      def time_with_time_zone(time_field, options = {})
        time_zone_field = options[:time_zone] || Greenwich::Utilities.get_time_zone_field(name, column_names)

        define_method "#{time_field}_utc" do
          read_attribute(time_field)
        end

        define_method "#{time_field}_utc=" do |time|
          write_attribute(time_field, time)
        end

        define_method time_field do
          time_zone = Greenwich::Utilities.get_time_zone(self, time_zone_field)
          time     = read_attribute(time_field)

          if time && time_zone
            time.in_time_zone(time_zone)
          else
            time
          end
        end

        define_method "#{time_field}=" do |value|
          time      = Greenwich::Utilities.coerce_to_time_without_zone(value)
          time_zone = Greenwich::Utilities.get_time_zone(self, time_zone_field)

          time      = if time && time_zone
                        ActiveSupport::TimeWithZone.new nil, time_zone, time
                      else
                        time
                      end

          write_attribute(time_field, time)
        end

        time_zone time_zone_field.to_sym, :for => time_field.to_sym
      end

      def time_zone(name, options = {})
        options[:for] = [options[:for]].compact unless options[:for].is_a? Array

        define_method name do
          time_zone_name = read_attribute(name)

          Greenwich::Utilities.get_time_zone_from_name(time_zone_name)
        end

        define_method "#{name}=" do |time_zone_string|
          time_zone = Greenwich::Utilities.get_time_zone_from_name(time_zone_string).try(:name)
          write_attribute(name, time_zone)

          options[:for].each do |time_field|
            time = read_attribute(time_field)

            send("#{time_field}=".to_sym, time) if time && time_zone
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Greenwich::Conversion
