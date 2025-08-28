class TeacherScheduleJob
  include Sidekiq::Job
  sidekiq_options retry: 3, dead: false

  def perform
    @dates = Rails.cache.read('current_dates')
    Teacher.find_each do |teacher|
      cache_key = "teacher:#{teacher.id}:schedule"
      schedules = (0..1).map do |offset|
        {
          week: offset,
          dates: @dates[offset][:dates].lazy.map do |date|
            service = TeacherScheduleService.new(teacher.id, date).execute
            schedule = service.schedule
            { date: date, scehdule: schedule }
          end.to_a
        }
      end.to_a
      Rails.cache.write(cache_key, schedules, expires_in: 25.hours)
      puts "SUCCES"
    end
    puts "PRFORMING IN TEACHRSCHEDULEJOB"
  end
end