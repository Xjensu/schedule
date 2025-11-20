# Конфигурация Falcon для высокой производительности
# Falcon использует асинхронный I/O и fiber-based concurrency

# Количество процессов (воркеров)
count ENV.fetch("WEB_CONCURRENCY", 4).to_i

# Хост и порт
hostname "0.0.0.0"
port ENV.fetch("PORT", 3000).to_i

# Кеширование
cache true

# Preload приложения
preload :rails

# Rack environment
rackup "config.ru"

# Graceful restart
timeout 30

# Настройки для production
if ENV['RAILS_ENV'] == 'production'
  # Оптимизация памяти
  GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
  
  # Лог
  logger Logger.new($stdout)
end
