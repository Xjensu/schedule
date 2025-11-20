# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.
#
# Puma starts a configurable number of processes (workers) and each process
# serves each request in a thread from an internal thread pool.
#
# You can control the number of workers using ENV["WEB_CONCURRENCY"]. You
# should only set this value when you want to run 2 or more workers. The
# default is already 1.
#
# The ideal number of threads per worker depends both on how much time the
# application spends waiting for IO operations and on how much you wish to
# prioritize throughput over latency.
#
# As a rule of thumb, increasing the number of threads will increase how much
# traffic a given process can handle (throughput), but due to CRuby's
# Global VM Lock (GVL) it has diminishing returns and will degrade the
# response time (latency) of the application.
#
# The default is set to 3 threads as it's deemed a decent compromise between
# throughput and latency for the average Rails application.
#
# Any libraries that use a connection pool or another resource pool should
# be configured to provide at least as many connections as the number of
# threads. This includes Active Record's `pool` parameter in `database.yml`.

# Увеличиваем количество воркеров для лучшей параллельности
workers ENV.fetch("WEB_CONCURRENCY", 4)

# Увеличиваем количество потоков для большего RPS
# Рекомендуется 16-32 потока на воркер для IO-bound операций
threads_count = ENV.fetch("RAILS_MAX_THREADS", 16)
threads threads_count, threads_count

preload_app!

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT", 3000)

# Увеличиваем backlog для обработки большего количества одновременных подключений
backlog ENV.fetch("PUMA_BACKLOG", 2048)

# Настройки для production
if ENV['RAILS_ENV'] == 'production'
  # Минимальное количество потоков перед форком воркера
  before_fork do
    ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
  end
end

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
  
  # Подключаем Redis для каждого воркера
  if defined?(Redis)
    Redis.current.disconnect!
  end
end

# Graceful shutdown
worker_shutdown_timeout 30

# Настройки для производительности
wait_for_less_busy_worker ENV.fetch("PUMA_WAIT_FOR_LESS_BUSY_WORKER", 0.001).to_f

# Настройка nakayoshi_fork для оптимизации памяти
nakayoshi_fork if ENV['RAILS_ENV'] == 'production'
