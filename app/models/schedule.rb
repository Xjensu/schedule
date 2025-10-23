class Schedule < ApplicationRecord
  belongs_to :academic_period
  belongs_to :student_group
  belongs_to :subject
  belongs_to :teacher, optional: true
  belongs_to :classroom, optional: true
  belongs_to :lesson, optional: true
end
