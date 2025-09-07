class SpecialPeriod < ApplicationRecord
  belongs_to :academic_period

  before_destroy :destroy_special_schedule

  private

  def destroy_special_schedule
    SpecialScheduleDestroyJob.perform_sync(self.id)
  end
end
