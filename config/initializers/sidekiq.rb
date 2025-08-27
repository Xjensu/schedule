require 'sidekiq'
require 'sidekiq-cron'

redis_config = Rails.application.config_for(:redis, env: Rails.env)

sentinel_hosts = [
  { host: 'sentinel-1', port: 26379, password: redis_config[:sentinel_password] },
  { host: 'sentinel-2', port: 26379, password: redis_config[:sentinel_password] },
  { host: 'sentinel-3', port: 26379, password: redis_config[:sentinel_password] }
]

Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://:#{redis_config[:password]}@#{redis_config[:master_name]}/0",
    sentinels: sentinel_hosts,
    password: redis_config[:password],
    role: :master,
    reconnect_attempts: 3
  }

  config.on(:startup) do
    Faculty.find_each do |faculty|
      # переводим faculty.process_time (Time) в cron
      hour   = faculty.processing_time.hour
      minute = faculty.processing_time.min

      Sidekiq::Cron::Job.create(
        name: "process_faculty_#{faculty.id}",
        cron: "#{minute} #{hour} * * *", # каждый день в своё время
        class: "FacultyJob",
        args: [ faculty.id ],
        queue: "default"
      )
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://:#{redis_config[:password]}@#{redis_config[:master_name]}/0",
    sentinels: sentinel_hosts,
    password: redis_config[:password],
    role: :master,
    reconnect_attempts: 3
  }
end

Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(File.expand_path('../schedule.yml', __dir__))
  end
end