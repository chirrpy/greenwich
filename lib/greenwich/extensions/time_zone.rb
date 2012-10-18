module ActiveSupport
  class TimeZone
    def freeze
      tzinfo; utc_offset;
      super
    end
  end
end
