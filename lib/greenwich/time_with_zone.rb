# module ActiveSupport
#   class TimeWithZone
#     def time_zone=(new_zone)
#       ActiveSupport::TimeWithZone.new(nil, ActiveSupport::TimeZone.new(new_zone), time)
#     end
#
#     def time_zone_name
#       time_zone.name
#     end
#
#     def truncated_time
#       ActiveSupport::TimeWithZone.new(nil, ActiveSupport::TimeZone.new('UTC'), time)
#     end
#
#     def truncated_time_as_string
#       truncated_time.to_s
#     end
#   end
#
#   class TimeZone
#     def to_s
#       name
#     end
#
#     def freeze
#       tzinfo; utc_offset;
#       super
#     end
#   end
# end
