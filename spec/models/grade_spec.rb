# == Schema Information
#
# Table name: grades
#
#  id         :integer          not null, primary key
#  grade      :string(255)
#  comment    :text
#  record_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  admin_id   :integer
#  note       :text
#

require 'spec_helper'

describe Grade do
  context 'satisfactory or unsatisfactory' do
    it 'calls record#graded when created' do
      record = create(:record)
      record.should_receive(:graded)

      Grade.create(grade: Grade::SATISFY, record: record)
    end

    it 'calls record#graded when updated' do
      grade = create(:grade_with_record, grade: Grade::VERIFY)
      grade.record.should_receive(:graded)

      grade.update_attributes(grade: Grade::UNSATISFY)
    end

    it 'does not call record#graded when grade is not updated' do
      grade = create(:grade_with_record, grade: Grade::VERIFY)
      grade.record.should_not_receive(:graded)

      grade.update_attributes(note: 'good')
    end
  end

  context 'require verification' do
    it 'calls record#onhold when created' do
      record = create(:record)
      record.should_receive(:onhold)

      Grade.create(grade: Grade::VERIFY, record: record)
    end
  end

  it 'calls record#ungraded when destroyed' do
    grade = create(:grade_with_record)
    grade.record.should_receive(:ungraded)

    grade.destroy
  end
end
