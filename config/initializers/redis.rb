require 'redis'
require 'connection_pool'

redis_config = Rails.application.config_for(:redis, env: Rails.env)

sentinel_hosts = [
  { host: 'sentinel-1', port: 26379, password: redis_config[:sentinel_password] },
  { host: 'sentinel-2', port: 26379, password: redis_config[:sentinel_password] },
  { host: 'sentinel-3', port: 26379, password: redis_config[:sentinel_password] }
]

REDIS_DEFAULT_OPTIONS = {
  url: "redis://:#{redis_config[:password]}@mymaster",
  sentinels: sentinel_hosts,
  password: redis_config[:password],
  role: :master,
  connect_timeout: 3,
  read_timeout: 3,
  write_timeout: 3
}.freeze

# Пул для записи
$redis_write_pool = ConnectionPool.new(size: 10, timeout: 3) do
  Redis.new(REDIS_DEFAULT_OPTIONS.merge(role: :master))
end

# Пул для чтения
$redis_read_pool = ConnectionPool.new(size: 5, timeout: 3) do
  Redis.new(REDIS_DEFAULT_OPTIONS.merge(role: :slave))
end