class UserMailer < ApplicationMailer
  default from: ENV["MAILER_USERNAME"]

  def sign_in_attempt(user, ip_address, timestamp)
    @user = user
    @ip_address = ip_address
    @timestamp = timestamp
    mail(to: @user.email, subject: "[Внимание] Попытка входа в ваш аккаунт")
  end

  def successful_sign_in(user, ip_address, timestamp)
    @user = user
    @ip_address = ip_address
    @timestamp = timestamp
    mail(to: @user.email, subject: "Успешный вход в ваш аккаунт")
  end
end
