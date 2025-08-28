class AcademicPeriod < ApplicationRecord
  belongs_to :faculty

  has_many :schedules
  has_many :special_periods
  has_many :special_schedules, through: :special_periods
  has_many :added_schedules, through: :schedules
  has_many :deleted_schedules, through: :schedules

  before_destroy :cleanup_associatd_data

  def end_date_after_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, 'должна быть после даты начала')
    end
  end

  private

  def cleanup_associatd_data
    AcademicPeriodDestroyJob.perform_async(id)
  end
end
