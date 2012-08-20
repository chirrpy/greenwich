module Greenwich  #:nodoc:
  module Conversion #:nodoc:
    def self.included(base) #:nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def time_with_custom_time_zone(time_field, options = {})
        time_zone_field = options[:time_zone]  || Greenwich::Utilities.get_time_zone_field(name, column_names)

        define_method "#{time_field}_utc" do
          value = read_attribute(time_field)

          return value unless value.present?

          value.utc
        end

        define_method "#{time_field}_utc=" do |time|
          write_attribute(time_field, time)
        end

        define_method time_field do
          instance_eval do
            time_zone_value = read_attribute(time_zone_field)
            time_zone       = Greenwich::Utilities.get_time_zone_from(time_zone_value)

            value = read_attribute(time_field)

            return value unless value.is_a?(Time) && time_zone.is_a?(ActiveSupport::TimeWithZone)

            value.in_time_zone(time_zone)
          end
        end

        define_method "#{time_field}=" do |time|
          instance_eval do
            if time.is_a?(String)
              write_attribute(time_field, time)
              return
            end
            if !time.is_a?(Time) && time.respond_to?(:to_time)
              begin
                time = time.to_time
              rescue
              end
            end

            unless time.is_a? Time
              write_attribute(time_field, time)
              return
            end

            time_zone_value = read_attribute(time_zone_field)
            time_zone       = Greenwich::Utilities.get_time_zone_from(time_zone_value)

            if time_zone.present?
              value = ActiveSupport::TimeWithZone.new nil, time_zone, time
            else
              value = time
            end

            write_attribute(time_field, value)
          end
        end

        time_zone "#{time_field}_time_zone".to_sym, :for => time_field.to_sym if options[:time_zone] == time_zone_field
      end

      def time_with_static_time_zone(time_field, options = {})
        time_zone_field = options[:time_zone]  || Greenwich::Utilities.get_time_zone_field(name, column_names)

        define_method "#{time_field}_utc" do
          value = read_attribute(time_field)

          return value unless value.present?

          value.utc
        end

        define_method "#{time_field}_utc=" do |time|
          write_attribute(time_field, time)
        end

        define_method time_field do
          instance_eval do
            begin
              time_zone_value = send(time_zone_field.to_sym)
            rescue
              time_zone_value = ''
            end

            time_zone       = Greenwich::Utilities.get_time_zone_from(time_zone_value)

            value = read_attribute(time_field)

            return value unless value.is_a?(Time) && time_zone.is_a?(ActiveSupport::TimeZone)

            value.in_time_zone(time_zone)
          end
        end

        define_method "#{time_field}=" do |time|
          instance_eval do
            if time.is_a?(String)
              write_attribute(time_field, time)
              return
            end
            if !time.is_a?(Time) && time.respond_to?(:to_time)
              begin
                time = time.to_time
              rescue
              end
            end

            unless time.is_a? Time
              write_attribute(time_field, time)
              return
            end

            begin
              time_zone_value = send(time_zone_field.to_sym)
            rescue
              time_zone_value = ''
            end

            time_zone = Greenwich::Utilities.get_time_zone_from(time_zone_value)

            if time_zone.present?
              value = ActiveSupport::TimeWithZone.new nil, time_zone, time
            else
              value = time
            end

            write_attribute(time_field, value)
          end
        end
      end

      def time_zone(name, options = {})
        options[:for] = [options[:for]].compact unless options[:for].is_a? Array

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

ActiveRecord::Base.send :include, Greenwich::Conversion
