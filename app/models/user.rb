class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :secure_validatable,
         :session_limitable

  def admin?
    admin 
  end
end
