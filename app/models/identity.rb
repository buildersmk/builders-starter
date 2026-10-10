# A person's global, passwordless login (one email). Holds the 6-digit login-code state and the
# sessions. The same Identity can be a User in several Accounts.
class Identity < ApplicationRecord
  include LoginCode

  has_many :sessions, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :accounts, through: :users

  normalizes :email_address, with: ->(value) { value.to_s.strip.downcase.presence }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
