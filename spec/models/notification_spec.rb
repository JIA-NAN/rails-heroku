# == Schema Information
#
# Table name: notifications
#
#  id                      :integer          not null, primary key
#  message                 :string(255)
#  sent                    :boolean          default(FALSE)
#  send_at                 :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  receiver                :string(255)
#  patient_id              :integer
#  notification_service_id :integer
#

require 'spec_helper'

describe Notification do
  before :each do
    @sms = create(:service_sms)
    @push = create(:service_push)
  end

  context 'validation on receiver' do
    it 'should set receiver to phone' do
      p = create(:patient, phone: '+6512345678')
      n = build(:notification, notification_service: @sms, patient: p)

      expect(n.valid?).to be_true
      expect(n.receiver).to eq('+6512345678')
    end

    it 'should set receiver to push_id' do
      p = create(:patient)
      n = build(:notification, notification_service: @push, patient: p)

      expect(n.valid?).to be_true
      expect(n.receiver).to eq(p.mist_id_for_push)
    end

    it 'should validate receiver' do
      p = create(:patient, phone: nil)
      n = build(:notification, notification_service: @sms, patient: p)

      expect(n.valid?).to be_false
      expect(n.errors[:receiver].empty?).to be_false
      expect(n.errors[:notification_service_id].empty?).to be_false
    end
  end

  context '#deliver' do
    before :each do
      SmsService.any_instance.stub(:send).and_return(:true)
      PushService.any_instance.stub(:send).and_return(:true)
    end

    it 'should not send again' do
      n = create(:notification, notification_service: @sms, sent: true)
      expect(n.deliver).to be_nil
    end

    it 'should send push notification' do
      n = create(:notification, notification_service_id: @push.id)

      expect_any_instance_of(PushService).to receive(:send).once
      expect(n.deliver).to be_true
      expect(n.sent).to be_true
    end

    it 'should send sms notification' do
      n = create(:notification, notification_service_id: @sms.id)

      expect_any_instance_of(SmsService).to receive(:send).once
      expect(n.deliver).to be_true
      expect(n.sent).to be_true
    end
  end

  context '.on_pill_times' do
    it 'should find nothing' do
      create_active_patient(Time.zone.now)
      create_active_patient(Time.zone.now + 30.minutes)
      create_active_patient(Time.zone.now - 30.minutes)

      expect(Notification.on_pill_times(@sms)).to eq(
        '1800' => [], '900' => [], '0' => [],
        '-1800' => [], '-3600' => [], '-7200' => []
      )
    end

    it 'should find mist_id_for_push' do
      p1 = create_active_patient(Time.zone.now, @sms)
      p2 = create_active_patient(Time.zone.now + 30.minutes, @sms)
      p3 = create_active_patient(Time.zone.now - 30.minutes, @sms)

      expect(Notification.on_pill_times(@sms, id: :mist_id_for_push)).to eq(
        '1800' => [p2.mist_id_for_push], '900' => [],
        '0' => [p1.mist_id_for_push],
        '-1800' => [p3.mist_id_for_push], '-3600' => [], '-7200' => []
      )
    end

    it 'should find phone number' do
      p1 = create_active_patient(Time.zone.now, @push)
      p2 = create_active_patient(Time.zone.now + 30.minutes, @push)
      p3 = create_active_patient(Time.zone.now - 30.minutes, @push)

      expect(Notification.on_pill_times(@push, id: :phone)).to eq(
        '1800' => [p2.phone],
        '900' => [],
        '0' => [p1.phone],
        '-1800' => [p3.phone],
        '-3600' => [],
        '-7200' => []
      )
    end
  end

  def create_active_patient(time, service = nil)
    ptime = create(:pill_time, Ptime.weekday_of(time) => Ptime.to_ptime(time))
    patient = ptime.schedule.patient

    if service
      patient.notification_services << service
      patient.save
    end

    patient
  end
end
