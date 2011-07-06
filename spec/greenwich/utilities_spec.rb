require 'spec_helper'

describe Greenwich::Utilities do
  describe "#truncate" do
    before { @expected_time = Time.utc(2011, 5, 13, 17, 31, 13, 0) }

    context "when passed a String" do
      it "returns the correct time if no offset is given" do
        truncated = Greenwich::Utilities.truncate("2011-05-13 17:31:13")
        truncated.should eql @expected_time
      end

      it "returns the correct time if an offset is given" do
        truncated = Greenwich::Utilities.truncate("2011-05-13 17:31:13 -0600")
        truncated.should eql @expected_time
      end
    end

    context "when passed a TimeWithZone" do
      before { @time = Time.utc(2011, 5, 13, 17, 31, 13) }

      it "returns the correct time if TimeWithZone is UTC" do
        utc_time_zone = ActiveSupport::TimeZone.new('UTC')
        time_with_zone = ActiveSupport::TimeWithZone.new(@time, utc_time_zone)

        truncated = Greenwich::Utilities.truncate(time_with_zone)
        truncated.should eql @expected_time
      end

      it "returns the correct time if TimeWithZone is not UTC" do
        alaskan_time_zone = ActiveSupport::TimeZone.new('Alaska')
        time_with_zone = ActiveSupport::TimeWithZone.new(nil, alaskan_time_zone, @time)

        truncated = Greenwich::Utilities.truncate(time_with_zone)
        truncated.should eql @expected_time
      end
    end

    context "when passed a DateTime" do
      it "returns the correct time if DateTime is UTC" do
        datetime = DateTime.civil(2011, 5, 13, 17, 31, 13, 0)

        truncated = Greenwich::Utilities.truncate(datetime)
        truncated.should eql @expected_time
      end

      it "returns the correct time if DateTime is not UTC" do
        datetime = DateTime.civil(2011, 5, 13, 17, 31, 13, -0.25)

        truncated = Greenwich::Utilities.truncate(datetime)
        truncated.should eql @expected_time
      end
    end
  end

  describe "#get_time_zone" do
    context "when passed a valid time zone" do
      it "returns that time zone" do
        time_zone = Greenwich::Utilities.get_time_zone(nil, 'foo')
        time_zone.should eql 'foo'
      end
    end

    context "when not passed a time zone" do
      before { @time = Time.utc(2011, 5, 13, 17, 31, 13) }

      context "and passed a TimeWithZone for the time" do
        it "returns the time zone associated with the time" do
          alaskan_time_zone = ActiveSupport::TimeZone.new('Alaska')
          time_with_zone = ActiveSupport::TimeWithZone.new(nil, alaskan_time_zone, @time)

          time_zone = Greenwich::Utilities.get_time_zone(time_with_zone, nil)
          time_zone.should eql alaskan_time_zone
        end

        it "returns the time zone associated with the time" do
          utc_time_zone = ActiveSupport::TimeZone.new('UTC')

          time_zone = Greenwich::Utilities.get_time_zone(@time, nil)
          time_zone.should eql utc_time_zone
        end
      end
    end
  end
end
