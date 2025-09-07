class SpecialScheduleDestroyJob
  include Sidekiq::Job
  sidekiq_options retry: 3, dead: false

  def perform(period_id)
    ActiveRecord::Base.transaction do
      cleanup_special_schedules(period_id)
    end
  rescue ActiveRecord::RecordNotDestroyed => e
    Rails.logger.error "Failed to destroy AcademicPeriod #{period_id}: #{e.message}"
    raise
  rescue StandardError => e
    Rails.logger.error "Error in AcademicPeriodDestroyJob for #{period_id}: #{e.message}"
    raise
  end

  private

  def cleanup_special_schedules(special_period_id)
    SpecialSchedule.joins(:special_period)
                  .where(special_period_id: special_period_id)
                  .delete_all
  end
end