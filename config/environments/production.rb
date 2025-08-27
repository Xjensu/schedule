require "active_support/core_ext/integer/time"

Rails.application.configure do

  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    sentinels: [
      {
        host: 'sentinel-1',
        port: 26379,
        password: ENV['REDIS_SENTINEL_PASSWORD']
      },
      {
        host: 'sentinel-2', 
        port: 26379,
        password: ENV['REDIS_SENTINEL_PASSWORD']
      },
      {
        host: 'sentinel-3',
        port: 26379,
        password: ENV['REDIS_SENTINEL_PASSWORD']
      }
    ],
    password: ENV['REDIS_PASSWORD'],
    namespace: "cache:production",
    role: :master,
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
end
