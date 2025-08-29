class AcademicPeriod < ApplicationRecord
  belongs_to :faculty

  has_many :schedules
  has_many :special_periods
  has_many :special_schedules, through: :special_periods
  has_many :added_schedules, through: :schedules
  has_many :deleted_schedules, through: :schedules

  after_create :schedule_destruction_job
  after_update :reschedule_destruction_job

  def end_date_after_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, 'должна быть после даты начала')
    end
  end

  private

  def schedule_destruction_job
    return unless end_date.present?

    destruction_time = calculate_destruction_time
    
    # Отменяем старый job если есть
    cancel_destruction_job
    
    # Планируем новый job
    job_id = AcademicPeriodDestroyJob.perform_at(destruction_time, id)
    
    Rails.logger.info "Scheduled destruction job #{job_id} for period #{id} at #{destruction_time}"
  end

  def reschedule_destruction_job
    # Перепланируем только если изменился end_date или период был восстановлен
    return unless saved_change_to_end_date? || saved_change_to_deleted_at?

    if end_date.present?
      schedule_destruction_job
    else
      # Если end_date удален, отменяем job
      cancel_destruction_job
    end
  end

  def cancel_destruction_job
    return unless has_attribute?(:destruction_job_id) && destruction_job_id.present?
    
    # Находим и удаляем scheduled job
    scheduled_jobs = Sidekiq::ScheduledSet.new
    job = scheduled_jobs.find { |j| j.jid == destruction_job_id }
    
    if job
      job.delete
      Rails.logger.info "Cancelled destruction job #{destruction_job_id} for period #{id}"
    end
    
    update_columns(
      destruction_scheduled_at: nil,
      destruction_job_id: nil
    )
  end

  def calculate_destruction_time
    return unless end_date.present?
    
    # Преобразуем end_date к дате
    end_date_obj = end_date.is_a?(String) ? Date.parse(end_date) : end_date.to_date
    
    # Вычисляем дату уничтожения
    destruction_date = end_date_obj + 8.days
    
    # Получаем время создания
    creation_time = created_at || Time.current
    
    # Создаем DateTime с правильным временем
    Time.zone.local(
      destruction_date.year,
      destruction_date.month,
      destruction_date.day,
      creation_time.hour,
      creation_time.min,
      creation_time.sec
    )
  end
end
