class User < ApplicationRecord
  has_many :computers, dependent: :destroy
  validates :name, presence: true
  has_secure_password
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
