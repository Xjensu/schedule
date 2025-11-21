# frozen_string_literal: true

# ============================================================================
# FALCON CONFIGURATION - Высокопроизводительный асинхронный веб-сервер
# ============================================================================
# Falcon использует async I/O и fiber-based concurrency для достижения
# высокого RPS при меньшем потреблении ресурсов по сравнению с Puma
#
# Преимущества:
# - До 10x больше RPS при том же железе
# - Меньше потребление памяти благодаря асинхронности
# - Нативная поддержка HTTP/2 и WebSockets
# - Эффективная работа с медленными клиентами
# ============================================================================

# Количество процессов (воркеров)
# Falcon эффективнее Puma, достаточно 2-4 воркеров на сервер
count = Integer(ENV.fetch("WEB_CONCURRENCY", 2))

# Hostname и порт
hostname = ENV.fetch("FALCON_HOSTNAME", "0.0.0.0")
port = Integer(ENV.fetch("PORT", 3000))

# ============================================================================
# НАСТРОЙКА RUBY GC ДЛЯ PRODUCTION
# ============================================================================
if ENV["RAILS_ENV"] == "production"
  ENV['RUBY_GC_HEAP_GROWTH_FACTOR'] ||= '1.1'
  ENV['RUBY_GC_HEAP_GROWTH_MAX_SLOTS'] ||= '40000'
  ENV['RUBY_GC_HEAP_INIT_SLOTS'] ||= '600000'
  ENV['RUBY_GC_HEAP_FREE_SLOTS_MIN_RATIO'] ||= '0.02'
  ENV['RUBY_GC_HEAP_FREE_SLOTS_MAX_RATIO'] ||= '0.10'
  ENV['RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR'] ||= '2.0'
end

# ============================================================================
# RACK APPLICATION
# ============================================================================
load :rack, :self_signed_tls do
  # Endpoint конфигурация
  endpoint Async::HTTP::Endpoint.parse("http://#{hostname}:#{port}").with(
    protocol: Async::HTTP::Protocol::HTTP11,
    scheme: "http",
    reuse_address: true,
    reuse_port: true
  )
  
  # Количество воркеров
  count count
  
  # Загружаем Rails приложение через config.ru
  app_path = File.expand_path("../config.ru", __dir__)
  
  # Callback перед созданием воркеров (preload)
  preload do
    # Загружаем Rails окружение
    require_relative "../config/environment"
    
    # Отключаем соединения перед форком
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.connection_pool.disconnect!
    end
    
    # Закрываем Redis соединения
    if defined?(Redis) && Redis.respond_to?(:current)
      begin
        Redis.current&.quit
      rescue => e
        # Игнорируем ошибки при закрытии
      end
    end
  end
  
  # Callback после создания каждого воркера
  fork do
    # Переподключаем ActiveRecord
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.establish_connection
      
      # Устанавливаем правильный размер пула для Falcon
      # Falcon использует fibers, поэтому pool может быть меньше
      pool_size = Integer(ENV.fetch("RAILS_MAX_THREADS", 32))
      ActiveRecord::Base.connection_pool.disconnect!
      
      config = ActiveRecord::Base.connection_db_config.configuration_hash
      ActiveRecord::Base.establish_connection(config.merge(pool: pool_size))
    end
    
    # Переподключаем Redis
    if defined?(Redis)
      begin
        Redis.current = Redis.new(
          url: ENV.fetch('REDIS_URL', 'redis://redis-master:6379/0'),
          password: ENV['REDIS_PASSWORD'],
          driver: :hiredis,
          reconnect_attempts: 3,
          connect_timeout: 2,
          read_timeout: 2,
          write_timeout: 2
        )
      rescue => e
        warn "Failed to connect Redis: #{e.message}"
      end
    end
    
    # Для Sidekiq
    if defined?(Sidekiq)
      Sidekiq.configure_client do |config|
        config.redis = {
          url: ENV.fetch('REDIS_URL', 'redis://redis-master:6379/0'),
          password: ENV['REDIS_PASSWORD'],
          driver: :hiredis
        }
      end
    end
  end
  
  # Загружаем и настраиваем Rack приложение
  rack app_path do |app|
    # Оборачиваем приложение в защитные middleware
    Rack::Builder.new do
      # Ограничение размера тела запроса (защита от DoS)
      use Rack::ContentLength
      
      # Основное Rails приложение
      run app
    end
  end
end

# ============================================================================
# SECURITY & LIMITS
# ============================================================================

# Максимальный размер тела запроса (100 MB) - защита от DoS
maximum_body_size Integer(ENV.fetch("FALCON_MAX_BODY_SIZE", 100 * 1024 * 1024))

# Таймауты для защиты от медленных клиентов (Slowloris attack)
timeout Float(ENV.fetch("FALCON_TIMEOUT", 30.0))
