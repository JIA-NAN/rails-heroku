class AutoGrade < ActiveRecord::Base
  attr_accessible :face_recognition_score, :is_face_recognized, :is_pill_taken
  belongs_to :record
end
