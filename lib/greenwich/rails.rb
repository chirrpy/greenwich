require  'greenwich'

module Greenwich  #:nodoc:
  module Aggregations #:nodoc:
    module ActiveRecord #:nodoc:
      def self.included(base) #:nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        def date_with_time_zone(name, options = {})
          options = { :time => time_field_name(name), :time_zone => time_zone_field_name(name), :allow_nil => true }.merge options

          mapping =  [ [options[:time], 'in_time_zone'], [options[:time_zone], 'zone'] ]

          composed_of name,
                      :class_name => 'Time',
                      :mapping => mapping,
                      :allow_nil => options[:allow_nil],
                      :constructor => Proc.new { |time, time_zone|
                        time.in_time_zone(time_zone)
                      },
                      :converter => Proc.new { |value|
                        raise(ArgumentError, "Can't convert #{value.class} to Time") unless value.respond_to?(:to_time)

                        value.to_time
                      }
        end

      private
        def time_field_name(name)
          if self.column_names.include? "#{name}_at"
            "#{name}_at".to_sym
          elsif self.column_names.include? "#{name}_datetime"
            "#{name}_datetime".to_sym
          end
        end

        def time_zone_field_name(name)
          if self.column_names.include? "#{name}_time_zone"
            "#{name}_time_zone".to_sym
          elsif self.column_names.include? "time_zone"
            "time_zone".to_sym
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Greenwich::Aggregations::ActiveRecord
