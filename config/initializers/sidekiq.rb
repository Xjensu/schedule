require 'sidekiq'
require 'sidekiq-cron'

redis_url = ENV.fetch('REDIS_URL') { "redis://:#{ENV['REDIS_PASSWORD']}@redis-master:6379/0" }

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, reconnect_attempts: 3 }

  config.on(:startup) do
    Faculty.find_each do |faculty|
      hour   = faculty.processing_time.hour
      minute = faculty.processing_time.min

      Sidekiq::Cron::Job.create(
        name: "process_faculty_#{faculty.id}",
        cron: "#{minute} #{hour} * * *",
        class: "FacultyJob",
        args: [faculty.id],
        queue: "default"
      )
    end

    Sidekiq::Cron::Job.load_from_hash YAML.load_file(File.expand_path('../schedule.yml', __dir__))
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, reconnect_attempts: 3 }
end