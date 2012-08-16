module Greenwich  #:nodoc:
  module Conversion #:nodoc:
    def self.included(base) #:nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def time_with_custom_time_zone(name, options = {})
        time_zone_field = options[:time_zone]  || Greenwich::Utilities.get_time_zone_field(name, column_names)
        time_field      = options[:time_field] || Greenwich::Utilities.get_time_field(name, column_names)

        define_method time_field do
          instance_eval do
            time_zone_value = read_attribute(time_zone_field)
            time_zone       = Greenwich::Utilities.get_time_zone_from(time_zone_value)

            value = read_attribute(time_field)

            return value unless value.present?

            value.in_time_zone(time_zone)
          end
        end

        define_method "#{time_field}=" do |time|
          instance_eval do
            if time.nil?
              write_attribute(time_field, time)
              return
            end

            time_zone_value = read_attribute(time_zone_field)
            time_zone       = Greenwich::Utilities.get_time_zone_from(time_zone_value)

            if time_zone.present?
              value = time_zone.parse(time.to_s(:db))
            else
              value = time
            end

            write_attribute(time_field, value)
          end
        end

        time_zone "#{name}_time_zone".to_sym, :for => name.to_sym if options[:time_zone] == time_zone_field
      end

      def time_with_static_time_zone(name, options = {})
        time_zone_field = options[:time_zone]  || Greenwich::Utilities.get_time_zone_field(name, column_names)
        time_field      = options[:time_field] || Greenwich::Utilities.get_time_field(name, column_names)

        define_method time_field do
          instance_eval do
            time_zone_value = send(time_zone_field.to_sym)
            time_zone       = Greenwich::Utilities.get_time_zone_from(time_zone_value)

            value = read_attribute(time_field)

            return value unless value.present?

            value.in_time_zone(time_zone)
          end
        end

        define_method "#{time_field}=" do |time|
          instance_eval do
            if time.nil?
              write_attribute(time_field, time)
              return
            end

            time_zone_value = send(time_zone_field.to_sym)
            time_zone       = Greenwich::Utilities.get_time_zone_from(time_zone_value)

            if time_zone.present?
              value = time_zone.parse(time.to_s(:db))
            else
              value = time
            end

            write_attribute(time_field, value)
          end
        end
      end

      def time_zone(name, options = {})
        options[:for] = [options[:for]].compact unless options[:for].is_a? Array
        options[:for].map! { |v| Greenwich::Utilities.get_time_field(v, column_names) }

        define_method "#{name}" do
          time_zone_name = read_attribute(name)

          Greenwich::Utilities.get_time_zone_from(time_zone_name)
        end

        define_method "#{name}=" do |time_zone_string|
          instance_eval do
            time_zone = Greenwich::Utilities.get_time_zone_from(time_zone_string).try(:name)
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
end
