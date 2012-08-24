module Greenwich
  module Conversion
    extend ActiveSupport::Concern

    module ClassMethods
      def time_with_time_zone(utc_time_field, options = {})
        time_field      = utc_time_field.to_s.gsub /_utc$/, ''
        time_zone_field = options[:time_zone] || "#{time_field}_time_zone"

        class_eval do
          columns_hash[time_field] = ActiveRecord::ConnectionAdapters::Column.new(time_field, nil, "datetime")
        end

        define_method "#{time_field}_utc=" do |value|
          greenwich_time_fields_converted["#{time_field}_utc"] = true

          super(value)
        end

        define_method time_field do
          time_zone = Greenwich::Utilities.get_time_zone(self, time_zone_field)
          time      = read_attribute(utc_time_field)
          time      = time.in_time_zone(time_zone) if time && time_zone

          time
        end

        define_method "#{time_field}=" do |value|
          time_zone = Greenwich::Utilities.get_time_zone(self, time_zone_field)
          time      = Greenwich::Utilities.coerce_to_time_without_zone(value)
          time      = ActiveSupport::TimeWithZone.new(nil, time_zone, time) if time && time_zone

          greenwich_time_fields_converted["#{time_field}_utc"] = true unless time_zone.nil?

          write_attribute(utc_time_field, time)
        end

        time_zone time_zone_field.to_sym, :for => utc_time_field.to_sym
      end

      def time_zone(name, options = {})
        associated_time_fields = Array.wrap(options[:for]).map {|f| f.to_s.gsub /_utc$/, ''}

        define_method name do
          time_zone_name = read_attribute(name)

          Greenwich::Utilities.coerce_to_time_zone(time_zone_name)
        end

        define_method "#{name}=" do |value|
          time_zone = Greenwich::Utilities.coerce_to_time_zone_name(value)
          write_attribute(name, time_zone)

          associated_time_fields.each do |time_field|
            if greenwich_time_field_needs_conversion?(time_field, name)
              send("#{time_field}=".to_sym, read_attribute("#{time_field}_utc"))

              greenwich_time_fields_converted["#{time_field}_utc"] = true
            end
          end
        end
      end
    end

    def greenwich_time_fields_converted
      @greenwich_time_fields_converted ||= {}
    end

    def greenwich_time_fields_converted=(value)
      @greenwich_time_fields_converted = value
    end

  private
    def greenwich_time_field_needs_conversion?(time_field, time_zone_field)
      (send("#{time_zone_field}_was".to_sym).nil? || send("#{time_field}_utc_was").nil?) &&
        read_attribute("#{time_field}_utc").present? &&
        self.greenwich_time_fields_converted["#{time_field}_utc"].nil?
    end
  end
end

ActiveRecord::Base.send :include, Greenwich::Conversion
