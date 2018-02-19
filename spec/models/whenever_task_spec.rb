# == Schema Information
#
# Table name: whenever_tasks
#
#  id         :integer          not null, primary key
#  task       :string(255)
#  meta       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe WheneverTask do
  let(:patient) { create(:patient) }

  context '.push_notify_scheduled' do
    before :each do
      @sms = create(:service_sms)
      @push = create(:service_push)

      SmsService.any_instance.stub(:send).and_return(:true)
      PushService.any_instance.stub(:send).and_return(:true)
    end

    it 'should send notifications' do
      create(:notification, notification_service: @sms, send_at: 10.minutes.ago)
      create(:notification, notification_service: @push, send_at: 10.minutes.ago)

      expect_any_instance_of(SmsService).to receive(:send).once
      expect_any_instance_of(PushService).to receive(:send).once

      WheneverTask.push_notify_scheduled
    end
  end

  context '.push_notify_pill_times' do
    before :each do
      @sms = create(:service_sms)
      @push = create(:service_push)

      SmsService.any_instance.stub(:send).and_return(:true)
      PushService.any_instance.stub(:send).and_return(:true)
    end

    it 'should loop through services' do
      create_active_patient(Time.zone.now, @push)
      create_active_patient(Time.zone.now + 30.minutes, @push)
      create_active_patient(Time.zone.now - 30.minutes, @push)
      create_active_patient(Time.zone.now, @sms)
      create_active_patient(Time.zone.now + 30.minutes, @sms)
      create_active_patient(Time.zone.now - 30.minutes, @sms)

      expect_any_instance_of(SmsService).to receive(:send).exactly(3).times
      expect_any_instance_of(PushService).to receive(:send).exactly(3).times

      WheneverTask.push_notify_pill_times
    end
  end

  context '.create_message' do
    it 'should create before time message' do
      expect(WheneverTask.create_message(patient, 15.minutes)).to match(
        /^.*#{patient.fullname}.*within the next 15 minutes.*$/
      )

      expect(WheneverTask.create_message(patient, 35.minutes)).to match(
        /^.*#{patient.fullname}.*within the next 35 minutes.*$/
      )
    end

    it 'should create on time message' do
      expect(WheneverTask.create_message(patient, 0.minutes)).to match(
        /^.*#{patient.fullname}.*now.*$/
      )
    end

    it 'should create after time message' do
      expect(WheneverTask.create_message(patient, -1.hours)).to match(
        /^.*#{patient.fullname}.*expired 60 minutes ago.*next 2 hours.*$/
      )
      expect(WheneverTask.create_message(patient, -2.hours)).to match(
        /^.*#{patient.fullname}.*expired 2 hours ago.*next 60 minutes.*$/
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
