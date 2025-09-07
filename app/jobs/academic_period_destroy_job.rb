class AcademicPeriodDestroyJob
  include Sidekiq::Job
  sidekiq_options retry: 3, dead: false

  def perform(period_id)
    academic_period = AcademicPeriod.find_by(id: period_id)
    unless academic_period
      Rails.logger.warn "AcademicPeriod #{period_id} not found - skipping destruction"
      return
    end

    if academic_period.destroyed?
      Rails.logger.info "AcademicPeriod #{period_id} already destroyed"
      return
    end

    ActiveRecord::Base.transaction do
      cleanup_added_schedules(period_id)
      cleanup_deleted_schedules(period_id)
      cleanup_special_periods(period_id)
      cleanup_schedules(period_id)

      academic_period.destroy!
    end
  rescue ActiveRecord::RecordNotDestroyed => e
    Rails.logger.error "Failed to destroy AcademicPeriod #{period_id}: #{e.message}"
    raise
  rescue StandardError => e
    Rails.logger.error "Error in AcademicPeriodDestroyJob for #{period_id}: #{e.message}"
    raise
  end

  private

  def cleanup_special_periods(academic_period_id)
    SpecialPeriod.where(academic_period_id: academic_period_id).each do |schedule|
      schedule.destroy
    end
  end

  def cleanup_schedules(academic_period_id)
    Schedule.where(academic_period_id: academic_period_id).delete_all
  end

  def cleanup_added_schedules(academic_period_id)
    AddedSchedule.joins(:schedule)
                .where(schedules: { academic_period_id: academic_period_id })
                .delete_all
  end

  def cleanup_deleted_schedules(academic_period_id)
    DeletedSchedule.joins(:schedule)
                  .where(schedules: { academic_period_id: academic_period_id })
                  .delete_all
  end
end