# == Schema Information
#
# Table name: patients
#
#  id                     :integer          not null, primary key
#  firstname              :string(255)      not null
#  lastname               :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(255)      default(''), not null
#  encrypted_password     :string(255)      default(''), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  authentication_token   :string(255)
#  mist_id                :string(255)      default(''), not null
#  phone                  :string(255)
#

require 'spec_helper'

describe Patient do
  it 'should validate phone' do
    expect(build(:patient, phone: '12345678').valid?).to be_falsey
    expect(build(:patient, phone: '+65123ab678').valid?).to be_falsey
    expect(build(:patient, phone: '+1234567').valid?).to be_falsey
    expect(build(:patient, phone: '+12345678').valid?).to be true
    expect(build(:patient, phone: '+123456789012').valid?).to be true
    expect(build(:patient, phone: '+1234567890123').valid?).to be_falsey
  end

  it 'should validate email' do
    expect(build(:patient, email: 'abc').valid?).to be_falsey
    expect(build(:patient, email: 'abc@abc').valid?).to be_falsey
    expect(build(:patient, email: 'abc@abc.com').valid?).to be true
  end

  context 'notification ids' do
    let(:patient) { create(:patient) }

    it 'alias push_id' do
      expect(patient.push_id).to eq(patient.mist_id_for_push)
    end

    it 'alias sms_id' do
      expect(patient.sms_id).to eq(patient.phone)
    end

    it 'alias email_id' do
      expect(patient.email_id).to eq(patient.email)
    end
  end

  it 'formats fullname' do
    expect(build(:patient).fullname).to eq('Patient, CG4001')
  end

  it 'formats fullname by dash' do
    expect(build(:patient).fullname(:dashed)).to eq('patient_cg4001')
  end

  it 'generates six digits mist id' do
    patient = create(:patient)
    expect(patient.mist_id).to match(/\d{6}/)
  end

  it 'prefix mist id for push notification' do
    patient = create(:patient)
    expect(patient.mist_id_for_push).to match(/user_\d{6}/)
  end

  context 'patient with an active schedule' do
    before :each do
      @patient = create(:patient)
      @schedule = create(:schedule, patient: @patient)
    end

    it '.with_active_schedule scope' do
      create_list(:patient, 3)
      expect(Patient.with_active_schedule.count).to eq(1)
    end

    it '#current_schedule return current schedule' do
      expect(@patient.current_schedule).to eq(@schedule)
    end

    context '#current_pill_time' do
      before :each do
        @time = Ptime.to_time(Ptime.to_ptime(Time.zone.now))
        @schedule = double('schedule', nearest_pill_time: @time)
        @patient.stub(current_schedule: @schedule)
      end

      it 'has no record for the pill time' do
        expect(@patient.current_pill_time).to eq(@time)
      end

      it 'has record for the pill time' do
        create(:record, patient: @patient, pill_time_at: @time)
        expect(@patient.current_pill_time).to eq(nil)
      end
    end

    context '#next_record_time' do
      before :each do
        @schedule = double('schedule', pill_times_from: [700, 800, 900])
        @patient.stub(current_schedule: @schedule)
      end

      context 'return the 1st pill time' do
        it 'has no record submitted' do
          expect(@patient.next_record_time).to eq(700)
          expect(@patient.next_record_time(:yesterday)).to eq(700)
        end

        it 'has record submitted but not within the time' do
          create(:yesterday_record, patient: @patient)
          expect(@patient.next_record_time).to eq(700)
        end

        it 'is on a future date' do
          expect(@patient.next_record_time(:tomorrow)).to eq(700)
          expect(@patient.next_record_time(Time.zone.now + 3.days)).to eq(700)
        end
      end

      context 'return the 2nd pill time' do
        it 'has one record submitted' do
          create(:record, patient: @patient)
          expect(@patient.next_record_time).to eq(800)
          expect(@patient.next_record_time(:yesterday)).to eq(700)
        end

        it 'has one record submitted in yesterday' do
          create(:yesterday_record, patient: @patient)
          expect(@patient.next_record_time).to eq(700)
          expect(@patient.next_record_time(:yesterday)).to eq(800)
        end
      end

      context 'return the 3rd pill time' do
        it 'has 2 records submitted' do
          create_list(:record, 2, patient: @patient)
          expect(@patient.next_record_time).to eq(900)
          expect(@patient.next_record_time(:yesterday)).to eq(700)
        end

        it 'has 2 records submitted in yesterday' do
          create_list(:yesterday_record, 2, patient: @patient)
          expect(@patient.next_record_time).to eq(700)
          expect(@patient.next_record_time(:yesterday)).to eq(900)
        end
      end

      context 'return nil' do
        it 'has all records submitted' do
          create_list(:record, 3, patient: @patient)
          expect(@patient.next_record_time).to be_nil
          expect(@patient.next_record_time(:yesterday)).to eq(700)
        end

        it 'has all records submitted in yesterday' do
          create_list(:yesterday_record, 3, patient: @patient)
          expect(@patient.next_record_time).to eq(700)
          expect(@patient.next_record_time(:yesterday)).to be_nil
        end
      end
    end
  end

  context 'patient without an active schedule' do
    before :each do
      @patient = create(:patient)
    end

    it '#current_schedule return nil' do
      expect(@patient.current_schedule).to be_nil

      assign_inactive_schedules(@patient)
      expect(@patient.current_schedule).to be_nil
    end

    it '#current_pill_time return nil' do
      expect(@patient.current_pill_time).to be_nil

      assign_inactive_schedules(@patient)
      expect(@patient.current_pill_time).to be_nil
    end

    it '#next_record_time return nil' do
      expect(@patient.next_record_time).to be_nil

      assign_inactive_schedules(@patient)
      expect(@patient.next_record_time).to be_nil
    end

    def assign_inactive_schedules(patient)
      create(:schedule_in_past, patient: patient)
      create(:schedule_in_future, patient: patient)
    end
  end

  context '#find_pill_notification' do
    before :each do
      @patient = create(:patient)
    end

    it 'return nil if no pill time' do
      @patient.stub(current_pill_time: nil)
      expect(@patient.find_pill_notification([1.minute])).to be_nil
    end

    it 'return nil if pill time diffed' do
      @patient.stub(current_pill_time: nil)
      Ptime.stub(seconds_to_now: 10.minutes)

      expect(@patient.find_pill_notification([1.minute])).to be_nil
    end

    it 'return pill time' do
      @patient.stub(current_pill_time: 900)
      Ptime.stub(seconds_to_now: 1.minute)

      expect(@patient.find_pill_notification([1.minute])).to eq(1.minute)
    end
  end

  context 'notification services' do
    before :each do
      create(:service_sms)
      create(:service_push)

      create_list(:patient, 3)
    end

    it 'should add service' do
      patient = Patient.first
      expect(patient.notification_services.empty?).to be true

      patient.notification_services << NotificationService.first
      patient.notification_services << NotificationService.last

      expect(patient.notification_services.count).to eq(2)
    end

    it 'should get service enabled patient' do
      patient = create(:patient)
      patient.notification_services << NotificationService.where(service: 'Sms')
      patient.save

      expect(Patient.enabled('Sms').count).to eq(1)
      expect(Patient.enabled('Sms').first.mist_id).to eq(patient.mist_id)
    end
  end
end
