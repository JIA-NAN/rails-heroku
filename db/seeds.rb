# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Side Effects
SideEffect.delete_all

SideEffect.create name: 'No Side Effect',
  description: 'No Side Effect Experienced'

SideEffect.create name: 'Headache',
  description: 'A headache or cephalalgia is pain anywhere in the region of the head or neck.'

SideEffect.create name: 'Nausea',
  description: 'Nausea is a sensation of unease and discomfort in the upper stomach with an involuntary urge to vomit.'

SideEffect.create name: 'Others',
  description: 'Please state in the comment box provided.'

puts "=== #{SideEffect.count} kinds of side effects created ==="

# Services
NotificationService.delete_all

NotificationService.create(name: "SMS Message", service: "Sms")
NotificationService.create(name: "Push Notification", service: "Push")


# Record Sequences
PillSequence.delete_all

sequence = PillSequence.create(name: 'Basic')

sequence.pill_sequence_steps.create step_no: 1,
  name: 'Position your head closer to match the white box'

sequence.pill_sequence_steps.create step_no: 2,
  name: 'Hold pill up and cover up the green box'

sequence.pill_sequence_steps.create step_no: 3,
  name: 'Open your mouth and place pill on tongue for 3s'

sequence.pill_sequence_steps.create step_no: 4,
  name: 'Drink water and swallow pill'

sequence.pill_sequence_steps.create step_no: 5,
  name: 'Open mouth again and hold out your tongue for 3s'

puts "=== pill sequence #{PillSequence.first.name} created ==="
puts "=== pill sequence steps #{PillSequence.first.steps.count} created ==="

# Roles
Role.delete_all

admin_role = Role.create(
  name: 'Admin',
  description: 'System Administrators')

Role.create(
  name: 'Doctor',
  description: 'Doctors')

Role.create(
  name: 'Health Worker',
  description: 'Health Workers')

puts "=== #{Role.count} admin roles created ==="

# Patients
Patient.delete_all

peter = Patient.create(
  email: 'lucy@gmail.com',
  firstname: 'Lucy',
  lastname: 'Lee',
  wallet_balance: 0,
  password: '12345678')

puts "=== demo patient: #{Patient.first.fullname} created ==="

john = Patient.create(
  email: 'jane@gmail.com',
  firstname: 'Jane',
  lastname: 'Tan',
  wallet_balance: 0,
  password: '12345678')

puts "=== demo patient: #{Patient.first.fullname} created ==="

# Admin
Admin.delete_all

admin = Admin.create(
  firstname: 'admin',
  lastname: 'admin',
  email: 'admin@fyp.com',
  password: 'adminadmin',
  role_ids: [admin_role.id])

puts "=== default admin: #{Admin.first.fullname} created ==="

admin = Admin.create(
  firstname: 'David',
  lastname: 'Chong',
  email: 'david@clinic.com',
  password: 'adminadmin',
  role_ids: [admin_role.id])

puts "=== default admin: #{Admin.first.fullname} created ==="

# Reward Rule
# $2 for every four consecutive days of adherence
RewardRule.delete_all
RewardRule.create(num_of_days: 4, reward: 2)

puts "=== Reward Rule created ==="

# Records
Record.delete_all
Grade.delete_all

# starts the seed 23 days before today
t = DateTime.now;
t = t - 1;

default_video = File.new(File.join(Rails.root, 'public', 'system', 'videos', 'sample.mp4'))

# Create valid records for three days
graded = true
received = true
(1..3).each do |i|
	record = Record.create(
		comment: '',
		received: received,
		graded: graded,
		video: received ? (default_video) : (nil),
		patient_id: peter.id,
		pill_sequence_id: sequence.id,
		pill_time_at: DateTime.new(t.year, t.month, t.day, 16, 0, 0),
		actual_pill_time_at: DateTime.new(t.year, t.month, t.day, rand(15..17), rand(0..59), rand(0..59))
	)
  Grade.create(
    record_id: record.id,
    pill_taken: Grade::PILL_TAKEN,
    comment: "",
    admin_id: admin.id,
    note: "",
	explanation: Grade::EXPLANATION_OTHERS
  )
	t = t - 1
end

# Create ungraded records
graded = false
for received in [true, false] do
	record = Record.create(
		comment: '',
		received: received,
		graded: graded,
		video: received ? (default_video) : (nil),
		patient_id: peter.id,
		pill_sequence_id: sequence.id,
		pill_time_at: DateTime.new(t.year, t.month, t.day, 16, 0, 0),
		actual_pill_time_at: DateTime.new(t.year, t.month, t.day, rand(15..17), rand(0..59), rand(0..59))
	)
	t = t - 1
end

# Create graded records, with different grading results
graded = true
for received in [true, false] do
	for pt in Grade::PILL_TAKEN_TYPES do
		for e in Grade::EXPLANATION_TYPES do
			record = Record.create(
				comment: '',
				received: received,
				graded: graded,
				video: received ? (default_video) : (nil),
				patient_id: peter.id,
				pill_sequence_id: sequence.id,
				pill_time_at: DateTime.new(t.year, t.month, t.day, 17, 0, 0),
				actual_pill_time_at: DateTime.new(t.year, t.month, t.day, rand(16..18), rand(0..59), rand(0..59))
			)
			Grade.create(
				record_id: record.id,
				pill_taken: pt,
				explanation: e,
				comment: "",
				admin_id: admin.id,
				note: ""
			)
			record = Record.create(
				comment: '',
				received: received,
				graded: graded,
				video: received ? (default_video) : (nil),
				patient_id: peter.id,
				pill_sequence_id: sequence.id,
				pill_time_at: DateTime.new(t.year, t.month, t.day, 10, 30, 0),
				actual_pill_time_at: DateTime.new(t.year, t.month, t.day, rand(9..11), rand(0..59), rand(0..59))
			)
			Grade.create(
				record_id: record.id,
				pill_taken: pt,
				explanation: e,
				comment: "",
				admin_id: admin.id,
				note: ""
			)
			t = t - 1
		end
	end
end

puts "=== #{Record.count} records created ==="

# Medicines
Medicine.delete_all
Schedule.delete_all
PillTime.delete_all

med1 = Medicine.create(name: 'Isoniazid')
med2 = Medicine.create(name: 'Rifampicin')
med3 = Medicine.create(name: 'Ethambutol')

puts "=== #{Medicine.count} kinds of medicines created ==="

# Create schedules
start_time = DateTime.now - 30;
end_time = start_time + 60;
schedule = Schedule.create(
  started_at: start_time,
  terminated_at: end_time,
  patient_id: peter.id
)
pill_time = PillTime.create(
  monday: 1600,
  tuesday: 1600,
  wednesday: 1600,
  thursday: 1600,
  friday: 1600,
  saturday: 1600,
  sunday: 1600,
  schedule_id: schedule.id
)
pill_time2 = PillTime.create(
  monday: 1000,
  tuesday: 1000,
  wednesday: 1000,
  thursday: 1000,
  friday: 1000,
  saturday: 1000,
  sunday: 1000,
  schedule_id: schedule.id
)

schedule = Schedule.create(
  started_at: start_time,
  terminated_at: end_time,
  patient_id: john.id
)
med1.pill_times = [pill_time]
med2.pill_times = [pill_time2]
pill_time.medicines = [med1]
pill_time2.medicines = [med2]
