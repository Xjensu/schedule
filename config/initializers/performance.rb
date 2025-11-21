# frozen_string_literal: true

# Оптимизация производительности для высокого RPS

if Rails.env.production?
  # Отключение ненужных middleware для максимальной производительности
  Rails.application.config.middleware.delete ActionDispatch::RequestId unless ENV['ENABLE_REQUEST_ID']
  
  # Оптимизация ActionController
  ActionController::Base.class_eval do
    # Отключение автоматической загрузки helpers для каждого контроллера
    # (использовать только если не нужны все helpers во всех контроллерах)
    # self.include_all_helpers = false
  end
  
  # Оптимизация JSON рендеринга
  ActiveSupport.json_encoder = Class.new do
    def self.encode(value)
      Oj.dump(value, mode: :compat, time_format: :ruby)
    end
  end if defined?(Oj)
  
  # Предварительная компиляция регулярных выражений для роутов
  Rails.application.routes.disable_clear_and_finalize = true
  
  # Отключение некоторых коллбэков для максимальной скорости
  ActiveSupport::Notifications.unsubscribe("start_processing.action_controller")
  ActiveSupport::Notifications.unsubscribe("process_action.action_controller")
  
  # Настройка кеша для фрагментов view
  ActionView::Base.cache_template_loading = true
end
