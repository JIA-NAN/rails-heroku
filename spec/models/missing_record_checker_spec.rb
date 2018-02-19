require 'spec_helper'

describe MissingRecordChecker do
  context '.mark_missed_record' do
    before :each do
      # set now = 9 am
      @now = Time.zone.now.midnight + 9.hours

      @patient = create(:patient)
      @schedule = create(:schedule, patient: @patient, started_at: @now.to_date)

      @passed_due = Ptime.to_ptime(@now - @schedule.pill_delay_time - 1.minute)
      @intime_due = Ptime.to_ptime(@now - 1.minute)
      # stub Time
      Time.zone.stub(now: @now)
    end

    it 'should not check yesterday if schedule started_at on today' do
      @patient.stub(next_record_time: nil)
      expect(@patient).not_to receive(:next_record_time).with(:yesterday)

      MissingRecordChecker.mark_missed_record(@patient)
      expect(@patient.records.count).to eq(0)
    end

    it 'should check yesterday if schedule started_at before today' do
      @schedule.update_attributes(started_at: (@now - 3.days).to_date)
      @patient.stub(next_record_time: nil)
      expect(@patient).to receive(:next_record_time).with(:yesterday)

      MissingRecordChecker.mark_missed_record(@patient)
      expect(@patient.records.count).to eq(0)
    end

    it 'should not mark when next_record_time = nil' do
      @patient.stub(next_record_time: nil)

      MissingRecordChecker.mark_missed_record(@patient)
      expect(@patient.records.count).to eq(0)
    end

    it 'should mark when next_record_time exceeds delay' do
      @patient.stub(next_record_time: @passed_due)

      MissingRecordChecker.mark_missed_record(@patient)
      expect(@patient.records.count).to eq(1)
    end

    context 'has next_record_time < delay' do
      it 'does not mark when current_pill_time is nil' do
        @patient.stub(next_record_time: @intime_due)
        @patient.stub(current_pill_time: nil)

        MissingRecordChecker.mark_missed_record(@patient)
        expect(@patient.records.count).to eq(0)
      end

      it 'dose not mark if has equal current_pill_time' do
        @patient.stub(next_record_time: @intime_due)
        @patient.stub(current_pill_time: Ptime.to_time(@intime_due))

        MissingRecordChecker.mark_missed_record(@patient)
        expect(@patient.records.count).to eq(0)
      end

      it 'marks missed when due less than current_pill_time' do
        @patient.stub(next_record_time: @passed_due)
        @patient.stub(current_pill_time: @now)

        MissingRecordChecker.mark_missed_record(@patient)
        expect(@patient.records.status(:missing).count).to eq(1)
      end

      it 'does not mark when due larger than current_pill_time' do
        @patient.stub(next_record_time: @intime_due)
        @patient.stub(current_pill_time: Ptime.to_time(@passed_due))

        MissingRecordChecker.mark_missed_record(@patient)
        expect(@patient.records.count).to eq(0)
      end
    end
  end
end
