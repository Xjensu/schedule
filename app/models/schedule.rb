class Schedule < ApplicationRecord
  belongs_to :academic_period
  belongs_to :student_group
  belongs_to :subject
  belongs_to :teacher, optional: true
  belongs_to :classroom, optional: true
  belongs_to :lesson, optional: true

  validates :teacher_id, uniqueness: {
    scope: [:day_of_week, :under, :start_time],
    message: "уже ведёт занятие в это время",
    if: -> { teacher_id.present? }
  }

  validates :classroom_id, uniqueness: {
    scope: [:day_of_week, :under, :start_time],
    message: "уже занята в это время",
    if: -> { classroom_id.present? }
  }
end
