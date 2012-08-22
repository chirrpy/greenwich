module Greenwich
  module Conversion
    extend ActiveSupport::Concern

    module ClassMethods
      def time_with_time_zone(time_field, options = {})
        time_zone_field = options[:time_zone] || Greenwich::Utilities.get_time_zone_field(name, column_names)

        class_eval do
          columns_hash["local_#{time_field}"] = ActiveRecord::ConnectionAdapters::Column.new("local_#{time_field}", nil, "datetime")
        end

        define_method "local_#{time_field}" do
          time_zone = Greenwich::Utilities.get_time_zone(self, time_zone_field)
          time      = read_attribute(time_field)
          time      = time.in_time_zone(time_zone) if time && time_zone

          time
        end

        define_method "local_#{time_field}=" do |value|
          time_zone = Greenwich::Utilities.get_time_zone(self, time_zone_field)
          time      = Greenwich::Utilities.coerce_to_time_without_zone(value)
          time      = ActiveSupport::TimeWithZone.new(nil, time_zone, time) if time && time_zone

          write_attribute(time_field, time)
        end

        time_zone time_zone_field.to_sym, :for => time_field.to_sym
      end

      def time_zone(name, options = {})
        associated_time_fields = Array.wrap options[:for]

        define_method name do
          time_zone_name = read_attribute(name)

          Greenwich::Utilities.coerce_to_time_zone(time_zone_name)
        end

        define_method "#{name}=" do |value|
          time_zone = Greenwich::Utilities.coerce_to_time_zone_name(value)
          write_attribute(name, time_zone)

          associated_time_fields.each do |time_field|
            send("local_#{time_field}=".to_sym, read_attribute(time_field))
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Greenwich::Conversion
