require 'redis'
require 'connection_pool'

redis_config = Rails.application.config_for(:redis, env: Rails.env)

puts "DADADADA", redis_config
puts "DADADADSSSS", Rails.env
puts "Missing required Redis configuration parameters, #{redis_config[:password]}, #{redis_config[:master_name]}, #{redis_config[:sentinels]} "

REDIS_DEFAULT_OPTIONS={
  url: "redis://:#{redis_config[:password]}@#{redis_config[:master_name]}",
  sentinels: redis_config[:sentinels].map do |sentinel|
    {
      host: sentinel[:host],
      port: sentinel[:port],
      password: redis_config[:sentinel_password]
    }
  end,
  password: redis_config[:password],
  role: :master,
  connect_timeout: redis_config[:connect_timeout] || 3,
  read_timeout: redis_config[:read_timeout] || 3,
  write_timeout: redis_config[:write_timeout] || 3,
  reconnect_attempts: redis_config[:reconnect_attempts] || 3,
}.freeze

# Создаём пул подключений для записи
$redis_write_pool = ConnectionPool.new(size: 10, timeout: 3) do
  Redis.new( REDIS_DEFAULT_OPTIONS.merge(role: :master) )
end

# Пул для чтения с реплик
$redis_read_pool = ConnectionPool.new(size: 5, timeout: 3) do
   Redis.new( REDIS_DEFAULT_OPTIONS.merge(role: :slave) )
end

# Универсальный пул (по умолчанию запись)
$redis = $redis_write_pool

# Маршрутизация через модуль
module RedisRouter
  def self.method_missing(method, *args, **kwargs, &block)
    if method.to_s.end_with?('_read')
      $redis_read_pool.with { |r| r.public_send(method.to_s.gsub('_read', ''), *args, **kwargs, &block) }
    else
      $redis_write_pool.with { |r| r.public_send(method, *args, **kwargs, &block) }
    end
  rescue Redis::BaseError => e
    Rails.logger.error "Redis Error: #{e.class} - #{e.message}"
    raise
  end

  def self.respond_to_missing?(method, include_private = false)
    $redis_write_pool.with { |r| r.respond_to?(method, include_private) } || super
  end
end

# Настройка кэша Rails
Rails.application.configure do
  config.cache_store = :redis_cache_store, {
    url: "redis://:#{redis_config[:password]}@#{redis_config[:master_name]}",
    sentinels: redis_config[:sentinels].map do |sentinel|
      {
        host: sentinel[:host],
        port: sentinel[:port],
        password: redis_config[:sentinel_password] || redis_config[:password]
      }
    end,
    password: redis_config[:password],
    sentinel_password: redis_config[:sentinel_password] || redis_config[:password],
    namespace: "cache:#{Rails.env}",
    connect_timeout: redis_config[:connect_timeout] || 3,
    read_timeout: redis_config[:read_timeout] || 3,
    write_timeout: redis_config[:write_timeout] || 3,
    reconnect_attempts: redis_config[:reconnect_attempts] || 3,
    pool_size: ENV.fetch('RAILS_MAX_THREADS', 5).to_i,
    pool_timeout: 3,
    error_handler: -> (method:, returning:, exception:) {
      Rails.logger.error "Redis cache operation #{method} failed: #{exception.class} - #{exception.message}"
    }
  }
end