# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/sign_in_attempt
  def sign_in_attempt
    UserMailer.sign_in_attempt
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/successful_sign_in
  def successful_sign_in
    UserMailer.successful_sign_in
  end
end
