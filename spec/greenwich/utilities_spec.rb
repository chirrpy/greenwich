require 'spec_helper'

describe Greenwich::Utilities do
  describe '.get_time_zone_field' do
    subject { Greenwich::Utilities.get_time_zone_field(name, columns) }

    let(:name) { 'foo_at' }

    context 'when columns includes a field-specific time zone field' do
      let(:columns) { %w(foo bar foo_at_time_zone) }

      it 'is the field-specific time zone field' do
        subject.should eql 'foo_at_time_zone'
      end
    end

    context 'when columns does not include a field-specific time zone field' do
      context 'but does include the general time zone field' do
        let(:columns) { %w(foo bar time_zone) }

        it 'is the general time zone field' do
          subject.should eql 'time_zone'
        end
      end

      context 'and does not include the general time zone field' do
        let(:columns) { %w(foo bar) }

        it 'is nil' do
          subject.should be_nil
        end
      end

    end
  end

  describe '.get_time_zone_from_name' do
    subject { Greenwich::Utilities.get_time_zone_from_name(value) }

    context 'when the value is nil' do
      let(:value) { nil }

      it 'is nil' do
        subject.should be_nil
      end
    end

    context 'when the value is blank' do
      let(:value) { '' }

      it 'is nil' do
        subject.should be_nil
      end
    end

    context 'when the value is not the name of a valid time zone' do
      let(:value) { 'foo' }

      it 'is nil' do
        subject.should be_nil
      end
    end

    context 'when the value is the name of a valid time zone' do
      let(:value) { 'Alaska' }

      it 'is the corresponding TimeZone' do
        subject.should eql ActiveSupport::TimeZone.new('Alaska')
      end
    end

    context 'when the value is a time zone' do
      let(:value) { ActiveSupport::TimeZone.new('Alaska') }

      it 'is the time zone' do
        subject.should eql value
      end
    end
  end
end
