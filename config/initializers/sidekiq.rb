require 'sidekiq'

redis_config = Rails.application.config_for(:redis, env: Rails.env)

puts "REDIS_CONF", redis_config

sentinel_hosts = [
  { host: 'sentinel-1', port: 26379, password: redis_config[:sentinel_password] },
  { host: 'sentinel-2', port: 26379, password: redis_config[:sentinel_password] },
  { host: 'sentinel-3', port: 26379, password: redis_config[:sentinel_password] }
]
puts "SNTINEL_HOSTS", sentinel_hosts

redis_config[:sentinels].each do |s|
  puts "SENTINEL_HOSTS2", s
end

Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://:#{redis_config[:password]}@#{redis_config[:master_name]}/0",
    sentinels: sentinel_hosts,
    password: redis_config[:password],
    role: :master,
    reconnect_attempts: 3
  }
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
