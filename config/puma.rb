workers ENV.fetch("WEB_CONCURRENCY", 4)

# Увеличиваем количество потоков для обработки большего количества запросов
threads_count = ENV.fetch("RAILS_MAX_THREADS", 16)
threads threads_count, threads_count

preload_app!

before_fork do
  if ENV["RAILS_ENV"] == "production"
    require 'nakayoshi_fork'
    Nakayoshi::Fork.apply!
  end
end

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT", 3000)

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Run the Solid Queue supervisor inside of Puma for single-server deployments
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# Specify the PID file. Defaults to tmp/pids/server.pid in development.
# In other environments, only set the PID file if requested.
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

on_worker_boot do
  # Переподключение БД при запуске воркера
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Graceful shutdown
worker_shutdown_timeout 30

# Оптимизация очереди запросов
queue_requests true
