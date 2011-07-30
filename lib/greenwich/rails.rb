require  'greenwich'

module Greenwich  #:nodoc:
  module Conversion #:nodoc:
    def self.included(base) #:nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def time_with_custom_time_zone(name, options = {})
        time_zone_field = options[:time_zone]  || Greenwich::Utilities.get_time_zone_field(name, column_names)
        time_field      = options[:time_field] || Greenwich::Utilities.get_time_field(name, column_names)

        skip_time_zone_conversion_for_attributes << time_field

        mapping = [ [time_field, 'truncated_time_as_string'], [time_zone_field, 'time_zone_name'] ]

        composed_of name,
                    :class_name => 'ActiveSupport::TimeWithZone',
                    :mapping => mapping,
                    :allow_nil => true,
                    :constructor => Proc.new { |time, time_zone|
                      time_zone = ActiveSupport::TimeZone.new(time_zone) unless time_zone.is_a? ActiveSupport::TimeZone
                      time = time.to_time

                      ActiveSupport::TimeWithZone.new(nil, time_zone, time)
                    },
                    :converter => Proc.new { |value|
                      raise ArgumentError, "You must pass an object that can be sent to ActiveSupport::TimeZone#new when setting this field (ie: field_name = [Time.now, 'CDT'])" if value[1].nil?

                      value[1] = ActiveSupport::TimeZone.new(value[1]) unless value[1].is_a? ActiveSupport::TimeZone
                      value[0] = value[0].to_time

                      ActiveSupport::TimeWithZone.new(nil, value[1], value[0])
                    }

        define_method "#{time_field}=" do |time|
          instance_eval do
            time_zone = read_attribute(time_zone)

            if time_zone.nil?
              write_attribute(time_field, time.to_s)
            else
              self.send("#{name}=".to_sym, [time, time_zone])
            end
          end
        end

        time_zone "#{name}_time_zone".to_sym, :for => name.to_sym if options[:time_zone] == time_zone_field
      end

      def time_zone(name, options = {})
        options[:for] = [options[:for]].compact unless options[:for].is_a? Array
        options[:for].map! { |v| [v, Greenwich::Utilities.get_time_field(v, column_names)] }

        define_method "#{name}" do
          time_zone_name = read_attribute(name)
          ActiveSupport::TimeZone.new(time_zone_name) unless time_zone_name.nil?
        end

        define_method "#{name}=" do |time_zone|
          instance_eval do
            raise ArgumentError, "You can't set this #{name} to nil.  Greenwich is used for working with times and zones.  If you don't need time zones, use a standard Ruby Time object instead." if time_zone.nil?

            time_zone = ActiveSupport::TimeZone.new(time_zone) unless time_zone.is_a? ActiveSupport::TimeZone || time_zone.nil?
            time_zone = time_zone.name if time_zone.respond_to? :name
            write_attribute(name, time_zone)

            options[:for].each do |composed_field, time_field|
              time = read_attribute(time_field)
              self.send("#{composed_field}=".to_sym, [time, time_zone]) unless time.nil?
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Greenwich::Conversion
