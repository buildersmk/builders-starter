# The membership of an Identity in one Account: the account-scoped name + role. The global login
# lives on Identity; "who you are in this account" lives here.
class User < ApplicationRecord
  ROLES = %w[ member admin owner ].freeze

  belongs_to :account
  belongs_to :identity, optional: true

  validates :name, presence: true
  validates :role, inclusion: { in: ROLES }

  def owner?
    role == "owner"
  end

  def admin?
    role == "admin" || role == "owner"
  end

  def email_address
    identity&.email_address
  end
end
