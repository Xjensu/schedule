class Users::SessionsController < Devise::SessionsController
  # Перехватываем попытку входа (до валидации)
  def create
    email = params[:user][:email].to_s.strip.downcase

    # Пытаемся найти пользователя по email
    user = User.find_by(email: email)

    # Уведомление о ПОПЫТКЕ входа (даже если email не существует)
    # Но чтобы не раскрывать информацию — отправляем только если пользователь существует
    if user
      UserMailer.sign_in_attempt(user, request.remote_ip, Time.current).deliver_later
    else
      # Опционально: логируем попытку входа с несуществующим email (без email-уведомления)
      Rails.logger.warn "Sign-in attempt with unknown email: #{email} from IP #{request.remote_ip}"
    end

    # Выполняем стандартную логику Devise
    super
  end

  # Перехватываем успешный вход
  def after_sign_in_path_for(resource)
    # Отправляем уведомление об УСПЕШНОМ входе
    UserMailer.successful_sign_in(resource, request.remote_ip, Time.current).deliver_later
    super
  end
end