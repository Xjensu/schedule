class DateProcessingJob
  include Sidekiq::Job

  def perform
    Rails.cache.write("current_dates", DateProcessor.generate_weeks_data(Date.current + 1), expires_in: 25.hours )
  end
end