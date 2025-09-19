class Schedule < ApplicationRecord
  belongs_to :academic_period
  belongs_to :student_group
  belongs_to :subject
  belongs_to :teacher
  belongs_to :classroom
  belongs_to :lesson

  validates :academic_period, presence: true
  validates :student_group, presence: true
  validates :subject, presence: true
  validates :lesson, presence: true
  validates :day_of_week, presence: true
  validates :start_time, presence: true
end
