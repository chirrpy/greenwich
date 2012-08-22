require 'spec_helper'
require 'pry'

root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
db_root = File.join(root, 'db')

Dir.mkdir(db_root) unless File.exists?(db_root)
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
                                        :database => "#{db_root}/conversion.db")

ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'model_with_time_zones'")
ActiveRecord::Base.connection.create_table(:model_with_time_zones) do |t|
  t.datetime :started_at
  t.string   :time_zone
end

class ModelWithTimeZone < ActiveRecord::Base
  include Greenwich::Conversion

  attr_accessible :started_at,
                  :started_at_utc,
                  :time_zone

  time_with_time_zone :started_at, :time_zone => :time_zone
end

describe Greenwich::Conversion do
  describe '.time_with_time_zone' do
    let(:model)             { ModelWithTimeZone.new }
    let(:alaskan_time_zone) { ActiveSupport::TimeZone.new('Alaska') }

    describe '#time_field_utc' do
      context 'when the time field is set to a non-UTC time' do
        before do
          model.time_zone  = alaskan_time_zone
          model.local_started_at = Time.utc(2012, 1, 1, 12, 0, 0)
        end

        it 'is the time in the UTC time zone' do
          model.started_at_utc.should eql Time.utc(2012, 1, 1, 21, 0, 0)
        end
      end

      context 'when the time field is not set' do
        before do
          model.time_zone  = alaskan_time_zone
          model.local_started_at = nil
        end

        it 'is nil' do
          model.started_at_utc.should be_nil
        end
      end
    end

    describe '#time_field_utc=' do
    end

    describe '#time_field' do
      context 'when it is nil' do
        before { model.send :write_attribute, :started_at, nil }

        it 'is nil' do
          model.local_started_at.should be_nil
        end
      end

      context 'when there is no time zone' do
        let(:raw_time_value) { Time.utc(2012, 1, 1, 12, 0, 0) }

        before do
          model.send :write_attribute, :started_at, raw_time_value
          model.stub(:time_zone).and_return nil
        end

        it 'returns the raw time field' do
          model.local_started_at.should eql raw_time_value
        end
      end

      context 'when it is something other than a Time' do
        before { model.send :write_attribute, :started_at, 5 }

        it 'returns the raw value' do
          model.local_started_at.should eql 5
        end
      end

      context 'when the time zone is set properly' do
        before { model.stub(:time_zone).and_return 'Alaska' }

        context 'when it is a time' do
          before { model.send :write_attribute, :started_at, Time.utc(2012, 1, 2, 12, 59, 1) }

          it 'returns the time in the time zone' do
            model.local_started_at.should eql alaskan_time_zone.parse('2012-01-02 3:59:01')
          end
        end
      end
    end

    describe '#time_field=' do
      let(:raw_time_field) { model.read_attribute(:started_at) }

      context 'when the time zone is set' do
        before { model.stub(:time_zone).and_return alaskan_time_zone.name }

        context 'and the field is set to nil' do
          before { model.local_started_at = nil }

          it 'the time field is nil' do
            raw_time_field.should be_nil
          end
        end

        context 'and the field is set to something which cannot be converted to a time' do
          before { model.local_started_at = 'foo' }

          it 'the time field is nil' do
            raw_time_field.should be_nil
          end
        end

        context 'and the field is set with UTC time' do
          before { model.local_started_at = Time.utc(2012, 1, 2, 12, 59, 1) }

          it 'the time field is adjusted for the time zone' do
            raw_time_field.should eql Time.utc(2012, 1, 2, 21, 59, 1)
          end
        end
      end

      context 'when the time zone is not set' do
        before { model.stub(:time_zone).and_return nil }

        context 'and the time field is set' do
          before { model.local_started_at = Time.utc(2012, 1, 2, 12, 59, 1) }

          it 'the time field is not adjusted' do
            raw_time_field.should eql Time.utc(2012, 1, 2, 12, 59, 1)
          end
        end

        context 'and the time field is not set' do
          before { model.local_started_at = nil }

          it 'the time field is nil' do
            raw_time_field.should be_nil
          end
        end
      end
    end

    context 'when it is saved to the database and reloaded' do
      before do
        model.local_started_at = Time.utc(2012, 1, 2, 12, 59, 1)
        model.time_zone  = 'Alaska'
        model.save!

        model.reload
      end

      it 'converts the time field to the local time' do
        model.local_started_at.should_not be_utc
        model.local_started_at.should eql alaskan_time_zone.parse('2012-01-02 12:59:01')
      end

      it 'converts the time field to a TimeWithZone' do
        model.local_started_at.should be_a ActiveSupport::TimeWithZone
      end
    end
  end

  describe '.time_zone' do
    let(:model)             { ModelWithTimeZone.new }
    let(:alaskan_time_zone) { ActiveSupport::TimeZone.new('Alaska') }

    context '#time_zone' do
      context 'when the object does have a time zone' do
        before { model.send(:write_attribute, :time_zone, alaskan_time_zone.name) }

        it 'is the time zone' do
          model.time_zone.should eql alaskan_time_zone
        end
      end

      context 'when the object does not have a time zone' do
        before { model.send(:write_attribute, :time_zone, nil) }

        it 'is nil' do
          model.time_zone.should be_nil
        end
      end
    end

    describe '#time_zone=' do
      let(:model)             { ModelWithTimeZone.new }
      let(:alaskan_time_zone) { ActiveSupport::TimeZone.new('Alaska') }
      let(:raw_time_field)    { model.send :read_attribute, :started_at }
      let(:raw_time_zone)     { model.read_attribute(:time_zone) }

      context 'when it is set after the time field is set' do
        before do
          model.send :write_attribute, :started_at, Time.utc(2012, 1, 2, 12, 59, 1)
          model.time_zone = alaskan_time_zone
        end

        it 'triggers the time field to be converted' do
          raw_time_field.should eql Time.utc(2012, 1, 2, 21, 59, 1)
        end
      end

      context 'when it is set before the time field is set' do
        before { model.time_zone = alaskan_time_zone }

        it 'sets the time zone but does not touch the time' do
          raw_time_field.should be_nil
          raw_time_zone.should eql 'Alaska'
        end
      end

      context 'when it is set to an ActiveSupport::TimeZone' do
        before { model.time_zone = alaskan_time_zone }

        it 'is set properly' do
          raw_time_zone.should eql 'Alaska'
        end
      end

      context 'when it is set to a time zone name' do
        before { model.time_zone = 'Alaska' }

        it 'is set properly' do
          raw_time_zone.should eql 'Alaska'
        end
      end

      context 'when it is set to an invalid time zone' do
        before { model.time_zone = 'I am not a time zone' }

        it 'is nil' do
          raw_time_zone.should be_nil
        end
      end
    end
  end
end
