require 'spec_helper'
require 'pry'

root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
db_root = File.join(root, 'db')

Dir.mkdir(db_root) unless File.exists?(db_root)
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
                                        :database => "#{db_root}/conversion.db")

ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'model_with_custom_time_zones'")
ActiveRecord::Base.connection.create_table(:model_with_custom_time_zones) do |t|
  t.datetime :started_at
  t.string   :time_zone
end

ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS 'model_with_static_time_zones'")
ActiveRecord::Base.connection.create_table(:model_with_static_time_zones) do |t|
  t.datetime :started_at
end

class ModelWithCustomTimeZone < ActiveRecord::Base
  include Greenwich::Conversion

  attr_accessible :started_at,
                  :time_zone

  time_with_custom_time_zone :started,   :time_zone => :time_zone
  time_zone                  :time_zone, :for       => [:started]
end

class ModelWithStaticTimeZone < ActiveRecord::Base
  include Greenwich::Conversion

  def time_zone
   'Central Time (US & Canada)'
  end

  attr_accessible :started_at

  time_with_static_time_zone :started,   :time_zone => :time_zone
end

describe Greenwich::Conversion do
  describe '.time_with_custom_time_zone' do
    let(:model)             { ModelWithCustomTimeZone.new }
    let(:central_time_zone) { ActiveSupport::TimeZone.new('Central Time (US & Canada)') }

    context 'when the time zone is set' do
      before { model.time_zone = central_time_zone.name }

      context 'and the time field is set' do
        before { model.started_at = Time.utc(2012, 1, 2, 12, 59, 1) }

        it 'converts the time field to the local time' do
          model.started_at.should eql central_time_zone.parse('2012-01-02 12:59:01')
        end
      end
    end

    context 'when the time zone is not set' do
      before { model.time_zone = nil }

      context 'and the time field is set' do
        before { model.started_at = Time.utc(2012, 1, 2, 12, 59, 1) }

        it 'does not convert the time field' do
          model.started_at.should eql Time.utc(2012, 1, 2, 12, 59, 1)
        end
      end
    end
  end

  describe '.time_zone' do
    let(:model)             { ModelWithCustomTimeZone.new }
    let(:central_time_zone) { ActiveSupport::TimeZone.new('Central Time (US & Canada)') }

    context 'when the time zone for the field is set' do
      before { model.time_zone = central_time_zone.name }

      it 'is the time zone' do
        model.time_zone.should eql central_time_zone
      end
    end

    context 'when the time zone for the field is not set' do
      before { model.time_zone = nil }

      it 'is nil' do
        model.time_zone.should be_nil
      end

      context 'but then it is set after the time field is set' do
        before do
          model.started_at = Time.utc(2012, 1, 2, 12, 59, 1)
          model.time_zone  = central_time_zone
        end

        it 'converts the time field' do
          model.started_at.should eql central_time_zone.parse('2012-01-02 12:59:01')
        end
      end
    end
  end
end