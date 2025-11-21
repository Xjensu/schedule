require "active_support/core_ext/integer/time"

Rails.application.configure do

  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  config.cache_store = :redis_cache_store, {
    url: ENV.fetch('REDIS_URL') { 'redis://@redis-master:6379/0' },
    password: ENV['REDIS_PASSWORD'],
    namespace: "cache:production",
    reconnect_attempts: 3,
    driver: :hiredis,
    # Дополнительная оптимизация для высокой нагрузки
    connect_timeout: 1,
    read_timeout: 1,
    write_timeout: 1
  }

  config.time_zone = "Moscow"

  config.active_storage.service = :local

  config.assume_ssl = false
  config.force_ssl = false

  config.action_controller.forgery_protection_origin_check = false

  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false
  config.active_job.queue_adapter = :sidekiq
  config.action_mailer.default_url_options =  { protocol: 'http' , host: "example.com" }
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]
  
  # Оптимизация Active Record
  config.active_record.query_log_tags_enabled = false
  config.active_record.automatic_scope_inversing = true
  config.active_record.strict_loading_by_default = false
  
  # Отключение verbose query logs для производительности
  config.active_record.verbose_query_logs = false
  
  # Оптимизация middleware stack
  config.middleware.delete Rack::ETag
  config.middleware.delete Rack::Sendfile

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com', 
    port: 587, 
    domain: ENV['DOMAIN'],
    user_name: ENV['MAILER_USERNAME'],
    password: ENV['MAILER_PASSWORD'],
    authentication: 'plain', 
    enable_starttls_auto: true                   
  }
end
